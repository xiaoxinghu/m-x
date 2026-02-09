export interface ActionItem {
  id: string;
  name: string;
  elispCode: string;
  keybinding: Keybinding | null;
}

export interface Keybinding {
  ctrl: boolean;
  alt: boolean;
  shift: boolean;
  meta: boolean;
  key: string;
}

export interface StoredConfig {
  actions: ActionItem[];
}
