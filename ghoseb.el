;;; ghoseb.el -- My customisations
;;; Time-stamp: "2009-12-26 13:09:50 ghoseb"

(require 'cl)

;;; ----------------------
;;; General customisations
;;; ----------------------
(set-scroll-bar-mode 'nil)
(show-paren-mode 1)
(savehist-mode 1)

;; ------------
;; General Info
;; ------------
(setq user-full-name "Baishampayan Ghose")
(setq user-mail-address "bg@infinitelybeta.com")

;; ----------------------
;; Final newline handling
;; ----------------------
(setq require-final-newline t)
(setq next-line-extends-end-of-buffer nil)
(setq next-line-add-newlines nil)

;; -----------
;; Frame Setup
;; -----------
(setq initial-frame-alist '((top . 20)
                            (left . 25)
                            (width . 205)
                            (height . 58)))
(setq frame-title-format "%b")
(setq icon-title-format  "%b")

;; ---------
;; TAB Setup
;; ---------
(setq-default tab-width 4
              standard-indent 4
              indent-tabs-mode nil)

;; -------------
;; Custom colors
;; -------------
;(set-default-font "Droid Sans Mono-9")
(set-default-font "Anonymous Pro-9")
(require 'color-theme-g0sub)
(color-theme-g0sub)

;; ---------------------------
;; Better Copy-Paste behaviour
;; ---------------------------
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

;; ----------------------------------------
;; Kill current buffer without confirmation
;; ----------------------------------------
(global-set-key "\C-xk" 'kill-current-buffer)
(defun kill-current-buffer ()
  "Kill the current buffer, without confirmation."
  (interactive)
  (kill-buffer (current-buffer)))

;; --------------------
;; Several useful hooks
;; --------------------
(add-hook 'before-save-hook 'time-stamp)

;; ESK specific
(defun turn-on-highlight-parens-mode ()
  (highlight-parentheses-mode 1))

(add-hook 'coding-hook 'turn-on-highlight-parens-mode)
(remove-hook 'coding-hook 'turn-on-hl-line-mode)
(remove-hook 'clojure-mode-hook 'idle-highlight)
(remove-hook 'emacs-lisp-mode-hook 'idle-highlight)

;; ---------
;; Templates
;; ---------
(require 'template)
(template-initialize)


;;; Rudel
(defun load-rudel ()
  (interactive)
  (add-to-list 'load-path "~/src/cedet/eieio")
  (add-to-list 'load-path "~/src/cedet/common")
  (add-to-list 'load-path "~/src/rudel/")
  (add-to-list 'load-path "~/src/rudel/jupiter")
  (add-to-list 'load-path "~/src/rudel/obby")
  (require 'rudel-mode)
  (require 'rudel-obby)
  (global-rudel-minor-mode))


;; ----------
;; Multi Term
;; ----------
(require 'multi-term)
(setq multi-term-program "/bin/zsh")
(global-set-key "\C-c\M-t" 'multi-term)

;;; --------
;;; Uniquify
;;; --------
(require 'uniquify)
(eval-after-load 'uniquify
  '(progn
     (setq uniquify-buffer-name-style 'reverse)
     (setq uniquify-separator "/")
     (setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
     (setq uniquify-ignore-buffers-re "^\\*")))

;;; -------
;;; Clojure
;;; -------
(clojure-slime-config "/home/ghoseb/opt")
(defun clj ()
  "Starts Clojure in Slime"
  (interactive)
  (slime 'clojure))

(eval-after-load "slime"
  '(progn
    (setq slime-complete-symbol*-fancy t)
    (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)))


;;; ------
;;; Erlang
;;; ------
(let ((distel-dir "/home/ghoseb/opt/distel/elisp"))
  (unless (member distel-dir load-path)
    (setq load-path (append load-path (list distel-dir)))))

(require 'distel)
(distel-setup)

(add-hook 'erlang-mode-hook
          (lambda ()
            ;; when starting an Erlang shell in Emacs, default in the node name
            (setq inferior-erlang-machine-options '("-sname" "emacs"))))

(defconst distel-shell-keys
  '(("\C-\M-i"   erl-complete)
    ("\M-?"      erl-complete)	
    ("\M-."      erl-find-source-under-point)
    ("\M-,"      erl-find-source-unwind) 
    ("\M-*"      erl-find-source-unwind))
  "Additional keys to bind when in Erlang shell.")

(add-hook 'erlang-shell-mode-hook
          (lambda ()
            ;; add some Distel bindings to the Erlang shell
            (dolist (spec distel-shell-keys)
              (define-key erlang-shell-mode-map (car spec) (cadr spec)))))

;;; ------------------------
;;; Useful utility functions
;;; ------------------------

(defun full-screen-toggle ()
  "toggle full-screen mode"
  (interactive)
  (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))

(global-set-key (kbd "<f11>") 'full-screen-toggle)

(defun revert-all-buffers()
  "Refresh all open buffers from their respective files"
  (interactive)
  (let* ((list (buffer-list))
         (buffer (car list)))
    (while buffer
      (if (string-match "\\*" (buffer-name buffer))
          (progn
            (setq list (cdr list))
            (setq buffer (car list)))
        (progn
          (set-buffer buffer)
          (revert-buffer t t t)
          (setq list (cdr list))
          (setq buffer (car list))))))
  (message "Refreshing open files"))

(global-set-key (kbd "<f5>") 'revert-all-buffers)

(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn (rename-file name new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil))))))

(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
         (newname (concat dir "/" name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (progn (copy-file filename newname 1)
             (delete-file filename)
             (set-visited-file-name newname)
             (set-buffer-modified-p nil)
             t))))

;; Custom files
(setq custom-file "~/.emacs-custom.el")
(load custom-file 'noerror)

