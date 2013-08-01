;; Granville Barnett's Emacs Config
;; granvillebarnett@gmail.com

;; Some of the settings in this file require external tools to have been
;; installed, they include:

;; - LaTeX (MacTeX)
;; - AucTeX
;; - OCaml (opam: utop + merlin)

;; Vanila Settings 
;; *****************************************************************************
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)            
(setq inhibit-startup-message t inhibit-startup-echo-area-message t)
(set-face-attribute 'default nil :height 240 :font "Menlo")
(setq ring-bell-function 'ignore)                                   
(line-number-mode t)                     
(column-number-mode t)                   
(size-indication-mode t)                 
(setq-default fill-column 80)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(setq default-major-mode 'text-mode)
(global-font-lock-mode t)
(ido-mode t)
(setq ido-enable-flex-matching t) ; fuzzy matching is a must have
(setq ido-enable-last-directory-history nil) ; forget latest selected directory

;; dump all backup files in specific location
(defun my-backup-file-name (fpath)
  "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
  (let (backup-root bpath)
    (setq backup-root "~/.emacs.d/emacs-backup")
    (setq bpath (concat backup-root fpath "~"))
    (make-directory (file-name-directory bpath) bpath)
    bpath
  )
)
(setq make-backup-file-name-function 'my-backup-file-name)

(require 'uniquify)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(server-start)

(setq mac-command-modifier 'meta)
(load-theme 'tango)


;; Elpa 
;; *****************************************************************************

(require 'package)


(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                           ("marmalade" . "http://marmalade-repo.org/packages/")
                           ("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(magit 
		      auto-complete
                      autopair
		      browse-kill-ring
		      perspective
		      rainbow-delimiters
		      haskell-mode
		      json
		      tuareg
		      evil)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))


;; Package Setup 
;; *****************************************************************************

(evil-mode)

(persp-mode)
(persp-rename "1")
(persp-switch "2")
(persp-switch "3")
(persp-switch "4")
(persp-switch "1")

(browse-kill-ring-default-keybindings) 	; m-y to browse kill ring

(require 'autopair)

;; autocomplete 
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
(setq ac-auto-show-menu 0.)		; show immediately

;; AucTeX 
;; cd into auctex dir
;; ./configure --with-texmf-dir=/usr/local/texlive/texmf-local
;; make
(add-to-list 'load-path "~/.emacs.d/auctex-11.87")
(add-to-list 'load-path "~/.emacs.d/auctex-11.87/preview")
(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)
(setq TeX-auto-save t)                  
(setq TeX-parse-self t)
(setq-default TeX-master nil)           ;set up AUCTeX to deal with
                                        ;multiple file documents.
(setq reftex-plug-into-AUCTeX t)

(setq reftex-label-alist
   '(("axiom"   ?a "ax:"  "~\\ref{%s}" nil ("axiom"   "ax.") -2)
     ("theorem" ?h "thr:" "~\\ref{%s}" t   ("theorem" "th.") -3)))

(setq reftex-cite-format 'natbib)

(defun latex-hooks()
  (set 'compile-command "rake"))

(add-hook 'LaTeX-mode-hook 'reftex-mode)
(add-hook 'LaTeX-mode-hook 'latex-hooks)

;; Hooks 
;; *****************************************************************************
(defun common-hooks() 
  (autopair-mode)
  (show-paren-mode)
  (rainbow-delimiters-mode)
  (local-set-key (kbd "M-e") 'tuareg-eval-buffer))

(add-hook 'c-mode-common-hook 'common-hooks)
(add-hook 'haskell-mode-hook 'common-hooks)

(add-to-list 'load-path "~/.opam/4.00.1/share/emacs/site-lisp/")
(require 'merlin)
(add-hook 'tuareg-mode-hook 'merlin-mode)
(add-hook 'tuareg-mode-hook 'common-hooks)
(setq merlin-use-auto-complete-mode t)
(autoload 'utop-setup-ocaml-buffer "utop" "Toplevel for OCaml" t)
(add-hook 'tuareg-mode-hook 'utop-setup-ocaml-buffer)
(add-hook 'typerex-mode-hook 'utop-setup-ocaml-buffer)

(require 'fsharp-mode)
(setq inferior-fsharp-program "/usr/bin/fsharpi --readline-")
(setq fsharp-compiler "/usr/bin/fsharpc")

;; Global Keybindings 
;; *****************************************************************************
(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))

;; replace C-x f and C-x b with some nicer alternatives
(global-set-key (kbd "M-f") 'ido-find-file)
(global-set-key (kbd "M-b") 'ido-switch-buffer)

;; I prefer this with ac
(global-set-key (kbd "M-s") 'ac-isearch)

(global-set-key (kbd "M-4") 'persp-switch)
(global-set-key (kbd "M-7") 'magit-status)
(global-set-key (kbd "M-9") 'query-replace)
(global-set-key (kbd "M-1") 'align-regexp)
(global-set-key (kbd "M-2") 'ack)

;; window stuff
;(global-set-key (kbd "M-" 'split-window-below))
(global-set-key (kbd "M-+") 'enlarge-window)
(global-set-key (kbd "M-+") 'enlarge-window)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-0") 'compile)

;; UI
;; (global-set-key [f9] 'ns-toggle-fullscreen)

;; VARIABLES
;; *****************************************************************************
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-auto-start 1)
 '(ac-modes (quote (emacs-lisp-mode d-mode lisp-mode lisp-interaction-mode slime-repl-mode c-mode cc-mode c++-mode go-mode java-mode malabar-mode clojure-mode clojurescript-mode scala-mode scheme-mode ocaml-mode tuareg-mode coq-mode haskell-mode agda-mode agda2-mode perl-mode cperl-mode python-mode ruby-mode lua-mode ecmascript-mode javascript-mode js-mode js2-mode php-mode css-mode makefile-mode sh-mode fortran-mode f90-mode ada-mode xml-mode sgml-mode ts-mode sclang-mode verilog-mode LaTeX-mode latex-mode rust-mode tuareg-interactive-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
