;;; popup.el --- Floating M-x frame -*- lexical-binding: t; -*-

(defun my/popup-command--frame-p (&optional frame)
  "Return non-nil if FRAME is a popup-command frame."
  (frame-parameter frame 'my-popup-command-frame))

(defun my/popup-command--centered-position (frame &optional base-frame)
  "Return cons of (LEFT . TOP) to center FRAME on BASE-FRAME's monitor."
  (let* ((attrs (frame-monitor-attributes (or base-frame (selected-frame))))
         (workarea (alist-get 'workarea attrs))
         (base-x (or (nth 0 workarea) 0))
         (base-y (or (nth 1 workarea) 0))
         (disp-w (or (nth 2 workarea) (display-pixel-width)))
         (disp-h (or (nth 3 workarea) (display-pixel-height)))
         (frame-w (frame-pixel-width frame))
         (frame-h (frame-pixel-height frame))
         (left (+ base-x (max 0 (/ (- disp-w frame-w) 2))))
         (top (+ base-y (max 0 (/ (- disp-h frame-h) 2)))))
    (cons left top)))

(defun my/popup-command--make-frame ()
  "Create and return a centered floating minibuffer-only frame."
  (let* ((params `((name . "my-m-x")
                   (minibuffer . only)
                   (width . 80)
                   (height . 5)
                   (undecorated . t)
                   (unsplittable . t)
                   (no-other-frame . t)
                   (skip-taskbar . t)
                   (menu-bar-lines . 0)
                   (tool-bar-lines . 0)
                   (vertical-scroll-bars . nil)
                   (horizontal-scroll-bars . nil)
                   (internal-border-width . 12)
                   (my-popup-command-frame . t)))
         (frame (make-frame params)))
    (let* ((pos (my/popup-command--centered-position frame (selected-frame))))
      (set-frame-position frame (car pos) (cdr pos)))
    frame))

(defun my/popup-command--call-with-frame (command)
  "Run COMMAND in a temporary centered minibuffer frame."
  (let* ((frame (if (my/popup-command--frame-p (selected-frame))
                    (selected-frame)
                  (my/popup-command--make-frame))))
    ;; Activate Emacs application first (critical for cross-monitor focus)
    (when (fboundp 'ns-do-applescript)
      (ns-do-applescript "tell application \"Emacs\" to activate"))
    ;; Raise frame and focus
    (raise-frame frame)
    (when (fboundp 'x-focus-frame)
      (x-focus-frame frame))
    (select-frame-set-input-focus frame)
    (select-window (minibuffer-window frame))
    ;; Defer command to next event loop - allows focus to settle without blocking
    (run-at-time 0 nil
      (lambda ()
        (when (frame-live-p frame)
          (select-window (minibuffer-window frame))
          (unwind-protect
              (call-interactively command)
            (when (and (frame-live-p frame)
                       (my/popup-command--frame-p frame))
              (delete-frame frame))))))))

;;;###autoload
(defun my/popup-command (&optional command)
  "Run COMMAND, showing a temporary popup frame if user input is likely.

When COMMAND is nil, defaults to `execute-extended-command'."
  (interactive)
  (let* ((cmd (or command #'execute-extended-command)))
    (unless (commandp cmd)
      (user-error "Not an interactive command: %S" cmd))
    (my/popup-command--call-with-frame cmd)))

;;;###autoload
(defalias 'my/m-x #'my/popup-command)

(provide 'popup)

;;; popup.el ends here
