<script lang="ts">	
	import Date from '../components/Date.svelte'
	import WithState from '../components/WithState.svelte'

	
	import apps from '../../../data/pca.json'


	import { fly, scale } from 'svelte/transition'
	import { flip } from 'svelte/animate'
	import { expoOut } from 'svelte/easing'


	import sound1 from '../sounds/cash-register-fake-88639.mp3'
	import sound2 from '../sounds/cash-register-kaching-sound-effect-125042.mp3'
	import sound3 from '../sounds/cash-register-purchase-87313.mp3'
	import sound4 from '../sounds/cha-ching-1-90777.mp3'
	import sound5 from '../sounds/cha-ching-7053.mp3'
</script>


<style>
	section {
		display: grid;
		gap: 1rem;
		grid-template-columns: repeat(auto-fit, minmax(16rem, 1fr));
	}

	a {
		display: contents;
	}

	article {
		display: grid;
		gap: 0.5rem;
		padding: 1rem;
		border-radius: 1rem;
		background-color: rgba(255, 255, 255, 0.2);
	}

	dl {
		gap: 0.5rem;
	}
	dl div {
		display: grid;
	}
	dt {
		min-width: 8rem;
	}
</style>


<svelte:window
	on:appDeploy={({ detail: app }) => {
		console.log(app)
		console.log({sound1, sound2, sound3, sound4, sound5})
		new Audio(
			{
				'arbitrum': sound1,
				'arbitrum-goerli': sound2,
				'goerli': sound3,
				'mainnet': sound4,
				'mumbai': sound5,
				'optimism': sound1,
				'polygon': sound2,
				'avalanche': sound3,
				'aurora': sound4,
			}[app.network]
		).play()
	}}
/>

<WithState
	let:state
>
	<main>
		<h2>Newest protocols</h2>

		<section>
			{#each
				(Object.values(state.apps) ?? apps)
					.sort((a, b) => b.timestamp - a.timestamp)
				as app,
				i (`${app.network}/${app.address}`)
			}
				<article
					animate:flip={{ duration: 100, easing: expoOut }}
					transition:scale={{ duration: 300, from: 0.4, opacity: 0 }}
				>
					<a href={`/apps/${app.network}/${app.address}`}>
						<h3>{app.name ?? `${app.network[0].toUpperCase()}${app.network.slice(1)} Contract`}</h3>
					</a>

					<dl>
						<div>
							<dt>Address</dt>
							<output>{app.address}</output>
						</div>

						<div>
							<dt>Block Number</dt>
							<dd>{app.block_number}</dd>
						</div>

						<div>
							<dt>Similar Contracts</dt>
							<dd>
								{#each app.most_similar_contracts.slice(0, 3) as contractName, i}
									<p>{contractName}</p>
								{/each}
							</dd>
						</div>

						<div>
							<dt>Gas Used</dt>
							<dd>{app.gas_used_for_deploy} wei</dd>
						</div>

						<!-- <div>
							<dt>Logs</dt>
							<dd>{app.logs_emitted_on_deploy}</dd>
						</div> -->

						<div>
							<dt>Timestamp</dt>
							<dd><Date date={app.timestamp * 1000} format="relative" /></dd>
						</div>
					</dl>
				</article>

				<!-- New <a href="">{app.network}</a> contract: {app.address}
				<br />
				Deployed by {app.address_from} in block {app.block_number}
				{app.functions.length > 0 && (
				<h4>Functions:</h4>
				)}
				<ul>
				{app.functions.map((f, j) => (
					<li key={j}>{f}</li>
				))}
				</ul>
				{app.events.length > 0 && <h4>Events:</h4>}
				<ul>
				{app.events.map((e, j) => (
					<li key={j}>{e}</li>
				))}
				</ul>
				{app.most_similar_contracts?.length && (
					<>
						<h4>Similar protocols:</h4>
						{app.most_similar_contracts.map((c, j) => (
							<a key={j}>
							{c}
							</a>
						))}
					</>
				)} -->
			{/each}
		</section>
	</main>
</WithState>
