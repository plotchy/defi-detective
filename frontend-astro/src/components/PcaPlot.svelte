<script lang="ts">
	import type { Branded } from '../types/Branded'

	import pcaData from '../../../data/pca.json'
	import DotPlot from '../components/LayerCake/DotPlot.svelte'

	type ProjectName = Branded<string, 'ProjectName'>
	type ProjectCategory = Branded<string, 'ProjectCategory'>

	// const normalizePcaData = (data: Record<ProjectName, [number, number]>) => (
	// 	Object.entries(data)
	// 		.map(([name, [x, y]]) => ({
	// 			x,
	// 			y,
	// 			name,
	// 		}))
	// )
</script>


<section>
	<DotPlot
		data={pcaData}
		xAccessor={datum => datum.position[0]}
		yAccessor={datum => datum.position[1]}
		labelAccessor={datum => datum.name}
		categoryAccessor={datum => 'All'}
		linkAccessor={datum => `/apps/0x${datum.address}`}
	/>
</section>


<style>
	section {
		display: grid;
		gap: 1rem;
		padding: 1.5rem;

		background-color: rgba(255, 255, 255, 0.25);
		border-radius: 1rem;
		box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.075);

		transition: 0.4s;
	}
</style>
