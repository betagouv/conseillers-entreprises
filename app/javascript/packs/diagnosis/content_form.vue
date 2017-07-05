<template>
    <div class="ui dimmable segment shadow-less" v-bind:class="{ dimmed: disabled }">
        <div class="ui simple inverted dimmer">
            <div class="ui text loader">{{ locales.save_loader }}</div>
        </div>
        <div class="ui form">
            <div class="field">
                <label>{{ locales.description }}</label>
                <textarea rows="2" v-model="diagnosis.content"></textarea>
            </div>
            <button class="small ui button" v-on:click="saveButtonClicked">
                {{ locales.save_description }}
            </button>
        </div>
    </div>
</template>

<script>
    import axios from 'axios'

    export default {
        name: 'content-form',
        props: ['diagnosis_id'],
        data () {
            return {
                diagnosis: {content: ''},
                disabled: true,
                locales: {
                    description: '',
                    save_description: '',
                    save_loader: ''
                }
            }
        },
        mounted: function () {
            this.mountPageData();
            this.getDiagnosis();
        },
        methods: {
            getDiagnosis: function () {
                var that;
                that = this;
                axios.get('/api/diagnoses/' + this.diagnosis_id  + '.json')
                    .then(function (response) {
                        that.diagnosis = response.data;
                        that.disabled = false;
                    })
                    .catch(function (error) {
                    });
            },
            updateDiagnosis: function () {
                var that;
                that = this;
                axios.patch('/api/diagnoses/' + this.diagnosis_id, { diagnosis: this.diagnosis } )
                    .then(function (response) {
                        that.$nextTick(() => {
                            that.diagnosis = response.data;
                            that.disabled = false;
                        })
                    })
                    .catch(function (error) {
                    });
            },
            mountPageData: function () {
                this.$nextTick(() => {
                    this.locales = pageLocales;
                })
            },
            saveButtonClicked: function () {
                this.$nextTick(() => {
                    this.disabled = true;
                })
                this.updateDiagnosis();
            }
        }
    }
</script>

<style lang="sass">
</style>