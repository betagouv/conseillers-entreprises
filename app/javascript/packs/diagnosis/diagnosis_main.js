import Vue from 'vue/dist/vue.esm'
import ContentForm from './content_form.vue'
import ContactModal from './contact_modal.vue'
import axios from 'axios'

var token = document.getElementsByName('csrf-token')[0].getAttribute('content');
axios.defaults.headers.common['X-CSRF-Token'] = token;
axios.defaults.headers.common['Accept'] = 'application/json';

new Vue({
    el: '#vue-js-app',
    components: {
        'content-form': ContentForm,
        'contact-modal': ContactModal
    }
});