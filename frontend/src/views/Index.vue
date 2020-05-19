<template>
<v-container fluid>
    <v-row justify="center">
        <v-col cols="12" sm="8" md="6">
            <v-text-field v-model="search" prepend-inner-icon="search" outlined rounded label="Search" class="my-12"></v-text-field>
        </v-col>
    </v-row>

    <v-row :justify="boards.length === 0 ? 'center' : 'start'">
        <v-col class="d-flex justify-center" cols="12" xs="12" sm="12" md="6" lg="4" xl="3">
            <v-card class="d-flex justify-center align-center my-12" color="transparent" flat height="250" width="350">
                <v-tooltip :disabled="!tooltips" bottom>
                    <template v-slot:activator="{ on }">
                        <v-btn color="accent" @click.stop="createBoard" fab height="100" width="100" v-on="on">
                            <v-icon x-large>mdi-plus</v-icon>
                        </v-btn>
                    </template>
                    <span>Create Board</span>
                </v-tooltip>

            </v-card>
        </v-col>

        <v-col v-for="board in filteredBoards" :key="board.name" class="d-flex justify-center" cols="12" xs="12" sm="12" md="6" lg="4" xl="3">
            <v-card dark class="my-12 d-flex align-center justify-center" color="primary" height="250" width="350" shaped hover @click.stop="$router.push('/board/' + board.board_id)">

                <v-card-title>
                    <span class="display-1">{{ board.board_name }}</span>
                </v-card-title>

            </v-card>

        </v-col>
    </v-row>
    <loading-dialog :active="connected && loadingDialog" message="Loading" />
    <loading-dialog :active="creatingDialog" message="Creating" />
    <loading-dialog :active="!connected" message="Connecting" />


</v-container>
</template>

<script>
import {
    Auth
} from 'aws-amplify';
import Fuse from 'fuse.js'

import LoadingDialog from '../components/LoadingDialog'

export default {
    props: ['connected', 'websocket', 'configureBackend', 'connectToBackend', 'tooltips'],
    computed: {
        filteredBoards: function () {
            if (this.search === '') return this.boards
            const fuse = new Fuse(this.boards, {
                keys: ['board_name'],
                threshold: 0.2
            })
            var results = fuse.search(this.search)
            if (results.length == 0) return []
            var filtered_results = []
            for (var result of results) {
                filtered_results.push(result.item)
            }
            return filtered_results
        }
    },
    data() {
        return {
            boards: [],
            search: '',
            loadingDialog: true,
            creatingDialog: false,
        }
    },
    async created() {
        // check for page content in session storage
        if (sessionStorage.getItem('boards')) {
            this.loadingDialog = false
            this.boards = JSON.parse(sessionStorage.getItem('boards'))
        }

        // ensure connected to backend
        await this.connectToBackend()
        this.$emit('setOnmessageFunction', this.onmessage)
        this.configureBackend()

        // request page content
        this.getBoards()
    },
    methods: {
        onmessage(event) {
            console.log('received message')
            var dict = JSON.parse(event.data);
            console.log(dict)
            if (dict.message === this.$getBoardsResponse) {
                this.loadingDialog = false
                this.boards = dict.data.boards;
                sessionStorage.setItem('boards', JSON.stringify(dict.data.boards))
            } else if (dict.message === this.$createBoardResponse) {
                var board_id = dict.data.board_id
                this.$router.push('/board/' + board_id)
            }
        },
        getBoards() {
            var vm = this;

            Auth.currentAuthenticatedUser()
                .then(data => {
                    var msg = {
                        message: vm.$getBoardsRoute,
                        token: data.signInUserSession.accessToken.jwtToken
                    }
                    console.log('Sending message:')
                    console.log(msg)

                    vm.websocket.send(JSON.stringify(msg));
                })
                .catch(err => console.log(err));
        },
        createBoard() {
            this.creatingDialog = true
            var vm = this;
            Auth.currentAuthenticatedUser()
                .then(data => {
                    var msg = {
                        message: vm.$createBoardRoute,
                        token: data.signInUserSession.accessToken.jwtToken
                    }
                    console.log('Sending message:')
                    console.log(msg)
                    vm.websocket.send(JSON.stringify(msg));
                })
                .catch(err => console.log(err));
        }
    },
    components: {
        LoadingDialog,
    }
}
</script>

<style>
</style>
