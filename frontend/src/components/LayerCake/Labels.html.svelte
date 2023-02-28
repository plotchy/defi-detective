<!--
	@component
	Adds HTML text labels based on a given list.
 -->
<script>
	import { getContext } from 'svelte';

	const { xGet, yGet } = getContext('LayerCake');

	/** @type {Array} labels - An array of objects that contain a field containing text label and data fields. */
	export let labels;

	/** @type {Function} getLabelName= - An accessor function to return the label field on your objects in the `labels` array. */
	export let getLabelName;

	/** @type {Function} [formatLabelName=d => d] - An optional formatting function. */
	export let formatLabelName = d => d;

	export let offset = { x: 0, y: -10 }
</script>


{#each labels as d}
	<div
		class="label"
		style="
			left:{$xGet(d) + offset.x}px;
			top:{$yGet(d) + offset.y}px;
		"
	>{formatLabelName(getLabelName(d))}</div>
{/each}


<style>
	.label {
		position: absolute;
		transform: translate(-50%, -50%);
		font-size: 0.5em;
	}
</style>
