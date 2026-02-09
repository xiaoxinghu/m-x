import { For, Show, createSignal, onMount } from 'solid-js'
import { deleteAction, getConfig, saveConfig } from '@/lib/storage'
import type { ActionItem } from '@/lib/types'
import './App.css'

function App() {
	const [actions, setActions] = createSignal<ActionItem[]>([])
	const [editingId, setEditingId] = createSignal<string | null>(null)
	const [name, setName] = createSignal('')
	const [elispCode, setElispCode] = createSignal('')

	onMount(async () => {
		const config = await getConfig()
		setActions([...config.actions])
	})

	const resetForm = () => {
		setEditingId(null)
		setName('')
		setElispCode('')
	}

	const editAction = (action: ActionItem) => {
		setEditingId(action.id)
		setName(action.name)
		setElispCode(action.elispCode)
	}

	const removeAction = async (id: string) => {
		await deleteAction(id)
		const config = await getConfig()
		setActions([...config.actions])
	}

	const saveAction = async () => {
		const nameValue = name().trim()
		const codeValue = elispCode().trim()
		if (!nameValue || !codeValue) {
			alert('Name and Elisp code are required.')
			return
		}

		const config = await getConfig()
		const id = editingId() || crypto.randomUUID()
		const index = config.actions.findIndex((a) => a.id === id)

		const nextAction: ActionItem = {
			id,
			name: nameValue,
			elispCode: codeValue,
		}

		if (index >= 0) {
			config.actions[index] = nextAction
		} else {
			config.actions.push(nextAction)
		}

		await saveConfig(config)
		setActions([...config.actions])
		resetForm()
	}

	return (
		<div class='page'>
			<header class='header'>
				<div>
					<h1>EmacsClient Actions</h1>
					<p>Manage actions available in the command palette popup.</p>
				</div>
				<a
					class='secondary-link'
					href='chrome://extensions/shortcuts'
					target='_blank'
					rel='noreferrer'
				>
					Keyboard shortcut settings
				</a>
			</header>

			<section class='panel'>
				<h2>{editingId() ? 'Edit Action' : 'New Action'}</h2>
				<label class='field'>
					<span>Name</span>
					<input
						type='text'
						value={name()}
						onInput={(event) => setName(event.currentTarget.value)}
						placeholder='Capture Note'
					/>
				</label>
				<label class='field'>
					<span>Elisp Code</span>
					<textarea
						rows={4}
						value={elispCode()}
						onInput={(event) => setElispCode(event.currentTarget.value)}
						placeholder='(org-capture)'
					/>
				</label>
				<div class='button-row'>
					<button class='primary' type='button' onClick={saveAction}>
						{editingId() ? 'Update Action' : 'Add Action'}
					</button>
					<Show when={editingId()}>
						<button class='secondary' type='button' onClick={resetForm}>
							Cancel
						</button>
					</Show>
				</div>
			</section>

			<section class='panel'>
				<h2>Configured Actions</h2>
				<Show
					when={actions().length > 0}
					fallback={
						<p class='empty'>No actions configured yet. Add your first action.</p>
					}
				>
					<div class='list'>
						<For each={actions()}>
							{(action) => (
								<div class='item'>
									<div class='item-content'>
										<div class='item-title'>{action.name}</div>
										<div class='item-code'>{action.elispCode}</div>
									</div>
									<div class='item-actions'>
										<button
											class='secondary'
											type='button'
											onClick={() => editAction(action)}
										>
											Edit
										</button>
										<button
											class='danger'
											type='button'
											onClick={() => removeAction(action.id)}
										>
											Delete
										</button>
									</div>
								</div>
							)}
						</For>
					</div>
				</Show>
			</section>
		</div>
	)
}

export default App
