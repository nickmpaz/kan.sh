<template>
<v-dialog v-model="active" fullscreen no-click-animation persistent hide-overlay transition="dialog-bottom-transition">
    <v-card>
        <v-toolbar dark color="primary" class="mb-12">
            <v-toolbar-title>Share</v-toolbar-title>
        </v-toolbar>
        <v-container>
            <v-row justify="center">
                <v-col class="d-flex flex-column justify-center" cols="12" xs="10" sm="8" md="6" lg="6" xl="6">
                    <v-text-field label="Username" v-model="username" outlined autofocus></v-text-field>
                    <div class="d-flex">
                    <v-btn large @click="cancel" class="mr-5" color="secondary" width="150">
                            <v-icon dark class="mr-3">mdi-close</v-icon>
                            Close
                        </v-btn>
                        <v-spacer />
                        <v-btn large @click="share" color="accent" width="150">
                            <v-icon dark class="mr-3">mdi-share</v-icon>
                            Share
                        </v-btn>
                    </div>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</v-dialog>
</template>

<script>

export default {

    props: ['active'],
    data() {
        return {
            username: '',
        }
    },        
    methods: {
        cancel() {
            this.username = ''
            this.$emit('cancelDialog')
        },
        share() {
            this.$emit('shareBoard', this.username)
            this.username = ''
        },
    }
}
</script>
