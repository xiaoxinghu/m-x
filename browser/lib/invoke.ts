export function getEmacsUrl(elispCode: string): string {
	const encodedExpr = encodeURIComponent(elispCode)
	return `emacs://eval?expr=${encodedExpr}`
}

export async function invokeEmacsAction(elispCode: string): Promise<void> {
	const url = getEmacsUrl(elispCode)
	const [tab] = await browser.tabs.query({ active: true, currentWindow: true })
	if (!tab?.id) {
		throw new Error('No active tab available for invocation')
	}

	await browser.scripting.executeScript({
		target: { tabId: tab.id },
		args: [url],
		func: (targetUrl: string) => {
			const anchor = document.createElement('a')
			anchor.href = targetUrl
			anchor.style.display = 'none'
			;(document.body || document.documentElement).appendChild(anchor)
			anchor.click()
			anchor.remove()
		},
	})
}
