<script lang="ts">
	import { lchToRgb } from '../../utils/colors'


	type Datum = $$Generic<object>
	type DatumLabel = $$Generic<string>
	type DatumCategory = $$Generic<string>


	export let data: Datum[]

	export let keyAccessor = datum => [xAccessor, yAccessor, labelAccessor, categoryAccessor].map(f => f(datum)).join('|')

	export let xAccessor = datum => datum.x
	export let yAccessor = datum => datum.y

	export let labelAccessor: (datum: Datum) => DatumLabel = datum => datum.name
	
	export let categoryAccessor: (datum: Datum) => DatumCategory = datum => datum.category

	const categories: DatumCategory[] = [...new Set(data.map(categoryAccessor))]

	export let categoryColors: Record<DatumCategory, string> = Object.fromEntries(categories.map((category, i, { length }) => [
		category,
		length === 1 ? 'rgba(50, 50, 50, 1)' : lchToRgb({l: 20, c: 80, h: i / length * 360})
		// `hsl(${Math.floor((i / length) * 360)}, 80%, 60%)`,
		// `hsl(${Math.floor(Math.random() * 360)}, 80%, 60%)`,
		// `#${Math.floor(Math.random() * 16777215).toString(16)}`,
	]))

	export let linkAccessor: (datum: Datum) => string


	const r = 3;
	const padding = 6;


	let showCategories = new Set()

	let filteredData: Datum[]
	$: filteredData = showCategories.size
		? data.filter((datum) => showCategories.has(categoryAccessor(datum)))
		: data


	let nearestDatum: Datum


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
	.legend input[type="checkbox"] {
		display: none;
	}
	.legend input[type="checkbox"] ~ * {
		transition-property: opacity;
	}
	.legend:has(:checked) input[type="checkbox"]:not(:checked) ~ * {
		opacity: 0.5;
	}
	.legend label {
		display: flex;
	}

	.label {
		display: inline-flex;
		padding: 0.25rem;
		line-height: 1;
		border-radius: 0.25em;
		text-shadow: 0 0.1em 0.2em rgba(0, 0, 0, 0.15);
		transition-duration: 0.2s;
		pointer-events: none;
	}
	.label[data-hovered="true"] {
		font-size: 0.7rem;
		translate: 0 -0.5em;
		background-color: rgba(255, 255, 255, 0.8);
		backdrop-filter: blur(4px);
		z-index: 1;
		position: sticky;
		inset: 0;
	}
	.chart-container:hover .label:not([data-hovered="true"]) {
		font-size: 0.3rem;
		opacity: 0.5;
	}

	.nearest-datum-link {
		position: absolute;
		inset: 0;
	}
</style>


<div
	class="chart-container"
>
	<LayerCake
		padding={{ top: 0, right: 5, bottom: 20, left: 25 }}
		x={xAccessor}
		y={yAccessor}
		xPadding={[padding, padding]}
		yPadding={[padding, padding]}
		data={filteredData}
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
			<a class="nearest-datum-link" href="{nearestDatum ? linkAccessor?.(nearestDatum) : '#'}">
				<QuadTree
					bind:found={nearestDatum}
					let:x
					let:y
					let:visible
				>
					<div
						class="circle"
						style="top:{y}px;left:{x}px;display: { visible ? 'block' : 'none' };"
					></div>
				</QuadTree>
			</a>

			<Labels
				labels={filteredData}
				getLabelName={labelAccessor}
				{keyAccessor}
				let:datum
				let:label
			>
				<span
					class="label"
					style="color: {categoryColors[categoryAccessor(datum)]}"
					data-hovered={nearestDatum === datum}
				>{label}</span>
			</Labels>
		</Html>
	</LayerCake>

	<div class="legend">
		<dl>
			{#each categories as category}
				<!-- <label
					on:mouseover={e => { showCategories.add(category); showCategories = showCategories }}
					on:focus={e => { showCategories.add(category); showCategories = showCategories }}
					on:mouseout={e => { showCategories.delete(category); showCategories = showCategories }}
					on:blur={e => { showCategories.delete(category); showCategories = showCategories }}
				> -->
				<label>
					<input
						type="checkbox"
						checked={showCategories.has(category)}
						on:input={(e) =>{
							e.target.checked
								? showCategories.add(category)
								: showCategories.delete(category)
							showCategories = showCategories
						}}
					/>
					<dt style="color: {categoryColors[category]}">●</dt>
					<dd>{category}</dd>
				</label>
			{/each}
		</dl>
	</div>
</div>
