;;; Mode line
(use-package my-modeline
  :ensure nil
  :config
  (setq mode-line-compact nil) ; Emacs 28
  (setq mode-line-right-align-edge 'right-margin) ; Emacs 30
  (setq-default mode-line-format
                '("%e"
                  my-modeline-kbd-macro
                  my-modeline-narrow
                  my-modeline-buffer-status
                  my-modeline-window-dedicated-status
                  my-modeline-input-method
                  "  "
                  my-modeline-buffer-identification
                  "  "
                  my-modeline-major-mode
                  my-modeline-process
                  "  "
                  my-modeline-vc-branch
                  "  "
                  my-modeline-eglot
                  "  "
                  my-modeline-flymake
                  "  "
                  mode-line-format-right-align ; Emacs 30
                  my-modeline-notmuch-indicator
                  "  "
                  my-modeline-misc-info))

  (with-eval-after-load 'spacious-padding
    (defun my/modeline-spacious-indicators ()
      "Set box attribute to `'my-modeline-indicator-button' if spacious-padding is enabled."
      (if (bound-and-true-p spacious-padding-mode)
          (set-face-attribute 'my-modeline-indicator-button nil :box t)
        (set-face-attribute 'my-modeline-indicator-button nil :box 'unspecified)))

    ;; Run it at startup and then afterwards whenever
    ;; `spacious-padding-mode' is toggled on/off.
    (my/modeline-spacious-indicators)

    (add-hook 'spacious-padding-mode-hook #'my/modeline-spacious-indicators)))

;;; Keycast mode
(use-package keycast
  :ensure t
  :after my-modeline
  :commands (keycast-mode-line-mode keycast-header-line-mode keycast-tab-bar-mode keycast-log-mode)
  :init
  (setq keycast-mode-line-format "%2s%k%c%R")
  (setq keycast-mode-line-insert-after 'my-modeline-vc-branch)
  (setq keycast-mode-line-window-predicate 'mode-line-window-selected-p)
  (setq keycast-mode-line-remove-tail-elements nil)
  :config
  (dolist (input '(self-insert-command org-self-insert-command))
    (add-to-list 'keycast-substitute-alist `(,input "." "Typing…")))

  (dolist (event '( mouse-event-p mouse-movement-p mwheel-scroll handle-select-window
                    mouse-set-point mouse-drag-region))
    (add-to-list 'keycast-substitute-alist `(,event nil))))

(provide 'my-emacs-modeline)
