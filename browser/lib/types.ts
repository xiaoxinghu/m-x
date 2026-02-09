export interface ActionItem {
  id: string;
  name: string;
  elispCode: string;
}

export interface StoredConfig {
  actions: ActionItem[];
}
