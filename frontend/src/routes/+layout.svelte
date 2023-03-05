<script lang="ts">
	import WithState from '../components/WithState.svelte'
	import Header from '../components/Header.svelte'
	import Footer from '../components/Footer.svelte'


	import '../styles/global.css'
	import '../styles/fonts.css'
</script>


<WithState>
	<Header />

	<slot />

	<Footer />
</WithState>
