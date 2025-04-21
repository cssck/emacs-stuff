;;; my-simple.el --- Common commands for my dotemacs -*- lexical-binding: t -*-

;; Copyright (C) 2020-2025  Protesilaos Stavrou

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
;; Common commands for my Emacs: <https://protesilaos.com/emacs/dotemacs/>.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'my-common)

(defgroup my-simple ()
  "Generic utilities for my dotemacs."
  :group 'editing)

(defcustom my-simple-date-specifier "%F"
  "Date specifier for `format-time-string'.
Used by `my-simple-inset-date'."
  :type 'string
  :group 'my-simple)

(defcustom my-simple-time-specifier "%R %z"
  "Time specifier for `format-time-string'.
Used by `my-simple-inset-date'."
  :type 'string
  :group 'my-simple)

;;; Commands

;;;; General commands

(defun my-simple--mark (bounds)
  "Mark between BOUNDS as a cons cell of beginning and end positions."
  (push-mark (car bounds))
  (goto-char (cdr bounds))
  (activate-mark))

;;;###autoload
(defun my-simple-sudo ()
  "Find the current file or directory using SUDO."
  (interactive)
  (let ((destination (or buffer-file-name default-directory)))
    (if (string= (file-remote-p destination 'method) "sudo")
        (user-error "Already using `sudo'")
      (find-file (format "/sudo::/%s" destination)))))

