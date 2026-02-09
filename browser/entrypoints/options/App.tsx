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
		<div class="mx-auto grid max-w-[900px] gap-5 bg-[#f7f9fc] px-5 pb-8 pt-7 text-[#0f172a] [font-family:'Inter_Tight','Avenir_Next','Segoe_UI',sans-serif]">
			<header class='flex items-start justify-between gap-4'>
				<div>
					<h1 class='mb-2 text-[28px] font-bold'>EmacsClient Actions</h1>
					<p class='text-slate-600'>Manage actions available in the command palette popup.</p>
				</div>
				<a
					class='self-center text-[13px] text-[#2155d6] no-underline hover:underline'
					href='chrome://extensions/shortcuts'
					target='_blank'
					rel='noreferrer'
				>
					Keyboard shortcut settings
				</a>
			</header>

			<section class='grid gap-3 rounded-xl border border-[#dbe3ef] bg-white p-[18px]'>
				<h2 class='text-lg font-semibold'>{editingId() ? 'Edit Action' : 'New Action'}</h2>
				<label class='grid gap-1.5'>
					<span class='text-[13px] font-semibold text-slate-700'>Name</span>
					<input
						class='w-full rounded-lg border border-[#c8d3e2] px-2.5 py-2.5'
						type='text'
						value={name()}
						onInput={(event) => setName(event.currentTarget.value)}
						placeholder='Capture Note'
					/>
				</label>
				<label class='grid gap-1.5'>
					<span class='text-[13px] font-semibold text-slate-700'>Elisp Code</span>
					<textarea
						class="w-full rounded-lg border border-[#c8d3e2] px-2.5 py-2.5 [font-family:'SF_Mono',Menlo,Monaco,Consolas,'Liberation_Mono',monospace]"
						rows={4}
						value={elispCode()}
						onInput={(event) => setElispCode(event.currentTarget.value)}
						placeholder='(org-capture)'
					/>
				</label>
				<div class='flex gap-2.5'>
					<button
						class='cursor-pointer rounded-lg border-0 bg-[#2155d6] px-3 py-2 font-semibold text-white'
						type='button'
						onClick={saveAction}
					>
						{editingId() ? 'Update Action' : 'Add Action'}
					</button>
					<Show when={editingId()}>
						<button
							class='cursor-pointer rounded-lg border-0 bg-[#e9eef7] px-3 py-2 font-semibold text-[#0f172a]'
							type='button'
							onClick={resetForm}
						>
							Cancel
						</button>
					</Show>
				</div>
			</section>

			<section class='grid gap-3 rounded-xl border border-[#dbe3ef] bg-white p-[18px]'>
				<h2 class='text-lg font-semibold'>Configured Actions</h2>
				<Show
					when={actions().length > 0}
					fallback={
						<p class='m-0 text-slate-500'>No actions configured yet. Add your first action.</p>
					}
				>
					<div class='grid gap-2.5'>
						<For each={actions()}>
							{(action) => (
								<div class='flex justify-between gap-3 rounded-[10px] border border-[#dbe3ef] p-3'>
									<div>
										<div class='font-bold'>{action.name}</div>
										<div class="mt-1 text-xs text-slate-500 [font-family:'SF_Mono',Menlo,Monaco,Consolas,'Liberation_Mono',monospace]">
											{action.elispCode}
										</div>
									</div>
									<div class='flex items-start gap-2'>
										<button
											class='cursor-pointer rounded-lg border-0 bg-[#e9eef7] px-3 py-2 font-semibold text-[#0f172a]'
											type='button'
											onClick={() => editAction(action)}
										>
											Edit
										</button>
										<button
											class='cursor-pointer rounded-lg border-0 bg-[#cb2738] px-3 py-2 font-semibold text-white'
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
