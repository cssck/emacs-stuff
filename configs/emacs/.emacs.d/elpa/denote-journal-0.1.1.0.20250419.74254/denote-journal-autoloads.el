;;; denote-journal-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (directory-file-name (file-name-directory load-file-name))) (car load-path)))



;;; Generated autoloads from denote-journal.el

(autoload 'denote-journal-new-entry "denote-journal" "\
Create a new journal entry in variable `denote-journal-directory'.
Use the variable `denote-journal-keyword' as a keyword for the
newly created file.  Set the title of the new entry according to the
value of the user option `denote-journal-title-format'.

With optional DATE as a prefix argument, prompt for a date.  If
`denote-date-prompt-use-org-read-date' is non-nil, use the Org
date selection module.

When called from Lisp DATE is a string and has the same format as
that covered in the documentation of the `denote' function.  It
is internally processed by `denote-valid-date-p'.

(fn &optional DATE)" t)
(autoload 'denote-journal-path-to-new-or-existing-entry "denote-journal" "\
Return path to existing or new journal file.
With optional DATE, do it for that date, else do it for today.  DATE is
a string and has the same format as that covered in the documentation of
the `denote' function.  It is internally processed by `denote-valid-date-p'.

If there are multiple journal entries for the date, prompt for one among
them using minibuffer completion.  If there is only one, return it.  If
there is no journal entry, create it.

(fn &optional DATE)")
(autoload 'denote-journal-new-or-existing-entry "denote-journal" "\
Locate an existing journal entry or create a new one.
A journal entry is one that has the value of the variable
`denote-journal-keyword' as part of its file name.

If there are multiple journal entries for the current date,
prompt for one using minibuffer completion.  If there is only
one, visit it outright.  If there is no journal entry, create one
by calling `denote-journal-extra-new-entry'.

With optional DATE as a prefix argument, prompt for a date.  If
`denote-date-prompt-use-org-read-date' is non-nil, use the Org
date selection module.

When called from Lisp, DATE is a string and has the same format
as that covered in the documentation of the `denote' function.
It is internally processed by `denote-valid-date-p'.

(fn &optional DATE)" t)
(autoload 'denote-journal-link-or-create-entry "denote-journal" "\
Use `denote-link' on journal entry, creating it if necessary.
A journal entry is one that has the value of the variable
`denote-journal-keyword' as part of its file name.

If there are multiple journal entries for the current date,
prompt for one using minibuffer completion.  If there is only
one, link to it outright.  If there is no journal entry, create one
by calling `denote-journal-extra-new-entry' and link to it.

With optional DATE as a prefix argument, prompt for a date.  If
`denote-date-prompt-use-org-read-date' is non-nil, use the Org
date selection module.

When called from Lisp, DATE is a string and has the same format
as that covered in the documentation of the `denote' function.
It is internally processed by `denote-valid-date-p'.

With optional ID-ONLY as a prefix argument create a link that
consists of just the identifier.  Else try to also include the
file's title.  This has the same meaning as in `denote-link'.

(fn &optional DATE ID-ONLY)" t)
(register-definition-prefixes "denote-journal" '("denote-journal-"))

;;; End of scraped data

(provide 'denote-journal-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; denote-journal-autoloads.el ends here
