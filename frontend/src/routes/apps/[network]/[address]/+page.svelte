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


	import apps from '../../../../../../data/pca.json'
	const appsByAddress = Object.fromEntries(apps.map(app => [`0x${app.address}`, app]))

	import { getContext } from 'svelte'
	const state = getContext<SvelteStore<State>>('state')


	let app: App
	$: app = $state.apps[`${network}/${address}`]
		?? appsByAddress[address] // fallback


	import ContractComparison from '../../../../components/ContractComparison.svelte'
</script>


<main>
	<h2>{app?.name ?? address}</h2>

	<output>{address}</output>

	<ContractComparison
		{address}
	/>
</main>
