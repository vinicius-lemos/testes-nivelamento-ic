<template>
  <h2>Busca de Operadoras</h2>
  <input type="text" v-model="term" />
  <button @click="search">Buscar</button>

  <div v-if="results.length">
    <h2>Resultados</h2>
    <table border="1">
      <thead>
        <tr>
          <th v-for="(value, key) in results[0]" :key="key">{{ key }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in results" :key="index">
          <td v-for="(value, key) in item" :key="key">{{ value }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
table th {
  font-weight: bold;
}
</style>

<script>
import axios from "axios";

export default {
  data() {
    return {
      term: "",
      results: [],
    };
  },
  methods: {
    async search() {
      try {
        const response = await axios.get("http://127.0.0.1:5000/search", {
          params: { term: this.term },
        });
        this.results = response.data.operators;
      } catch (error) {
        console.error("Error");
      }
    },
  },
};
</script>
