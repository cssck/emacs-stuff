;;; The Modus themes

;; The themes are highly customisable.  Read the manual:
;; <https://protesilaos.com/emacs/modus-themes>.
(use-package modus-themes
  :ensure t
  :demand t
  :bind (("<f5>" . modus-themes-toggle)
         ("C-<f5>" . modus-themes-select)
         ("M-<f5>" . modus-themes-rotate))
  :config
  (setq modus-themes-custom-auto-reload nil
        modus-themes-to-toggle '(modus-operandi modus-vivendi)
        ;; modus-themes-to-toggle '(modus-operandi-tinted modus-vivendi-tinted)
        ;; modus-themes-to-toggle '(modus-operandi-deuteranopia modus-vivendi-deuteranopia)
        ;; modus-themes-to-toggle '(modus-operandi-tritanopia modus-vivendi-tritanopia)
        modus-themes-to-rotate modus-themes-items
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui t
        modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-completions '((t . (bold)))
        modus-themes-prompts '(bold)
        modus-themes-headings
        '((agenda-structure . (variable-pitch light 2.2))
          (agenda-date . (variable-pitch regular 1.3))
          (t . (regular 1.15))))

  ;; (setq modus-themes-common-palette-overrides
  ;;       '((cursor cyan-intense)
  ;;         (comment magenta-faint)
  ;;         (bg-paren-match bg-magenta-subtle)
  ;;         (fg-paren-match magenta)))
  (setq modus-themes-common-palette-overrides nil)

  (if (my-emacs-theme-environment-dark-p)
      (modus-themes-load-theme (cadr modus-themes-to-toggle))
    (modus-themes-load-theme (car modus-themes-to-toggle))))

(provide 'my-emacs-modus-themes)
