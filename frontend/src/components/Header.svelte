<script lang="ts">
	import Link from './Link.svelte';
	import { SITE_TITLE } from '../consts';
</script>


<header>
	<h1>
		{SITE_TITLE}
	</h1>

	<nav>
		<Link href="/">Feed</Link>
		<Link href="/chart-1">Chart 1</Link>
		<Link href="/chart-2">Chart 2</Link>
	</nav>
</header>


<style>
	h1 {
		list-style-type: list-item;
		position: relative;
		color: rgba(0, 0, 0, 0.8);
	}
	h1::before {
		content: '🕵🏻';
		position: absolute;
		right: calc(100% + 1rem);
	}
</style>
