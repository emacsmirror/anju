;;; test-anju-main-menu.el --- Main menu tests       -*- lexical-binding: t; -*-

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
(require 'anju-main-menu)
(require 'anju-test-utils)

(ert-deftest test-anju-main-menu--reconfigure-bookmarks ()
  "Test for `anju-main-menu--reconfigure-bookmarks'."
  (anju-main-menu--reconfigure-bookmarks)

  (let* ((bookmarks-keymap (easy-menu-get-map global-map '(menu-bar Bookmarks))))
    (anju-test-keymap
     bookmarks-keymap
     "Bookmarks"
     5
     (lambda (items)
       (let* ((item0 (seq-elt items 0))
              (item1 (seq-elt items 1))
              (item2 (seq-elt items 2))
              (item3 (seq-elt items 3))
              (item4 (seq-elt items 4)))

         (anju-test-menu-item
          item0
          "Edit Bookmarks"
          #'list-bookmarks
          "Display a list of existing bookmarks.")

         (anju-test-menu-item
          item2
          "Add Bookmark…"
          #'bookmark-set-no-overwrite
          "Set a bookmark named NAME at the current location.")

         (anju-test-menu-item
          item4
          "Jump to Bookmark…"
          #'bookmark-jump
          "Jump to bookmark"))))))

;; (ert-deftest test-anju-main-menu--reconfigure-help ()
;;   "Test for `anju-main-menu--reconfigure-help'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-main-menu--reconfigure-text-mode ()
;;   "Test for `anju-main-menu--reconfigure-text-mode'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(provide 'test-anju-main-menu)
;;; test-anju-main-menu.el ends here
