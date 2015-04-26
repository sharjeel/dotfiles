(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; Look & Feel (This should be copied into main init.el for safe loading)
;; (if (display-graphic-p)
;;     (load-theme 'sanityinc-tomorrow-eighties nil nil)
;;   (load-theme 'sanityinc-tomorrow-night nil nil))

(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq visible-bell t)
(menu-bar-mode t)

(ignore-errors
  (cond ((eq system-type 'windows-nt)
	 (set-face-attribute 'default nil :font "Consolas 10")
	 ; (set-face-attribute 'default nil :font "Droid Sans Mono 10")
	 (scroll-bar-mode 0) )
	((eq system-type 'gnu/linux)
	 (set-face-attribute 'default nil :font "DejaVu Sans Mono 10")
	 )))

(remove-hook 'text-mode-hook #'turn-on-auto-fill)
(auto-fill-mode -1)
(turn-off-auto-fill)
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
               (indent-tabs-mode  nil))) ;
 
;; Personal key preferences
(global-set-key (kbd "C-z") 'undo-tree-undo)

;; Multiple cursors
(when (require 'multiple-cursors nil 'no-error)
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C-,") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/1mark-previous-like-this)
  (global-set-key (kbd "C-c C-,") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-.") 'mc/mark-more-like-this-extended) )

;; Key-chords
(when (require 'keychord nil 'no-error)
  (key-chord-mode 1)
  (key-chord-define-global "fj" 'smex)
  (key-chord-define-global "cv" 'yank)
  (key-chord-define-global "xo" 'other-window)
  (key-chord-define-global "xs" 'save-some-buffers)
  (key-chord-define-global "xb" 'ido-switch-buffer))
  ; (when (require 'evil nil 'no-error)
  ;  (key-chord-define-global "jk" 'evil-mode)))

;; Automatically start server if in graphical mode
(if (display-graphic-p)  
    (server-start))
; Confirm before exiting if server is running
(add-hook 'kill-emacs-query-functions
	  (lambda () (if (and (fboundp 'server-running-p) (server-running-p) )
			 (y-or-n-p "Server is running. Do you really want to quit?")
		       t)))

;; Automatically refresh reload unmodified buffers when buffers get changed
(global-auto-revert-mode t)
