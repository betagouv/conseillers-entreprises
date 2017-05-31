import Vue from 'vue/dist/vue.esm'
import axios from 'axios'

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
                that.user = response.data;
            })
            .catch(function (error) {
                console.log('axios.get error');
            });
    }
});
