<script lang="ts">
	type Datum = $$Generic<{}>
	type DatumLabel = $$Generic<string>
	type DatumSeries = $$Generic<string>


	export let data: Datum[]

	export let xAccessor = datum => datum.x
	export let yAccessor = datum => datum.y

	export let labelAccessor: (datum: Datum) => DatumLabel = datum => datum.name
	
	export let seriesAccessor: (datum: Datum) => DatumSeries = datum => datum.category
	export let seriesColors: Record<DatumSeries, string> = {}


	const r = 3;
	const padding = 6;


	import { LayerCake, Svg, WebGL, Html } from 'layercake'
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

		<WebGL>
			<ScatterWebGL
				{r}
			/>
			<!-- fill={seriesColors[seriesAccessor(datum)]]} -->
		</WebGL>

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
				labels={
					data
				}
				getLabelName={labelAccessor}
			/>
		</Html>
	</LayerCake>
</div>