;;;###autoload
(defun my-simple-mark-sexp ()
  "Mark symbolic expression at or near point.
Repeat to extend the region forward to the next symbolic
expression."
  (interactive)
  (if (and (region-active-p)
           (eq last-command this-command))
      (ignore-errors (forward-sexp 1))
    (when-let* ((thing (cond
                        ((thing-at-point 'url) 'url)
                        ((thing-at-point 'sexp) 'sexp)
                        ((thing-at-point 'string) 'string)
                        ((thing-at-point 'word) 'word))))
      (my-simple--mark (bounds-of-thing-at-point thing)))))

;;;###autoload
(defun my-simple-keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

;; DEPRECATED 2023-12-26: I have not used `my-simple-describe-symbol'
;; since a very long time.  The idea is fine, but having a key binding
;; to provide a shortcut for C-h o RET is wasteful.

;; (autoload 'symbol-at-point "thingatpt")
;;
;; ;;;###autoload
;; (defun my-simple-describe-symbol ()
;;   "Run `describe-symbol' for the `symbol-at-point'."
;;   (interactive)
;;   (describe-symbol (symbol-at-point)))

;; DEPRECATED 2023-12-26: The `my-simple-goto-definition' is a good
;; idea but it needs more work.  Ultimately though, it is easier to
;; just produce a Help buffer and just go to the source from there by
;; typing 's'.

;; (declare-function help--symbol-completion-table "help-fns" (string pred action))
;;
;; ;;;###autoload
;; (defun my-simple-goto-definition (symbol)
;;   "Prompt for SYMBOL and go to its source.
;; When called from Lisp, SYMBOL is a string."
;;   (interactive
;;    (list
;;     (completing-read "Go to source of SYMBOL: "
;;                      #'help--symbol-completion-table
;;                      nil :require-match)))
;;   (xref-find-definitions symbol))

;; DEPRECATED 2023-12-26: I have no need for these commands.  I was
;; just experimenting with a simple implementation.  It is not robust.
;; I can fix it, but I will still not use it, so I am deprecating it
;; instead.

;; (autoload 'number-at-point "thingatpt")
;;
;; (defun my-simple--number-operate (number amount operation)
;;   "Perform OPERATION on NUMBER given AMOUNT and return the result.
;; OPERATION is the keyword `:increment' or `:decrement' to perform
;; `1+' or `1-', respectively."
;;   (when (and (numberp number) (numberp amount))
;;     (let ((fn (pcase operation
;;                 (:increment #'+)
;;                 (:decrement #'-)
;;                 (_ (user-error "Unknown operation `%s' for number `%s'" operation number)))))
;;       (funcall fn number amount))))
;;
;; (defun my-simple--number-replace (number amount operation)
;;   "Perform OPERATION on NUMBER at point by AMOUNT."
;;   (when-let* ((bounds (bounds-of-thing-at-point 'number))
;;               (replacement (my-simple--number-operate number amount operation)))
;;     (delete-region (car bounds) (cdr bounds))
;;     (save-excursion
;;       (insert (number-to-string replacement)))))
;;
;; ;;;###autoload
;; (defun my-simple-number-increment (number amount)
;;   "Increment NUMBER by AMOUNT.
;; When called interactively, NUMBER is the one at point, while
;; AMOUNT is either 1 or that of a number prefix argument."
;;   (interactive
;;    (list
;;     (number-at-point)
;;     (prefix-numeric-value current-prefix-arg)))
;;   (my-simple--number-replace number amount :increment))
;;
;; ;;;###autoload
;; (defun my-simple-number-decrement (number amount)
;;   "Decrement NUMBER by AMOUNT.
;; When called interactively, NUMBER is the one at point, while
;; AMOUNT is either 1 or that of a number prefix argument."
;;   (interactive
;;    (list
;;     (number-at-point)
;;     (prefix-numeric-value current-prefix-arg)))
;;   (my-simple--number-replace number amount :decrement))

;;;; Commands for lines

;;;###autoload
(defun my-simple-new-line-below (n)
  "Create N empty lines below the current one.
When called interactively without a prefix numeric argument, N is
1."
  (interactive "p")
  (goto-char (line-end-position))
  (dotimes (_ n) (insert "\n")))

;;;###autoload
(defun my-simple-new-line-above (n)
  "Create N empty lines above the current one.
When called interactively without a prefix numeric argument, N is
1."
  (interactive "p")
  (let ((point-min (point-min)))
    (if (or (bobp)
            (eq (point) point-min)
            (eq (line-number-at-pos point-min) 1))
        (progn
          (goto-char (line-beginning-position))
          (dotimes (_ n) (insert "\n"))
          (forward-line (- n)))
      (forward-line (- n))
      (my-simple-new-line-below n))))

;;;###autoload
(defun my-simple-copy-line ()
  "Copy the current line to the `kill-ring'."
  (interactive)
  (copy-region-as-kill (line-beginning-position) (line-end-position)))

(make-obsolete 'my-simple-copy-line-or-region 'my-simple-copy-line "2023-09-26")

;;;###autoload
(defun my-simple-kill-ring-save (&optional beg end)
  "Copy the current region or line.
When the region is active, use `kill-ring-save' between the BEG and END
positions.  Otherwise, copy the current line."
  ;; NOTE 2025-02-23: Using (interactive "r") returns an error before
  ;; running the body of this function if there is no mark.  This
  ;; happens when visiting a file.
  (interactive
   (when (region-active-p)
     (list
      (region-beginning)
      (region-end))))
  (if (and beg end)
      (copy-region-as-kill beg end)
    (my-simple-copy-line))
  (setq this-command 'kill-ring-save))

;;;###autoload
(defun my-simple-kill-region (&optional beg end)
  "Do `kill-region' when the region is active, else `kill-ring-save' symbol at point."
  (interactive
   (when (region-active-p)
     (list
      (region-beginning)
      (region-end))))
  (if (and beg end)
      (kill-region beg end)
    (my-simple-mark-sexp)
    (copy-region-as-kill (region-beginning) (region-end)))
  (setq this-command 'kill-ring-save))

(defun my-simple--duplicate-buffer-substring (boundaries)
  "Duplicate buffer substring between BOUNDARIES.
BOUNDARIES is a cons cell representing buffer positions."
  (unless (consp boundaries)
    (error "`%s' is not a cons cell" boundaries))
  (let ((beg (car boundaries))
        (end (cdr boundaries)))
    (goto-char end)
    (newline)
    (insert (buffer-substring-no-properties beg end))))

;;;###autoload
(defun my-simple-duplicate-line-or-region ()
  "Duplicate the current line or active region."
  (interactive)
  (unless mark-ring                  ; needed when entering a new buffer
    (push-mark (point) t nil))
  (my-simple--duplicate-buffer-substring
   (if (region-active-p)
       (cons (region-beginning) (region-end))
     (cons (line-beginning-position) (line-end-position))))
  (setq this-command 'yank))

;;;###autoload
(defun my-simple-yank-replace-line-or-region ()
  "Replace line or region with latest kill.
This command can then be followed by the standard
`yank-pop' (default is bound to \\[yank-pop])."
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (delete-region (line-beginning-position) (line-end-position)))
  (yank)
  (setq this-command 'yank))

;;;###autoload
(defun my-simple-multi-line-below ()
  "Move half a screen below."
  (interactive)
  (forward-line (floor (window-height) 2))
  (setq this-command 'scroll-up-command))

;;;###autoload
(defun my-simple-multi-line-above ()
  "Move half a screen above."
  (interactive)
  (forward-line (- (floor (window-height) 2)))
  (setq this-command 'scroll-down-command))

;;;###autoload
(defun my-simple-kill-line-backward ()
  "Kill from point to the beginning of the line."
  (interactive)
  (kill-line 0)
  (setq this-command 'kill-line))

;;;###autoload
(defun my-simple-delete-line ()
  "Delete (not kill) from point to the end of the line."
  (interactive)
  (let ((point (point))
        (end (line-end-position)))
    (if (eq point end)
        (delete-region point (+ end 1))
      (delete-region point end)))
  (setq this-command 'kill-whole-line))

;;;###autoload
(defun my-simple-delete-line-backward ()
  "Delete (not kill) from point to the beginning of the line."
  (interactive)
  (let ((point (point))
        (beg (line-beginning-position)))
    (if (eq point beg)
        (delete-region (- beg 1) point)
      (delete-region point beg)))
  (setq this-command 'kill-whole-line))

;;;###autoload
(define-minor-mode my-simple-auto-fill-visual-line-mode
  "Enable `visual-line-mode' and disable `auto-fill-mode' in the current buffer."
  :global nil
  (if my-simple-auto-fill-visual-line-mode
      (progn
        (auto-fill-mode -1)
        (visual-line-mode 1))
    (auto-fill-mode 1)
    (visual-line-mode -1)))

;;;; Commands for text insertion or manipulation

;;;###autoload
(defun my-simple-insert-date (&optional arg)
  "Insert the current date as `my-simple-date-specifier'.

With optional prefix ARG (\\[universal-argument]) also append the
current time understood as `my-simple-time-specifier'.

When region is active, delete the highlighted text and replace it
with the specified date."
  (interactive "P")
  (let* ((date my-simple-date-specifier)
         (time my-simple-time-specifier)
         (format (if arg (format "%s %s" date time) date)))
    (when (use-region-p)
      (delete-region (region-beginning) (region-end)))
    (insert (format-time-string format))))

(defun my-simple--pos-url-on-line (char)
  "Return position of `my-common-url-regexp' at CHAR."
  (when (integer-or-marker-p char)
    (save-excursion
      (goto-char char)
      (re-search-forward my-common-url-regexp (line-end-position) :noerror))))

;;;###autoload
(defun my-simple-escape-url-line (char)
  "Escape all URLs or email addresses on the current line.
When called from Lisp CHAR is a buffer position to operate from
until the end of the line.  In interactive use, CHAR corresponds
to `line-beginning-position'."
  (interactive
   (list
    (if current-prefix-arg
        (re-search-forward
         my-common-url-regexp
         (line-end-position) :no-error
         (prefix-numeric-value current-prefix-arg))
      (line-beginning-position))))
  (when-let* ((regexp-end (my-simple--pos-url-on-line char)))
    (goto-char regexp-end)
    (unless (looking-at ">")
      (insert ">")
      (when (search-backward "\s" (line-beginning-position) :noerror)
        (forward-char 1))
      (insert "<"))
    (my-simple-escape-url-line (1+ regexp-end)))
  (goto-char (line-end-position)))

;; Thanks to Bruno Boal for the original `my-simple-escape-url-region'.
;; Check Bruno's Emacs config: <https://github.com/BBoal/emacs-config>.

;;;###autoload
(defun my-simple-escape-url-region (&optional beg end)
  "Apply `my-simple-escape-url-line' on region lines between BEG and END."
  (interactive
   (if (region-active-p)
       (list (region-beginning) (region-end))
     (error "There is no region!")))
  (let ((beg (min beg end))
        (end (max beg end)))
    (save-excursion
      (goto-char beg)
      (setq beg (line-beginning-position))
      (while (<= beg end)
        (my-simple-escape-url-line beg)
        (beginning-of-line 2)
        (setq beg (point))))))

;;;###autoload
(defun my-simple-escape-url-dwim ()
  "Escape URL on the current line or lines implied by the active region.
Call the commands `my-simple-escape-url-line' and
`my-simple-escape-url-region' ."
  (interactive)
  (if (region-active-p)
      (my-simple-escape-url-region (region-beginning) (region-end))
    (my-simple-escape-url-line (line-beginning-position))))

;;;###autoload
(defun my-simple-zap-to-char-backward (char &optional arg)
  "Backward `zap-to-char' for CHAR.
Optional ARG is a numeric prefix to match ARGth occurance of
CHAR."
  (interactive
   (list
    (read-char-from-minibuffer "Zap to char: " nil 'read-char-history)
    (prefix-numeric-value current-prefix-arg)))
  (zap-to-char (- arg) char t))

(defvar my-simple-flush-and-diff-history nil
  "Minibuffer history for `my-simple-flush-and-diff'.")

;;;###autoload
(defun my-simple-flush-and-diff (regexp beg end)
  "Call `flush-lines' for REGEXP and produce diff if file is modified.
When region is active, operate between the region boundaries
demarcated by BEG and END."
  (interactive
   (let ((regionp (region-active-p)))
     (list
      (read-regexp "Flush lines using REGEXP: " nil 'my-simple-flush-and-diff-history)
      (and regionp (region-beginning))
      (and regionp (region-end)))))
  (flush-lines regexp (or beg (point-min)) (or end (point-max)) :no-message)
  (when (and (buffer-modified-p) buffer-file-name)
    (diff-buffer-with-file (current-buffer))))

;; FIXME 2023-09-28: The line prefix is problematic.  I plan to rewrite it.

;; (defcustom my-simple-line-prefix-strings '(">" "+" "-")
;;   "List of strings used as line prefixes.
;; The command which serves as the point of entry is
;; `my-simple-insert-line-prefix'."
;;   :type '(repeat string)
;;   :group 'my-simple)
;;
;; (defun my-simple--line-prefix-regexp (&optional string)
;;   "Format regular expression for `my-simple--line-prefix-p'.
;; With optional STRING use it directly.  Else format the regexp by
;; concatenating `my-simple-line-prefix-strings'."
;;   (if string
;;       (format "^%s " string)
;;     (format "^[%s] " (apply #'concat my-simple-line-prefix-strings))))
;;
;; (defun my-simple--line-prefix-p (&optional string)
;;   "Return non-nil if line beginning has an appropriate string prefix.
;; With optional STRING test that it is at the beginning of the line."
;;   (save-excursion
;;     (goto-char (line-beginning-position))
;;     (looking-at (my-simple--line-prefix-regexp string))))
;;
;; (defun my-simple--line-prefix-insert (string)
;;   "Insert STRING at the beginning of the line, followed by a space."
;;   (save-excursion
;;     (goto-char (line-beginning-position))
;;     (insert string)
;;     (insert " ")))
;;
;; (defun my-simple--line-prefix-infer-string ()
;;   "Return line prefix string if it matches `my-simple--line-prefix-p'."
;;   (when (my-simple--line-prefix-p)
;;     (string-trim
;;      (buffer-substring-no-properties (match-beginning 0) (match-end 0)))))
;;
;; (defun my-simple--line-prefix-toggle (string)
;;   "Insert or remove STRING at the beginning of the line."
;;   (if (my-simple--line-prefix-p string)
;;       (delete-region (match-beginning 0) (match-end 0))
;;     (my-simple--line-prefix-insert string)))
;;
;; (defvar my-simple--line-prefix-history nil
;;   "Minibuffer history of `my-simple--line-prefix-prompt'.")
;;
;; (defun my-simple--line-prefix-prompt ()
;;   "Prompt for string to use as line prefix.
;; Provide `my-simple-line-prefix-strings' as completion
;; candidates, though accept arbitrary input."
;;   (let ((default (car my-simple--line-prefix-history)))
;;     (completing-read
;;      (format-prompt "Select line prefix" default)
;;      my-simple-line-prefix-strings
;;      nil nil nil
;;      'my-simple--line-prefix-history default)))
;;
;; (defun my-simple-line-prefix-infer-or-prompt ()
;;   "Infer string for line prefix or prompt for one."
;;   (or (my-simple--line-prefix-infer-string)
;;       (my-simple--line-prefix-prompt)))
;;
;; ;;;###autoload
;; (defun my-simple-insert-line-prefix-dwim (string)
;;   "Toggle presence of STRING at the beginning of the line.
;;
;; When called interactively try to infer STRING based on the line
;; prefix.  If one is found among `my-simple-line-prefix-strings',
;; perform a removal outright.
;;
;; If no string can be inferred, prompt for STRING among
;; `my-simple-line-prefix-strings'.  Accept arbitrary strings at
;; the prompt.
;;
;; When the region is active, toggle the presence of STRING for each
;; line in the region."
;;   (interactive (list (my-simple-line-prefix-infer-or-prompt)))
;;   (if-let* ((region-p (region-active-p))
;;             (beg (region-beginning))
;;             (end (line-number-at-pos (region-end))))
;;       (progn
;;         (goto-char beg)
;;         (push-mark (point))
;;         (while (<= (line-number-at-pos (point)) end)
;;           (my-simple--line-prefix-toggle string)
;;           (forward-line 1)))
;;     (my-simple--line-prefix-toggle string)))

;;;; Commands for object transposition

;; The "move" functions all the way to `my-simple-move-below-dwim'
;; are courtesy of Bruno Boal: <https://git.sr.ht/~bboal>.  With minor
;; tweaks by me.
(defun my-simple--move-line (count dir)
  "Move line or region COUNTth times in DIR direction."
  (let* ((start (pos-bol))
         (end (pos-eol))
         diff-eol-point
         diff-eol-mark)
    (when-let* (((use-region-p))
                (pos (point))
                (mrk (mark))
                (line-diff-mark-point (1+ (- (line-number-at-pos mrk)
                                             (line-number-at-pos pos)))))
      (if (> pos mrk)
          (setq start (pos-bol line-diff-mark-point)) ; pos-bol of where the mark is
        (setq end (pos-eol line-diff-mark-point)))    ; pos-eol of the line where the mark is
      (setq diff-eol-mark (1+ (- end mrk))))          ; 1+ to get the \n
    ;; this is valid for region or a single line
    (setq diff-eol-point (1+ (- end (point))))
    (let* ((max (point-max))
           (end (1+ end))
           (end (if (> end max) max end))
           (deactivate-mark)
           (lines (delete-and-extract-region start end)))
      (forward-line (* count dir))
      ;; Handle the special case when there isn't a newline as the eob.
      (when (and (eq (point) max)
                 (/= (current-column) 0))
        (insert "\n"))
      (insert lines)
      ;; if user provided a region
      (when diff-eol-mark
        (set-mark (- (point) diff-eol-mark)))
      ;; either way go to same point location reference initial motion
      (goto-char (- (point) diff-eol-point)))))

(defun my-simple--move-line-user-error (boundary)
  "Return `user-error' with message accounting for BOUNDARY.
BOUNDARY is a buffer position, expected to be `point-min' or `point-max'."
  (when-let* ((bound (line-number-at-pos boundary))
              (scope (cond
                      ((and (use-region-p)
                            (or (= (line-number-at-pos (point)) bound)
                                (= (line-number-at-pos (mark)) bound)))
                       "region is ")
                      ((= (line-number-at-pos (point)) bound)
                       "")
                      (t nil))))
    (user-error (format "Warning: %salready in the last line!" scope))))

(defun my-simple-move-above-dwim (arg)
  "Move line or region ARGth times up.
If ARG is nil, do it one time."
  (interactive "p")
  (unless (my-simple--move-line-user-error (point-min))
    (my-simple--move-line arg -1)))

(defun my-simple-move-below-dwim (arg)
  "Move line or region ARGth times down.
If ARG is nil, do it one time."
  (interactive "p")
  (unless (my-simple--move-line-user-error (point-max))
    (my-simple--move-line arg 1)))

(defmacro my-simple-define-transpose (scope)
  "Define transposition command for SCOPE.
SCOPE is the text object to operate on.  The command's name is
my-simple-transpose-SCOPE."
  `(defun ,(intern (format "my-simple-transpose-%s" scope)) (arg)
     ,(format "Transpose %s.
Transposition over an active region will swap the object at
the region beginning with the one at the region end." scope)
     (interactive "p")
     (let ((fn (intern (format "%s-%s" "transpose" ,scope))))
       (if (use-region-p)
           (funcall fn 0)
         (funcall fn arg)))))

;;;###autoload (autoload 'my-simple-transpose-lines "my-simple")
;;;###autoload (autoload 'my-simple-transpose-paragraphs "my-simple")
;;;###autoload (autoload 'my-simple-transpose-sentences "my-simple")
;;;###autoload (autoload 'my-simple-transpose-sexps "my-simple")
;;;###autoload (autoload 'my-simple-transpose-words "my-simple")
(my-simple-define-transpose "lines")
(my-simple-define-transpose "paragraphs")
(my-simple-define-transpose "sentences")
(my-simple-define-transpose "sexps")
(my-simple-define-transpose "words")

;;;###autoload
(defun my-simple-transpose-chars ()
  "Always transposes the two characters before point.
There is no dragging the character forward.  This is the
behaviour of `transpose-chars' when point is at the end of the
line."
  (interactive)
  (if (eq (point) (line-end-position))
      (transpose-chars 1)
    (transpose-chars -1)
    (forward-char)))

;;;; Commands for paragraphs

;;;###autoload
(defun my-simple-unfill-region-or-paragraph (&optional beg end)
  "Unfill paragraph or, when active, the region.
Join all lines in region delimited by BEG and END, if active,
while respecting any empty lines (so multiple paragraphs are not
joined, just unfilled).  If no region is active, operate on the
paragraph.  The idea is to produce the opposite effect of both
`fill-paragraph' and `fill-region'."
  (interactive "r")
  (let ((fill-column most-positive-fixnum))
    (if (use-region-p)
        (fill-region beg end)
      (fill-paragraph))))

;;;; Commands for windows and pages

;;;###autoload
(defun my-simple-other-window ()
  "Wrapper for `other-window' and `next-multiframe-window'.
If there is only one window and multiple frames, call
`next-multiframe-window'.  Otherwise, call `other-window'."
  (interactive)
  (if (and (one-window-p) (length> (frame-list) 1))
      (progn
        (call-interactively #'next-multiframe-window)
        (setq this-command #'next-multiframe-window))
    (call-interactively #'other-window)
    (setq this-command #'other-window)))

;;;###autoload
(defun my-simple-narrow-visible-window ()
  "Narrow buffer to wisible window area.
Also check `my-simple-narrow-dwim'."
  (interactive)
  (let* ((bounds (my-common-window-bounds))
         (window-area (- (cdr bounds) (car bounds)))
         (buffer-area (- (point-max) (point-min))))
    (if (/= buffer-area window-area)
        (narrow-to-region (car bounds) (cdr bounds))
      (user-error "Buffer fits in the window; won't narrow"))))

;;;###autoload
(defun my-simple-narrow-dwim ()
  "Do-what-I-mean narrowing.
If region is active, narrow the buffer to the region's
boundaries.

If pages are defined by virtue of `my-common-page-p', narrow to
the current page boundaries.

If no region is active and no pages exist, narrow to the visible
portion of the window.

If narrowing is in effect, widen the view."
  (interactive)
  (unless mark-ring                  ; needed when entering a new buffer
    (push-mark (point) t nil))
  (cond
   ((and (use-region-p)
         (null (buffer-narrowed-p)))
    (narrow-to-region (region-beginning) (region-end)))
   ((my-common-page-p)
    (narrow-to-page))
   ((null (buffer-narrowed-p))
    (my-simple-narrow-visible-window))
   ((widen))))

(defun my-simple--narrow-to-page (count &optional back)
  "Narrow to COUNTth page with optional BACK motion."
  (if back
      (narrow-to-page (or (- count) -1))
    (narrow-to-page (or (abs count) 1)))
  ;; Avoids the problem of skipping pages while cycling back and forth.
  (goto-char (point-min)))

;;;###autoload
(defun my-simple-forward-page-dwim (&optional count)
  "Move to next or COUNTth page forward.
If buffer is narrowed to the page, keep the effect while
performing the motion.  Always move point to the beginning of the
narrowed page."
  (interactive "p")
  (if (buffer-narrowed-p)
      (my-simple--narrow-to-page count)
    (forward-page count)
    (setq this-command 'forward-page)))

;;;###autoload
(defun my-simple-backward-page-dwim (&optional count)
  "Move to previous or COUNTth page backward.
If buffer is narrowed to the page, keep the effect while
performing the motion.  Always move point to the beginning of the
narrowed page."
  (interactive "p")
  (if (buffer-narrowed-p)
      (my-simple--narrow-to-page count t)
    (backward-page count)
    (setq this-command 'backward-page)))

;;;###autoload
(defun my-simple-delete-page-delimiters (&optional beg end)
  "Delete lines with just page delimiters in the current buffer.
When region is active, only operate on the region between BEG and
END, representing the point and mark."
  (interactive "r")
  (let (b e)
    (if (use-region-p)
        (setq b beg
              e end)
      (setq b (point-min)
            e (point-max)))
    (widen)
    (flush-lines (format "%s$" page-delimiter) b e)
    (setq this-command 'flush-lines)))

;; NOTE 2023-06-18: The idea of narrowing to a defun in an indirect
;; buffer is still experimental.
(defun my-simple-narrow--guess-defun-symbol ()
  "Try to return symbol of current defun as a string."
  (save-excursion
    (beginning-of-defun)
    (search-forward " ")
    (thing-at-point 'symbol :no-properties)))

;;;###autoload
(defun my-simple-narrow-to-cloned-buffer ()
  "Narrow to defun in cloned buffer.
Name the buffer after the defun's symbol."
  (interactive)
  (clone-indirect-buffer-other-window
   (format "%s -- %s"
           (buffer-name)
           (my-simple-narrow--guess-defun-symbol))
   :display)
  (narrow-to-defun))

;;;; Commands for buffers

(defun my-simple--display-unsaved-buffers (buffers buffer-menu-name)
  "Produce buffer menu listing BUFFERS called BUFFER-MENU-NAME."
  (let ((old-buf (current-buffer))
        (buf (get-buffer-create buffer-menu-name)))
    (with-current-buffer buf
      (Buffer-menu-mode)
      (setq-local Buffer-menu-files-only nil
                  Buffer-menu-buffer-list buffers
                  Buffer-menu-filter-predicate nil)
      (list-buffers--refresh buffers old-buf)
      (tabulated-list-print))
    (display-buffer buf)))

(defun my-simple--get-unsaved-buffers ()
  "Get list of unsaved buffers."
  (seq-filter
   (lambda (buffer)
     (and (buffer-file-name buffer)
          (buffer-modified-p buffer)))
   (buffer-list)))

;;;###autoload
(defun my-simple-display-unsaved-buffers ()
  "Produce buffer menu listing unsaved file-visiting buffers."
  (interactive)
  (if-let* ((unsaved-buffers (my-simple--get-unsaved-buffers)))
      (my-simple--display-unsaved-buffers unsaved-buffers "*Unsaved buffers*")
    (message "No unsaved buffers")))

(defun my-simple-display-unsaved-buffers-on-exit (&rest _)
  "Produce buffer menu listing unsaved file-visiting buffers.
Add this as :before advice to `save-buffers-kill-emacs'."
  (when-let* ((unsaved-buffers (my-simple--get-unsaved-buffers)))
    (my-simple--display-unsaved-buffers unsaved-buffers "*Unsaved buffers*")))

;;;###autoload
(defun my-simple-copy-current-buffer-name ()
  "Add the current buffer's name to the `kill-ring'."
  (declare (interactive-only t))
  (interactive)
  (kill-new (buffer-name (current-buffer))))

;;;###autoload
(defun my-simple-copy-current-buffer-file ()
  "Add the current buffer's file path to the `kill-ring'."
  (declare (interactive-only t))
  (interactive)
  (if buffer-file-name
      (kill-new buffer-file-name)
    (user-error "%s is not associated with a file" (buffer-name (current-buffer)))))

;;;###autoload
(defun my-simple-kill-buffer (buffer)
  "Kill current BUFFER without confirmation.
When called interactively, prompt for BUFFER."
  (interactive (list (read-buffer "Select buffer: ")))
  (let ((kill-buffer-query-functions nil))
    (kill-buffer (or buffer (current-buffer)))))

;;;###autoload
(defun my-simple-kill-buffer-current (&optional arg)
  "Kill current buffer.
With optional prefix ARG (\\[universal-argument]) delete the
buffer's window as well.  Kill the window regardless of ARG if it
satisfies `my-common-window-small-p' and it has no previous
buffers in its history."
  (interactive "P")
  (let ((kill-buffer-query-functions nil))
    (if (or (and (my-common-window-small-p)
                 (null (window-prev-buffers)))
            (and arg (not (one-window-p))))
        (kill-buffer-and-window)
      (kill-buffer))))

;;;###autoload
(defun my-simple-rename-file-and-buffer (name)
  "Apply NAME to current file and rename its buffer.
Do not try to make a new directory or anything fancy."
  (interactive
   (list (read-string "Rename current file: " (buffer-file-name))))
  (let ((file (buffer-file-name)))
    (if (vc-registered file)
        (vc-rename-file file name)
      (rename-file file name))
    (set-visited-file-name name t t)))

(defun my-simple--buffer-major-mode-prompt ()
  "Prompt of `my-simple-buffers-major-mode'.
Limit list of buffers to those matching the current
`major-mode' or its derivatives."
  (let ((read-buffer-function nil)
        (current-major-mode major-mode))
    (read-buffer
     (format "Buffer for %s: " major-mode)
     nil
     :require-match
     (lambda (pair) ; pair is (name-string . buffer-object)
       (with-current-buffer (cdr pair)
         (derived-mode-p current-major-mode))))))

;;;###autoload
(defun my-simple-buffers-major-mode ()
  "Select BUFFER matching the current one's major mode."
  (interactive)
  (switch-to-buffer (my-simple--buffer-major-mode-prompt)))

(defun my-simple--buffer-vc-root-prompt ()
  "Prompt of `my-simple-buffers-vc-root'."
  (let ((root (or (vc-root-dir)
                  (locate-dominating-file "." ".git")))
        (read-buffer-function nil))
    (read-buffer
     (format "Buffers in %s: " root)
     nil t
     (lambda (pair) ; pair is (name-string . buffer-object)
       (with-current-buffer (cdr pair) (string-match-p root default-directory))))))

;;;###autoload
(defun my-simple-buffers-vc-root ()
  "Select buffer matching the current one's VC root."
  (interactive)
  (switch-to-buffer (my-simple--buffer-vc-root-prompt)))

;;;###autoload
(defun my-simple-swap-window-buffers (counter)
  "Swap states of live buffers.
With two windows, transpose their buffers.  With more windows,
perform a clockwise rotation.  Do not alter the window layout.
Just move the buffers around.

With COUNTER as a prefix argument, do the rotation
counter-clockwise."
  (interactive "P")
  (when-let* ((winlist (if counter (reverse (window-list)) (window-list)))
              (wincount (count-windows))
              ((> wincount 1)))
    (dotimes (i (- wincount 1))
      (window-swap-states (elt winlist i) (elt winlist (+ i 1))))))

;;;; Commands for files

(cl-defmethod register--type ((_regval vector)) 'vector)

(cl-defmethod register-val-describe ((val vector) _verbose)
  (if-let* ((pos (aref val 2))
            (file (aref val 1)))
      (princ (format "%s at position %s" file pos))
    (princ "Garbage data")))

;;;###autoload
(defun my-simple-file-to-register (register)
  "Store current location of file's point in REGISTER."
  (interactive (list (register-read-with-preview "File with point to register: ")))
  (set-register register (vector 'file-with-point (buffer-file-name) (point))))

(defvar my-simple-file-to-register-jump-hook nil
  "Normal hook called after jumping to a file register.
See `my-simple-file-to-register'.")

;;;###autoload
(cl-defmethod register-val-jump-to ((val vector) delete)
  "Handle how to jump to a location register.
This is like the default, but does not ask to visit a file: it does it
outright."
  (cond
   ((eq (aref val 0) 'file-with-point)
    (find-file (aref val 1))
    (goto-char (aref val 2))
    (run-hooks 'my-simple-file-to-register-jump-hook))
   (t (cl-call-next-method val delete))))

;;;; Commands of a general nature

(autoload 'color-rgb-to-hex "color")
(autoload 'color-name-to-rgb "color")

(defun my-simple-accessible-colors (variant)
  "Return list of accessible `defined-colors'.
VARIANT is either `dark' or `light'."
  (let ((variant-color (if (eq variant 'black) "#000000" "#ffffff")))
    (seq-filter
     (lambda (c)
       (let* ((rgb (color-name-to-rgb c))
              (r (nth 0 rgb))
              (g (nth 1 rgb))
              (b (nth 2 rgb))
              (hex (color-rgb-to-hex r g b 2)))
         (when (>= (my-common-contrast variant-color hex) 4.5)
           c)))
     (defined-colors))))

(defun my-simple--list-accessible-colors-prompt ()
  "Use `read-multiple-choice' to return white or black background."
  (intern
   (cadr
    (read-multiple-choice
     "Variant"
     '((?b "black" "Black background")
       (?w "white" "White background"))
     "Choose between white or black background."))))

;;;###autoload
(defun my-simple-list-accessible-colors (variant)
  "Return buffer with list of accessible `defined-colors'.
VARIANT is either `dark' or `light'."
  (interactive (list (my-simple--list-accessible-colors-prompt)))
  (list-colors-display (my-simple-accessible-colors variant)))

;;;; Global minor mode to override key maps

(defvar my-simple-override-mode-map (make-sparse-keymap)
  "Key map of `my-simple-override-mode'.
Enable that mode to have its key bindings take effect over those of the
major mode.")

(define-minor-mode my-simple-override-mode
  "Enable the `my-simple-override-mode-map'."
  :init-value nil
  :global t
  :keymap my-simple-override-mode-map)

(provide 'my-simple)
;;; my-simple.el ends here
