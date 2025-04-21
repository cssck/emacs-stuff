(defvar my-emacs-tiling-window-manager-regexp "bspwm\\|herbstluftwm\\|i3"
  "Regular expression to  tiling window managers.
See definition of `my-emacs-with-desktop-session'.")

(defmacro my-emacs-with-desktop-session (&rest body)
  "Expand BODY if desktop session is not a tiling window manager.
See `my-emacs-tiling-window-manager-regexp' for what
constitutes a matching tiling window manager."
  (declare (indent 0))
  `(when-let* ((session (getenv "DESKTOP_SESSION"))
               ((not (string-match-p session my-emacs-tiling-window-manager-regexp))))
     ,@body))

(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      frame-title-format '("%b")
      ring-bell-function 'ignore
      use-dialog-box t ; only for mouse events
      use-file-dialog nil
      use-short-answers t
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-x-resources t
      inhibit-startup-echo-area-message user-login-name
      inhibit-startup-buffer-menu t)

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
