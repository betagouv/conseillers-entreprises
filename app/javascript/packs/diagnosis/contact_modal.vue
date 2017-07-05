<template>
    <div>
        Username : {{ username }}
    </div>
</template>

<script>
    import axios from 'axios'

    export default {
        name: 'contact-modal',
        props: ['username'],
        data () {
            return {
                name: 'nameeee'
            }
        },
        mounted: function () {
        },
        methods: {}
    }
</script>

<style lang="sass">
</style>