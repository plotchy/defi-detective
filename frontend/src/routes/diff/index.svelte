<script lang="ts">

import DiffEditor from '../../components/DiffEditor.svelte'

</script>

<DiffEditor
	client:visible
	leftText={`
		hello
		123
		world
	`}
	rightText={`
		hello
		456
		world
	`}
/>
