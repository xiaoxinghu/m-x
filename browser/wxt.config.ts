import { defineConfig } from 'wxt'

// See https://wxt.dev/api/config.html
export default defineConfig({
	webExt: {
		startUrls: [
			'https://brettterpstra.com/2026/01/07/markdown-fixup-an-opinionated-markdown-linter/',
		],
	},
	modules: ['@wxt-dev/module-solid'],
	manifest: {
		permissions: ['storage', 'tabs'],
		host_permissions: ['<all_urls>'],
		name: 'EmacsClient',
		description: 'Trigger Emacs actions from Chrome with custom keybindings',
	},
})
