;; -*- mode: elisp -*-

;; disable the splash screen
;; (setq inhibit-splash-screen t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(use-package smex
  :ensure t
  :bind (("M-x" . smex))
  :config (smex-initialize))

;; org-cliplink
(use-package org-cliplink :ensure t)
(defun system-keyboard ()
  "Returns current content of system keyboard"
  (shell-command-to-string "wl-paste"))
(defun cliplink-system-keyboard ()
  "Puts system clipboard in killring, then calls `org-cliplink`"
  (interactive)
  (kill-new (system-keyboard))
  (org-cliplink))
(global-set-key (kbd "C-x p i") 'cliplink-system-keyboard)
(setq org-capture-templates
 '(("K" "Cliplink capture task" entry (file "")
    "* TODO %(org-cliplink-capture) \n  SCHEDULED: %t\n" :empty-lines 1)))


;; xdg-open is a great browser
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox-wayland")

;; display line numbers
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;; always follow symlinks
(setq vc-follow-symlinks t)

;; autosave properly (not with the #file# method)
(when (version<= "26.1" emacs-version)
  (add-hook 'org-mode-hook 'auto-save-visited-mode))

;; always autoload from disk
(global-auto-revert-mode t)

;; backup configuration (I hate *~ everywhere)
(setq backup-directory-alist `(("." . "~/.saves")))
(setq version-control t      ;; use version numbers for backups
      kept-new-versions 10   ;; number of newest versions to keep
      kept-old-versions 0    ;; number of oldest versions to keep
      delete-old-versions t  ;; don't ask to delete excess backup options
      backup-by-copying t)   ;; copy all files, don't rename them

;; I'm too used to hitting C-w in vim...
(global-set-key (kbd "C-w") 'ignore)

;; for sunrise/sunset
(require 'cl)
(require 'solar)
(setq calendar-latitude 47.608013)
(setq calendar-longitude -122.335167)
(setq calendar-location-name "Seattle, WA")

;; for global use in any file
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;;;; org mode configuration
(with-eval-after-load 'org
  (setq org-modules '(org-habit))
  (org-load-modules-maybe t)
  (load "~/org-mode/next-spec-day")
  (load "~/org-mode/meditation")
  ;; add a CLOSED stamp whenever a TOOD item is marked DONE
  (setq org-log-done 'time)
  ;; and put it in LOGBOOK
  (setq org-log-into-drawer t)
  ;; don't split line on M-RET
  (setq org-M-RET-may-split-line nil)
  ;; org-indent-mode
  (setq org-startup-indented t)
  ;; wrap lines
  (add-hook 'org-mode-hook 'visual-line-mode)
  (setf org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
  ;; estimate time before clocking in
  (defun org-set-effort-if-not-set ()
    (when (and
	   (not (org-entry-get nil "effort"))
	   (org-entry-is-todo-p)
	   (and (org-entry-get nil "style")
		(not (string= (downcase (org-entry-get nil "style")) "habit"))))
      (org-set-effort)))
  (add-hook 'org-clock-in-prepare-hook 'org-set-effort-if-not-set)

  (defun last-sunday ()
    "returns `time` of last Sunday"
    (seconds-to-time
     (string-to-number
      (calc-eval "(unixtime(newweek(now())))"))))
  (defun format-org-inactive-time-string (time)
    "formats an emacs-time as an org time string [%Y-%m-%d]"
    (format-time-string "[%Y-%m-%d]" time))
  (defun format-agenda-closed-filter (comparison-str time)
    "formats an emacs-time as a +CLOSED`comparison-str`\"`time`\""
    "expects `comparison-str` to be a string e.g. \">=\""
    (concat "+CLOSED" comparison-str "\"" (format-org-inactive-time-string time) "\""))
  (setq org-agenda-span 1) ;; show only today in agenda view
  (setq org-agenda-custom-commands
	`(("A" "[A]genda" agenda ""
	   ((org-agenda-files
	     (remove
	      "~/org-mode/habits.org"
	      (remove
	       "~/org-mode/day.org"
	       (remove
		"~/org-mode/calendar.org"
		org-agenda-files))))))
	  ("u" "[u]nschduled/undeadlined TODOs"
	   tags "-DEADLINE={.+}-SCHEDULED={.+}/!+TODO")
	  ("c" "[c]losed past week" tags
	   (concat
	    (format-agenda-closed-filter
	     ">=" (time-subtract (last-sunday) (days-to-time 6)))
	    (format-agenda-closed-filter
	     "<=" (time-add (last-sunday) (days-to-time 1)))))
	  ("d" "closed to[d]ay" tags
	   (concat "+CLOSED>=\""
		   (format-time-string "[%Y-%m-%d]" (current-time))
		   "\""))))

  (setq org-todo-keywords
	'((sequence "TODO(t)" "WIP(i)" "|" "DONE(d)")
	  (sequence "WAITING(w)" "|")
	  (sequence "|" "CANCELED(c)")))

  ;; capture
  (setq org-default-notes-file (concat org-directory "/capture.org"))
  (define-key global-map "\C-c[" 'org-capture)
  (setq org-refile-use-outline-path 'file)
  (setq org-directory-files (directory-files org-directory nil ".*\.org$"))
  (setq org-refile-targets '((nil :maxlevel . 9) (org-directory-files :maxlevel . 9)))

  ;; https://www.reddit.com/r/emacs/comments/4golh1/how_to_auto_export_html_when_saving_in_orgmode/
  (defun toggle-org-html-export-on-save ()
    (interactive)
    (if (memq 'org-html-export-to-html after-save-hook)
	(progn
	  (remove-hook 'after-save-hook 'org-html-export-to-html t)
	  (message "Disabled org html export on save for current buffer"))
      (add-hook 'after-save-hook 'org-html-export-to-html nil t)
      (message "Enabled org html export on save for current buffer")))

  (defun org-todo-with-date (&optional arg)
    (interactive "P")
    (cl-letf* ((org-read-date-prefer-future nil)
	       (my-current-time (org-read-date t t nil "when:" nil nil nil))
	       ((symbol-function 'current-time)
		#'(lambda () my-current-time))
	       ((symbol-function 'org-today)
		#'(lambda () (time-to-days my-current-time)))
	       ((symbol-function 'org-current-effective-time)
		#'(lambda () my-current-time))
	       (super (symbol-function 'format-time-string))
	       ((symbol-function 'format-time-string)
		#'(lambda (fmt &optional time time-zone)
		    (funcall super fmt my-current-time time-zone))))
      (org-todo arg)))
  (define-key org-mode-map "\C-ct" 'org-todo-with-date)
  )

;;;; org-pomodoro config
(with-eval-after-load 'org-pomodoro
  (add-hook 'org-pomodoro-finished-hook 'start-org-break-clock)
  (add-hook 'org-pomodor-break-finished-hook 'stop-org-break-clock)
  (global-set-key (kbd "C-c C-x C-p") 'org-pomodoro))

;;;; hledger-mode configuration
;; To open files with .journal extension in hledger-mode
;(add-to-list 'auto-mode-alist '("\\.journal\\'" . hledger-mode))
;(add-to-list 'auto-mode-alist '("\\.ledger\\'" . hledger-mode))
;(add-to-list 'auto-mode-alist '("\\.hledger\\'" . hledger-mode))
;(with-eval-after-load 'hledger-mode
;  ;; path to journal file
;  (setq hledger-jfile (getenv "LEDGER_FILE"))
;  ;;; Auto-completion for account names
;  ;; For company-mode users
;  (add-to-list 'company-backends 'hledger-company)
;  (company-mode))

;;;; company-mode config
(with-eval-after-load 'company-mode
					;(setq company-global-modes '(hledger-mode))
  (setq company-global-modes '(ledger-mode))
					;(add-hook 'after-init-hook 'global-company-mode)
  (global-set-key (kbd "C-\\") 'company-complete))

;; show matching parens in elisp
(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (setq show-paren-delay 0)
	    (show-paren-mode 1)))

;;;; ledger mode
(add-to-list 'auto-mode-alist '("\\.ledger$" . ledger-mode)); company-mode flymake-mode))
(add-to-list 'auto-mode-alist '("\\.journal$" . ledger-mode)); company-mode flymake-mode))

(defun birthday (year month day remind name)
  (interactive "*nYear: \nnMonth: \nnDay: \nnWarning period: \nMName: ")
  (insert (format "%%%%(diary-remind '(org-anniversary %1$04d %2$02d %3$02d) %4$d) %5$s's %%d birthday" year month day remind name)))

(defun convert-birthday (event-line)
  (interactive "*d")
  ; puts point at beginning, mark at end
  (org-mark-subtree)
  (let ((element (org-element-at-point)))))

(defun diary-sunrise ()
  (let ((dss (diary-sunrise-sunset)))
    (with-temp-buffer
      (insert dss)
      (goto-char (point-min))
      (search-forward " (")
      (buffer-substring (point-min) (match-beginning 0)))))

(defun diary-sunset ()
  (let ((dss (diary-sunrise-sunset))
        start end sunset daylight)
    (with-temp-buffer
      (insert dss)
      (goto-char (point-min))
      (search-forward ", ")
      (setq start (match-end 0))
      (search-forward " (")
      (setq end (match-beginning 0))
      (goto-char start)
      (capitalize-word 1)
      (setq sunset (buffer-substring start end))
      (search-forward "(" nil t 2)
      (setq start (match-beginning 0))
      (setq end (point-max))
      (setq daylight (buffer-substring start end))
      (concat sunset " " daylight))))

;; org-cliplink
(defun system-keyboard ()
  "Returns current content of system keyboard"
  (shell-command-to-string "wl-paste"))
(defun cliplink-system-keyboard ()
  "Puts system clipboard in killring, then calls `org-cliplink`"
  (interactive)
  (kill-new (system-keyboard))
  (org-cliplink))
(global-set-key (kbd "C-x p i") 'cliplink-system-keyboard)
(setq org-capture-templates
 '(("K" "Cliplink capture task" entry (file "")
    "* TODO %(org-cliplink-capture) \n  SCHEDULED: %t\n" :empty-lines 1)))

 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
'(calendar-chinese-all-holidays-flag t)
 '(holiday-bahai-holidays nil)
 '(holiday-hebrew-holidays nil)
 '(holiday-islamic-holidays nil)
 '(ledger-post-account-alignment-column 2)
 '(ledger-post-amount-alignment-column 70)
 '(ledger-reports
   '(("dolbal" "ledger -l \"commodity == '$'\" bal")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
 '(org-agenda-files
   '("/home/maynard/org-mode/day.org" "/home/maynard/org-mode/habits.org"))
 '(org-directory "~/org-mode")
 '(org-pomodoro-audio-player "/usr/bin/play -q -V0 -v2")
 '(org-pomodoro-finished-sound "/home/maynard/org-mode/gong.mp3")
 '(org-pomodoro-long-break-sound "/home/maynard/org-mode/long-gong.mp3")
 '(org-pomodoro-short-break-sound "/home/maynard/org-mode/gong.mp3")
 '(org-pomodoro-start-sound "/home/maynard/org-mode/gong.mp3")
 '(package-selected-packages
   '(use-package org-cliplink ## ledger-mode company org-pomodoro org)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
