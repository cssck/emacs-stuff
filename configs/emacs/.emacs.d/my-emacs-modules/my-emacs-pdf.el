(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install)
  (setq pdf-view-resize-factor 1.1)
  (setq-default pdf-view-display-size 'fit-page))

(provide 'my-emacs-pdf)
