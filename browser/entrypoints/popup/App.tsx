import { For, Show, createEffect, createMemo, createSignal, onMount } from 'solid-js'
import { getConfig } from '@/lib/storage'
import { invokeEmacsAction } from '@/lib/invoke'
import type { ActionItem } from '@/lib/types'

function App() {
	const [actions, setActions] = createSignal<ActionItem[]>([])
	const [query, setQuery] = createSignal('')
	const [selectedIndex, setSelectedIndex] = createSignal(0)
	const [isRunning, setIsRunning] = createSignal(false)
	const [errorMessage, setErrorMessage] = createSignal<string | null>(null)
	let searchInputRef: HTMLInputElement | undefined

	onMount(async () => {
		const config = await getConfig()
		setActions(config.actions)
		searchInputRef?.focus()
	})

	const filteredActions = createMemo(() => {
		const term = query().trim().toLowerCase()
		if (!term) return actions()
		return actions().filter((action) => {
			return (
				action.name.toLowerCase().includes(term) ||
				action.elispCode.toLowerCase().includes(term)
			)
		})
	})

	createEffect(() => {
		const list = filteredActions()
		const current = selectedIndex()
		if (list.length === 0) {
			setSelectedIndex(0)
			return
		}
		if (current >= list.length) {
			setSelectedIndex(list.length - 1)
		}
	})

	const runAction = async (action: ActionItem | undefined) => {
		if (!action || isRunning()) return

		setIsRunning(true)
		setErrorMessage(null)
		try {
			await invokeEmacsAction(action.elispCode)
			window.close()
		} catch (error) {
			console.error('Failed to invoke Emacs action:', error)
			setErrorMessage('Failed to invoke Emacs. Check protocol handler setup.')
		} finally {
			setIsRunning(false)
		}
	}

	const onKeyDown = async (event: KeyboardEvent) => {
		const list = filteredActions()

		if (event.key === 'ArrowDown') {
			event.preventDefault()
			if (list.length > 0) {
				setSelectedIndex((idx) => (idx + 1) % list.length)
			}
			return
		}

		if (event.key === 'ArrowUp') {
			event.preventDefault()
			if (list.length > 0) {
				setSelectedIndex((idx) => (idx - 1 + list.length) % list.length)
			}
			return
		}

		if (event.key === 'Enter') {
			event.preventDefault()
			await runAction(list[selectedIndex()])
			return
		}

		if (event.key === 'Escape') {
			window.close()
		}
	}

	return (
		<div
			class="w-[420px] bg-[radial-gradient(circle_at_top,#2f3f5e_0%,#121826_58%)] p-3 text-[#f2f5fb] [font-family:'Inter_Tight','Avenir_Next','Segoe_UI',sans-serif]"
			onKeyDown={onKeyDown}
		>
			<div class='overflow-hidden rounded-[14px] border border-[#33435f] bg-[rgba(14,20,33,0.95)] shadow-[0_16px_40px_rgba(4,8,18,0.45)]'>
				<input
					ref={searchInputRef}
					class='w-full border-0 border-b border-[#33435f] bg-transparent px-4 py-[14px] text-sm text-[#f2f5fb] outline-none placeholder:text-[#90a1bf]'
					type='text'
					placeholder='Search Emacs action...'
					value={query()}
					onInput={(event) => {
						setQuery(event.currentTarget.value)
						setSelectedIndex(0)
					}}
				/>

				<div class='max-h-[280px] overflow-y-auto p-1.5' role='listbox' aria-label='Actions'>
					<Show
						when={filteredActions().length > 0}
						fallback={
							<div class='px-3 py-4 text-xs text-[#99a9c7]'>
								{actions().length === 0
									? 'No actions yet. Open extension options to add one.'
									: 'No actions match your search.'}
							</div>
						}
					>
						<For each={filteredActions()}>
							{(action, index) => (
								<button
									type='button'
									class="flex w-full cursor-pointer flex-col gap-[3px] rounded-[10px] border-0 bg-transparent px-3 py-2.5 text-left text-[#e7ecf6] hover:bg-[rgba(63,95,165,0.4)]"
									classList={{
										'bg-[linear-gradient(130deg,#3f5fa5_0%,#295179_100%)]': index() === selectedIndex(),
									}}
									onMouseEnter={() => setSelectedIndex(index())}
									onClick={() => runAction(action)}
								>
									<span class='text-[13px] font-semibold tracking-[0.01em]'>{action.name}</span>
									<span
										class="[font-family:'SF_Mono',Menlo,Monaco,Consolas,'Liberation_Mono',monospace] truncate whitespace-nowrap text-[11px] text-[#a6b5d3]"
										classList={{
											'text-[#dce8ff]': index() === selectedIndex(),
										}}
									>
										{action.elispCode}
									</span>
								</button>
							)}
						</For>
					</Show>
				</div>

				<div class='flex items-center gap-3 border-t border-[#33435f] px-3 pb-2.5 pt-2 text-[11px] text-[#90a1bf]'>
					<span>Up/Down: Navigate</span>
					<span>Enter: Run</span>
					<span>Esc: Close</span>
					<button
						type='button'
						class='ml-auto cursor-pointer border-0 bg-transparent p-0 text-[11px] text-[#c5d3ec] hover:underline'
						onClick={() => browser.runtime.openOptionsPage()}
					>
						Edit Actions
					</button>
				</div>
				<Show when={errorMessage()}>
					<div class='px-3 pb-3 pt-2 text-xs text-[#ffb6b3]'>{errorMessage()}</div>
				</Show>
			</div>
		</div>
	)
}

export default App
