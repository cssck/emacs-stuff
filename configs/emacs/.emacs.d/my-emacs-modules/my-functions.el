  (defun my-kill-buffer-and-window ()
    "Kill the current buffer and delete the selected window."
    (interactive)
    (let ((window-to-delete (selected-window))
  	  (buffer-to-kill (current-buffer))
  	  (delete-window-hook (lambda () (ignore-errors (delete-window)))))
      (unwind-protect
  	  (progn
  	    (add-hook 'kill-buffer-hook delete-window-hook t t)
  	    (if (kill-buffer (current-buffer))
  		;; If `delete-window' failed before, we rerun it to regenerate
  		;; the error so it can be seen in the echo area.
  		(when (eq (selected-window) window-to-delete)
  		  (delete-window)))))))

  (defun new-vterm ()
    (interactive)
    (let ((current-prefix-arg '(4))) ;; emulate C-u
      (call-interactively 'vterm)))

  (defun dired-open-file ()
    "In Dired, open the file named on this line."
    (interactive)
    (let* ((file (dired-get-filename nil t)))
      (call-process "xdg-open" nil 0 nil file)))

  (defun insert-above-and-jump ()
    "Insert line above current line."
    (interactive)
    (beginning-of-line)
    (newline-and-indent)
    (forward-line -1)
    (indent-according-to-mode))

  (defun insert-line-below-and-jump ()
    "Insert line below current line."
    (interactive)
    (end-of-line)
    (newline-and-indent))

  (defun my-enlarge-window-horizontally ()
    "Enlarge window horizontally."
    (interactive)
    (enlarge-window-horizontally 4))

  (defun my-shrink-window-horizontally ()
    "Shrink window horizontally."
    (interactive)
    (shrink-window-horizontally 4))

  (defun my-erc-channel-search ()
    (interactive)
    (insert "/msg alis LIST **"))

(provide 'my-functions)
