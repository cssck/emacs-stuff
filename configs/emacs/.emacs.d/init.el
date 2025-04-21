  (defvar use-exwm nil)

  (when use-exwm (load "~/.exwm.el"))

;; For those who use my dotfiles and need an easy way to write their
;; own extras on top of what I already load: search below for the files
;; my-emacs-pre-custom.el and my-emacs-post-custom.el
(defgroup my-emacs nil
  "User options for my dotemacs.
These produce the expected results only when set in a file called
my-emacs-pre-custom.el.  This file must be in the same
directory as the init.el."
  :group 'file)

(defcustom my-emacs-load-theme-family 'modus
  "Set of themes to load.
Valid values are the symbols `ef', `modus', and `standard', which
reference the `ef-themes', `modus-themes', and `standard-themes',
respectively.

A nil value does not load any of the above (use Emacs without a
theme).

This user option must be set in the `my-emacs-pre-custom.el'
file.  If that file exists in the Emacs directory, it is loaded
before all other modules of my setup."
  :group 'my-emacs
  :type '(choice :tag "Set of themes to load" :value modus
                 (const :tag "The `ef-themes' module" ef)
                 (const :tag "The `modus-themes' module" modus)
                 (const :tag "The `standard-themes' module" standard)
                 (const :tag "Do not load a theme module" nil)))

(defcustom my-emacs-completion-ui 'vertico
  "Choose minibuffer completion UI between `mct' or `vertico'.
If the value is nil, the default completion user interface is
used.  On Emacs 30, this is close the experience with `mct'.

This user option must be set in the `my-emacs-pre-custom.el'
file.  If that file exists in the Emacs directory, it is loaded
before all other modules of my setup."
  :group 'my-emacs
  :type '(choice :tag "Minibuffer user interface"
                 (const :tag "Default user interface" nil)
                 (const :tag "The `mct' module" mct)
                 (const :tag "The `vertico' module" vertico)))

