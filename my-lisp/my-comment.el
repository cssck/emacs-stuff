;;; my-comment.el --- Extensions newcomment.el for my dotemacs -*- lexical-binding: t -*-

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
;;
;; This covers my newcomment.el extras, for use in my Emacs setup:
;; https://protesilaos.com/emacs/dotemacs.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(require 'newcomment)
(require 'my-common)

(defgroup my-comment ()
  "Extensions for newcomment.el."
  :group 'comment)

(defcustom my-comment-keywords
  '("TODO" "NOTE" "XXX" "REVIEW" "FIXME")
  "List of strings with keywords used by `my-comment-timestamp-keyword'."
  :type '(repeat string)
  :group 'my-comment)

(defcustom my-comment-timestamp-format-concise "%F"
  "Specifier for date in `my-comment-timestamp-keyword'.
Refer to the doc string of `format-time-string' for the available
options."
  :type 'string
  :group 'my-comment)

(defcustom my-comment-timestamp-format-verbose "%F %T %z"
  "Like `my-comment-timestamp-format-concise', but longer."
  :type 'string
  :group 'my-comment)

;;;###autoload
(defun my-comment (n)
  "Comment N lines, defaulting to the current one.
When the region is active, comment its lines instead."
  (interactive "p")
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line n)))

(make-obsolete 'my-comment-comment-dwim 'my-comment "2023-09-28")

(defvar my-comment--keyword-hist '()
  "Minibuffer history of `my-comment--keyword-prompt'.")

(defun my-comment--keyword-prompt (keywords)
  "Prompt for candidate among KEYWORDS (per `my-comment-timestamp-keyword')."
  (let ((def (car my-comment--keyword-hist)))
    (completing-read
     (format "Select keyword [%s]: " def)
     keywords nil nil nil 'my-comment--keyword-hist def)))

(defun my-comment--format-date (verbose)
  "Format date using `format-time-string'.
VERBOSE has the same meaning as `my-comment-timestamp-keyword'."
  (format-time-string
   (if verbose
       my-comment-timestamp-format-verbose
     my-comment-timestamp-format-concise)))

(defun my-comment--timestamp (keyword &optional verbose)
  "Format string using current time and KEYWORD.
VERBOSE has the same meaning as `my-comment-timestamp-keyword'."
  (format "%s %s: " keyword (my-comment--format-date verbose)))

(defun my-comment--format-comment (string)
  "Format comment STRING per `my-comment-timestamp-keyword'.
STRING is a combination of a keyword and a time stamp."
  (concat comment-start
          (make-string comment-add (string-to-char comment-start))
          comment-padding
          string
          comment-end))

(defun my-comment--maybe-newline ()
  "Call `newline' if current line is not empty.
Check `my-comment-timestamp-keyword' for the rationale."
  (unless (my-common-line-regexp-p 'empty 1)
    (save-excursion (newline))))

;;;###autoload
(defun my-comment-timestamp-keyword (keyword &optional verbose)
  "Add timestamped comment with KEYWORD.

When called interactively, the list of possible keywords is that
of `my-comment-keywords', though it is possible to input
arbitrary text.

If point is at the beginning of the line or if line is empty (no
characters at all or just indentation), the comment is started
there in accordance with `comment-style'.  Any existing text
after the point will be pushed to a new line and will not be
turned into a comment.

If point is anywhere else on the line and the line is not empty,
the comment is appended to the line with `comment-indent'.

The comment is always formatted as DELIMITER KEYWORD DATE:, with
the date format being controlled by the variable
`my-comment-timestamp-format-concise'.  DELIMITER is the value
of `comment-start', as defined by the current major mode.

With optional VERBOSE argument (such as a prefix argument), use
an alternative date format, as specified by
`my-comment-timestamp-format-verbose'."
  (interactive
   (list
    (my-comment--keyword-prompt my-comment-keywords)
    current-prefix-arg))
  (let ((string (my-comment--timestamp keyword verbose))
        (beg (point)))
    (cond
     ((my-common-line-regexp-p 'empty)
      (insert (my-comment--format-comment string)))
     ((eq beg (line-beginning-position))
      (insert (my-comment--format-comment string))
      (indent-region beg (point))
      (my-comment--maybe-newline))
     (t
      (comment-indent t)
      (insert (concat " " string))))))

(provide 'my-comment)
;;; my-comment.el ends here
