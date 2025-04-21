;;; my-abbrev.el --- Functions for use with abbrev-mode -*- lexical-binding: t -*-

;; Copyright (C) 2025-2025  Protesilaos Stavrou

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://protesilaos.com/emacs/dotemacs
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Functions for use with `abbrev-mode'.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(defgroup my-abbrev ()
  "Functions for use with `abbrev-mode'."
  :group 'editing)

(defcustom my-abbrev-time-specifier "%R"
  "Time specifier for `format-time-string'."
  :type 'string
  :group 'my-abbrev)

(defcustom my-abbrev-date-specifier "%F"
  "Date specifier for `format-time-string'."
  :type 'string
  :group 'my-abbrev)

(defun my-abbrev-current-time ()
  "Insert the current time per `my-abbrev-time-specifier'."
  (insert (format-time-string my-abbrev-time-specifier)))

(defun my-abbrev-current-date ()
  "Insert the current date per `my-abbrev-date-specifier'."
  (insert (format-time-string my-abbrev-date-specifier)))

(defun my-abbrev-jitsi-link ()
  "Insert a Jitsi link."
  (insert (concat "https://meet.jit.si/" (format-time-string "%Y%m%dT%H%M%S"))))

(defvar my-abbrev-update-html-history nil
  "Minibuffer history for `my-abbrev-update-html-prompt'.")

(defun my-abbrev-update-html-prompt ()
  "Minibuffer prompt for `my-abbrev-update-html'.
Use completion among previous entries, retrieving their data from
`my-abbrev-update-html-history'."
  (completing-read
   "Insert update for manual: "
   my-abbrev-update-html-history
   nil nil nil 'my-abbrev-update-html-history))

(defun my-abbrev-update-html ()
  "Insert message to update NAME.html page, by prompting for NAME."
  (insert (format "Update %s.html" (my-abbrev-update-html-prompt))))

(defvar my-abbrev-org-macro-key-history nil
  "Minibuffer history for `my-abbrev-org-macro-key-prompt'.")

(defun my-abbrev-org-macro-key-prompt ()
  "Minibuffer prompt for `my-abbrev-org-macro-key'.
Use completion among previous entries, retrieving their data from
`my-abbrev-org-macro-key-history'."
  (completing-read
   "Key binding: "
   my-abbrev-org-macro-key-history
   nil nil nil 'my-abbrev-org-macro-key-history))

(defvar my-abbrev-org-macro-key-symbol-history nil
  "Minibuffer history for `my-abbrev-org-macro-key-symbol-prompt'.")

(defun my-abbrev-org-macro-key-symbol-prompt ()
  "Minibuffer prompt for `my-abbrev-org-macro-key'.
Use completion among previous entries, retrieving their data from
`my-abbrev-org-macro-key-symbol-history'."
  (completing-read
   "Command name: "
   my-abbrev-org-macro-key-symbol-history
   nil nil nil 'my-abbrev-org-macro-key-symbol-history))

(defun my-abbrev-org-macro-key-command ()
  "Insert {{{kbd(KEY)}}} (~SYMBOL~) by prompting for KEY and SYMBOL."
  (insert (format "{{{kbd(%s)}}} (~%s~)"
                  (my-abbrev-org-macro-key-prompt)
                  (my-abbrev-org-macro-key-symbol-prompt))))

(defun my-abbrev-org-macro-key ()
  "Insert {{{kbd(KEY)}}} by prompting for KEY."
  (insert (format "{{{kbd(%s)}}}" (my-abbrev-org-macro-key-prompt))))

(provide 'my-abbrev)
;;; my-abbrev.el ends here
