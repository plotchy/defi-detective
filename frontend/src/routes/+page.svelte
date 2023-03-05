<script lang="ts">
	import Header from '../components/Header.svelte'
	import Footer from '../components/Footer.svelte'
	import { SITE_TITLE, SITE_DESCRIPTION } from '../consts'
	
	import WithState from '../components/WithState.svelte'
	
	import PcaPlot from '../components/PcaPlot.svelte'
</script>

<style>
	main {
		align-content: stretch;
		grid-template:
			auto
			1fr
			/ 100%;
	}
</style>


<main>
	<h2>{SITE_TITLE}</h2>

	<PcaPlot />
</main>
