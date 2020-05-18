<template>
<v-app id="inspire" :style="{background: $vuetify.theme.currentTheme.background}">
    <v-navigation-drawer v-if="signedIn" v-model="drawer" app clipped disable-route-watcher disable-resize-watcher>
        <v-list>
            <v-list-item @click.stop="drawer = false; $router.push('/')" link>
                <v-list-item-action>
                    <v-icon>mdi-view-dashboard</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                    <v-list-item-title>Dashboard</v-list-item-title>
                </v-list-item-content>
            </v-list-item>
            <v-list-item @click.stop="drawer = false; $router.push('/settings')" link>
                <v-list-item-action>
                    <v-icon>mdi-tune</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                    <v-list-item-title>Settings</v-list-item-title>
                </v-list-item-content>
            </v-list-item>
            <v-list-item @click.stop="signOut" link>
                <v-list-item-action>
                    <v-icon>mdi-logout</v-icon>
                </v-list-item-action>
                <v-list-item-content>
                    <v-list-item-title>Sign Out</v-list-item-title>
                </v-list-item-content>
            </v-list-item>
        </v-list>
    </v-navigation-drawer>
    <v-app-bar app clipped-left>
        <v-app-bar-nav-icon v-if="signedIn" @click.stop="drawer = !drawer" />
        <v-toolbar-title>{{ $settings.nav_bar_title }}</v-toolbar-title>
    </v-app-bar>
    <v-content>

        <router-view :websocket="websocket" :configureBackend="configureBackend" :connectToBackend="connectToBackend" @setOnmessageFunction="setOnmessageFunction" :tooltips="tooltips" @setTooltipSettings="setTooltipSettings">
        </router-view>

    </v-content>
    <loading-dialog :active="!connected && $route.name != 'Auth'" message="Connecting" />
</v-app>
</template>

<script>
import LoadingDialog from './components/LoadingDialog'
import {
    Hub
} from 'aws-amplify';

import {
    Auth
} from 'aws-amplify'

export default {
    data: () => ({
        signedIn: false,
        drawer: false,
        websocket: null,
        connected: false,
        onmessage: () => {},
        tooltips: true,
    }),
    beforeCreate() {
        // this does things when auth state changes
        Hub.listen('auth', (data) => {
            console.log('A new auth event has happened: ' + data.payload.event);
            if (data.payload.event === 'signIn') {
                this.signedIn = true
                this.$router.push('/')
            }
            if (data.payload.event === 'signOut') {
                this.signedIn = false
                this.$router.push('/auth')
            }
        })
        // this makes sure that the right thing happens when user first hits page
        Auth.currentAuthenticatedUser()
            .then(() => this.signedIn = true)
            .catch(() => {
                this.signedIn = false
                console.log('User not signed in. Redirecting to auth page.')
                this.$router.push('/auth')
            })

    },
    async created() {
        // handle dark mode preference
        if (localStorage.getItem('darkModePreference')) {
            console.log('Found dark mode preference: ' + localStorage.getItem('darkModePreference'))
            this.$vuetify.theme.dark = JSON.parse(localStorage.getItem('darkModePreference'))
        } else {
            console.log('Did not find dark mode preference. Setting to default.')
            this.$vuetify.theme.dark = this.$darkModeDefault
        }

        this.getTooltipSettings()

    },
    methods: {
        connectToBackend() {
            var vm = this;
            return new Promise(function (resolve, reject) {
                console.log('Opening websocket to backend.')
                if (vm.websocket && vm.websocket.url === vm.$websocketAPI && vm.websocket.readyState === WebSocket.OPEN) {
                    vm.connected = true
                    console.log('Websocket already connected.')
                    resolve()
                } else {
                    console.log('Opening connection.')
                    vm.websocket = new WebSocket(vm.$websocketAPI);
                    vm.websocket.onopen = function () {
                        console.log("Websocket is open.")
                        vm.connected = true
                        Auth.currentAuthenticatedUser()
                            .then(data => {
                                var msg = {
                                    message: vm.$connectRoute,
                                    token: data.signInUserSession.accessToken.jwtToken
                                }
                                console.log('Sending message:')
                                console.log(msg)
                                vm.websocket.send(JSON.stringify(msg));
                            })
                            .catch(err => console.log(err));
                        resolve();
                    }
                    vm.websocket.onerror = function (err) {
                        console.log("websocket error: " + err)
                        reject(err);
                    }
                }
            })
        },
        configureBackend() {
            console.log('configuring backend.')
            var vm = this
            this.websocket.onmessage = this.onmessage
            this.websocket.onclose = async function () {
                vm.connected = false
                await vm.connectToBackend()
                vm.configureBackend()
            }
            this.websocket.onerror = async function () {
                vm.connected = false
                await vm.connectToBackend()
                vm.configureBackend()
            }

        },
        setOnmessageFunction(onmessageFunction) {
            console.log('Caught $emit. Setting websocket onmessage function.')
            this.onmessage = onmessageFunction
        },
        async signOut() {
            await Auth.signOut()
            this.signedIn = false;
            this.drawer = false;
            this.$router.push('/auth');
        },
        getTooltipSettings() {
            if (localStorage.getItem('tooltips')) {
                console.log('Found tooltip preference: ' + localStorage.getItem('tooltips'))
                this.tooltips = JSON.parse(localStorage.getItem('tooltips'))
            } else {
                console.log('Did not find tooltip preference. Setting to default.')
                this.tooltips = this.$tooltipDefault
            }
        },
        setTooltipSettings(tooltips) {
            this.tooltips = tooltips
            localStorage.setItem('tooltips', JSON.stringify(tooltips))
        }
    },
    components: {
        LoadingDialog
    }
}
</script>

<style>

html {
    overflow-y: auto;
}

</style>
