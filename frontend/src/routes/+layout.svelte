<script lang="ts">
	import Header from '../components/Header.svelte'
	import Footer from '../components/Footer.svelte'


	import '../styles/global.css'
	import '../styles/fonts.css'
</script>


<Header />

<slot />

<Footer />
