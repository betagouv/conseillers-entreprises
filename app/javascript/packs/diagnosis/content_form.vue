<template>
    <div id="content-form">
        <h1>{{ diagnosis.content }}</h1>
    </div>
</template>

<script>
    import axios from 'axios'

    export default {
        name: 'content-form',
        data () {
            return {
                diagnosis: { content: 'Hello world!'}
            }
        },
        mounted: function () {
            this.getDiagnosis();

        },
        methods: {
            getDiagnosis: function () {
                var that;
                that = this;
                console.log('getDiagnosis');
                axios.get('/api/diagnoses/1.json')
                    .then(function (response) {
                        that.$nextTick(() => {
                            that.diagnosis = response.data;
                        })
                    })
                    .catch(function (error) {
                        console.log('axios.get error' + error);
                    });
            }
        }
    }
</script>

<style lang="sass">
    .example
        font-weight: bold
</style>