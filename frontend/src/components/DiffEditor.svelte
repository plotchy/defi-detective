<script lang="ts">
	export let leftText = ''
	export let rightText = ''

	import * as monaco from 'monaco-editor'

	let container: HTMLElement

	$: if(container){console.log({container})
		const diffEditor = monaco.editor.createDiffEditor(container)

		diffEditor.setModel({
			original: monaco.editor.createModel(
				leftText,
				"text/plain"
			),
			modified: monaco.editor.createModel(
				rightText,
				"text/plain"
			),
		});

		const navi = monaco.editor.createDiffNavigator(diffEditor, {
			followsCaret: true, // resets the navigator state when the user selects something in the editor
			ignoreCharChanges: true, // jump from line to line
		})
	}
</script>


<div id="container" bind:this={container} />


<style>
	#container {
		height: 30rem;
	}
</style>
