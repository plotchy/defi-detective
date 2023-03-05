<script lang="ts">	
	import Date from '../../components/Date.svelte'
	import WithState from '../../components/WithState.svelte'

	
	import apps from '../../../../data/pca.json'


	import { fly, scale } from 'svelte/transition'
	import { flip } from 'svelte/animate'
	import { expoInOut } from 'svelte/easing'
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


<WithState let:state>
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
					animate:flip={{ duration: () => Object.values(state.apps).length > 20 ? 0 : 500, delay: i * 10, easing: expoInOut }}
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

						<div>
							<dt>Logs</dt>
							<!-- <dd>{app.logs_emitted_on_deploy}</dd> -->
						</div>

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
