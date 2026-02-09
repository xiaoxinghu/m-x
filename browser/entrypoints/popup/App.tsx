import { createSignal, onMount, For, Show } from 'solid-js'
import { KeybindingRecorder } from '@/components/KeybindingRecorder'
import { getConfig, saveConfig, deleteAction } from '@/lib/storage'
import type { ActionItem, Keybinding } from '@/lib/types'
import './App.css'

function App() {
	const [actions, setActions] = createSignal<ActionItem[]>([])
	const [editingId, setEditingId] = createSignal<string | null>(null)

	// Form state
	const [name, setName] = createSignal('')
	const [elispCode, setElispCode] = createSignal('')
	const [keybinding, setKeybinding] = createSignal<Keybinding | null>(null)

	onMount(async () => {
		const config = await getConfig()
		setActions(config.actions)
	})

	const saveAction = async () => {
		const nameValue = name().trim()
		const codeValue = elispCode().trim()

		if (!nameValue || !codeValue) {
			alert('Name and Elisp code are required')
			return
		}

		const config = await getConfig()
		const id = editingId() || crypto.randomUUID()

		if (editingId()) {
			const index = config.actions.findIndex((a) => a.id === editingId())
			if (index !== -1) {
				config.actions[index] = {
					id,
					name: nameValue,
					elispCode: codeValue,
					keybinding: keybinding(),
				}
			}
		} else {
			config.actions.push({
				id,
				name: nameValue,
				elispCode: codeValue,
				keybinding: keybinding(),
			})
		}

		await saveConfig(config)
		setActions(config.actions)
		resetForm()
	}

	const editAction = (action: ActionItem) => {
		setEditingId(action.id)
		setName(action.name)
		setElispCode(action.elispCode)
		setKeybinding(action.keybinding)
	}

	const removeAction = async (id: string) => {
		await deleteAction(id)
		const config = await getConfig()
		setActions(config.actions)
	}

	const resetForm = () => {
		setEditingId(null)
		setName('')
		setElispCode('')
		setKeybinding(null)
	}

	return (
		<div
			style={{ padding: '20px', 'min-width': '500px', 'max-width': '600px' }}
		>
			<h1 style={{ 'margin-bottom': '20px', 'font-size': '24px' }}>
				Emacs Actions
			</h1>

			<div
				style={{
					'margin-bottom': '30px',
					padding: '15px',
					border: '1px solid #ddd',
					'border-radius': '8px',
				}}
			>
				<h2 style={{ 'margin-bottom': '15px', 'font-size': '18px' }}>
					{editingId() ? 'Edit Action' : 'Add New Action'}
				</h2>

				<div style={{ 'margin-bottom': '12px' }}>
					<label
						style={{
							display: 'block',
							'margin-bottom': '4px',
							'font-weight': 'bold',
						}}
					>
						Name:
					</label>
					<input
						type='text'
						value={name()}
						onInput={(e) => setName(e.currentTarget.value)}
						placeholder='e.g., Capture Note'
						style={{
							width: '100%',
							padding: '8px',
							'border-radius': '4px',
							border: '1px solid #ccc',
						}}
					/>
				</div>

				<div style={{ 'margin-bottom': '12px' }}>
					<label
						style={{
							display: 'block',
							'margin-bottom': '4px',
							'font-weight': 'bold',
						}}
					>
						Elisp Code:
					</label>
					<textarea
						value={elispCode()}
						onInput={(e) => setElispCode(e.currentTarget.value)}
						placeholder='e.g., (org-capture)'
						rows={3}
						style={{
							width: '100%',
							padding: '8px',
							'border-radius': '4px',
							border: '1px solid #ccc',
							'font-family': 'monospace',
						}}
					/>
				</div>

				<div style={{ 'margin-bottom': '15px' }}>
					<label
						style={{
							display: 'block',
							'margin-bottom': '4px',
							'font-weight': 'bold',
						}}
					>
						Keybinding:
					</label>
					<KeybindingRecorder
						keybinding={keybinding()}
						onChange={setKeybinding}
					/>
				</div>

				<div style={{ display: 'flex', gap: '8px' }}>
					<button
						onClick={saveAction}
						style={{
							padding: '10px 20px',
							'border-radius': '4px',
							border: 'none',
							background: '#646cff',
							color: 'white',
							cursor: 'pointer',
							'font-weight': 'bold',
						}}
					>
						{editingId() ? 'Update' : 'Add'} Action
					</button>
					<Show when={editingId()}>
						<button
							onClick={resetForm}
							style={{
								padding: '10px 20px',
								'border-radius': '4px',
								border: '1px solid #ccc',
								background: 'white',
								cursor: 'pointer',
							}}
						>
							Cancel
						</button>
					</Show>
				</div>
			</div>

			<div>
				<h2 style={{ 'margin-bottom': '15px', 'font-size': '18px' }}>
					Configured Actions
				</h2>
				<Show when={actions().length === 0}>
					<p style={{ color: '#888', 'font-style': 'italic' }}>
						No actions configured yet.
					</p>
				</Show>
				<For each={actions()}>
					{(action) => (
						<div
							style={{
								padding: '12px',
								border: '1px solid #ddd',
								'border-radius': '8px',
								'margin-bottom': '10px',
							}}
						>
							<div
								style={{
									display: 'flex',
									'justify-content': 'space-between',
									'align-items': 'start',
								}}
							>
								<div style={{ flex: 1 }}>
									<div
										style={{ 'font-weight': 'bold', 'margin-bottom': '4px' }}
									>
										{action.name}
									</div>
									<div
										style={{
											'font-family': 'monospace',
											'font-size': '12px',
											color: '#666',
											'margin-bottom': '4px',
										}}
									>
										{action.elispCode}
									</div>
									<Show when={action.keybinding}>
										<div style={{ 'font-size': '12px', color: '#888' }}>
											Keybinding:{' '}
											{[
												action.keybinding!.ctrl && 'Ctrl',
												action.keybinding!.alt && 'Alt',
												action.keybinding!.shift && 'Shift',
												action.keybinding!.meta && 'Meta',
												action.keybinding!.key.toUpperCase(),
											]
												.filter(Boolean)
												.join(' + ')}
										</div>
									</Show>
								</div>
								<div style={{ display: 'flex', gap: '8px' }}>
									<button
										onClick={() => editAction(action)}
										style={{
											padding: '6px 12px',
											'border-radius': '4px',
											border: '1px solid #ccc',
											background: 'white',
											cursor: 'pointer',
										}}
									>
										Edit
									</button>
									<button
										onClick={() => removeAction(action.id)}
										style={{
											padding: '6px 12px',
											'border-radius': '4px',
											border: '1px solid #ccc',
											background: '#ff4444',
											color: 'white',
											cursor: 'pointer',
										}}
									>
										Delete
									</button>
								</div>
							</div>
						</div>
					)}
				</For>
			</div>
		</div>
	)
}

export default App
