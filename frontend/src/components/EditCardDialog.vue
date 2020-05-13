<template>
<v-dialog v-model="active" fullscreen persistent no-click-animation transition="dialog-bottom-transition">
    <v-card>
        <v-toolbar dark color="primary" class="mb-12">
            <v-toolbar-title>Edit</v-toolbar-title>
        </v-toolbar>
        <v-container>
            <v-row justify="center">
                <v-col class="d-flex flex-column justify-center" cols="12" xs="10" sm="8" md="6" lg="6" xl="6">
                    <v-text-field label="Title" v-model="title" outlined></v-text-field>
                    <v-textarea label="Description" v-model="description" outlined auto-grow></v-textarea>
                    <div class="d-flex">
                        <v-btn large @click="cancel" :class="buttonClass" color="secondary" width="150">
                            <v-icon dark class="mr-3">mdi-close</v-icon>
                            Close
                        </v-btn>
                        <v-spacer />
                        <v-btn large @click="del" class="mr-5" color="error" width="150">
                            <v-icon dark class="mr-3">mdi-delete</v-icon>
                            delete
                        </v-btn>
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
    props: ['active', 'title', 'description'],
    computed: {
        buttonClass() {
            if (this.$vuetify.theme.dark) {
                return "mr-5"
            } else {
                return "mr-5 grey--text text--darken-3"
            }
        }
    },
    methods: {
        cancel() {
            this.$emit('cancelDialog')
        },
        save() {
            this.$emit('saveEditCard', this.title, this.description)
        },
        del() {
            this.$emit('deleteEditCard')
        }
    }
}
</script>
