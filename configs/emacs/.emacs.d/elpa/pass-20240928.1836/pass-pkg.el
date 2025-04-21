;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "pass" "20240928.1836"
  "Major mode for password-store.el."
  '((emacs              "25")
    (password-store     "1.7.4")
    (password-store-otp "0.1.5")
    (f                  "0.17"))
  :url "https://github.com/NicolasPetton/pass"
  :commit "1a9f6100153b07ac4f4d1d332501240e94c38f1e"
  :revdesc "1a9f6100153b"
  :keywords '("password-store" "password" "keychain")
  :authors '(("Nicolas Petton" . "petton.nicolas@gmail.com")
             ("Damien Cassou" . "damien@cassou.me"))
  :maintainers '(("Nicolas Petton" . "petton.nicolas@gmail.com")
                 ("Damien Cassou" . "damien@cassou.me")))
