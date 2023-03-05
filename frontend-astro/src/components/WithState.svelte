<script context="module" lang="ts">
	import { readable } from 'svelte/store'

	type State = {
		items: Item[]
	}

	type Item = {
		
	}

	const state = readable<State>(
		{
			items: [],
		},
		set => {
			if(!globalThis.WebSocket) return

			const address = 'ws://10.0.0.91:9002'

			let state: State = {
				items: [],
			}

			console.log('Connecting...')

			const socket = new WebSocket(address)

			socket.onopen = () => {
				console.log('Connected')
			}

			socket.onmessage = (event) => {
				console.log('event', event)
				state.items = [...state.items, JSON.parse(event.data)]
				set(state)
			}

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


<slot {state} />
