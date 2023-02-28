<script lang="ts">
	import type { Branded } from '../types/Branded'

	import pcaData from '../../../data/pcacat.json'
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

	const categories = [...new Set(pcaData.map(pcaData => pcaData.category as ProjectCategory))]
</script>


<section>
	<DotPlot
		data={pcaData}
		xAccessor={datum => datum.data[0]}
		yAccessor={datum => datum.data[1]}
		labelAccessor={datum => datum.name}
		seriesAccessor={datum => datum.category}
		seriesColors={Object.fromEntries(categories.map((category, i, { length }) => [
			category,
			`hsl(${Math.floor((i / length) * 360)}, 80%, 60%)`,
			// `hsl(${Math.floor(Math.random() * 360)}, 80%, 60%)`,
			// `#${Math.floor(Math.random() * 16777215).toString(16)}`,
		]))}
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
