;;; my-elfeed.el --- Elfeed extensions for my dotemacs -*- lexical-binding: t -*-

;; Copyright (C) 2021-2025  Protesilaos Stavrou

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://protesilaos.com/emacs/dotemacs
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; NOTE 2022-06-08: This is old code.  There are things I would like to
;; improve.

;;
;; Extensions for Elfeed, intended for use in my Emacs setup:
;; https://protesilaos.com/emacs/dotemacs.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(eval-when-compile (require 'subr-x))
(require 'elfeed nil t)
(require 'url-util)
(require 'my-common)

(defgroup my-elfeed ()
  "Personal extensions for Elfeed."
  :group 'elfeed)

(defcustom my-elfeed-feeds-file (expand-file-name "~/feeds.el.gpg")
  "Path to file with `elfeed-feeds'."
  :type 'string
  :group 'my-elfeed)

(defcustom my-elfeed-archives-directory "~/org/feeds/"
  "Path to directory for storing Elfeed entries."
  :type 'string
  :group 'my-elfeed)

(defcustom my-elfeed-tag-faces nil
  "Add faces for certain tags.
The tags are: critical, important, personal."
  :type 'boolean
  :group 'my-elfeed)

(defcustom my-elfeed-search-tags '(critical important personal)
  "List of user-defined tags.
Used by `my-elfeed-toggle-tag'."
  :type 'list
  :group 'my-elfeed)

(defface my-elfeed-entry-critical '((t :inherit font-lock-warning-face))
  "Face for Elfeed entries tagged with `critical'.")

(defface my-elfeed-entry-important '((t :inherit font-lock-constant-face))
  "Face for Elfeed entries tagged with `important'.")

(defface my-elfeed-entry-personal '((t :inherit font-lock-variable-name-face))
  "Face for Elfeed entries tagged with `personal'.")

;;;; Utilities

;;;###autoload
(defun my-elfeed-load-feeds ()
  "Load file containing the `elfeed-feeds' list.
Add this to `elfeed-search-mode-hook'."
  (let ((feeds my-elfeed-feeds-file))
    (if (file-exists-p feeds)
        (load-file feeds)
      (user-error "Missing feeds' file"))))

(defvar elfeed-search-face-alist)

;;;###autoload
(defun my-elfeed-fontify-tags ()
  "Expand Elfeed faces if `my-elfeed-tag-faces' is non-nil."
  (if my-elfeed-tag-faces
      (setq elfeed-search-face-alist
            '((critical my-elfeed-entry-critical)
              (important my-elfeed-entry-important)
              (personal my-elfeed-entry-personal)
              (unread elfeed-search-unread-title-face)))
    (setq elfeed-search-face-alist
          '((unread elfeed-search-unread-title-face)))))

(defvar my-elfeed--tag-hist '()
  "History of inputs for `my-elfeed-toggle-tag'.")

(defun my-elfeed--character-prompt (tags)
  "Helper of `my-elfeed-toggle-tag' to read TAGS."
  (let ((def (car my-elfeed--tag-hist)))
    (completing-read
     (format "Toggle tag [%s]: " def)
     tags nil t nil 'my-elfeed--tag-hist def)))

(defvar elfeed-show-entry)
(declare-function elfeed-tagged-p "elfeed")
(declare-function elfeed-search-toggle-all "elfeed")
(declare-function elfeed-show-tag "elfeed")
(declare-function elfeed-show-untag "elfeed")

;;;###autoload
(defun my-elfeed-toggle-tag (tag)
  "Toggle TAG for the current item.

When the region is active in the `elfeed-search-mode' buffer, all
entries encompassed by it are affected.  Otherwise the item at
point is the target.  For `elfeed-show-mode', the current entry
is always the target.

The list of tags is provided by `my-elfeed-search-tags'."
  (interactive
   (list
    (intern
     (my-elfeed--character-prompt my-elfeed-search-tags))))
  (if (derived-mode-p 'elfeed-show-mode)
      (if (elfeed-tagged-p tag elfeed-show-entry)
          (elfeed-show-untag tag)
        (elfeed-show-tag tag))
    (elfeed-search-toggle-all tag)))

(defvar elfeed-show-truncate-long-urls)
(declare-function elfeed-entry-title "elfeed")
(declare-function elfeed-show-refresh "elfeed")

;;;; General commands

(defvar elfeed-search-filter-active)
(defvar elfeed-search-filter)
(declare-function elfeed-db-get-all-tags "elfeed")
(declare-function elfeed-search-update "elfeed")
(declare-function elfeed-search-clear-filter "elfeed")

(defun my-elfeed--format-tags (tags sign)
  "Prefix SIGN to each tag in TAGS."
  (mapcar (lambda (tag)
            (format "%s%s" sign tag))
          tags))

;;;###autoload
(defun my-elfeed-search-tag-filter ()
  "Filter Elfeed search buffer by tags using completion.

Completion accepts multiple inputs, delimited by `crm-separator'.
Arbitrary input is also possible, but you may have to exit the
minibuffer with something like `exit-minibuffer'."
  (interactive)
  (unwind-protect
      (elfeed-search-clear-filter)
    (let* ((elfeed-search-filter-active :live)
           (db-tags (elfeed-db-get-all-tags))
           (plus-tags (my-elfeed--format-tags db-tags "+"))
           (minus-tags (my-elfeed--format-tags db-tags "-"))
           (all-tags (delete-dups (append plus-tags minus-tags)))
           (tags (completing-read-multiple
                  "Apply one or more tags: "
                  all-tags #'my-common-crm-exclude-selected-p t))
           (input (string-join `(,elfeed-search-filter ,@tags) " ")))
      (setq elfeed-search-filter input))
    (elfeed-search-update :force)))

(provide 'my-elfeed)
;;; my-elfeed.el ends here
