<script lang="ts">
	import { page } from '$app/stores'

	export const load = async ({ fetch, params }) => ({
		address: params.address
	})

	let address
	$: address = $page.params.address


	import apps from '../../../../../data/pca.json'

	const appsByAddress = Object.fromEntries(apps.map(app => [`0x${app.address}`, app]))

	export const getStaticPaths = async () => {
		return apps.map((app) => ({
			params: { address: `0x${app.address}` },
			props: app,
		}))

		// const apps = []

		// for(let i = 0n; i < 0xffffffffffffffffffffffffffffffffffffffffn; i++)
		// 	apps.map((app) => ({
		// 		params: { address: `0x${i.toString(16)}` },
		// 		props: app,
		// 	}))
		
		// return apps
	}


	let app
	$: app = appsByAddress[address]
	console.log(address, appsByAddress, app, address in appsByAddress)


	import ContractComparison from '../../../components/ContractComparison.svelte'
</script>


<style>
	a {
		display: contents;
	}

	section {
		display: grid;
		gap: 0.5rem;
		padding: 1rem;
		border-radius: 1rem;
		background-color: rgba(255, 255, 255, 0.2);
	}
</style>


<main>
	<h1>{app.name}</h1>

	<output>0x{app.address}</output>

	<h3>Compare</h3>

	<ContractComparison
		address={app.address}
	/>
</main>
