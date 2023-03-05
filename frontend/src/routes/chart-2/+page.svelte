<script lang="ts">
	import { SITE_TITLE, SITE_DESCRIPTION } from '../../consts'
	
	import PcaPlot from '../../components/PcaPlot.svelte'
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
