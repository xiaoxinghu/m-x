import { For, Show, createEffect, createMemo, createSignal, onMount } from 'solid-js'
import { getConfig } from '@/lib/storage'
import { invokeEmacsAction } from '@/lib/invoke'
import type { ActionItem } from '@/lib/types'
import './App.css'

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
		<div class='palette-shell' onKeyDown={onKeyDown}>
			<div class='palette'>
				<input
					ref={searchInputRef}
					class='palette-search'
					type='text'
					placeholder='Search Emacs action...'
					value={query()}
					onInput={(event) => {
						setQuery(event.currentTarget.value)
						setSelectedIndex(0)
					}}
				/>

				<div class='palette-list' role='listbox' aria-label='Actions'>
					<Show
						when={filteredActions().length > 0}
						fallback={
							<div class='empty-state'>
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
									class='palette-item'
									classList={{ active: index() === selectedIndex() }}
									onMouseEnter={() => setSelectedIndex(index())}
									onClick={() => runAction(action)}
								>
									<span class='item-name'>{action.name}</span>
									<span class='item-code'>{action.elispCode}</span>
								</button>
							)}
						</For>
					</Show>
				</div>

				<div class='palette-footer'>
					<span>Up/Down: Navigate</span>
					<span>Enter: Run</span>
					<span>Esc: Close</span>
					<button
						type='button'
						class='options-link'
						onClick={() => browser.runtime.openOptionsPage()}
					>
						Edit Actions
					</button>
				</div>
				<Show when={errorMessage()}>
					<div class='error-message'>{errorMessage()}</div>
				</Show>
			</div>
		</div>
	)
}

export default App
