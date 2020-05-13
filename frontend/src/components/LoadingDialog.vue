<template>
<div class="text-center">
    <v-dialog v-model="active" persistent width="300">
        <v-card color="secondary" class="pt-2" :dark="$vuetify.theme.dark">
            <v-card-text class="title">
                {{ message }}
                <v-progress-linear height="10" class="mt-1" striped indeterminate></v-progress-linear>
            </v-card-text>
        </v-card>
    </v-dialog>
</div>
</template>

<script>
export default {
    props: ['active', 'message'],
}
</script>
