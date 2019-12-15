(if (display-graphic-p)
    (setq theme-to-load 'sanityinc-tomorrow-eighties)
  (setq theme-to-load 'sanityinc-tomorrow-eighties))

;; Look & Feel (This should be copied into main init.el for safe loading) 
;; (load-theme theme-to-load nil nil)
;; (if (daemonp)
;;     (add-hook 'after-make-frame-functions
;;               (lambda (frame)
;;                 (select-frame frame)
;;                 (load-theme theme-to-load t)))
;;       (load-theme theme-to-load t))

(ignore-errors
  (require 'color-theme-sanityinc-tomorrow))

(require 'package)
(require 'cl)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq visible-bell t)               ; No beeps, bell on errors
(menu-bar-mode t)                   ; Menu bar visible
(tool-bar-mode -1)                  ; Toolbar disbaled
(setq scroll-step 1)                ; Smooth scrolling
(setq mouse-wheel-follow-mouse 't)  ; scroll window under mouse
(setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling
(scroll-bar-mode 0)

(ignore-errors
  (cond ((eq system-type 'windows-nt)
	 ; (set-face-attribute 'default nil :font "Consolas 10")
	 (set-face-attribute 'default nil :font "Droid Sans Mono 10")
	 (scroll-bar-mode 0) )
	((eq system-type 'gnu/linux)
	 (set-face-attribute 'default nil :font "DejaVu Sans Mono 10")
	 )))

;; C-c left, C-c right for winner undo/redo
(winner-mode 1)

(remove-hook 'text-mode-hook #'turn-on-auto-fill)
(auto-fill-mode -1)
(turn-off-auto-fill)
(setq flyspell-issue-welcome-flag nil) ;; fix flyspell problem
(electric-pair-mode 1)
(delete-selection-mode 1); delete selected text when typing
(column-number-mode 1)
(recentf-mode 1) ; keep a list of recently opened files
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
	"~/.emacs.d/yasnippet-snippets/snippets/"     ;; yasnippet snippets
	"~/.emacs.d/work-snippets"          ;; machine specific snippets
	"~/.emacs.d/snippets"               ;; misc
        )))

(defun snippets ()
  (interactive)
  (let ((choice (car (completing-read-multiple "Directory: " yas-snippet-dirs))))
    (find-file choice)))


;; Python related stuff
(setq python-indent 4)
(add-hook 'python-mode-hook
          (lambda ()
               (setq tab-width 4)
               (setq tab-always-indent t)
               (indent-tabs-mode  nil)))

;; Don't ask about following symbolic link to git-controlled source file
(setq vc-follow-symlinks t)
 
;; Personal key preferences
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-v") 'yank)
(global-set-key (kbd "C-c C-v") 'scroll-up-command)
(global-set-key (kbd "C-c M-v") 'scroll-down-command)

;; Tmux
(defun emamux-copy-region ()
  (interactive)
  (if (region-active-p)
      (progn
	(kill-ring-save (region-beginning) (region-end))
	(emamux:copy-kill-ring 0))))
(global-set-key (kbd "C-M-w") 'emamux-copy-region)

;; Splitting screen should be simpler
(global-set-key (kbd "C-x |") 'split-window-right)
(global-set-key (kbd "C-x -") 'split-window-below)

;; tmux like keybindings
(define-key input-decode-map "\e\eOA" [(meta up)])
(define-key input-decode-map "\e\eOB" [(meta down)])
(define-key input-decode-map "\e\eOD" [(meta left)])
(define-key input-decode-map "\e\eOC" [(meta right)])
(global-set-key [(meta up)] 'windmove-up)
(global-set-key [(meta down)] 'windmove-down)
(global-set-key [(meta left)] 'windmove-left)
(global-set-key [(meta right)] 'windmove-right)

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))
(global-set-key (kbd "C-c <down>") 'windmove-down)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)

;; Ace-jump
(when (require 'ace-jump-mode nil 'no-error)
  (global-set-key (kbd "<f1>") 'ace-jump-mode)
  (global-set-key (kbd "<f2>") 'ace-jump-mode)
  (global-set-key (kbd "C-c SPC") 'ace-jump-mode)
  (global-set-key (kbd "M-s s") 'ace-jump-mode)
  (global-set-key (kbd "M-s M-s") 'ace-jump-mode)
  (global-set-key (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
  (global-set-key (kbd "M-s x") 'ace-jump-mode-pop-mark))

;; Multiple cursors
(when (require 'multiple-cursors nil 'no-error)
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C-,") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/1mark-previous-like-this)
  (global-set-key (kbd "C-c C-,") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-.") 'mc/mark-more-like-this-extended))

;; Key-chords
(when (require 'keychord nil 'no-error)
  (key-chord-mode 1)
  (key-chord-define-global "`]" 'yank)
  (key-chord-define-global "cv" 'yank)
  (key-chord-define-global "uy" (insert "uytfe"))
  (key-chord-define-global "xj" 'smex)
  (key-chord-define-global "xo" 'other-window)
  (key-chord-define-global "xs" 'save-some-buffers)
  (key-chord-define-global "xb" 'ido-switch-buffer)
  (when (require 'emamux nil 'no-error)
    (key-chord-define-global "tw"
     (lambda ()
       (interactive)
       (call-interactively 'kill-ring-save (this-command-keys-vector))
       (call-interactively 'emamux:copy-kill-ring (this-command-keys-vector)))))
  (when (require 'evil nil 'no-error)
    (key-chord-define-global "ev" 'evil-mode))
  (when (require 'ace-jump-mode nil 'no-error)
    (key-chord-define-global "fj" 'ace-jump-char-mode)))


; helm if available, otherwise ido
(if (file-exists-p "~/.emacs.d/helm/helm-config.elc")
    (progn
      (add-to-list 'load-path (expand-file-name "~/.emacs.d/helm"))
      (require 'helm-config)
      (helm-mode 1))
  (ignore-errors
    (progn
      (smex-initialize)
      (setq ido-ubiquitous t)
      (ido-mode t))))

;; powerline, if available
(add-to-list 'load-path "~/.emacs.d/vendor/emacs-powerline")
(when (require 'powerline nil 'no-error)
  (powerline-default-theme)
  (scroll-bar-mode -1)
  (custom-set-faces
   '(mode-line ((t (:foreground "#030303" :background "#bdbdbd" :box nil))))
   '(mode-line-inactive ((t (:foreground "#f9f9f9" :background "#666666" :box nil))))))

;; web-mode
(when (require 'web-mode nil 'no-error)
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode)))

;; Automatically start server if in graphical mode
(if (display-graphic-p)  
    (server-start))
;; Confirm before exiting if server is running
(add-hook 'kill-emacs-query-functions
	  (lambda () (if (and (fboundp 'server-running-p) (server-running-p) )
			 (y-or-n-p "Server is running. Do you really want to quit?")
		       t)))

(custom-set-variables 
  ;; Temporary files which are cleaned up in emacs client sessions
  '(server-temp-file-regexp "^/tmp/Re\\|/draft$\\|COMMIT_EDITMSG$"))


;; Automatically refresh reload unmodified buffers when buffers get changed
(global-auto-revert-mode t)

;; ediff
(setq ediff-split-window-function 'split-window-horizontally)

;; evil
;; (when (require 'evil nil 'no-error)
;;   (define-key evil-normal-state-map "\C-e" 'move-end-of-line)
;;   (define-key evil-insert-state-map "\C-e" 'move-end-of-line)
;;   (define-key evil-visual-state-map "\C-e" 'move-end-of-line)
;;   (define-key evil-motion-state-map "\C-e" 'move-end-of-line)
;;   (define-key evil-normal-state-map "\C-f" 'forward-char)
;;   (define-key evil-insert-state-map "\C-f" 'forward-char)
;;   (define-key evil-insert-state-map "\C-f" 'forward-char)
;;   (define-key evil-normal-state-map "\C-b" 'backward-char)
;;   (define-key evil-insert-state-map "\C-b" 'backward-char)
;;   (define-key evil-visual-state-map "\C-b" 'backward-char)
;;   (define-key evil-normal-state-map "\C-d" 'delete-char)
;;   (define-key evil-insert-state-map "\C-d" 'delete-char)
;;   (define-key evil-visual-state-map "\C-d" 'delete-char)
;;   (define-key evil-normal-state-map "\C-n" 'next-line)
;;   (define-key evil-insert-state-map "\C-n" 'next-line)
;;   (define-key evil-visual-state-map "\C-n" 'next-line)
;;   (define-key evil-normal-state-map "\C-p" 'previous-line)
;;   (define-key evil-insert-state-map "\C-p" 'previous-line)
;;   (define-key evil-visual-state-map "\C-p" 'previous-line)
;;   (define-key evil-normal-state-map "\C-w" 'delete)
;;   (define-key evil-insert-state-map "\C-w" 'delete)
;;   (define-key evil-visual-state-map "\C-w" 'delete)
;;   (define-key evil-normal-state-map "\C-y" 'yank)
;;   (define-key evil-insert-state-map "\C-y" 'yank)
;;   (define-key evil-visual-state-map "\C-y" 'yank)
;;   (define-key evil-normal-state-map "\C-k" 'kill-line)
;;   (define-key evil-insert-state-map "\C-k" 'kill-line)
;;   (define-key evil-visual-state-map "\C-k" 'kill-line)
;;   (define-key evil-normal-state-map "Q" 'call-last-kbd-macro)
;;   (define-key evil-visual-state-map "Q" 'call-last-kbd-macro)
;;   (define-key evil-normal-state-map (kbd "TAB") 'evil-undefine)
;;   (define-key evil-insert-state-map "\C-z" 'evil-normal-state)

;;   (defun evil-undefine ()
;;     (interactive)
;;     (let (evil-mode-map-alist)
;;       (call-interactively (key-binding (this-command-keys)))))

;;   (evil-mode 1)
;;   (setq evil-move-cursor-back nil))

(defun init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun myinit ()
  (interactive)
  (find-file "~/.personalconfig/emacs.init.el"))
