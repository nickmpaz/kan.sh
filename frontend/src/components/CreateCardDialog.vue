<template>
<v-dialog v-model="active" fullscreen no-click-animation persistent hide-overlay transition="dialog-bottom-transition">
    <v-card>
        <v-toolbar dark color="primary" class="mb-12">
            <v-toolbar-title>Create</v-toolbar-title>
        </v-toolbar>
        <v-container>
            <v-row justify="center">
                <v-col class="d-flex flex-column justify-center" cols="12" xs="10" sm="8" md="6" lg="6" xl="6">
                    <v-text-field label="Title" v-model="cardTitle" outlined autofocus></v-text-field>
                    <v-textarea label="Description" v-model="cardDescription" outlined auto-grow></v-textarea>
                    <div class="d-flex">
                    <v-btn large @click="cancel" :class="buttonClass" color="secondary" width="150">
                            <v-icon dark class="mr-3">mdi-close</v-icon>
                            Close
                        </v-btn>
                        <v-spacer />
                        <v-btn large @click="save" color="accent" width="150">
                            <v-icon dark class="mr-3">mdi-check</v-icon>
                            Save
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
    computed: {
        buttonClass() {
            if (this.$vuetify.theme.dark) {
                return "mr-5"
            } else {
                return "mr-5 grey--text text--darken-3"
            }
        }
    },
    data() {
        return {
            cardTitle: '',
            cardDescription: ''
        }
    },
    methods: {
        cancel() {
            this.$emit('cancelDialog')
            this.cardTitle = ''
            this.cardDescription = ''
        }, 
        save() {
            this.$emit('saveCreateCard', this.cardTitle, this.cardDescription)
            this.cardTitle = ''
            this.cardDescription = ''
        }
    }
}
</script>
