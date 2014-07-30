;;; init.el --- Where all the magic begins
;;
;; Part of the Emacs Starter Kit
;;
;; This is the first thing to get loaded.
;;

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; Look & Feel (This should be copied into main init.el for safe loading)
; (load-theme (quote monokai) nil nil)
; (load-theme (quote solarized-dark) nil nil)

(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq visible-bell t)
(menu-bar-mode t)

(ignore-errors
  (cond ((eq system-type 'windows-nt)
B	 (set-face-attribute 'default nil :font "Consolas 10")
	 ; (set-face-attribute 'default nil :font "Droid Sans Mono 10")
	 (scroll-bar-mode 0)
	 )
	((eq system-type 'gnu/linux)
	 (set-face-attribute 'default nil :font "DejaVu Sans Mono 10")
	 )
	)
  )
 
(auto-fill-mode -1)
(setq flyspell-issue-welcome-flag nil) ;; fix flyspell problem
 
(remove-hook 'text-mode-hook #'turn-on-auto-fill)
(setq flyspell-issue-welcome-flag nil) ;; fix flyspell problem

(if (fboundp 'zencoding-mode)
    (zencoding-mode (quote toggle)) )
 
;; Yasnippet
(require 'yasnippet nil t)
(if (fboundp 'yas-global-mode)
    (yas-global-mode 1) )
 
;; Python related stuff
(setq python-indent 4)
(add-hook 'python-mode-hook
          (lambda ()
               (setq tab-width 4)
               (setq tab-always-indent t)
               (indent-tabs-mode  nil)))
 
