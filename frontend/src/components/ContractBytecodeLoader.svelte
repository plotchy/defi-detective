<script lang="ts">
	// export let name: string
	export let address: string

	// let code: string
	// $: (async () => {
	// 	code = await import(`../../../00byaddress/${address}.sol`)
	// })()
</script>


{#await fetch(`http://localhost:9003/get_bytecode_for_address/${address}`)
	.then(response => response.json())
	.then(result => {
		if(result.contract === 'No matches found')
			throw new Error('No matches found')
		return result
	})
}
	<strong>Loading contract bytecode...</strong>
{:then bytecode}
	<slot {bytecode} />
{:catch error}
	{error}
{/await}
