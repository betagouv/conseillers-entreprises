<template>
    <div id="content-form">
        <div class="ui dimmable segment shadow-less" v-bind:class="{ dimmed: disabled }">
            <div class="ui simple inverted dimmer">
                <div class="ui text loader">{{ pageData.locales.save_loader }}</div>
            </div>
            <div class="ui form">
                <div class="field">
                    <label>{{ pageData.locales.description }}</label>
                    <textarea rows="2" v-model="diagnosis.content"></textarea>
                </div>
                <button class="small ui button" v-on:click="saveButtonClicked">
                    {{ pageData.locales.save_description }}
                </button>
            </div>
        </div>
    </div>
</template>

<script>
    import axios from 'axios'

    export default {
        name: 'content-form',
        data () {
            return {
                diagnosis: { content: ''},
                disabled: true,
                pageData: {
                    diagnosis_id: '',
                    locales: {
                        description: '',
                        save_description: '',
                        save_loader: ''
                    }
                }
            }
        },
        mounted: function () {
            this.mountPageData();
        },
        watch: {
            pageData: function (val) {
                console.log('diagnosis_id: ' + this.pageData.diagnosis_id );
                if(val.diagnosis_id) {
                    this.getDiagnosis();
                }
            }
        },
        methods: {
            getDiagnosis: function () {
                var that;
                that = this;
                console.log('getDiagnosis');
                axios.get('/api/diagnoses/' + this.pageData.diagnosis_id  + '.json')
                    .then(function (response) {
                        that.$nextTick(() => {
                            that.diagnosis = response.data;
                            that.disabled = false;
                        })
                    })
                    .catch(function (error) {
                        console.log('axios.get error' + error);
                    });
            },
            updateDiagnosis: function () {
                var that;
                that = this;
                console.log('updateDiagnosis with content: ' + this.diagnosis.content);

                axios.patch('/api/diagnoses/' + this.pageData.diagnosis_id, { diagnosis: this.diagnosis } )
                    .then(function (response) {
                        that.$nextTick(() => {
                            that.diagnosis = response.data;
                            that.disabled = false;
                        })
                    })
                    .catch(function (error) {
                        console.log('axios.get error' + error);
                    });
            },
            mountPageData: function () {
                this.$nextTick(() => {
                    console.log('launchData' + launchData.locales.description)
                    this.pageData = launchData;
                })
            },
            saveButtonClicked: function () {
                this.$nextTick(() => {
                    console.log('saveButtonClicked')
                    this.disabled = true;
                })
                this.updateDiagnosis();
            }
        }
    }
</script>

<style lang="sass">
</style>