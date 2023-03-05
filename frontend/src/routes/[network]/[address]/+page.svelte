<script lang="ts">
	import type { State, Network, Address, App } from '../../../../components/WithState.svelte'

	export const load = async ({ params: { network, address }}) => ({
		network,
		address,
	})

	import { page } from '$app/stores'

	let network: Network
	let address: Address
	$: (
		{network, address} = $page.params as {network: Network, address: Address}
	)


	import apps from '../../../../../data/pca.json'
	const appsByAddress = Object.fromEntries(apps.map(app => [`0x${app.address}`, app]))


	import ContractComparison from '../../../components/ContractComparison.svelte'
	import WithState from '../../../components/WithState.svelte'
</script>


<WithState let:state>
	{@const app = state.apps[`${network}/${address}`] ?? appsByAddress[address]}

	{#if app}
		<main>
			<div class="row">
				<h2>📝 {app.name ?? `${app.network[0].toUpperCase().replace('-g', ' G')}${app.network.slice(1)} Contract`}</h2>
				<output>{address}</output>
			</div>

			<ContractComparison
				{address}
			/>
		</main>
	{/if}
</WithState>
