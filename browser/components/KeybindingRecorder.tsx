import { createSignal, Show } from 'solid-js';
import type { Keybinding } from '@/lib/types';

interface KeybindingRecorderProps {
  keybinding: Keybinding | null;
  onChange: (keybinding: Keybinding | null) => void;
}

function formatKeybinding(kb: Keybinding | null): string {
  if (!kb) return 'Click to record';
  const parts: string[] = [];
  if (kb.ctrl) parts.push('Ctrl');
  if (kb.alt) parts.push('Alt');
  if (kb.shift) parts.push('Shift');
  if (kb.meta) parts.push('Meta');
  if (kb.key) parts.push(kb.key.toUpperCase());
  return parts.join(' + ') || 'Click to record';
}

export function KeybindingRecorder(props: KeybindingRecorderProps) {
  const [isRecording, setIsRecording] = createSignal(false);

  const handleKeyDown = (e: KeyboardEvent) => {
    if (!isRecording()) return;

    e.preventDefault();
    e.stopPropagation();

    // Only accept letter keys, numbers, or function keys
    if (e.key.length === 1 || e.key.startsWith('F')) {
      const keybinding: Keybinding = {
        ctrl: e.ctrlKey,
        alt: e.altKey,
        shift: e.shiftKey,
        meta: e.metaKey,
        key: e.key,
      };

      props.onChange(keybinding);
      setIsRecording(false);
    }
  };

  const startRecording = () => {
    setIsRecording(true);
  };

  const clear = (e: MouseEvent) => {
    e.stopPropagation();
    props.onChange(null);
  };

  return (
    <div style={{ display: 'flex', gap: '8px', 'align-items': 'center' }}>
      <button
        onClick={startRecording}
        onKeyDown={handleKeyDown}
        style={{
          padding: '8px 12px',
          'border-radius': '4px',
          border: isRecording() ? '2px solid #646cff' : '1px solid #ccc',
          background: isRecording() ? '#f0f0ff' : 'white',
          cursor: 'pointer',
          'min-width': '150px',
          'text-align': 'left',
        }}
      >
        {isRecording() ? 'Press keys...' : formatKeybinding(props.keybinding)}
      </button>
      <Show when={props.keybinding}>
        <button
          onClick={clear}
          style={{
            padding: '8px 12px',
            'border-radius': '4px',
            border: '1px solid #ccc',
            background: 'white',
            cursor: 'pointer',
          }}
        >
          Clear
        </button>
      </Show>
    </div>
  );
}
