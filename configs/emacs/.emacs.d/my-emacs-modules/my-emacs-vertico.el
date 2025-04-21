;;; Vertical completion layout (vertico)
(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :config
  (setq vertico-scroll-margin 0)
  (setq vertico-count 5)
  (setq vertico-resize t)
  (setq vertico-cycle t)

  (with-eval-after-load 'rfn-eshadow
    ;; This works with `file-name-shadow-mode' enabled.  When you are in
    ;; a sub-directory and use, say, `find-file' to go to your home '~/'
    ;; or root '/' directory, Vertico will clear the old path to keep
    ;; only your current input.
    (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)))

;;; Custom tweaks for vertico (my-vertico.el)
(use-package my-vertico
  :ensure nil
  :demand t
  :after vertico
  :bind
  ( :map vertico-map
    ("<left>" . backward-char)
    ("<right>" . forward-char)
    ("TAB" . my-vertico-private-complete)
    ("DEL" . vertico-directory-delete-char)
    ("M-DEL" . vertico-directory-delete-word)
    ("M-," . vertico-quick-insert)
    ("M-." . vertico-quick-exit)
    :map vertico-multiform-map
    ("RET" . my-vertico-private-exit)
    ("<return>" . my-vertico-private-exit)
    ("C-n" . my-vertico-private-next)
    ("<down>" . my-vertico-private-next)
    ("C-p" . my-vertico-private-previous)
    ("<up>" . my-vertico-private-previous)
    ("C-l" . vertico-multiform-vertical))
  :config
  (setq vertico-multiform-commands
        `(("consult-\\(.*\\)?\\(find\\|grep\\|ripgrep\\)" ,@my-vertico-multiform-maximal)))
  (setq vertico-multiform-categories
        `(;; Maximal
          (embark-keybinding ,@my-vertico-multiform-maximal)
          (multi-category ,@my-vertico-multiform-maximal)
          (consult-location ,@my-vertico-multiform-maximal)
          (imenu ,@my-vertico-multiform-maximal)
          (unicode-name ,@my-vertico-multiform-maximal)
          ;; Minimal
          (file ,@my-vertico-multiform-minimal
                (vertico-sort-function . my-vertico-sort-directories-first))
          (t ,@my-vertico-multiform-minimal)))

  (vertico-multiform-mode 1))

(provide 'my-emacs-vertico)
