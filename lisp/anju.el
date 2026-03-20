;;; anju.el --- Mouse UX Customizations              -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Charles Choi

;; Author: Charles Choi <charles.choi@yummymelon.com>
;; URL: https://github.com/kickingvegas/casual
;; Keywords: tools
;; Version: 0.1.3-rc.1
;; Package-Requires: ((emacs "28.1") (magit "4.4.0") (casual "2.14.0") (markdown-mode "2.7"))

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

;; Anju is a project to align mouse interactions in Emacs with contemporary
;; (circa 2026) expectations. Effort towards this alignment is made in the
;; following areas:

;; - Context-sensitive menus
;; - De-emphasis of middle mouse button usage (binding <mouse-2>)
;; - Support direct manipulation when possible
;; - Re-organization of the main menu bar

;; The features offered by Anju are opinionated, but avoids unconventional
;; behavior. Anju aspires to bring a calmer mouse experience to Emacs.

;; INSTALLATION

;; Basic installation of Anju composes of two parts:

;; 1. Turn on `context-menu-mode' to major modes of preference. This is done
;;    using the `add-hook' function as shown below.

;;     (add-hook 'prog-mode-hook #'context-menu-mode)
;;     (add-hook 'text-mode-hook #'context-menu-mode)
;;     (add-hook 'dired-mode-hook #'context-menu-mode)
;;     (add-hook 'shell-mode-hook #'context-menu-mode)

;; 2. Call `anju-init' in your Emacs initialization file.

;;     (anju-init)

;; The `anju-init' command can be customized to preference. Read more on this in
;; the Anju User Guide in Info.

;;; Code:
(require 'anju-mode-line)
(require 'anju-main-menu)
(require 'anju-context-menu)


;; -------------------------------------------------------------------
;; Initialization Routines

;;;###autoload (autoload 'anju-init "anju" nil t)
(defun anju-init ()
  "Reconfigure Emacs mouse menus and bindings to Anju specification.

This initialization command for Anju reconfigures the following areas
of mouse menus and bindings:

- Legacy mouse bindings (`anju-unset-legacy-mouse-bindings-enable')
- Mode line bindings (`anju-mode-line-bindings-enable')
- Main menu (`anju-reconfigure-main-menu-enable')
- Context menu (`anju-reconfigure-context-menu-functions-enable')

Each area is controlled with a customizable variable and all are by
default t. Changes to any of these variables will require a restart of
Emacs."
  (interactive)
  (if anju-unset-legacy-mouse-bindings-enable
      (anju-utils--unset-legacy-mouse-bindings))

  (if anju-mode-line-bindings-enable
      (anju-mode-line--set-bindings))

  (if anju-reconfigure-main-menu-enable
      (run-hooks 'anju-reconfigure-main-menu-hook))

  (if anju-reconfigure-context-menu-functions-enable
      (anju-reconfigure-context-menu-functions)))

(provide 'anju)
;;; anju.el ends here
