<template>
<v-row align="center" justify="center" class="fill-height">
    <div class="d-flex justify-center">
        <amplify-authenticator :style="amplifyStyle">
            <amplify-sign-in :header-text="signInConfig.headerText" slot="sign-in" />
            <amplify-sign-up :header-text="signUpConfig.headerText" :form-fields.prop="signUpConfig.formFields" slot="sign-up" />
        </amplify-authenticator>
    </div>
</v-row>
</template>

<script>

export default {
    computed: {
        amplifyStyle() {
            return `
            --amplify-font-family: Roboto;
            --amplify-primary-color: ${this.$vuetify.theme.currentTheme.primary};
            --amplify-primary-tint: ${this.$vuetify.theme.currentTheme.primary};
            --amplify-primary-shade: ${this.$vuetify.theme.currentTheme.primary};
            --amplify-secondary-tint: ${this.$vuetify.theme.currentTheme.error};
            --amplify-secondary-shade: ${this.$vuetify.theme.currentTheme.error};
            --amplify-red: #000000;
            `
        }
    },
    data() {
        return {
            signInConfig: {
                headerText: "Sign In",
            },
            signUpConfig: {
                headerText: "Sign Up",
                formFields: [{
                        type: "username"
                    },
                    {
                        type: "password"
                    },
                    {
                        type: "email"
                    }
                ]
            },
        }
    },
    methods: {
    }
}
</script>
