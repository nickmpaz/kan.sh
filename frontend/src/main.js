import Vue from 'vue'
import vuetify from './plugins/vuetify';
import router from './router'

import '@aws-amplify/ui-vue'
import Amplify from 'aws-amplify'
import awsconfig from './aws-exports'

import App from './App.vue'

import 'material-design-icons-iconfont/dist/material-design-icons.css'

Amplify.configure(awsconfig)
// Vue.use(AmplifyPlugin, AmplifyModules)
Vue.config.productionTip = false



var settings = require('./settings')
Vue.prototype.$settings = settings




Vue.prototype.$darkModeDefault = true
Vue.prototype.$tooltipDefault = true

Vue.prototype.$connectRoute = 'connect'
Vue.prototype.$websocketAPI = process.env.VUE_APP_WEBSOCKET_API
Vue.prototype.$getBoardsRoute = 'get_boards'
Vue.prototype.$createBoardRoute = 'create_board'
Vue.prototype.$shareBoardRoute = 'share_board'
Vue.prototype.$deleteBoardRoute = 'delete_board'
Vue.prototype.$getBoardContentsRoute = 'get_board_contents'
Vue.prototype.$updateBoardContentsRoute = 'update_board_contents'

Vue.prototype.$createBoardResponse = 'create_board_response'
Vue.prototype.$deleteBoardResponse = 'delete_board_response'
Vue.prototype.$getBoardsResponse = 'get_boards_response'
Vue.prototype.$updateBoardContentsResponse = 'update_board_contents_response'


new Vue({
  vuetify,
  router,
  render: h => h(App)
}).$mount('#app')
