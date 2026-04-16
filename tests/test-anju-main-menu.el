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
(require 'cl-lib)
(require 'anju-main-menu)
(require 'anju-test-utils)

(ert-deftest test-anju-window-swap-menu ()
  (anju-test-keymap
   anju-window-swap-menu
   "Swap Window"
   4
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i)
                            "↑"
                            #'windmove-swap-states-up
                            "Swap window up")

       (anju-test-menu-item (seq-elt items (cl-incf i))
                            "↓"
                            #'windmove-swap-states-down
                            "Swap window down")

       (anju-test-menu-item (seq-elt items (cl-incf i))
                            "←"
                            #'windmove-swap-states-left
                            "Swap window left")

       (anju-test-menu-item (seq-elt items (cl-incf i))
                            "→"
                            #'windmove-swap-states-right
                            "Swap window right")))))

(ert-deftest test-anju-main-menu--reconfigure-file-menu ()
  (anju-main-menu--reconfigure-file-menu)

  (let ((swap-map (lookup-key global-map [menu-bar file Swap\ Window])))
    (should swap-map)
    (should (eq (car swap-map) 'keymap))))

(ert-deftest test-anju-main-menu--reconfigure-options-menu ()
  (anju-main-menu--reconfigure-options-menu)

  (let ((cua-mode (lookup-key global-map [menu-bar options cua-mode])))
    (should (not cua-mode))))

(ert-deftest test-anju-main-menu--reconfigure-bookmarks ()
  "Test for `anju-main-menu--reconfigure-bookmarks'."
  (anju-main-menu--reconfigure-bookmarks)

  (let* ((bookmarks-keymap (easy-menu-get-map global-map '(menu-bar Bookmarks))))
    (anju-test-keymap
     bookmarks-keymap
     "Bookmarks"
     5
     (lambda (items)
       (let ((i 0))
         (anju-test-menu-item
          (seq-elt items i)
          "Edit Bookmarks"
          #'list-bookmarks
          "Display a list of existing bookmarks.")

         (should (string-equal "--" (nth 1 (seq-elt items (cl-incf i)))))

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Add Bookmark…"
          #'bookmark-set-no-overwrite
          "Set a bookmark named NAME at the current location.")

         (should (string-equal "--" (nth 1 (seq-elt items (cl-incf i)))))

         (anju-test-menu-item
          (seq-elt items (cl-incf i))
          "Jump to Bookmark…"
          #'bookmark-jump
          "Jump to bookmark"))))))


;; TODO: write test-anju-main-menu--reconfigure-help
;; (ert-deftest test-anju-main-menu--reconfigure-help ()
;;   "Test for `anju-main-menu--reconfigure-help'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; TODO: write test-anju-main-menu--reconfigure-text-mode
;; (ert-deftest test-anju-main-menu--reconfigure-text-mode ()
;;   "Test for `anju-main-menu--reconfigure-text-mode'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(provide 'test-anju-main-menu)
;;; test-anju-main-menu.el ends here
