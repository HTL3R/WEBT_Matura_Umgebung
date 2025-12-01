<script>
import TheWelcome from '../components/TheWelcome.vue'
import axios from 'axios'
import Sight from '../components/Sight.vue'
export default {





created() {

  this.getSights();
},

data() {
  return {
    sights: [],
    newSight: {}
  }
},

components: {
  Sight
}, 
methods: {
  async getSights() {

  const path = 'http://localhost/sight'
  axios.get(path).then((res) => {
    this.sights = res.data
    
  })
  .catch((err)=> {
    console.console.error(err);
    
  })
},

async addSights() {

const path = 'http://localhost/sight/new'
axios.post(path, this.newSight,{
  headers: {
    "Content-Type":"application/json"
  }
}).then((res) => {
console.log(res)
this.getSights()  
})
.catch((err)=> {
  console.console.error(err);
  
})
},
},

  
}

</script>

<template>

<Sight v-for="(sight, index) in sights" :key="sight.id" :sight="sight">


</Sight>

<form>
<input type = "text" class="form-control" v-model="newSight.name">
<input type = "text" class="form-control" v-model="newSight.address">
<input type = "number" class="form-control" v-model="newSight.zip">
<input type = "text" class="form-control" v-model="newSight.city">

</form>


</template>
