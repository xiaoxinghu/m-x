(defmacro present (&rest body)
  "Create a buffer with BUFFER-NAME and eval BODY in a basic frame."
  (declare (indent 1) (debug t))
  `(let* ((buffer (get-buffer-create (generate-new-buffer-name "*present*")))
          (frame (make-frame '((auto-raise . t)
                               (font . "Menlo 15")
                               (top . 200)
                               (height . 10)
                               (width . 110)
                               (internal-border-width . 20)
                               (left . 0.33)
                               (left-fringe . 0)
                               (line-spacing . 3)
                               (menu-bar-lines . 0)
                               (minibuffer . only)
                               (right-fringe . 0)
                               (tool-bar-lines . 0)
                               (undecorated . t)
                               (unsplittable . t)
                               (vertical-scroll-bars . nil)))))
     (set-face-attribute 'ivy-current-match frame
                         :background "#2a2a2a"
                         :foreground 'unspecified)
     (select-frame frame)
     (select-frame-set-input-focus frame)
     (with-current-buffer buffer
       (condition-case nil
           (unwind-protect
               ,@body
             (delete-frame frame)
             (kill-buffer buffer))
         (quit (delete-frame frame)
               (kill-buffer buffer))))))
