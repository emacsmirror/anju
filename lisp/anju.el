;;; anju.el --- Mouse UX Customizations              -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Charles Choi

;; Author: Charles Choi <charles.choi@yummymelon.com>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'mouse)
(require 'windmove)
(require 'map)



;; -------------------------------------------------------------------
;; Mode Line Customization

(defun anju-window-under-mouse ()
  "Return the live window under the current mouse pointer.

Derived from code found at URL
`https://emacs.stackexchange.com/questions/21497/how-to-find-the-window-under-the-mouse-pointer'."
  (interactive)
  (let* ((mouse-pos (mouse-position))
         (frame (car mouse-pos))
         (x (cadr mouse-pos))
         (y (cddr mouse-pos))
         (window (window-at x y frame)))
    window))

;; TODO: need to figure out how to work on inactive window the mouse is pointing to
(easy-menu-define anju-windmove-swap-menu nil
  "Keymap for mouse window swap menu."
  '("Swap"
    :visible (and (eq (selected-window) (anju-window-under-mouse)) (not (one-window-p t)))
    ["↑" windmove-swap-states-up
     :visible (window-in-direction 'above)
     :help "Swap window up"]

    ["↓" windmove-swap-states-down
     :visible (window-in-direction 'below)
     :help "Swap window down"]

    ["←" windmove-swap-states-left
     :visible (window-in-direction 'left)
     :help "Swap window left"]

    ["→" windmove-swap-states-right
     :visible (window-in-direction 'right)
     :help "Swap window right"]))

(easy-menu-define anju-window-management-menu nil
  "Keymap for mouse window management menu."
  '(nil
    ["×" mouse-delete-window
     :visible (not (one-window-p t))
     :help "Delete Window"]

    ["Split →" mouse-split-window-horizontally
     :help "Split Right"]

    ["Split ↓" mouse-split-window-vertically
     :help "Split Below"]))

(easy-menu-define cc/mouse-buffer-menu nil
  "Keymap for mouse buffer menu."
  '(nil
    ["← Previous" previous-buffer
     :help "Previous Buffer"]

    ["→ Next" next-buffer
     :help "Next buffer"]

    ["List All Buffers" ibuffer
     :help "List all buffers"]))

(easy-menu-add-item anju-window-management-menu nil anju-windmove-swap-menu)

(defun anju-popup-window-management-menu (click)
  "Popup mouse window management with CLICK."
  (interactive "e")
  (popup-menu anju-window-management-menu click))

(defun anju-popup-buffer-menu (click)
  "Popup mouse buffer navigation with CLICK."
  (interactive "e")
  (popup-menu (anju--buffer-list) click)

  ;;(popup-menu cc/mouse-buffer-menu click)

  )

(defun anju--string-match-p (pat str)
  (let ((match (string-match-p pat str)))
    (if match
        (if (>= match 0)
            t nil)
      nil)))

(defun anju-temporary-buffer-filter (buf)
  "Return t if BUF name is has pattern *<name>*."
  (let ((bufname (string-trim (buffer-name buf))))
    (not
     (or
      (anju--string-match-p "^\\*.*\\*$" bufname)
      (anju--string-match-p "^\\*info\\*\\(<[[:digit:]]*>\\)*$" bufname)))))

(defun anju-info-buffer-filter (buf)
  "Return t if BUF is an Info buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'Info-mode)))

(defun anju-help-buffer-filter (buf)
  "Return t if BUF is an Info buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'help-mode)))

(defun anju--buffer-list ()
  "Vector of menu items to populate `anju-popup-buffer-menu'."
  (interactive)
  (unless recentf-mode (recentf-mode 1))

  (let* (;; (open-buffers (seq-take (buffer-list) 50))
         (open-buffers (buffer-list))
         (plain-buffers (seq-filter #'anju-temporary-buffer-filter open-buffers))
         (info-buffers (seq-filter #'anju-info-buffer-filter open-buffers))
         (help-buffers (seq-filter #'anju-help-buffer-filter open-buffers))

         (plain-buffers (seq-take plain-buffers 7))

         ;; (recent-files (seq-take recentf-list 5))
         ;; (recent-files (seq-filter
         ;;                (lambda (e)
         ;;                  (let ((bufname (buffer-file-name)))
         ;;                    (if bufname
         ;;                        (not (string-equal bufname (expand-file-name e)))
         ;;                      nil)))
         ;;                recent-files))

         (buffer-items (mapcar (lambda (buf)
                                 (vector (format "%s" (buffer-name buf))
                                         `(lambda () (interactive) (switch-to-buffer ,buf))
                                         :visible (and (eq (selected-window) (anju-window-under-mouse)))))
                               (append plain-buffers info-buffers help-buffers)
                               ;; plain-buffers
                               ))

         ;; (file-items (mapcar (lambda (file)
         ;;                       (vector (concat "File: " (file-name-nondirectory file))
         ;;                               `(lambda () (interactive) (find-file ,file))))
         ;;                     recent-files))

         (menu-items (append buffer-items
                             ;; '("---")
                             ;; file-items
                             '("---")
                             '(["Set Selected" mouse-set-point
                                :visible (not (and (eq (selected-window) (anju-window-under-mouse))))
                                :help "Set window at point as selected"]

                               ["← Previous" previous-buffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "Previous Buffer"]

                               ["→ Next" next-buffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "Next buffer"]

                               ["≣ List All Buffers" ibuffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "List all buffers"]))))
    ;; (pp cb)
    ;; (pp open-buffers)
    ;; (pp recent-files)
    menu-items))

(defvar anju--frame-register-alist nil
  "Internal dictionary for frames used by `anju-delete-other-windows'.")

(defun anju--new-register-id ()
  (let ((test t)
        (register-id nil))
    (while test
      (setq register-id (+ 8000 (random 1000))) ; TODO: need to parameterize?
      (unless (member register-id (map-values anju--frame-register-alist))
        (setq test nil)))

    (if anju--frame-register-alist
        (setq anju--frame-register-alist
              (map-insert anju--frame-register-alist (selected-frame) register-id))
      (setq anju--frame-register-alist (list `(,(selected-frame) . ,register-id))))
    register-id))

(defun anju--window-configuration-to-register ()
  "Set register id."
  (let* ((cache-register-id (map-elt anju--frame-register-alist (selected-frame)))
         (register-id (if cache-register-id
                          cache-register-id
                        (anju--new-register-id))))
    (window-configuration-to-register register-id)))

(defun anju--scrub-frame-register-list ()
  "Scrub `anju--frame-register-alist'."
  (let ((frames (seq-filter (lambda (f) (frame-live-p f)) (frame-list)))
        (keys (map-keys anju--frame-register-alist)))
    (mapc (lambda (key)
            (if (not (member key frames))
                (map-delete anju--frame-register-alist key)))
          keys)))

(defun anju-delete-other-windows (&optional window interactive)
  "Make WINDOW fill its frame.
- INTERACTIVE is passed to `delete-other-windows'."
  (interactive "i\np")
  (anju--scrub-frame-register-list)
  (if (one-window-p t)
      (progn
        (let ((register-id (map-elt anju--frame-register-alist (selected-frame))))
          (if register-id
              (jump-to-register register-id)))
        (message "Only one window."))
    (progn
      (anju--window-configuration-to-register)
      (delete-other-windows window interactive))))

(defun anju--unset-mouse-legacy-bindings ()
  "Routine to unset Emacs legacy mouse keybindings."
  (keymap-global-unset "<mode-line> C-<mouse-2>" t)
  (keymap-global-unset "<vertical-scroll-bar> C-<mouse-2>" t)
  (keymap-global-unset "<horizontal-scroll-bar> C-<mouse-2>" t)
  (keymap-global-unset "<vertical-line> C-<mouse-2>" t)
  (keymap-global-unset "<right-divider> C-<mouse-2>" t)
  (keymap-global-unset "<bottom-divider> C-<mouse-2>" t)
  (keymap-global-unset "<mode-line> <mouse-2>" t)
  (keymap-global-unset "<mode-line> <mouse-3>" t)
  (keymap-global-unset "<mode-line> <double-mouse-1>" t)
  (keymap-unset mode-line-buffer-identification-keymap "<mode-line> <mouse-1>" t)
  (keymap-unset mode-line-buffer-identification-keymap "<mode-line> <mouse-3>" t))

(defun anju--set-mode-line-bindings ()
  "Set Anju bindings."
  (keymap-set mode-line-buffer-identification-keymap
              "<mode-line> <mouse-1>"
              #'anju-popup-buffer-menu)

  (keymap-global-set "<mode-line> <double-mouse-1>" #'anju-delete-other-windows)

  ;; (keymap-global-set "<vertical-scroll-bar> <mouse-3>"
  ;;                    #'mouse-split-window-vertically)

  (keymap-global-set "<mode-line> <down-mouse-3>"
                     #'anju-popup-window-management-menu))


;; -------------------------------------------------------------------
;; Help Menu Customization

(defun anju--command-in-new-frame (cmd)
  "Invoke CMD in a new frame.
This command creates a new frame populated by CMD."
  (other-frame-prefix)
  (call-interactively cmd))

(defun anju--reconfigure-help-menu ()
  "Reconfigure help menu."
  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Info in New Frame"
                       (lambda ()
                         (interactive)
                         (anju--command-in-new-frame #'info))
                       :help "Show Info manual in new frame."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["New Info in New Frame…"
                       (lambda ()
                         (interactive)
                         (anju--command-in-new-frame #'info-display-manual))
                       :help "Show new Info manual in new frame."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Man Page in New Frame…"
                       (lambda ()
                         (interactive)
                         (anju--command-in-new-frame #'man))
                       :help "Show man page in new frame."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Describe Symbol…"
                       describe-symbol
                       :help "Describe symbol."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Describe Key or Mouse…"
                       describe-key
                       :help "Describe key or mouse operation."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Library Commentary…"
                       finder-commentary
                       :help "Show commentary for Elisp library."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Emacs FAQ"
                       view-emacs-FAQ
                       :help "View Emacs FAQ."]
                      'describe-copying)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Emacs News"
                       view-emacs-news
                       :help "View Emacs news about this release."]
                      'describe-copying)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Emacs Known Problems"
                       view-emacs-problems
                       :help "View Emacs known problems."]
                      'describe-copying)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Send Bug Report…"
                       report-emacs-bug
                       :help "Send Emacs bug report."]
                      'describe-copying)

  (define-key global-map [menu-bar help-menu  emacs-tutorial] nil t)
  (define-key global-map [menu-bar help-menu  emacs-tutorial-language-specific] nil t)
  (define-key global-map [menu-bar help-menu  emacs-psychotherapist] nil t)
  (define-key global-map [menu-bar help-menu  more-manuals] nil t)
  (define-key global-map [menu-bar help-menu  emacs-manual] nil t)
  (define-key global-map [menu-bar help-menu  getting-new-versions] nil t)
  (define-key global-map [menu-bar help-menu  describe-copying] nil t)
  (define-key global-map [menu-bar help-menu  describe-no-warranty] nil t)
  (define-key global-map [menu-bar help-menu  about-gnu-project] nil t)
  (define-key global-map [menu-bar help-menu  external-packages] nil t)
  (define-key global-map [menu-bar help-menu  emacs-faq] nil t)
  (define-key global-map [menu-bar help-menu  emacs-news] nil t)
  (define-key global-map [menu-bar help-menu  emacs-known-problems] nil t)
  (define-key global-map [menu-bar help-menu  emacs-manual-bug] nil t)
  (define-key global-map [menu-bar help-menu  send-emacs-bug-report] nil t)
  (define-key global-map [menu-bar help-menu  getting-new-versions] nil t)
  (define-key global-map [menu-bar help-menu  about-gnu-project] nil t))


;; -------------------------------------------------------------------
;; Initialization Routines

(defcustom anju-reconfigure-menu-hook nil
  "Main menu mode hooks to run in `anju-init'."
  :type 'hook
  :options '(anju--reconfigure-help-menu)
  :group 'anju)

(defun anju-init ()
  "Initialization for Anju."
  (interactive)
  (anju--unset-mouse-legacy-bindings)
  (anju--set-mode-line-bindings)

  ;; file
  ;; edit
  ;; bookmarks
  ;; tools

  (run-hooks 'anju-reconfigure-menu-hook)

  ;; (anju--reconfigure-help-menu)
  )

(provide 'anju)
;;; anju.el ends here
