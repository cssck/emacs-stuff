;;; my-scratch.el --- Scratch buffers for editable major mode of choice -*- lexical-binding: t -*-

;; Copyright (C) 2023-2025  Protesilaos Stavrou

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
;; Set up a scratch buffer for an editable major mode of choice.  The
;; idea is based on the `scratch.el' package by Ian Eure:
;; <https://github.com/ieure/scratch-el>.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(require 'my-common)

(defgroup my-scratch ()
  "Scratch buffers for editable major mode of choice."
  :group 'editing)

(defcustom my-scratch-default-mode 'text-mode
  "Default major mode for `my-scratch-scratch-buffer'."
  :type 'symbol
  :group 'my-scratch)

(defun my-scratch--scratch-list-modes ()
  "List known major modes."
  (let (symbols)
    (mapatoms
     (lambda (symbol)
       (when (and (functionp symbol)
                  (or (provided-mode-derived-p symbol 'text-mode)
                      (provided-mode-derived-p symbol 'prog-mode)))
         (push symbol symbols))))
    symbols))

(defun my-scratch--insert-comment ()
  "Insert comment for major mode, if appropriate.
Insert a comment if `comment-start' is non-nil and the buffer is
empty."
  (when (and (my-common-empty-buffer-p) comment-start)
    (insert (format "Scratch buffer for: %s\n\n" major-mode))
    (goto-char (point-min))
    (comment-region (line-beginning-position) (line-end-position))))

(defun my-scratch--prepare-buffer (region &optional mode)
  "Add contents to scratch buffer and name it accordingly.

REGION is added to the contents to the new buffer.

Use the current buffer's major mode by default.  With optional
MODE use that major mode instead."
  (let ((major (or mode major-mode)))
    (with-current-buffer (pop-to-buffer (format "*%s scratch*" major))
      (funcall major)
      (my-scratch--insert-comment)
      (goto-char (point-max))
      (unless (string-empty-p region)
        (when (my-common-line-regexp-p 'non-empty)
          (insert "\n\n"))
        (insert region)))))

(defvar my-scratch--major-mode-history nil
  "Minibuffer history of `my-scratch--major-mode-prompt'.")

(defun my-scratch--major-mode-prompt ()
  "Prompt for major mode and return the choice as a symbol."
  (intern
   (completing-read "Select major mode: "
                    (my-scratch--scratch-list-modes)
                    nil
                    :require-match
                    nil
                    'my-scratch--major-mode-history)))

(defun my-scratch--capture-region ()
  "Capture active region, else return empty string."
  (if (region-active-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    ""))

;;;###autoload
(defun my-scratch-buffer (&optional arg)
  "Produce a scratch buffer matching the current major mode.

With optional ARG as a prefix argument (\\[universal-argument]),
use `my-scratch-default-mode'.

With ARG as a double prefix argument, prompt for a major mode
with completion.  Candidates are derivatives of `text-mode' or
`prog-mode'.

If region is active, copy its contents to the new scratch
buffer.

Buffers are named as *MAJOR-MODE scratch*.  If one already exists
for the given MAJOR-MODE, any text is appended to it."
  (interactive "P")
  (let ((region (my-scratch--capture-region)))
    (pcase (prefix-numeric-value arg)
      (16 (my-scratch--prepare-buffer region (my-scratch--major-mode-prompt)))
      (4 (my-scratch--prepare-buffer region my-scratch-default-mode))
      (_ (my-scratch--prepare-buffer region)))))

(provide 'my-scratch)
;;; my-scratch.el ends here
