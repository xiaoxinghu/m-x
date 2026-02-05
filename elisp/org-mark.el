;;; org-mark.el --- Search and open links captured in links.org  -*- lexical-binding: t -*-

(defvar my/links-org-file
  (expand-file-name "links.org" my/org-location)
  "Path to the org file containing captured links.")

(defun my/org-links--parse ()
  "Parse links.org and return an alist of (display-string . url)."
  (let ((entries '()))
    (with-temp-buffer
      (insert-file-contents my/links-org-file)
      (goto-char (point-min))
      (while (re-search-forward
              ;; Match level-1 headlines containing an org link [[url][description]]
              "^\\*+ .*\\[\\[\\([^]]+\\)\\]\\[\\([^]]+\\)\\]\\]"
              nil t)
        (let ((url  (match-string 1))
              (desc (match-string 2)))
          (push (cons desc url) entries))))
    (reverse entries)))

(defvar my/org-links--current-entries nil
  "Holds entries during completing-read for the annotator to access.")

(defun my/org-links--annotate (candidate)
  "Marginalia annotator for org-link category."
  (when-let ((url (cdr (assoc candidate my/org-links--current-entries))))
    (marginalia--fields
     (url :truncate 1.0 :face 'marginalia-documentation))))

(add-to-list 'marginalia-annotators
             '(org-link my/org-links--annotate))

(defun my/org-links-search ()
  "Search links captured in links.org via completing-read (works with Vertico)."
  (interactive)
  (let* ((entries (my/org-links--parse))
         (candidates (mapcar #'car entries))
         (table (lambda (str pred action)
                  (cond
                    ((eq action 'metadata)
                     '(metadata (category . org-link)))
                    ((and (consp action) (eq (car action) 'boundaries))
                     '(boundaries 0 . 0))
                    ((eq action t)
                     (all-completions str candidates pred))
                    ((null action)
                     (try-completion str candidates pred))))))
    (unwind-protect
      (progn
        (setq my/org-links--current-entries entries)
        (let ((chosen (substring-no-properties
                       (completing-read "Link: " table nil nil))))
          (if-let ((url (cdr (assoc chosen entries))))
              (browse-url url)
            (message "No link selected."))))
      (setq my/org-links--current-entries nil))))

(provide 'org-mark)
;;; org-mark.el ends here
