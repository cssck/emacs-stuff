;;; Isearch, occur, grep, and extras (my-search.el)
(use-package isearch
  :ensure nil
  :demand t
  :config
  (setq search-whitespace-regexp ".*?" ; one `setq' here to make it obvious they are a bundle
        isearch-lax-whitespace t
        isearch-regexp-lax-whitespace nil))

(use-package isearch
  :ensure nil
  :demand t
  :config
  (setq search-highlight t)
  (setq isearch-lazy-highlight t)
  (setq lazy-highlight-initial-delay 0.5)
  (setq lazy-highlight-no-delay-length 4))

(use-package isearch
  :ensure nil
  :demand t
  :config
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format "(%s/%s) ")
  (setq lazy-count-suffix-format nil))

(use-package isearch
  :ensure nil
  :demand t
  :config
  (setq isearch-wrap-pause t) ; `no-ding' makes keyboard macros never quit
  (setq isearch-repeat-on-direction-change t))

(use-package isearch
  :ensure nil
  :demand t
  :config
  (setq list-matching-lines-jump-to-current-line nil) ; do not jump to current line in `*occur*' buffers
  (add-hook 'occur-mode-hook #'my-common-truncate-lines-silently) ; from `my-common.el'
  (add-hook 'occur-mode-hook #'hl-line-mode))

(use-package isearch
  :ensure nil
  :demand t
  :bind
  ( :map global-map
    ("C-." . isearch-forward-symbol-at-point) ; easier than M-s . // I also have `my-simple-mark-sexp' on C-,
    :map minibuffer-local-isearch-map
    ("M-/" . isearch-complete-edit)
    :map occur-mode-map
    ("t" . toggle-truncate-lines)
    :map isearch-mode-map
    ("C-g" . isearch-cancel) ; instead of `isearch-abort'
    ("M-/" . isearch-complete)))

(use-package my-search
  :ensure nil
  :bind
  ( :map global-map
    ("M-s M-%" . my-search-replace-markup) ; see `my-search-markup-replacements'
    ("M-s M-<" . my-search-isearch-beginning-of-buffer)
    ("M-s M->" . my-search-isearch-end-of-buffer)
    ("M-s g" . my-search-grep)
    ("M-s u" . my-search-occur-urls)
    ("M-s t" . my-search-occur-todo-keywords)
    ("M-s M-t" . my-search-grep-todo-keywords) ; With C-u it runs `my-search-git-grep-todo-keywords'
    ("M-s M-T" . my-search-git-grep-todo-keywords)
    ("M-s s" . my-search-outline)
    ("M-s M-o" . my-search-occur-outline)
    ("M-s M-u" . my-search-occur-browse-url)
    :map isearch-mode-map
    ("<up>" . my-search-isearch-repeat-backward)
    ("<down>" . my-search-isearch-repeat-forward)
    ("<backspace>" . my-search-isearch-abort-dwim)
    ("<C-return>" . my-search-isearch-other-end))
  :config
  (setq my-search-outline-regexp-alist
        '((emacs-lisp-mode . "^\\((\\|;;;+ \\)")
          (org-mode . "^\\(\\*+ +\\|#\\+[Tt][Ii][Tt][Ll][Ee]:\\)")
          (outline-mode . "^\\*+ +")
          (emacs-news-view-mode . "^\\*+ +")
          (conf-toml-mode . "^\\[")
          (markdown-mode . "^#+ +")))
  (setq my-search-todo-keywords
        (concat "TODO\\|FIXME\\|NOTE\\|REVIEW\\|XXX\\|KLUDGE"
                "\\|HACK\\|WARN\\|WARNING\\|DEPRECATED\\|BUG"))

  (with-eval-after-load 'pulsar
    (add-hook 'my-search-outline-hook #'pulsar-recenter-center)
    (add-hook 'my-search-outline-hook #'pulsar-reveal-entry)))

;;; grep and xref
(use-package re-builder
  :ensure nil
  :commands (re-builder regexp-builder)
  :config
  (setq reb-re-syntax 'read))

(use-package xref
  :ensure nil
  :commands (xref-find-definitions xref-go-back)
  :config
  ;; All those have been changed for Emacs 28
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read) ; for M-.
  (setq xref-show-xrefs-function #'xref-show-definitions-buffer) ; for grep and the like
  (setq xref-file-name-display 'project-relative))

(use-package grep
  :ensure nil
  :commands (grep lgrep rgrep)
  :config
  (setq grep-save-buffers nil)
  (setq grep-use-headings t) ; Emacs 30

  (let ((executable (or (executable-find "rg") "grep"))
        (rgp (string-match-p "rg" grep-program)))
    (setq grep-program executable)
    (setq grep-template
          (if rgp
              "/usr/bin/rg -nH --null -e <R> <F>"
            "/usr/bin/grep <X> <C> -nH --null -e <R> <F>"))
    (setq xref-search-program (if rgp 'ripgrep 'grep))))

;;; wgrep (writable grep)
;; See the `grep-edit-mode' for the new built-in feature.
(unless (>= emacs-major-version 31)
  (use-package wgrep
    :ensure t
    :after grep
    :bind
    ( :map grep-mode-map
      ("e" . wgrep-change-to-wgrep-mode)
      ("C-x C-q" . wgrep-change-to-wgrep-mode)
      ("C-c C-c" . wgrep-finish-edit))
    :config
    (setq wgrep-auto-save-buffer t)
    (setq wgrep-change-readonly-file t)))

(provide 'my-emacs-search)
