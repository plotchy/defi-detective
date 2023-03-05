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
		events: string[];
		functions: string[];
		most_similar_contracts: string[];
	}

	export type State = {
		apps: Record<`${Network}/${Address}`, App>
	}


	import { readable } from 'svelte/store'

	const state = readable<State>(
		{
			apps: {},
		},
		set => {
			if(!globalThis.WebSocket) return

			const address = 'ws://localhost:9002'

			let state: State = {
				apps: {},
			}

			console.info('Connecting...')

			const socket = new WebSocket(address)

			console.log({socket})

			socket.onopen = () => {
				console.info('Connected')
			}

			socket.onmessage = (event) => {
				console.log('event', event)
				const app = JSON.parse(event.data)
				state.apps = {...state.apps, [`${app.network}/${app.address}`]: app}
				console.log({state})
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
</script>


<slot state={$state} />
