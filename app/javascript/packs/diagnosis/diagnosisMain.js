import Vue from 'vue/dist/vue.esm'
import store from './store'
import ContentForm from './contentForm.vue.erb'
import SendEmailSegment from './sendEmailSegment.vue.erb'

new Vue({
    el: '#vue-js-app',
    store,
    components: {
        'content-form': ContentForm,
        'contact-modal': SendEmailSegment
    }
});