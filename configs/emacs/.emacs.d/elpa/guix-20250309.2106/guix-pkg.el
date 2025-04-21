;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "guix" "20250309.2106"
  "Interface for GNU Guix."
  '((emacs         "24.3")
    (dash          "2.11.0")
    (geiser        "0.8")
    (bui           "1.2.0")
    (magit-popup   "2.1.0")
    (edit-indirect "0.1.4"))
  :url "https://emacs-guix.gitlab.io/website/"
  :commit "287fc4fbea0c90efca01af8fd0d64748903253cf"
  :revdesc "287fc4fbea0c"
  :keywords '("tools")
  :authors '(("Alex Kost" . "alezost@gmail.com"))
  :maintainers '(("Alex Kost" . "alezost@gmail.com")))
