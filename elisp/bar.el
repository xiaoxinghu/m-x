;;; bar.el --- Floating M-x frame -*- lexical-binding: t; -*-

(defun my/m-x--frame-p (&optional frame)
  "Return non-nil if FRAME is a my/m-x frame."
  (frame-parameter frame 'my-m-x-frame))

(defun my/m-x--centered-position (frame &optional base-frame)
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

(defun my/m-x--make-frame ()
  "Create and return a centered floating minibuffer-only frame for M-x."
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
                   (my-m-x-frame . t)))
         (frame (make-frame params)))
    (let* ((pos (my/m-x--centered-position frame (selected-frame))))
      (set-frame-position frame (car pos) (cdr pos)))
    frame))

;;;###autoload
(defun my/m-x ()
  "Open a floating frame and run `execute-extended-command'."
  (interactive)
  (let* ((frame (if (my/m-x--frame-p (selected-frame))
                    (selected-frame)
                  (my/m-x--make-frame))))
    (select-frame-set-input-focus frame)
    (with-selected-frame frame
      (unwind-protect
          (call-interactively #'execute-extended-command)
        (when (and (frame-live-p frame)
                   (my/m-x--frame-p frame))
          (delete-frame frame))))))

(provide 'bar)

;;; bar.el ends here
