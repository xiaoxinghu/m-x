(defvar mx--context nil
  "Context plist injected by the M-x app.
Expected keys include :mouse-x and :mouse-y.")


(defun present--context-get (key &optional default)
  "Return KEY from `mx--context', or DEFAULT when missing."
  (if (listp mx--context)
      (or (plist-get mx--context key) default)
    default))

(defun present--mouse-position ()
  "Return mouse position as a cons cell (X . Y)."
  (let ((x (present--context-get :mouse-x))
        (y (present--context-get :mouse-y)))
    (if (and (numberp x) (numberp y))
        (cons x y)
      (mouse-absolute-pixel-position))))

(defun present--workarea-at-point (x y)
  "Return monitor workarea that contains point X,Y."
  (let ((target nil))
    (dolist (attrs (display-monitor-attributes-list))
      (let* ((geom (alist-get 'geometry attrs))
             (gx (nth 0 geom))
             (gy (nth 1 geom))
             (gw (nth 2 geom))
             (gh (nth 3 geom)))
        (when (and (<= gx x) (< x (+ gx gw))
                   (<= gy y) (< y (+ gy gh)))
          (setq target attrs))))
    (alist-get 'workarea (or target (car (display-monitor-attributes-list))))))

(defun present--position-frame (frame position)
  "Position FRAME on the monitor that contains the mouse cursor.
POSITION is one of the symbols: center, left-top, left-bottom,
right-top, right-bottom."
  (let* ((mouse (present--mouse-position))
         (workarea (present--workarea-at-point (car mouse) (cdr mouse)))
         (area-x (nth 0 workarea))
         (area-y (nth 1 workarea))
         (area-w (nth 2 workarea))
         (area-h (nth 3 workarea))
         (frame-w (frame-pixel-width frame))
         (frame-h (frame-pixel-height frame))
         (gap 20)
         (left (pcase position
                 ((or 'left-top 'left-bottom)
                  (+ area-x gap))
                 ((or 'right-top 'right-bottom)
                  (+ area-x (- area-w frame-w gap)))
                 (_
                  (+ area-x (max 0 (/ (- area-w frame-w) 2))))))
         (top  (pcase position
                 ((or 'left-top 'right-top)
                  (+ area-y gap))
                 ((or 'left-bottom 'right-bottom)
                  (+ area-y (- area-h frame-h gap)))
                 (_
                  (+ area-y (max 0 (/ (- area-h frame-h) 2)))))))
    (set-frame-position frame left top)))

(defmacro present (&rest body)
  "Create a buffer and eval BODY in a basic frame.
BODY may optionally begin with a position symbol controlling where the
frame appears on the monitor that contains the mouse cursor.  Valid
positions are: center (default), left-top, left-bottom, right-top,
right-bottom."
  (declare (indent 1) (debug t))
  (let* ((position (if (memq (car body)
                             '(center left-top left-bottom right-top right-bottom))
                       (prog1 (car body) (setq body (cdr body)))
                     'center)))
    `(let* ((buffer (get-buffer-create (generate-new-buffer-name "*present*")))
            (frame (make-frame '((auto-raise . t)
                                 (font . "Menlo 15")
                                 (height . 10)
                                 (width . 110)
                                 (internal-border-width . 20)
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
       (present--position-frame frame ',position)
       (letrec ((focus-watcher
                 (lambda ()
                   (when (and (frame-live-p frame)
                              (not (frame-focus-state frame)))
                     (remove-function after-focus-change-function focus-watcher)
                     (run-with-timer 0 nil
                       (lambda ()
                         (when (frame-live-p frame)
                           (with-selected-frame frame
                             (abort-recursive-edit)))))))))
         (add-function :after after-focus-change-function focus-watcher))
       (with-current-buffer buffer
         (condition-case nil
             (unwind-protect
                 ,@body
               (when (frame-live-p frame) (delete-frame frame))
               (when (buffer-live-p buffer) (kill-buffer buffer)))
           (quit
            (when (frame-live-p frame) (delete-frame frame))
            (when (buffer-live-p buffer) (kill-buffer buffer))))))))

(provide 'present)
