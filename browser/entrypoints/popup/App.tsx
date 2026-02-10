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
			class="w-[420px] bg-[var(--ec-bg)] p-2 text-[var(--ec-text)] [font-family:'Iosevka','JetBrains_Mono','SF_Mono',Menlo,Monaco,Consolas,'Liberation_Mono',monospace]"
			onKeyDown={onKeyDown}
		>
			<div class='overflow-hidden rounded border border-[var(--ec-border)] bg-[var(--ec-surface)]'>
				<input
					ref={searchInputRef}
					class='w-full border-0 border-b border-[var(--ec-border)] bg-transparent px-3 py-2 text-[13px] text-[var(--ec-text)] outline-none placeholder:text-[var(--ec-text-subtle)]'
					type='text'
					placeholder='Search Emacs action...'
					value={query()}
					onInput={(event) => {
						setQuery(event.currentTarget.value)
						setSelectedIndex(0)
					}}
				/>

				<div class='max-h-[280px] overflow-y-auto p-1' role='listbox' aria-label='Actions'>
					<Show
						when={filteredActions().length > 0}
						fallback={
							<div class='px-3 py-4 text-xs text-[var(--ec-text-subtle)]'>
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
									class="flex w-full cursor-pointer flex-col gap-[2px] rounded border border-transparent bg-transparent px-2 py-2 text-left text-[var(--ec-text)] hover:border-[var(--ec-border)] hover:bg-[var(--ec-item-hover)]"
									classList={{
										'border-[var(--ec-border-strong)] bg-[var(--ec-item-active)] text-[var(--ec-text-strong)]':
											index() === selectedIndex(),
									}}
									onMouseEnter={() => setSelectedIndex(index())}
									onClick={() => runAction(action)}
								>
									<span class='text-[13px] font-medium'>{action.name}</span>
									<span
										class='truncate whitespace-nowrap text-[11px] text-[var(--ec-text-muted)]'
										classList={{
											'text-[var(--ec-text)]': index() === selectedIndex(),
										}}
									>
										{action.elispCode}
									</span>
								</button>
							)}
						</For>
					</Show>
				</div>

				<div class='flex items-center gap-3 border-t border-[var(--ec-border)] px-3 pb-2 pt-2 text-[11px] text-[var(--ec-text-subtle)]'>
					<span>Up/Down: Navigate</span>
					<span>Enter: Run</span>
					<span>Esc: Close</span>
					<button
						type='button'
						class='ml-auto cursor-pointer border-0 bg-transparent p-0 text-[11px] text-[var(--ec-link)] hover:underline'
						onClick={() => browser.runtime.openOptionsPage()}
					>
						Edit Actions
					</button>
				</div>
				<Show when={errorMessage()}>
					<div class='px-3 pb-3 pt-2 text-xs text-[var(--ec-danger)]'>{errorMessage()}</div>
				</Show>
			</div>
		</div>
	)
}

export default App
