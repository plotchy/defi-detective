<script lang="ts">
	// export let name: string
	export let address: string

	// let code: string
	// $: (async () => {
	// 	code = await import(`../../../00byaddress/${address}.sol`)
	// })()
</script>


{#await fetch(`http://localhost:9003/get_contract_for_address/${address}`)}
	Loading contract...
{:then response}
	{#await response.json() then data}
		<slot {data} />
	{/await}
{/await}
