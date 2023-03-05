<script lang="ts">
	import apps from '../../../../data/pca.json'
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
</style>


<main>
	<h2>Newest protocols</h2>

	<section>
		{#each apps as app}
			<a href={`/apps/0x${app.address}`}>
				<article>
					<h3>{app.name}</h3>
					<output>0x{app.address}</output>
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
			</a>
		{/each}
	</section>
</main>
