;;; anju-main-menu.el --- Main Menu Customization    -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Charles Choi

;; Author: Charles Choi <kickingvegas@gmail.com>
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
(require 'bookmark)
(require 'make-mode)
(require 'org)
(require 'markdown-mode)
(require 'anju-utils)
(require 'anju-style-text)
(require 'casual-bookmarks)


;; -------------------------------------------------------------------
;; File Menu Customization
(easy-menu-define anju-window-swap-menu nil
  "Keymap for mouse window swap menu."
  '("Swap Window"
    :visible (not (one-window-p t))
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

(defun anju-main-menu--reconfigure-file ()
  "Reconfigure File menu."
  (easy-menu-add-item global-map '(menu-bar file)
                      anju-window-swap-menu
                      'one-window)

  (when anju-file-menu-replace-make-frame-on
    (define-key global-map [menu-bar file make-frame-on-display] nil t)
    (define-key global-map [menu-bar file make-frame-on-monitor] nil t)

    (easy-menu-add-item (lookup-key global-map [menu-bar file]) nil
                        ["New Frame on Display Server..."
                         make-frame-on-display
                         :visible (and (fboundp 'make-frame-on-display)
                                       (eq (window-system) 'x))
                         :help "Open a new frame on a display server"]
                        'delete-this-frame)
    (easy-menu-add-item (lookup-key global-map [menu-bar file]) nil
                        ["New Frame on Monitor..."
                         make-frame-on-monitor
                         :visible
                         (and (fboundp 'make-frame-on-monitor)
                              (> (length (display-monitor-attributes-list)) 1)
                              (if (eq (window-system) 'ns) ; this is fixed in 31+
                                  (version<= "31" emacs-version)
                                  t))
                         :help "Open a new frame on another monitor"]
                        'delete-this-frame)))


;; -------------------------------------------------------------------
;; Options Menu
(defun anju-main-menu--reconfigure-options ()
  "Reconfigure Options menu."
  (define-key global-map [menu-bar options cua-mode] nil t))


;; -------------------------------------------------------------------
;; Reconfigure Bookmarks Menu
(defun anju-main-menu--reconfigure-bookmarks ()
  "Reconfigure Bookmarks Menu."
  (easy-menu-add-item global-map '(menu-bar)
                      casual-bookmarks-main-menu
                      "Tools")

  (define-key global-map [menu-bar edit bookmark] nil t))



;; -------------------------------------------------------------------
;; Help Menu Customization


(defun anju-main-menu--reconfigure-help ()
  "Reconfigure help menu."
  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Info in New Frame"
                       (lambda ()
                         (interactive)
                         (anju-utils--command-in-new-frame #'info))
                       :help "Show Info manual in new frame."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["New Info in New Frame…"
                       (lambda ()
                         (interactive)
                         (anju-utils--command-in-new-frame #'info-display-manual))
                       :help "Show new Info manual in new frame."]
                      'emacs-tutorial)

  (easy-menu-add-item global-map '(menu-bar help-menu)
                      ["Man Page in New Frame…"
                       (lambda ()
                         (interactive)
                         (anju-utils--command-in-new-frame #'man))
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

  (when anju-help-menu-remove-emacs-tutorial
    (define-key global-map [menu-bar help-menu  emacs-tutorial] nil t)
    (define-key global-map [menu-bar help-menu  emacs-tutorial-language-specific] nil t))

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
;; Text Mode Menu Customization

(defun anju-main-menu--reconfigure-text-mode ()
  "Reconfigure Text mode menu."
  (easy-menu-remove-item text-mode-menu nil "Center Line")
  (easy-menu-remove-item text-mode-menu nil "Center Region")
  (easy-menu-remove-item text-mode-menu nil "Center Paragraph")
  (easy-menu-remove-item text-mode-menu nil "Paragraph Indent")
  (easy-menu-remove-item text-mode-menu nil "---")

  (easy-menu-add-item text-mode-menu nil anju-transform-text-menu "Auto Fill")
  (easy-menu-add-item text-mode-menu nil anju-style-menu "Auto Fill")
  (easy-menu-add-item text-mode-menu nil anju-center-text-menu "Auto Fill")
  (easy-menu-add-item text-mode-menu nil anju-fill-text-menu "Auto Fill"))


;; -------------------------------------------------------------------
;; Imenu Configuration


(defun anju-imenu-add-menubar-index ()
  "Add imenu index to menubar."
  (condition-case err (imenu-add-menubar-index)
    (imenu-unavailable
     (let ((inhibit-message t))
       (message "Warning: %s" (error-message-string err))))))

(defun anju-imenu-auto-rescan ()
  "Set local `imenu-auto-rescan' to t."
  (setq-local imenu-auto-rescan t))

(defun anju-main-menu--reconfigure-imenu ()
  "Configure main menu to include index menu for different modes.

Current modes affected:
- `prog-mode'
- `makefile-mode'
- `org-mode'
- `markdown-mode'

Auto rescan `imenu-auto-rescan' is enabled for all affected modes."

  (let ((hooks '(markdown-mode-hook
                 makefile-mode-hook
                 prog-mode-hook
                 org-mode-hook)))

    (mapc (lambda (hook)
            (if (eq hook 'prog-mode-hook)
                (add-hook hook #'anju-imenu-add-menubar-index)
              (add-hook hook #'imenu-add-menubar-index))
            (add-hook hook #'anju-imenu-auto-rescan))
          hooks)

    (if (<= org-imenu-depth 2)
        (setopt org-imenu-depth 7))))

(provide 'anju-main-menu)
;;; anju-main-menu.el ends here
