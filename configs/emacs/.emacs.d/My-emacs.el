(use-package ibuffer-vc
  :ensure t
  :after ibuffer
  :config
  (define-key ibuffer-mode-map (kbd "/ V") 'ibuffer-vc-set-filter-groups-by-vc-root))

(setq ibuffer-formats
	   '((mark modified read-only " "
		   (name 60 60 :left :elide) ; change: 60s were originally 18s
		   " "
		   (size 9 -1 :right)
		   " "
		   (mode 16 16 :left :elide)
		   " " filename-and-process)
	     (mark " "
		   (name 16 -1)
		   " " filename)))

(info "(elisp) Buffer Display Action Alists")
