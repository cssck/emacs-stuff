;;; denote-silo-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from denote-silo.el

(autoload 'denote-silo-create-note "denote-silo" "\
Select SILO and run `denote' in it.
SILO is a file path from `denote-silo-directories'.

When called from Lisp, SILO is a file system path to a directory that
conforms with `denote-silo-path-is-silo-p'.

(fn SILO)" t)
(autoload 'denote-silo-open-or-create "denote-silo" "\
Select SILO and run `denote-open-or-create' in it.
SILO is a file path from `denote-silo-directories'.

When called from Lisp, SILO is a file system path to a directory that
conforms with `denote-silo-path-is-silo-p'.

(fn SILO)" t)
(autoload 'denote-silo-select-silo-then-command "denote-silo" "\
Select SILO and run Denote COMMAND in it.
SILO is a file path from `denote-silo-directories', while
COMMAND is one among `denote-silo-commands'.

When called from Lisp, SILO is a file system path to a directory that
conforms with `denote-silo-path-is-silo-p'.

(fn SILO COMMAND)" t)
(autoload 'denote-silo-dired "denote-silo" "\
Switch to SILO directory using `dired'.
SILO is a file path from `denote-silo-directories'.

When called from Lisp, SILO is a file system path to a directory that
conforms with `denote-silo-path-is-silo-p'.

(fn SILO)" t)
(autoload 'denote-silo-cd "denote-silo" "\
Switch to SILO directory using `cd'.
SILO is a file path from `denote-silo-directories'.

When called from Lisp, SILO is a file system path to a directory that
conforms with `denote-silo-path-is-silo-p'.

(fn SILO)" t)
(register-definition-prefixes "denote-silo" '("denote-silo-"))

;;; End of scraped data

(provide 'denote-silo-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; denote-silo-autoloads.el ends here
