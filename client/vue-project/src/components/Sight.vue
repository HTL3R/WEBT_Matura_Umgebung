<template>

<div class="m-2 bg-gray-200 w-1/4">
<p>Name: {{sight.name}}</p>
<p>Adress: {{sight.address}}</p>
<p>Zip: {{sight.zip}}</p>
<p>City: {{sight.city}}</p>

</div>

</template>

<script>
export default {
    props: ['sight']
}


</script>