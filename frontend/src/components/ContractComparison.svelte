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
	<br>

	<h3>🎛️ Bytecode</h3>

	<pre>{bytecode.bytecode}</pre>

	<br>

	<SimilarContractsLoader {address} let:contracts>
		<div class="row">
			<h3>Similar Contracts</h3>

			<label>
				<span>Compare:</span>
				<select bind:value={compareContract}>
					{#each contracts as contract}
						<option value={contract?.name}>{contract?.name}</option>
					{/each}
				</select>
			</label>
		</div>

		<DiffEditor
			leftText={bytecode}
			rightText={compareContract?.source_code ?? `Select a contract to compare`}
		/>
	</SimilarContractsLoader>
</ContractBytecodeLoader>
