<template>
    <div id="profile">
        <p>{{ message }}</p>
    </div>
</template>

<script>
    export default {
        el: '#profile',
        data: function () {
            return {
                message: "PROFILE !!!!"
            }
        }
    }
</script>

<style scoped>
    p {
        font-size: 2em;
        text-align: center;
    }
</style>
