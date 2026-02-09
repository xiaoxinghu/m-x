import { getConfig } from '@/lib/storage'
import type { Keybinding } from '@/lib/types'

function keybindingsMatch(kb1: Keybinding, event: KeyboardEvent): boolean {
	return (
		kb1.ctrl === event.ctrlKey &&
		kb1.alt === event.altKey &&
		kb1.shift === event.shiftKey &&
		kb1.meta === event.metaKey &&
		kb1.key.toLowerCase() === event.key.toLowerCase()
	)
}

async function invokeEmacsAction(elispCode: string) {
	const encodedExpr = encodeURIComponent(elispCode)
	const url = `emacs://eval?expr=${encodedExpr}`

	// Get the active tab and send message to content script to open URL
	try {
		const [tab] = await browser.tabs.query({
			active: true,
			currentWindow: true,
		})
		if (tab.id) {
			await browser.tabs.sendMessage(tab.id, {
				type: 'openURL',
				url: url,
			})
		}
	} catch (error) {
		console.error('Failed to invoke Emacs action:', error)
	}
}

export default defineBackground(() => {
	console.log('EmacsClient background script started')

	// Listen for keyboard shortcuts from content scripts
	browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
		if (message.type === 'keypress') {
			handleKeypress(message.event).then((handled) => {
				sendResponse({ handled })
			})
			return true // Keep the message channel open for async response
		}
	})

	async function handleKeypress(event: any): Promise<boolean> {
		const config = await getConfig()

		for (const action of config.actions) {
			if (action.keybinding && keybindingsMatch(action.keybinding, event)) {
				console.log('Triggering action:', action.name)
				invokeEmacsAction(action.elispCode)
				return true // Indicate that the keypress was handled
			}
		}
		return false // Keypress was not handled
	}

	// Listen for storage changes to reload configuration
	browser.storage.onChanged.addListener((changes, areaName) => {
		if (areaName === 'local' && changes.emacsClientConfig) {
			console.log('Configuration updated')
		}
	})
})
