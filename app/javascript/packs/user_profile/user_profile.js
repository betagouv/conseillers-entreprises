import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import ProfileItem from './profile_item.vue'

var token = document.getElementsByName('csrf-token')[0].getAttribute('content');
axios.defaults.headers.common['X-CSRF-Token'] = token;
axios.defaults.headers.common['Accept'] = 'application/json';

const profile = new Vue({
    el: '#profile',
    data: {
        user: {},
        editMode: false,
        trad: {},
        profileFields: [
            'email',
            'first_name',
            'last_name'
        ],
        immutableFields: [
            'email'
        ]
    },
    components: {},
    computed: {},
    mounted: function () {
        this.getUser();
        this.mountTraductions();
    },
    methods: {
        mountTraductions: function () {
            this.trad = traductions;
        },
        getUser: function () {
            var that;
            that = this;
            axios.get('/profile.json')
                .then(function (response) {
                    that.user = response.data;
                })
                .catch(function (error) {
                    console.log('axios.get error' + error);
                });
        },
        patchUser: function () {
            var that;
            that = this;
            axios.patch('/profile', { user: this.user})
                .then(function (response) {
                    that.user = response.data.user;
                })
                .catch(function (error) {
                    console.log('axios.patch error' + error);
                });
        },
        editButtonClicked: function () {
            this.unmodifiedUser = $.extend(true, {}, this.user);
            this.editMode = true;
        },
        saveButtonClicked: function () {
            this.unmodifiedUser = {};
            this.editMode = false;
            this.patchUser();
        },
        cancelButtonClicked: function () {
            this.user = $.extend(true, {}, this.unmodifiedUser);
            this.editMode = false;
        }
    }
});