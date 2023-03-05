<script context="module" lang="ts">
	import type { Branded } from '../types/Branded'

	export type Network = Branded<string, 'Network'>

	export type Address = Branded<string, 'Address'>

	export type App = {
		network: string;
		address: string;
		block_number: number;
		new_creation: boolean;
		address_from: string;
		events: any[];
		functions: string[];
		most_similar_contracts: string[];
		timestamp: number;
		gas_used_for_deploy: number;
		logs_emitted_on_deploy: string;
	}


	export type State = {
		apps: Record<`${Network}/${Address}`, App>,
		connectionStatus: 'idle' | 'connecting' | 'connected' | 'disconnected',
	}


	import { readable } from 'svelte/store'

	const state = readable<State>(
		{
			apps: {},
			connectionStatus: 'idle',
		},
		set => {
			if(!globalThis.WebSocket) return

			const address = 'ws://localhost:9002'

			let state: State = {
				apps: {},
				connectionStatus: 'connecting',
			}

			console.info('Connecting...')

			const socket = new WebSocket(address)

			console.log({socket})

			socket.onopen = () => {
				console.info('Connected')

				state.connectionStatus = 'connected'
				set(state)
			}

			socket.onmessage = (event) => {
				console.log('event', event)
				const app = JSON.parse(event.data)
				state.apps = {...state.apps, [`${app.network}/${app.address}`]: app}
				console.log({state})

				dispatchEvent?.(new CustomEvent('appDeploy', { detail: { app } }))

				set(state)
			}

			socket.onclose = () => {
				console.info('Disconnected')

				state.connectionStatus = 'disconnected'
				set(state)
			}

			globalThis.addEventListener('beforeunload', () => {
				socket.close()
			})

			return () => {
				socket.close()
			}
		}
	)
</script>


<script lang="ts">
	import { setContext } from 'svelte'

	$: setContext('state', $state)

	$: console.log($state)
</script>


<slot state={$state} />

{#if $state.connectionStatus === 'connected'}
	<aside class="toast connected">Connected</aside>
{:else if $state.connectionStatus === 'connecting'}
	<aside class="toast connecting">Disconnected</aside>
{:else if $state.connectionStatus === 'disconnected'}
	<aside class="toast disconnected">Disconnected</aside>
{/if}


<style>
	.toast {
		position: fixed;
		z-index: 1;
		bottom: 0.75rem;
		right: 0.75rem;
		padding: 0.4rem 0.8rem;
		animation: Toast 5s forwards;
		border-radius: 0.5em;
		color: rgba(255, 255, 255, 0.8);
		text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
	}

	.connected {
		background: rgba(0, 161, 0, 0.5);
	}
	.disconnected {
		background: rgba(255, 0, 0, 0.5);
	}
	.connecting {
		background: rgba(255, 255, 0, 0.5);
	}

	@keyframes Toast {
		from, to {
			opacity: 0;
			transform: translateY(100%);
		}
		10%, 90% {
			opacity: 1;
			transform: translateY(0);
		}
	}
</style>