;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "password-store" "20231201.954"
  "Password store (pass) support."
  '((emacs       "26.1")
    (with-editor "2.5.11"))
  :url "https://www.passwordstore.org/"
  :commit "b5e965a838bb68c1227caa2cdd874ba496f10149"
  :revdesc "b5e965a838bb"
  :keywords '("tools" "pass" "password" "password-store" "gpg")
  :authors '(("Svend Sorensen" . "svend@svends.net"))
  :maintainers '(("Tino Calancha" . "tino.calancha@gmail.com")))
