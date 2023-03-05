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


<ContractBytecodeLoader {address} let:bytecode>
	<pre>{bytecode}</pre>

	<SimilarContractsLoader {address} let:contracts>
		<label>
			<span>Compare:</span>
			<select bind:value={compareContract}>
				{#each contracts as contract}
					<option value={contract}>{contract}</option>
				{/each}
			</select>
		</label>

		<DiffEditor
			leftText={bytecode}
			rightText={compareContract?.bytecode ?? `Select a contract to compare`}
		/>
	</SimilarContractsLoader>
</ContractBytecodeLoader>
