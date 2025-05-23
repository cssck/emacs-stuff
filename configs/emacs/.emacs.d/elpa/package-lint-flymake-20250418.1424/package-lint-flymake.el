;;; package-lint-flymake.el --- A package-lint Flymake backend  -*- lexical-binding: t; -*-

;; Copyright (C) 2018 J. Alexander Branham (alex DOT branham AT gmail DOT com)

;; Package-Requires: ((emacs "26.1") (package-lint "0.5"))
;; Package-Version: 20250418.1424
;; Package-Revision: 26b27201f127
;; Homepage: https://github.com/purcell/package-lint

;; This file is not part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 3, or (at your option) any later
;; version.

;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;; MA 02110-1301 USA.

;;; Commentary:

;; Flymake is the built-in Emacs package to support on-the-fly syntax
;; checking.  This library adds support for flymake to `package-lint'.
;; It requires Emacs 26.

;; Enable it by calling `package-lint-flymake-setup' from a
;; file-visiting buffer.  To enable in all `emacs-lisp-mode' buffers:
;;
;; (add-hook 'emacs-lisp-mode-hook #'package-lint-flymake-setup)

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'flymake)
(require 'package-lint)

(declare-function flymake-diag-region "flymake")
(declare-function flymake-make-diagnostic "flymake")

(defun package-lint-flymake (report-fn &rest _args)
  "A Flymake backend for `package-lint'.
Use `package-lint-flymake-setup' to add this to
`flymake-diagnostic-functions'.  Calls REPORT-FN directly."
  (if (package-lint-looks-like-a-package-p)
      (let ((collection (package-lint-buffer)))
        (cl-loop for (line col type message) in
                 collection
                 for (beg . end) = (flymake-diag-region (current-buffer) line col)
                 collect
                 (flymake-make-diagnostic
                  (current-buffer)
                  beg end
                  (if (eq type 'warning) :warning :error)
                  message)
                 into diags
                 finally (funcall report-fn diags)))
    (funcall report-fn nil)))

;;;###autoload
(defun package-lint-flymake-setup ()
  "Setup package-lint integration with Flymake."
  (interactive)
  (if (< emacs-major-version 26)
      (error "Package-lint-flymake requires Emacs 26 or later")
    (add-hook 'flymake-diagnostic-functions #'package-lint-flymake nil t)
    (flymake-mode)))


(provide 'package-lint-flymake)

;;; package-lint-flymake.el ends here
