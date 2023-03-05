<script lang="ts">
	// export let name: string
	export let address: string
</script>


{#await fetch(`http://localhost:9003/get_similar_contract_for_address/${address}`)
	.then(response => response.json())
	.then(result => {
		if(result.contract === 'No matches found')
			throw new Error('No matches found')
		return result
	})
}
	<strong>📝 Finding similar contracts...</strong>
{:then {most_similar_contracts: contracts}}
	<slot {contracts} />
{:catch error}
	{error}
{/await}