(defcustom my-emacs-completion-extras t
  "When non-nil load extras for minibuffer completion.
These include packages such as `consult' and `embark'."
  :group 'my-emacs
  :type 'boolean)

(defcustom my-emacs-treesitter-extras t
  "When non-nil load extras for tree-sitter integration
These include packages such as `expreg' and generally anything
that adds functionality on top of what the major mode provides."
  :group 'my-emacs
  :type 'boolean)

(defcustom my-emacs-load-which-key t
  "When non-nil, display key binding hints after a short delay.
This user option must be set in the `my-emacs-pre-custom.el'
file.  If that file exists in the Emacs directory, it is loaded
before all other modules of my setup."
  :group 'my-emacs
  :type 'boolean)

(defcustom my-emacs-load-icons t
  "When non-nil, enable iconography in various contexts.
This installs and uses the `nerd-icons' package and its variants.
NOTE that you still need to invoke `nerd-icons-install-fonts'
manually to first get the icon files.

This user option must be set in the `my-emacs-pre-custom.el'
file.  If that file exists in the Emacs directory, it is loaded
before all other modules of my setup."
  :group 'my-emacs
  :type 'boolean)

(setq make-backup-files nil)
(setq backup-inhibited nil) ; Not sure if needed, given `make-backup-files'
(setq create-lockfiles nil)

;; Make native compilation silent and prune its cache.
(when (native-comp-available-p)
  (setq native-comp-async-report-warnings-errors 'silent) ; Emacs 28 with native compilation
  (setq native-compile-prune-cache t)) ; Emacs 29

;; Disable the damn thing by making it disposable.
(setq custom-file (make-temp-file "emacs-custom-"))

(setq default-input-method "ukrainian-computer")
(setq default-transient-input-method "ukrainian-computer")

(with-eval-after-load "quail"
  (push
   (cons "dvorak"
         (concat
          "                              "
          "`~1!2@3#4$5%6^7&8*9(0)[{]}    "   ; numbers
          "  '\",<.>pPyYfFgGcCrRlL/?=+\\|  " ; qwerty
          "  aAoOeEuUiIdDhHtTnNsS-_      "   ; asdf
          "  ;:qQjJkKxXbBmMwWvVzZ        "   ; zxcv
          "                              "))
   quail-keyboard-layout-alist)

  (quail-set-keyboard-layout "dvorak"))

;; Enable these
(mapc
 (lambda (command)
   (put command 'disabled nil))
 '(list-timers narrow-to-region narrow-to-page upcase-region downcase-region))

;; And disable these
(mapc
 (lambda (command)
   (put command 'disabled t))
 '(overwrite-mode iconify-frame diary))

(setq initial-buffer-choice t)
(setq initial-major-mode 'lisp-interaction-mode)
(setq initial-scratch-message
      (format ";; This is `%s'.  Use `%s' to evaluate and print results.\n\n"
              'lisp-interaction-mode
              (propertize
               (substitute-command-keys "\\<lisp-interaction-mode-map>\\[eval-print-last-sexp]")
               'face 'help-key-binding)))

(mapc
 (lambda (string)
   (add-to-list 'load-path (locate-user-emacs-file string)))
 '("my-lisp" "my-emacs-modules"))

;;;; Packages

(setq package-vc-register-as-project nil) ; Emacs 30

(add-hook 'package-menu-mode-hook #'hl-line-mode)

;; Also read: <https://protesilaos.com/codelog/2022-05-13-emacs-elpa-devel/>
(setq package-archives
      '(("gnu-elpa" . "https://elpa.gnu.org/packages/")
        ("gnu-elpa-devel" . "https://elpa.gnu.org/devel/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

;; Highest number gets priority (what is not mentioned has priority 0)
(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

;; NOTE 2023-08-21: I build Emacs from source, so I always get the
;; latest version of built-in packages.  However, this is a good
;; solution to set to non-nil if I ever switch to a stable release.
(setq package-install-upgrade-built-in nil)

(defvar my-emacs-my-packages
  '(agitate
    altcaps
    beframe
    consult-denote
    cursory
    denote
    denote-journal
    denote-markdown
    denote-org
    denote-silo
    denote-sequence
    dired-preview
    ef-themes
    fontaine
    lin
    logos
    mct
    modus-themes
    notmuch-indicator
    pulsar
    show-font
    spacious-padding
    standard-themes
    substitute
    sxhkdrc-mode
    theme-buffet
    tmr)
  "List of symbols representing the packages I develop/maintain.")

;; Also read: <https://protesilaos.com/codelog/2022-05-13-emacs-elpa-devel/>
(setq package-pinned-packages
      `(,@(mapcar
           (lambda (package)
             (cons package "gnu-elpa-devel"))
           my-emacs-my-packages)))

(use-package compile-angel
  :ensure t
  :demand t
  :config
  ;; Set `compile-angel-verbose' to nil to disable compile-angel messages.
  ;; (When set to nil, compile-angel won't show which file is being compiled.)
  (setq compile-angel-verbose nil)

  (push "init.el" copmile-angel-excluded-files)
  (push "early-init.el" compile-angel-excluded-files)

  ;; Uncomment the line below to compile automatically when an Elisp file is saved
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files before they are loaded
  ;; using `load' or `require'.
  (compile-angel-on-load-mode))

;; Ensure that quitting only occurs once Emacs finishes native compiling,
;; preventing incomplete or leftover compilation files in `/tmp`.
(setq native-comp-async-query-on-exit t)
(setq confirm-kill-processes t)

;; Non-nil means to native compile packages as part of their installation.
(setq package-native-compile t)

(setq custom-safe-themes t)

(defmacro my-emacs-comment (&rest body)
  "Determine what to do with BODY.

If BODY contains an unquoted plist of the form (:eval t) then
return BODY inside a `progn'.

Otherwise, do nothing with BODY and return nil, with no side
effects."
  (declare (indent defun))
  (let ((eval))
    (dolist (element body)
      (when-let* (((plistp element))
                  (key (car element))
                  ((eq key :eval))
                  (val (cadr element)))
        (setq eval val
              body (delq element body))))
    (when eval `(progn ,@body))))

;; Sample use of `my-emacs-comment'.  The function
;; `my-emacs-insert-comment-macro' is never evaluated.
(my-emacs-comment
  (defun my-emacs-insert-comment-macro (beg end)
    "Wrap region between BEG and END in `my-emacs-comment'."
    (interactive "r")
    (if (region-active-p)
        (let ((text (buffer-substring beg end)))
          (delete-region beg end)
          (insert (format "(my-emacs-comment\n%s)" text))
          (indent-region beg end))
      (user-error "No active region; will not insert `my-emacs-comment' here"))))

(defmacro my-emacs-keybind (keymap &rest definitions)
  "Expand key binding DEFINITIONS for the given KEYMAP.
DEFINITIONS is a sequence of string and command pairs."
  (declare (indent 1))
  (unless (zerop (% (length definitions) 2))
    (error "Uneven number of key+command pairs"))
  (let ((keys (seq-filter #'stringp definitions))
        ;; We do accept nil as a definition: it unsets the given key.
        (commands (seq-remove #'stringp definitions)))
    `(when-let* (((keymapp ,keymap))
                 (map ,keymap))
       ,@(mapcar
          (lambda (pair)
            (let* ((key (car pair))
                   (command (cdr pair)))
              (unless (and (null key) (null command))
                `(define-key map (kbd ,key) ,command))))
          (cl-mapcar #'cons keys commands)))))

;; Sample of `my-emacs-keybind'

;; (my-emacs-keybind global-map
;;   "C-z" nil
;;   "C-x b" #'switch-to-buffer
;;   "C-x C-c" nil
;; ;; Notice the -map as I am binding keymap here, not a command:
;;   "C-c b" beframe-prefix-map
;;   "C-x k" #'kill-buffer)

(defmacro my-emacs-abbrev (table &rest definitions)
  "Expand abbrev DEFINITIONS for the given TABLE.
DEFINITIONS is a sequence of (i) string pairs mapping the
abbreviation to its expansion or (ii) a string and symbol pair
making an abbreviation to a function."
  (declare (indent 1))
  (unless (zerop (% (length definitions) 2))
    (error "Uneven number of key+command pairs"))
  `(if (abbrev-table-p ,table)
       (progn
         ,@(mapcar
            (lambda (pair)
              (let ((abbrev (nth 0 pair))
                    (expansion (nth 1 pair)))
                (if (stringp expansion)
                    `(define-abbrev ,table ,abbrev ,expansion)
                  `(define-abbrev ,table ,abbrev "" ,expansion))))
            (seq-split definitions 2)))
     (error "%s is not an abbrev table" ,table)))

(defvar my-emacs-package-form-regexp
  "^(\\(my-emacs-keybind\\|my-emacs-abbrev\\) +'?\\([0-9a-zA-Z-]+\\)"
  "Regexp to add packages to `lisp-imenu-generic-expression'.")

(eval-after-load 'lisp-mode
  `(add-to-list 'lisp-imenu-generic-expression
                (list "Packages" ,my-emacs-package-form-regexp 2)))

(defconst my-emacs-font-lock-keywords
  '(("(\\(my-emacs-\\(keybind\\|abbrev\\)\\)\\_>[ \t']*\\(\\(\\sw\\|\\s_\\)+\\)?"
     (3 font-lock-variable-name-face nil t))
    ("(\\(my-emacs-comment\\)\\_>[ \t']*"
     (1 font-lock-preprocessor-face nil t))))

(font-lock-add-keywords 'emacs-lisp-mode my-emacs-font-lock-keywords)

  ;; For those who use my dotfiles and need an easy way to write their
  ;; own extras on top of what I already load.  The file must exist at
  ;; ~/.emacs.d/my-emacs-pre-custom.el
  ;;
  ;; The purpose of this file is for the user to define their
  ;; preferences BEFORE loading any of the modules.
  (load (locate-user-emacs-file "my-emacs-pre-custom.el") :no-error :no-message)

  (require 'my-emacs-theme)
  (require 'my-emacs-essentials)
  (require 'my-emacs-modeline)
  (require 'my-emacs-completion)
  (require 'my-emacs-search)
  (require 'my-emacs-dired)
  (require 'my-emacs-window)
  (require 'my-emacs-git)
  (require 'my-emacs-org)
  (require 'my-emacs-langs)
  (require 'my-emacs-email)
  (require 'my-emacs-web)
  (when my-emacs-load-which-key
    (require 'my-emacs-which-key))
  (when my-emacs-load-icons
    (require 'my-emacs-icons))
  (require 'my-emacs-pdf)
  (require 'my-emacs-gptel)
  (require 'my-functions)  

  ;; For those who use my dotfiles and need an easy way to write their
  ;; own extras on top of what I already load.  The file must exist at
  ;; ~/.emacs.d/my-emacs-post-custom.el
  ;;
  ;; The purpose of the "post customisations" is to make tweaks to what
  ;; I already define, such as to change the default theme.  See above
  ;; for the `my-emacs-pre-custom.el' to make changes BEFORE loading
  ;; any of my other configurations.
  (load (locate-user-emacs-file "my-emacs-post-custom.el") :no-error :no-message)
