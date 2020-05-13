<template>
<v-row align="center" justify="center">
    <v-col cols="12" sm="8" md="4">
        <v-card class="elevation-12">
            <v-toolbar color="primary" dark flat>
                <v-toolbar-title>{{ formState === 'signUp' ? 'Sign Up' : 'Confirm' }}</v-toolbar-title>
            </v-toolbar>
            <v-card-text>
                <v-form ref="form" v-model="valid">
                    <v-text-field v-model="username" :rules="usernameRules" :error-messages="error" id="Username" label="Username" name="Username" prepend-icon="person" type="text" :readonly="formState === 'confirmSignUp'" required />
                    <v-text-field v-if="formState === 'signUp'" v-model="password" :rules="passwordRules" id="Password" label="Password" name="Password" prepend-icon="lock" type="password" required />
                    <v-text-field v-if="formState === 'signUp'" v-model="email" :rules="emailRules" id="Email" label="Email" name="Email" prepend-icon="email" type="text" required />
                    <v-text-field v-if="formState === 'confirmSignUp'" v-model="authCode" :rules="authCodeRules" id="AuthCode" :label="'Auth Code (' + email + ')'" name="AuthCode" prepend-icon="lock" type="text" required />
                </v-form>
            </v-card-text>
            <div class="d-flex py-5 justify-space-around">
                <v-btn color="primary" @click.stop="switchToSignIn()"  outlined  width="200">Sign In</v-btn>

                <v-btn v-if="formState === 'signUp'" color="primary" @click.stop="signUp()" width="200">Sign Up</v-btn>
                <v-btn v-if="formState === 'confirmSignUp'" color="primary" @click.stop="confirmSignUp()" width="200">Confirm</v-btn>
            </div>
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
            formState: 'signUp',
            valid: true,
            error: '',
            username: null,
            usernameRules: [
                v => !!v || 'Username cannot be empty',
            ],
            password: '',
            passwordRules: [
                v => !!v || 'Password cannot be empty',
            ],
            email: '',
            emailRules: [
                v => !!v || 'E-mail cannot be empty',
                v => /.+@.+\..+/.test(v) || 'E-mail must be valid',
            ],
        }
    },
    methods: {
        switchToSignIn() {
            this.toggle();
        },
        async signUp() {
            this.error = '';
            this.valid = true;
            if (!this.$refs.form.validate()) {
                console.log("not valid")
                return;
            }
            let username = this.username;
            let password = this.password;
            let email = this.email;
            try {
                await Auth.signUp({
                    username,
                    password,
                    attributes: {
                        email
                    }
                })
                this.formState = 'confirmSignUp'
            } catch (e) {
                this.error = e.message;
            }
        },
        async confirmSignUp() {
            try {

                await Auth.confirmSignUp(this.username, this.authCode)
                await Auth.signIn(this.username, this.password);
                this.$router.push('/')
            } catch (e){
                this.error = e.message;
            }
        }
    }
}
</script>
