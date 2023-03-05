<script lang="ts">
	export let leftText = ''
	export let rightText = ''

	import * as monaco from 'monaco-editor'

	let container: HTMLElement
	let diffEditor: monaco.editor.IStandaloneDiffEditor
	let leftTextModel: monaco.editor.ITextModel
	let rightTextModel: monaco.editor.ITextModel
	let diffNavigator: monaco.editor.IDiffNavigator

	$: if(container)
		diffEditor ??= monaco.editor.createDiffEditor(container)

	$: if(leftText)
		if(!leftTextModel)
			leftTextModel = monaco.editor.createModel(
				leftText,
				"text/plain"
			)
		else
			leftTextModel.setValue(leftText)

	$: if(rightText)
		if(!rightTextModel)
			rightTextModel = monaco.editor.createModel(
				rightText,
				"text/plain"
			)
		else
			rightTextModel.setValue(rightText)
	
	$: if(diffEditor && leftTextModel && rightTextModel)
		diffEditor.setModel({
			original: leftTextModel,
			modified: rightTextModel,
		})

	$: if(diffEditor)
		diffNavigator = monaco.editor.createDiffNavigator(diffEditor, {
			followsCaret: true, // resets the navigator state when the user selects something in the editor
			ignoreCharChanges: true, // jump from line to line
		})
</script>


<div id="container" bind:this={container} />


<style>
	#container {
		height: 30rem;
		border-radius: 0.33rem;
		overflow: hidden;
	}
</style>
