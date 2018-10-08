;; -*- mode: elisp -*-

;; disable the splash screen
;; (setq inhibit-splash-screen t)

;; enable transient mark mode
(transient-mark-mode 1)

;;;; org mode configuration
;; enable org mode
(require 'org)
;; make org work with files ending in .org
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
;; The above is the default in recent emacsen

(global-set-key "\C-ca" 'org-agenda)
