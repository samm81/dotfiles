;; -*- mode: elisp -*-

;; disable the splash screen
;; (setq inhibit-splash-screen t)

;; enable transient mark mode
(transient-mark-mode 1)

;; xdg-open is a great browser
(setq browse-url-browser-function 'browse-url-generic
 browse-url-generic-program "/usr/bin/xdg-open")

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
;; don't split line on M-RET
(setq org-M-RET-may-split-line nil)
;; org-indent-mode
(setq org-startup-indented t)

(setq org-agenda-custom-commands
 `(;; match unscheduled/undeadlined TODOs
  ("u" "[u]nschduled/undeadlined TODOs" tags "-DEADLINE={.+}-SCHEDULED={.+}/!+TODO")))

(custom-set-variables
 '(org-directory "~/org-mode")
 '(org-agenda-files (list org-directory)))
