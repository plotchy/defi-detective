<script lang="ts">
	import HeaderLink from './HeaderLink.svelte';
	import { SITE_TITLE } from '../consts';
</script>


<header>
	<h1>
		{SITE_TITLE}
	</h1>

	<nav>
		<HeaderLink href="/">Feed</HeaderLink>
		<HeaderLink href="/chart-1">Chart 1</HeaderLink>
		<HeaderLink href="/chart-2">Chart 2</HeaderLink>
		<HeaderLink href="https://github.com/plotchy/defi-detective" target="_blank">GitHub</HeaderLink>
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
