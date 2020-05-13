<template>
    <v-container class="fill-height" fluid>
        <sign-up v-if="formState === 'signUp'" :toggle="toggle"></sign-up>
        <sign-in v-if="formState === 'signIn'" :toggle="toggle"></sign-in>
    </v-container>
</template>

<script>
import SignUp from './SignUp'
import SignIn from './SignIn'

export default {
    name: 'app',
    data() {
        return {
            formState: 'signIn',
        }
    },
    methods: {
        toggle() {
            this.formState = this.formState === 'signUp' ? 'signIn' : 'signUp';
        },
    },
    components: {
        SignUp,
        SignIn
    }
}
</script>

<style>

</style>
