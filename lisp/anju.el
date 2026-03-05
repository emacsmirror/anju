;;; anju.el --- Mouse UX Customizations              -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Charles Choi

;; Author: Charles Choi <charles.choi@yummymelon.com>
;; URL: https://github.com/kickingvegas/casual
;; Keywords: tools
;; Version: 0.1.0
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

;;

;;; Code:
(require 'anju-mode-line)
(require 'anju-main-menu)
(require 'anju-context-menu)


;; -------------------------------------------------------------------
;; Initialization Routines

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
