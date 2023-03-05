<script lang="ts">
	// export let name: string
	export let address: string

	import DiffEditor from './DiffEditor.svelte'
	import ContractBytecodeLoader from './ContractBytecodeLoader.svelte'
	import SimilarContractsLoader from './SimilarContractsLoader.svelte'

	let compareContract

	// let code: string
	// $: (async () => {
	// 	code = await import(`../../../00byaddress/${address}.sol`)
	// })()
</script>


<ContractBytecodeLoader {address} let:data={contract}>
	<SimilarContractsLoader {address} let:data={contracts}>
		<label>
			<span>Compare:</span>
			<select bind:value={compareContract}>
				{#each contracts as contract}
					<option value={contract}>{contract.address}</option>
				{/each}
			</select>
		</label>

		<DiffEditor
			leftText={contract.code}
		/>
	</SimilarContractsLoader>
</ContractBytecodeLoader>
