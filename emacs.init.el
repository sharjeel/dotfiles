;; Look & Feel (This should be copied into main init.el for safe loading)

;; (if (display-graphic-p)
;;     (load-theme 'sanityinc-tomorrow-eighties nil nil)
;;   (load-theme 'sanityinc-tomorrow-night nil nil))

(ignore-errors
  (require 'color-theme-sanityinc-tomorrow))

(require 'package)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

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
 
;; Multiple cursors
(when (require 'multiple-cursors nil 'no-error)
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C-,") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/1mark-previous-like-this)
  (global-set-key (kbd "C-c C-,") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-.") 'mc/mark-more-like-this-extended) )

; helm if available, otherwise ido
(if (file-exists-p "~/.emacs.d/helm")
    (progn
      (add-to-list 'load-path (expand-file-name "~/emacs.d/helm"))
      (require 'helm-config)
      (helm-mode 1))
  (ignore-errors
    (smex-initialize)
    (setq ido-ubiquitous t)))

; Auto load disk changes
(global-auto-revert-mode t)
