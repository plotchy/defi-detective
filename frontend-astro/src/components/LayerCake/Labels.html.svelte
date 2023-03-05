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

	export let keyAccessor = d => Math.random().toString()
</script>


{#each labels as datum (keyAccessor(datum))}
	<span
		class="label"
		style="
			--x: {$xGet(datum) + offset.x}px;
			--y: {$yGet(datum) + offset.y}px;
		"
	>
		<slot
			{datum}
			label={formatLabelName(getLabelName(datum))}
		>
			{formatLabelName(getLabelName(datum))}
		</slot>
	</span>
{/each}


<style>
	.label {
		translate: var(--x) var(--y);
		position: absolute;
		offset: path('M 0 0') 0px;
		font-size: 0.5em;
	}
</style>
