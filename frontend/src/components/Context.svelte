<script lang="ts">
	type T = $$Generic<object>

	import { getContext } from 'svelte'

	export let key: string

	export let context = getContext<T>(key)
</script>


<slot {context} />
