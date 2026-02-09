import { storage } from 'wxt/utils/storage'
import type { StoredConfig, ActionItem } from './types'

// Define storage item with WXT's storage API
const configStorage = storage.defineItem<StoredConfig>(
	'local:emacsClientConfig',
	{
		fallback: { actions: [] },
		version: 1,
	},
)

export async function getConfig(): Promise<StoredConfig> {
	return await configStorage.getValue()
}

export async function saveConfig(config: StoredConfig): Promise<void> {
	await configStorage.setValue(config)
}

export async function addAction(action: ActionItem): Promise<void> {
	const config = await getConfig()
	config.actions.push(action)
	await saveConfig(config)
}

export async function updateAction(
	id: string,
	updates: Partial<ActionItem>,
): Promise<void> {
	const config = await getConfig()
	const index = config.actions.findIndex((a) => a.id === id)
	if (index !== -1) {
		config.actions[index] = { ...config.actions[index], ...updates }
		await saveConfig(config)
	}
}

export async function deleteAction(id: string): Promise<void> {
	const config = await getConfig()
	config.actions = config.actions.filter((a) => a.id !== id)
	await saveConfig(config)
}

// Export the storage item for direct access if needed (e.g., for watching changes)
export { configStorage }
