import Vue from 'vue';
import Vuetify from 'vuetify/lib';
import colors from 'vuetify/lib/util/colors'

Vue.use(Vuetify);

export default new Vuetify({
    customVariables: ['~/assets/variables.scss'],
    theme: {
        themes: {
            light: {
                primary: '#1976D2',
                secondary: colors.grey.lighten3,
                accent: '#424242',
                error: '#FF5252',
                info: '#2196F3',
                success: '#4CAF50',
                warning: '#FFC107',
                background: colors.grey.lighten4,
            },
            dark: {
                primary: '#bb86fc',
                secondary: colors.grey.darken3,
                accent: '#03dac6',
                error: '#cf6679',
            }
        },
    },
})
