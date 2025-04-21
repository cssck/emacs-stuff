;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "emms" "20250405.1417"
  "The Emacs Multimedia System."
  '((cl-lib  "0.5")
    (nadvice "0.3")
    (seq     "0"))
  :url "https://www.gnu.org/software/emms/"
  :commit "abb4f614dae6b7e90ee1f275d8a5e40721c39d54"
  :revdesc "abb4f614dae6"
  :keywords '("emms" "mp3" "ogg" "flac" "music" "mpeg" "video" "multimedia")
  :authors '(("Jorgen Schäfer" . "forcer@forcix.cx"))
  :maintainers '(("Yoni Rabkin" . "yrk@gnu.org")))
