<script lang="ts">
	import { page } from '$app/stores'


	export let href
	export let className


	const isActive = href === $page.url.pathname || href === $page.url.pathname.replace(/\/$/, '');
</script>


<a href={href} class:list={[className, { active: isActive }]} {...$$props}>
	<slot />
</a>


<style>
	a {
		display: inline-block;
		text-decoration: none;
	}
	a.active {
		font-weight: bolder;
		text-decoration: underline;
	}
</style>
