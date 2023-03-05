<script lang="ts">
	// export let name: string
	export let address: string
</script>


{#await fetch(`http://localhost:9003/get_similar_contract_for_address/0x${address}`)}
	Finding similar contracts...
{:then response}
	{#await response.json() then data}
		<slot {data} />
	{/await}
{/await}
