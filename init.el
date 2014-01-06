;; Granville Barnett's Emacs Config
;; granvillebarnett@gmail.com

;; Prerequisites:
;; - OCaml (utop + merlin + ocp-indent)

;; Structure
;; - GUI + Basics 
;; - Elpa 
;; - Package Configuration
;; - Hooks
;; - Global Keybindings

;; *****************************************************************************
;; GUI + Basics
;; *****************************************************************************
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)            
(setq inhibit-startup-message t inhibit-startup-echo-area-message t)
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


;; *****************************************************************************
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
                      autopair
		      perspective
		      rainbow-delimiters
		      haskell-mode
		      google-this
		      ack-and-a-half
                      auto-complete
		      solarized-theme
		      tuareg
		      scala-mode2
		      sbt-mode
		      sml-mode
		      evil)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; *****************************************************************************
;; Package Configuration 
;; *****************************************************************************
(require 'solarized-dark-theme)

(evil-mode)

(persp-mode)
(persp-rename "1")
(persp-switch "2")
(persp-switch "3")
(persp-switch "4")
(persp-switch "1")

;; autocomplete 
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
(setq ac-auto-show-menu 0.)		; show immediately

;; AucTeX: not elpa. 
(add-to-list 'load-path "~/.emacs.d/no-elpa/auctex")
(add-to-list 'load-path "~/.emacs.d/no-elpa/auctex/preview")
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
(add-hook 'LaTeX-mode-hook 'reftex-mode)

;; OCaml: not elpa. Install via opam: merlin, ocp-indent, utop
(add-to-list 'load-path "~/.opam/4.01.0/share/emacs/site-lisp/")
(require 'merlin)
(setq merlin-use-auto-complete-mode t)
(autoload 'utop-setup-ocaml-buffer "utop" "Toplevel for OCaml" t)
(load-file "~/.opam/4.01.0/share/emacs/site-lisp/ocp-indent.el")

;; f#
(setq inferior-fsharp-program "/usr/bin/fsharpi --readline-")
(setq fsharp-compiler "usr/bin/fsharpc")

;; *****************************************************************************
;; Hooks 
;; *****************************************************************************
(defun common-hooks() 
  (autopair-mode)
  (show-paren-mode)
  (rainbow-delimiters-mode))

(defun scala-hooks()
  (local-set-key (kbd "M-e") 'sbt-send-region))

;; Scala
(add-hook 'scala-mode-hook 'common-hooks)
(add-hook 'scala-mode-hook 'scala-hooks)
(add-hook 'sbt-mode-hook 'common-hooks)

;; Ocaml
(defun ocp-indent-buffer ()
  (interactive nil)
  (ocp-indent-region (point-min) (point-max)))

(defun ocaml-hooks()
  (local-set-key (kbd "M-e") 'tuareg-eval-buffer)
  (local-set-key (kbd "M-/") 'utop-edit-complete)
  (local-set-key (lbd "M-q") 'ocp-indent-buffer))

(defun repl-hooks()
  (autopair-mode)
  (rainbow-delimiters-mode))

(add-hook 'utop-mode-hook 'repl-hooks)
(add-hook 'tuareg-mode-hook 'common-hooks)
(add-hook 'tuareg-mode-hook 'ocaml-hooks)
(add-hook 'tuareg-mode-hook 'merlin-mode)
(add-hook 'tuareg-mode-hook 'common-hooks)
(add-hook 'tuareg-mode-hook 'utop-setup-ocaml-buffer)
(add-hook 'typerex-mode-hook 'utop-setup-ocaml-buffer)

;; Haskell
(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)
(add-hook 'haskell-mode-hook 'turn-on-haskell-unicode-input-method)
(add-hook 'haskell-mode-hook 'common-hooks)

(defun haskell-hooks()
  (local-set-key (kbd "M-e") 'inferior-haskell-load-file))
(add-hook 'haskell-mode-hook 'haskell-hooks)

;; F# hooks
(defun fsharp-hooks()
  (common-hooks)
  (local-set-key (kbd "M-e") 'fsharp-eval-phrase))
(add-hook 'fsharp-mode-hook 'fsharp-hooks)

;; C 
(setq c-default-style "linux" c-basic-offset 4)

(defun c-hooks()
  (local-set-key (kbd "RET") 'newline-and-indent)
  (c-set-offset 'arglist-intro '+)	; aligns args split across lines
)

(add-hook 'c-mode-common-hook 'common-hooks)
(add-hook 'c-mode-common-hook 'c-hooks)

;; *****************************************************************************
;; Global Keybindings 
;; *****************************************************************************

;; Buffers, info in general
(global-set-key (kbd "M-f") 'ido-find-file)
(global-set-key (kbd "M-b") 'ido-switch-buffer)
(global-set-key (kbd "M-?") 'google-this)
(global-set-key (kbd "M-9") 'query-replace)
(global-set-key (kbd "M-0") 'ack-and-a-half)

;; Packages...
(global-set-key (kbd "M-4") 'persp-switch)
(global-set-key (kbd "M-7") 'magit-status)
(global-set-key (kbd "M--") 'ac-isearch)

;; window stuff
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-+") 'enlarge-window)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-m") 'compile)


;; Variable 
;; -----------------------------------------------------------------------------
(setq mac-option-modifier 'super)
(setq mac-command-modifier 'meta)
;;(set-face-attribute 'default nil :height 160)
(set-face-attribute 'default nil :height 160)
(global-unset-key (kbd "M-3"))
(global-set-key (kbd "M-3") '(lambda() (interactive) (insert-string "#")))
;; -----------------------------------------------------------------------------

;; Junk
;; -----------------------------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-modes (quote (emacs-lisp-mode prolog-mode
 prolog-inferior-mode bibtex-mode d-mode lisp-mode latex-mode
 fsharp-mode inferior-fsharp-mode LaTeX-mode
 lisp-interaction-mode slime-repl-mode c-mode cc-mode c++-mode
 go-mode java-mode malabar-mode clojure-mode clojurescript-mode
 scala-mode sbt-mode scheme-mode ocaml-mode tuareg-mode coq-mode
 haskell-mode agda-mode agda2-mode perl-mode erlang-mode
 cperl-mode python-mode ruby-mode lua-mode ecmascript-mode
 javascript-mode js-mode js2-mode php-mode css-mode makefile-mode
 sh-mode fortran-mode f90-mode ada-mode xml-mode sgml-mode
 ts-mode verilog-mode markdown-mode sml-mode erlang-shell-mode
 rust-mode inferior-sml-mode)))
 '(custom-safe-themes (quote ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "b1e54397de2c207e550dc3a090844c4b52d1a2c4a48a17163cce577b09c28236"
 default))) '(sml-indent-level 2))
;; -----------------------------------------------------------------------------
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
