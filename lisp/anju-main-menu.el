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
(require 'anju-utils)
(require 'anju-style-text)
(require 'casual-bookmarks)



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
  (easy-menu-add-item text-mode-menu nil anju-style-menu "Auto Fill"))

(provide 'anju-main-menu)
;;; anju-main-menu.el ends here
