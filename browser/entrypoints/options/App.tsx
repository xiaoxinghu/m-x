import { For, Show, createSignal, onMount } from 'solid-js'
import { deleteAction, getConfig, saveConfig } from '@/lib/storage'
import type { ActionItem } from '@/lib/types'

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
		<div class="mx-auto grid max-w-[900px] gap-4 bg-[var(--ec-bg)] px-5 pb-8 pt-7 text-[var(--ec-text)] [font-family:'Iosevka','JetBrains_Mono','SF_Mono',Menlo,Monaco,Consolas,'Liberation_Mono',monospace]">
			<header class='flex items-start justify-between gap-4'>
				<div>
					<h1 class='mb-2 text-2xl font-medium'>M-x Actions</h1>
					<p class='text-[var(--ec-text-muted)]'>
						Manage actions available in the command palette popup.
					</p>
				</div>
				<a
					class='self-center text-[13px] text-[var(--ec-link)] no-underline hover:underline'
					href='chrome://extensions/shortcuts'
					target='_blank'
					rel='noreferrer'
				>
					Keyboard shortcut settings
				</a>
			</header>

			<section class='grid gap-3 rounded border border-[var(--ec-border)] bg-[var(--ec-surface)] p-4'>
				<h2 class='text-lg font-medium'>{editingId() ? 'Edit Action' : 'New Action'}</h2>
				<label class='grid gap-1.5'>
					<span class='text-[13px] text-[var(--ec-text-muted)]'>Name</span>
					<input
						class='w-full rounded border border-[var(--ec-border)] bg-[var(--ec-panel)] px-2.5 py-2 text-[13px] text-[var(--ec-text)] outline-none placeholder:text-[var(--ec-text-subtle)]'
						type='text'
						value={name()}
						onInput={(event) => setName(event.currentTarget.value)}
						placeholder='Capture Note'
					/>
				</label>
				<label class='grid gap-1.5'>
					<span class='text-[13px] text-[var(--ec-text-muted)]'>Elisp Code</span>
					<textarea
						class='w-full rounded border border-[var(--ec-border)] bg-[var(--ec-panel)] px-2.5 py-2 text-[13px] text-[var(--ec-text)] outline-none placeholder:text-[var(--ec-text-subtle)]'
						rows={4}
						value={elispCode()}
						onInput={(event) => setElispCode(event.currentTarget.value)}
						placeholder='(org-capture)'
					/>
				</label>
				<div class='flex gap-2.5'>
					<button
						class='cursor-pointer rounded border border-[var(--ec-border-strong)] bg-[var(--ec-item-active)] px-3 py-2 text-[13px] text-[var(--ec-text-strong)]'
						type='button'
						onClick={saveAction}
					>
						{editingId() ? 'Update Action' : 'Add Action'}
					</button>
					<Show when={editingId()}>
						<button
							class='cursor-pointer rounded border border-[var(--ec-border)] bg-[var(--ec-panel)] px-3 py-2 text-[13px] text-[var(--ec-text)]'
							type='button'
							onClick={resetForm}
						>
							Cancel
						</button>
					</Show>
				</div>
			</section>

			<section class='grid gap-3 rounded border border-[var(--ec-border)] bg-[var(--ec-surface)] p-4'>
				<h2 class='text-lg font-medium'>Configured Actions</h2>
				<Show
					when={actions().length > 0}
					fallback={
						<p class='m-0 text-[var(--ec-text-muted)]'>
							No actions configured yet. Add your first action.
						</p>
					}
				>
					<div class='grid gap-2.5'>
						<For each={actions()}>
							{(action) => (
								<div class='flex justify-between gap-3 rounded border border-[var(--ec-border)] bg-[var(--ec-panel)] p-3'>
									<div>
										<div class='font-medium'>{action.name}</div>
										<div class='mt-1 text-xs text-[var(--ec-text-muted)]'>
											{action.elispCode}
										</div>
									</div>
									<div class='flex items-start gap-2'>
										<button
											class='cursor-pointer rounded border border-[var(--ec-border)] bg-[var(--ec-surface)] px-3 py-2 text-[13px] text-[var(--ec-text)]'
											type='button'
											onClick={() => editAction(action)}
										>
											Edit
										</button>
										<button
											class='cursor-pointer rounded border border-[var(--ec-danger-border)] bg-[var(--ec-danger-surface)] px-3 py-2 text-[13px] text-[var(--ec-danger)]'
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
