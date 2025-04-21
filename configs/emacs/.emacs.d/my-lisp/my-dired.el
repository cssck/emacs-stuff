;;; my-dired.el --- Extensions to dired.el for my dotemacs -*- lexical-binding: t -*-

;; Copyright (C) 2020-2025  Protesilaos Stavrou

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
;; This covers my dired.el extensions, for use in my Emacs setup:
;; https://protesilaos.com/emacs/dotemacs.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(require 'my-common)
(require 'dired)
(require 'dired-aux)

(defgroup my-dired ()
  "Extensions for Dired."
  :group 'dired)

;;;; Flat Dired listing

(defvar my-dired-regexp-history nil
  "Minibuffer history of `my-dired-regexp-prompt'.")

(defun my-dired-regexp-prompt ()
  (let ((default (car my-dired-regexp-history)))
    (read-regexp
     (format-prompt "Files matching REGEXP" default)
     default 'my-dired-regexp-history)))

(defun my-dired--get-files (regexp)
  "Return files matching REGEXP, recursively from `default-directory'."
  (directory-files-recursively default-directory regexp nil))

;;;###autoload
(defun my-dired-search-flat-list (regexp)
  "Return a Dired buffer for files matching REGEXP.
Perform the search recursively from the current directory."
  (interactive (list (my-dired-regexp-prompt)))
  (if-let* ((files (my-dired--get-files regexp))
            (relative-paths (mapcar #'file-relative-name files)))
      (dired (cons (format "my-flat-dired for `%s'" regexp) relative-paths))
    (error "No files matching `%s'" regexp)))

;;;; General commands

;; NOTE 2023-06-27: This user option is quick-and-dirty.  I prefer not
;; to have an option at all and simply do the right thing based on
;; `dired-guess-shell-alist-user'.
(defcustom my-dired-always-external-regexp
  "\\(mkv\\|mp4\\|mp4\\|ogg\\|m4a\\|webm\\)"
  "Regular expression of file extensions to open externally.
The test is performed by `my-dired-open-dwim', which then
defers to the `dired-guess-shell-alist-user'."
  :group 'my-dired
  :type 'string)

;; NOTE 2023-06-27: This is a proof-of-concept.  See the previous
;; note.
(defun my-dired-open-dwim (files)
  "Open FILES using the appropriate program."
  (interactive (list (dired-get-marked-files)))
  (if-let* ((extension (file-name-extension (car files)))
            ((string-match-p extension my-dired-always-external-regexp))
            (guess (dired-guess-default files))
            (program (if (listp guess) (car guess) guess)))
      (dired-do-async-shell-command program nil files)
    (find-file (car files))))

(defvar my-dired--limit-hist '()
  "Minibuffer history for `my-dired-limit-regexp'.")

;;;###autoload
(defun my-dired-limit-regexp (regexp omit)
  "Limit Dired to keep files matching REGEXP.

With optional OMIT argument as a prefix (\\[universal-argument]),
exclude files matching REGEXP.

Restore the buffer with \\<dired-mode-map>`\\[revert-buffer]'."
  (interactive
   (list
    (read-regexp
     (concat "Files "
             (when current-prefix-arg
               (propertize "NOT " 'face 'warning))
             "matching PATTERN: ")
     nil 'my-dired--limit-hist)
    current-prefix-arg))
  (dired-mark-files-regexp regexp)
  (unless omit (dired-toggle-marks))
  (dired-do-kill-lines)
  (add-to-history 'my-dired--limit-hist regexp))

(defvar my-dired--find-grep-hist '()
  "Minibuffer history for `my-dired-grep-marked-files'.")

;; Also see `my-search-grep' from my-search.el.
;;;###autoload
(defun my-dired-grep-marked-files (regexp &optional arg)
  "Run `find' with `grep' for REGEXP on marked files.
When no files are marked or when just a single one is marked,
search the entire directory instead.

With optional prefix ARG target a single marked file.

We assume that there is no point in marking a single file and
running find+grep on its contents.  Visit it and call `occur' or
run grep directly on it without the whole find part."
  (interactive
   (list
    (read-string "grep for PATTERN (marked files OR current directory): " nil 'my-dired--find-grep-hist)
    current-prefix-arg)
   dired-mode)
  (when-let* ((marks (dired-get-marked-files 'no-dir))
              (files (mapconcat #'identity marks " "))
              (args (if (or arg (length> marks 1))
                        ;; Thanks to Sean Whitton for pointing out an
                        ;; earlier superfluity of mine: we do not need
                        ;; to call grep through find when we already
                        ;; know the files we want to search in.  Check
                        ;; Sean's dotfiles:
                        ;; <https://git.spwhitton.name/dotfiles>.
                        ;;
                        ;; Any other errors or omissions are my own.
                        (format "grep -nH --color=auto %s %s" (shell-quote-argument regexp) files)
                      (concat
                       "find . -not " (shell-quote-argument "(")
                       " -wholename " (shell-quote-argument "*/.git*")
                       " -prune " (shell-quote-argument ")")
                       " -type f"
                       " -exec grep -nHE --color=auto " regexp " "
                       (shell-quote-argument "{}")
                       " " (shell-quote-argument ";") " "))))
    (compilation-start
     args
     'grep-mode
     (lambda (mode) (format "*my-dired-find-%s for '%s'" mode regexp))
     t)))

;;;; Subdir extras and Imenu setup

(defvar my-dired--directory-header-regexp "^ +\\(.+\\):\n"
  "Pattern to match Dired directory headings.")

;;;###autoload
(defun my-dired-subdirectory-next (&optional arg)
  "Move to next or optional ARGth Dired subdirectory heading.
For more on such headings, read `dired-maybe-insert-subdir'."
  (interactive "p")
  (let ((pos (point))
        (subdir my-dired--directory-header-regexp))
    (goto-char (line-end-position))
    (if (re-search-forward subdir nil t (or arg nil))
        (progn
          (goto-char (match-beginning 1))
          (goto-char (line-beginning-position)))
      (goto-char pos))))

;;;###autoload
(defun my-dired-subdirectory-previous (&optional arg)
  "Move to previous or optional ARGth Dired subdirectory heading.
For more on such headings, read `dired-maybe-insert-subdir'."
  (interactive "p")
  (let ((pos (point))
        (subdir my-dired--directory-header-regexp))
    (goto-char (line-beginning-position))
    (if (re-search-backward subdir nil t (or arg nil))
        (goto-char (line-beginning-position))
      (goto-char pos))))

(autoload 'dired-current-directory "dired")
(autoload 'dired-kill-subdir "dired-aux")

;;;###autoload
(defun my-dired-remove-inserted-subdirs ()
  "Remove all inserted Dired subdirectories."
  (interactive)
  (goto-char (point-max))
  (while (and (my-dired-subdirectory-previous)
              (not (equal (dired-current-directory)
                          (expand-file-name default-directory))))
    (dired-kill-subdir)))

(autoload 'cl-remove-if-not "cl-seq")

(defun my-dired--dir-list (list)
  "Filter out non-directory file paths in LIST."
  (cl-remove-if-not
   (lambda (dir)
     (file-directory-p dir))
   list))

(defun my-dired--insert-dir (dir &optional flags)
  "Insert DIR using optional FLAGS."
  (dired-maybe-insert-subdir (expand-file-name dir) (or flags nil)))

(autoload 'dired-get-filename "dired")
(autoload 'dired-get-marked-files "dired")
(autoload 'dired-maybe-insert-subdir "dired-aux")
(defvar dired-subdir-switches)
(defvar dired-actual-switches)

;;;###autoload
(defun my-dired-insert-subdir (&optional arg)
  "Generic command to insert subdirectories in Dired buffers.

When items are marked, insert those which are subsirectories of
the current directory.  Ignore regular files.

If no marks are active and point is on a subdirectory line,
insert it directly.

If no marks are active and point is not on a subdirectory line,
prompt for a subdirectory using completion.

With optional ARG as a single prefix (`\\[universal-argument]')
argument, prompt for command line flags to pass to the underlying
ls program.

With optional ARG as a double prefix argument, remove all
inserted subdirectories."
  (interactive "p")
  (let* ((name (dired-get-marked-files))
         (flags (when (eq arg 4)
                  (read-string "Flags for `ls' listing: "
                               (or dired-subdir-switches dired-actual-switches)))))
    (cond  ; NOTE 2021-07-20: `length>', `length=' are from Emacs28
     ((eq arg 16)
      (my-dired-remove-inserted-subdirs))
     ((and (length> name 1) (my-dired--dir-list name))
      (mapc (lambda (file)
              (when (file-directory-p file)
                (my-dired--insert-dir file flags)))
            name))
     ((and (length= name 1) (file-directory-p (car name)))
      (my-dired--insert-dir (car name) flags))
     (t
      (let ((selection (read-directory-name "Insert directory: ")))
        (my-dired--insert-dir selection flags))))))

(defun my-dired--imenu-prev-index-position ()
  "Find the previous file in the buffer."
  (let ((subdir my-dired--directory-header-regexp))
    (re-search-backward subdir nil t)))

(defun my-dired--imenu-extract-index-name ()
  "Return the name of the file at point."
  (file-relative-name
   (buffer-substring-no-properties (+ (line-beginning-position) 2)
                                   (1- (line-end-position)))))

;;;###autoload
(defun my-dired-setup-imenu ()
  "Configure imenu for the current Dired buffer.
Add this to `dired-mode-hook'."
  (set (make-local-variable 'imenu-prev-index-position-function)
       'my-dired--imenu-prev-index-position)
  (set (make-local-variable 'imenu-extract-index-name-function)
       'my-dired--imenu-extract-index-name))

(provide 'my-dired)
;;; my-dired.el ends here
