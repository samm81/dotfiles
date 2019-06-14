;; -*- mode: elisp -*-

;; disable the splash screen
;; (setq inhibit-splash-screen t)

;; enable transient mark mode
(transient-mark-mode 1)

;; xdg-open is a great browser
(setq browse-url-browser-function 'browse-url-generic
 browse-url-generic-program "xdg-open")

;;;; org mode configuration
(with-eval-after-load 'org
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
  ;; wrap lines
  (add-hook 'org-mode-hook 'visual-line-mode)
  ;; autosave properly (not with the #file# method)
  ;; requires emacs 26.1
  (add-hook 'org-mode-hook 'auto-save-visited-mode)
  ;; autoload
  (add-hook 'org-mode-hook 'global-auto-revert-mode)

  (setq org-agenda-custom-commands
   `(;; match unscheduled/undeadlined TODOs
     ("u" "[u]nschduled/undeadlined TODOs" tags "-DEADLINE={.+}-SCHEDULED={.+}/!+TODO")
     ;; match all closed items in the past week
     ("c" "[c]losed in past week" tags
      (concat "+CLOSED>=\"" (format-time-string "[%Y-%m-%d]"
                  (time-subtract (current-time) (days-to-time 7)))
        "\""))))

  (setq org-refile-use-outline-path 'file)

  (custom-set-variables
   '(org-agenda-files '("~/org-mode"))
   '(org-directory "~/org-mode"))

  ;; capture
  (setq org-default-notes-file (concat org-directory "/capture.org"))
  (define-key global-map "\C-c[" 'org-capture)
  (setq org-refile-targets '((nil :maxlevel . 9) (org-agenda-files :maxlevel . 9)))
  ; (setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
  ; (setq org-refile-use-outline-path t)                  ; Show full paths for refiling
  )
