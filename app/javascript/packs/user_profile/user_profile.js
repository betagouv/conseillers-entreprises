import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import Profile from './profile.vue'


// document.addEventListener('DOMContentLoaded', () => {
//     const profile = new Vue(Profile).$mount('profile');
//     console.log(profile);
// });


const profile = new Vue({
    el: '#profile',
    data: {
        user: {},
        editMode: false
    },
    components: {},
    mounted: function () {
        var that;
        that = this;
        axios.get('/users/edit.json')
            .then(function (response) {
                console.log(response.data);
                that.user = response.data;
                console.log('axios.get success');
            })
            .catch(function (error) {
                console.log('axios.get error');
                console.log(error);
            });
    }
});
