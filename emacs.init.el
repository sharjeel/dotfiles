;; Look & Feel (This should be copied into main init.el for safe loading)

;; (if (display-graphic-p)
;;     (load-theme 'sanityinc-tomorrow-eighties nil nil)
;;   (load-theme 'sanityinc-tomorrow-night nil nil))

(ignore-errors
  (require 'color-theme-sanityinc-tomorrow))

(require 'package)
(require 'cl)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq visible-bell t)               ; No beeps, bell on errors
(menu-bar-mode t)                   ; Menu bar visible
(tool-bar-mode -1)                  ; Toolbar disbaled
(setq scroll-step 1)                ; Smooth scrolling
(setq mouse-wheel-follow-mouse 't)  ; scroll window under mouse
(setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling

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
(electric-pair-mode 1)
(delete-selection-mode 1); delete selected text when typing
(global-linum-mode 1)
(column-number-mode 1)
(recentf-mode 1) ; keep a list of recently opened files
(tabbar-mode 1)
(modify-all-frames-parameters (list (cons 'cursor-type 'bar)))
 
(remove-hook 'text-mode-hook #'turn-on-auto-fill)
(setq flyspell-issue-welcome-flag nil) ;; fix flyspell problem

;; Zencoding mode
(if (fboundp 'zencoding-mode)
    (zencoding-mode (quote toggle)) )
 
;; Yasnippet
(require 'yasnippet nil t)
(if (fboundp 'yas-global-mode)
    (yas-global-mode 1) )
(setq yas-snippet-dirs
    (delete-if-not 'file-directory-p
      '("~/.personalconfig/emacs/snippets/" ;; personal snippets collection
	"~/.emacs.d/yasnippet-snippets"     ;; yasnippet snippets
	"~/.emacs.d/work-snippets"          ;; machine specific snippets
	"~/.emacs.d/snippets"               ;; misc
        )))

 
;; Python related stuff
(setq python-indent 4)
(add-hook 'python-mode-hook
          (lambda ()
               (setq tab-width 4)
               (setq tab-always-indent t)
               (indent-tabs-mode  nil)))
 
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

; helm if available, otherwise ido
(if (file-exists-p "~/.emacs.d/helm")
    (progn
      (add-to-list 'load-path (expand-file-name "~/emacs.d/helm"))
      (require 'helm-config)
      (helm-mode 1))
  (ignore-errors
    (smex-initialize)
    (setq ido-ubiquitous t)))

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
