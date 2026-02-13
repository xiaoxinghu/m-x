import { defineConfig } from 'wxt'
import tailwindcss from '@tailwindcss/vite'

// See https://wxt.dev/api/config.html
export default defineConfig({
	vite: () => ({
		plugins: [tailwindcss()],
	}),
	webExt: {
		startUrls: [
			'https://brettterpstra.com/2026/01/07/markdown-fixup-an-opinionated-markdown-linter/',
		],
	},
	modules: ['@wxt-dev/module-solid'],
	manifest: {
		permissions: ['storage', 'activeTab', 'scripting'],
		commands: {
			_execute_action: {
				suggested_key: {
					default: 'Ctrl+Shift+E',
					mac: 'Command+Shift+E',
				},
			},
		},
		name: 'M-x',
		description: 'Trigger Emacs actions from a popup command palette',
	},
})
