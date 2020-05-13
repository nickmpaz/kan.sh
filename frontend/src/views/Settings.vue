<template>
    <v-container class="mt-10" fluid>

    <v-row align="center" justify="center">
        <v-col cols="12" md="10" lg="8">
            <v-card class="elevation-12">
                <v-row>
                    <v-col cols="6">
                        <div class="mx-5 mt-5 mb-8">
                        <span class="title">Appearances</span>
                        </div>
                        
                        <v-switch v-model="$vuetify.theme.dark" @change="setDarkModePreference()" primary label="Dark Mode" class="mx-5" />
                        <v-switch v-model="tooltipsOn" @change="setTooltipSettings" primary label="Tooltips" class="mx-5" />
                    </v-col>
                    <v-col cols="6">

                    </v-col>
                </v-row>
            </v-card>
        </v-col>
    </v-row>
    </v-container>


</template>

<script>
export default {
    props: ['tooltips'],
    data() {
        return {
            tooltipsOn: null
        }
    },
    created() {
        this.tooltipsOn = this.tooltips
    },
    methods: {
        setDarkModePreference() {
            localStorage.setItem('darkModePreference', JSON.stringify(this.$vuetify.theme.dark))
        },
        setTooltipSettings(tooltips) {
            this.$emit('setTooltipSettings', tooltips)
        }
    },
    components: {

    }
}
</script>

<style>

</style>
