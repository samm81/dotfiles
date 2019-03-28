;; -*- mode: elisp -*-

;; disable the splash screen
;; (setq inhibit-splash-screen t)

;; enable transient mark mode
(transient-mark-mode 1)

;; xdg-open is a great browser
(setq browse-url-browser-function 'browse-url-generic
 browse-url-generic-program "xdg-open")

;; please wrap lines
(visual-line-mode t)

;;;; org mode configuration
;; enable org mode
(require 'org)
;; make org work with files ending in .org
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;; The above is the default in recent emacsen

(global-set-key "\C-ca" 'org-agenda)
;; add a CLOSED stamp whenever a TOOD item is marked DONE
(setq org-log-done 'time)
;; and put it in LOGBOOK
(setq org-log-into-drawer t)
;; don't split line on M-RET
(setq org-M-RET-may-split-line nil)
;; org-indent-mode
(setq org-startup-indented t)
;; don't add newlines after a heading
(setq org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))

(setq org-agenda-custom-commands
 `(;; match unscheduled/undeadlined TODOs
   ("u" "[u]nschduled/undeadlined TODOs" tags "-DEADLINE={.+}-SCHEDULED={.+}/!+TODO")
   ;; match all closed items in the past week
   ("c" "[c]losed in past week" tags
    (concat "+CLOSED>=\"" (format-time-string "[%Y-%m-%d]"
					      (time-subtract (current-time) (days-to-time 7)))
	    "\""))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   (quote
    ("~/org-mode/2019.org" "~/org-mode/capture.org" "~/org-mode/todo.org" "~/org-mode/travel.org" "~/org-mode/notes.org" "~/org-mode/china-blog.org" "~/org-mode/blog.org")))
 '(org-directory "~/org-mode"))

;; capture
(setq org-default-notes-file (concat org-directory "/capture.org"))
(define-key global-map "\C-c[" 'org-capture)
(setq org-refile-targets '((nil :maxlevel . 9) (org-agenda-files :maxlevel . 9)))
; (setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
; (setq org-refile-use-outline-path t)                  ; Show full paths for refiling
