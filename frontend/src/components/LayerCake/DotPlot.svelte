<script lang="ts">
	type Datum = $$Generic<{}>
	type DatumLabel = $$Generic<string>
	type DatumCategory = $$Generic<string>


	export let data: Datum[]

	export let xAccessor = datum => datum.x
	export let yAccessor = datum => datum.y

	export let labelAccessor: (datum: Datum) => DatumLabel = datum => datum.name
	
	export let categoryAccessor: (datum: Datum) => DatumCategory = datum => datum.category

	const categories: DatumCategory[] = [...new Set(data.map(categoryAccessor))]

	export let categoryColors: Record<DatumCategory, string> = Object.fromEntries(categories.map((category, i, { length }) => [
		category,
		`hsl(${Math.floor((i / length) * 360)}, 80%, 60%)`,
		// `hsl(${Math.floor(Math.random() * 360)}, 80%, 60%)`,
		// `#${Math.floor(Math.random() * 16777215).toString(16)}`,
	]))

	const r = 3;
	const padding = 6;


	import { LayerCake, Svg, WebGL, Html, Canvas } from 'layercake'
	import ScatterCanvas from './Scatter.canvas.svelte'
	import ScatterWebGL from './Scatter.webgl.svelte'
	import AxisX from './AxisX.svelte'
	import AxisY from './AxisY.svelte'
	import QuadTree from './QuadTree.html.svelte'
	import Labels from './Labels.html.svelte'
</script>


<style>
	/*
		The wrapper div needs to have an explicit width and height in CSS.
		It can also be a flexbox child or CSS grid element.
		The point being it needs dimensions since the <LayerCake> element will
		expand to fill it.
	*/
	.chart-container {
		width: 100%;
		height: 100%;

		display: grid;
		grid-template:
			1fr
			/ 1fr auto;
		gap: 1rem;
	}

	.circle {
		position: absolute;
		border-radius: 50%;
		background-color: rgba(171,0, 214);
		transform: translate(-50%, -50%);
		pointer-events: none;
		width: 10px;
		height: 10px;
	}

	.legend {
		overflow: auto;
		height: 0;
		min-height: 100%;
	}
</style>


<div class="chart-container">
	<LayerCake
		padding={{ top: 0, right: 5, bottom: 20, left: 25 }}
		x={xAccessor}
		y={yAccessor}
		xPadding={[padding, padding]}
		yPadding={[padding, padding]}
		data={data}
	>
		<Svg>
			<AxisX />
			<AxisY
				ticks={5}
			/>
		</Svg>

		<Canvas>
			<ScatterCanvas
				r={datum => 3}
				fill={datum => categoryColors[categoryAccessor(datum)]}
			/>
		</Canvas>

		<!-- <WebGL>
			<ScatterWebGL
				{r}
			/>
		</WebGL> -->

		<Html>
			<QuadTree
				let:x
				let:y
				let:visible
			>
				<div
					class="circle"
					style="top:{y}px;left:{x}px;display: { visible ? 'block' : 'none' };"
				></div>
			</QuadTree>

			<Labels
				labels={data}
				getLabelName={labelAccessor}
				let:datum
				let:label
			>
				<span style="color: {categoryColors[categoryAccessor(datum)]}">{label}</span>
			</Labels>
		</Html>
	</LayerCake>

	<div class="legend">
		<dl>
			{#each categories as category}
				<div>
					<dt style="color: {categoryColors[category]}">●</dt>
					<dd>{category}</dd>
				</div>
			{/each}
		</dl>
	</div>
</div>
