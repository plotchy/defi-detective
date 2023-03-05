<!--
	@component
	Generates a canvas scatter plot.
 -->
<script lang="ts">
	import { getContext } from 'svelte'
	import { scaleCanvas } from 'layercake'


	type Datum = $$Generic<{}>

	const { data, xGet, yGet, width, height } = getContext('LayerCake')

	const { ctx } = getContext('canvas')

	export let r: () => number

	export let fill: (datum: Datum) => string

	$: if ($ctx) {
		/* --------------------------------------------
		* If you were to have multiple canvas layers
		* maybe for some artistic layering purposes
		* put these reset functions in the first layer, not each one
		* since they should only run once per update
		*/
		scaleCanvas($ctx, $width, $height)
		$ctx.clearRect(0, 0, $width, $height)

		/* --------------------------------------------
		* Draw our scatterplot
		*/
		$data.forEach(datum => {
			$ctx.beginPath()
			$ctx.arc($xGet(datum), $yGet(datum), r(), 0, 2 * Math.PI, false)
			// $ctx.lineWidth = strokeWidth
			// $ctx.strokeStyle = stroke
			// $ctx.stroke()
			$ctx.fillStyle = fill(datum)
			$ctx.fill()
		})
	}
</script>
