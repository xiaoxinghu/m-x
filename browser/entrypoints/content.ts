export default defineContentScript({
	matches: ['<all_urls>'],
	main() {
		console.log('EmacsClient content script loaded')

		// Listen for keydown events to trigger actions
		document.addEventListener(
			'keydown',
			(event) => {
				// Only process if modifier keys are involved to avoid interfering with normal typing
				if (event.ctrlKey || event.altKey || event.metaKey) {
					// Send the keypress to the background script
					browser.runtime
						.sendMessage({
							type: 'keypress',
							event: {
								key: event.key,
								ctrlKey: event.ctrlKey,
								altKey: event.altKey,
								shiftKey: event.shiftKey,
								metaKey: event.metaKey,
							},
						})
						.then((response) => {
							// If the background script handled this, prevent default behavior
							if (response?.handled) {
								event.preventDefault()
								event.stopPropagation()
							}
						})
						.catch(() => {
							// Ignore errors (e.g., if background script isn't ready)
						})
				}
			},
			true,
		)

		// Listen for messages from background script to open URLs
		browser.runtime.onMessage.addListener((message) => {
			if (message.type === 'openURL') {
				openCustomURL(message.url)
			}
		})

		// Function to open custom URL schemes (like emacs://)
		function openCustomURL(url: string) {
			console.log('Opening custom URL:', url)

			// Create an invisible anchor element and click it
			// This properly triggers macOS URL handlers
			const anchor = document.createElement('a')
			anchor.href = url
			anchor.style.display = 'none'
			document.body.appendChild(anchor)
			anchor.click()

			// Clean up
			setTimeout(() => {
				document.body.removeChild(anchor)
			}, 100)
		}
	},
})
