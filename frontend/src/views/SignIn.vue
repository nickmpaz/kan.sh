<template>
<v-row align="center" justify="center">
    <v-col cols="12" sm="8" md="6" lg="5" xl="4">
        <v-card class="elevation-12">
            <v-toolbar color="primary" dark flat>
                <v-toolbar-title>Sign In</v-toolbar-title>
            </v-toolbar>
            <v-card-text>
                <v-form ref="form" v-model="valid">
                    <v-text-field @keydown.enter="signIn()" v-model="username" :rules="usernameRules" :error-messages="error" id="Username" label="Username" name="Username" prepend-icon="person" type="text" required />
                    <v-text-field @keydown.enter="signIn()" v-model="password" :rules="passwordRules" id="Password" label="Password" name="Password" prepend-icon="lock" type="password" required />
                </v-form>
            </v-card-text>
            <v-container>
                <v-row>
                    <v-col cols="12" lg="6">
                        <div class="d-flex justify-center">
                            <v-btn color="primary" @click.stop="switchToSignUp()" outlined width="200">Sign Up</v-btn>
                        </div>
                    </v-col>
                    <v-col cols="12" lg="6">
                        <div class="d-flex justify-center">
                            <v-btn color="primary" @click.stop="signIn()" :loading="loading" width="200">Sign In</v-btn>
                        </div>
                    </v-col>
                </v-row>
            </v-container>
        </v-card>
    </v-col>
</v-row>
</template>

<script>
import {
    Auth
} from 'aws-amplify'

export default {
    props: ['toggle'],
    data() {
        return {
            valid: true,
            error: '',
            loading: false,
            username: '',
            usernameRules: [
                v => !!v || 'Username cannot be empty',
            ],
            password: '',
            passwordRules: [
                v => !!v || 'Password cannot be empty',
            ],
        }
    },
    methods: {
        switchToSignUp() {
            this.toggle();
        },
        async signIn() {
            this.loading = true;
            this.error = '';
            this.valid = true;
            if (!this.$refs.form.validate()) {
                console.log("not valid")
                this.loading = false;
                return;
            }
            try {
                await Auth.signIn(this.username, this.password);
                this.loading = false;
                this.$router.push('/')
            } catch (e) {
                this.error = e.message;
                this.loading = false;
            }
        }
    }
}
</script>
