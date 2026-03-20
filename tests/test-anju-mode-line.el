;;; test-anju-mode-line.el --- Mode line tests       -*- lexical-binding: t; -*-

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
(require 'anju-mode-line)
(require 'anju-test-utils)

(ert-deftest test-anju-mode-line-buffer-list-function ()
  "Test for `anju-mode-line-buffer-list-function'."
  (should (fboundp anju-mode-line-buffer-list-function)))

(ert-deftest test-anju-window-management-menu ()
  "Test for `anju-window-management-menu'."
  (anju-test-keymap
   anju-window-management-menu
   nil
   4
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2))
            (item3 (seq-elt items 3)))

       (anju-test-menu-item
        item0
        "×"
        #'mouse-delete-window
        "Delete window")

       (anju-test-menu-item
        item1
        "Split →"
        #'split-window-horizontally
        "Split right")

       (anju-test-menu-item
        item2
        "Split ↓"
        #'split-window-vertically
        "Split below")

       (let* ((swap-kmap (seq-elt item3 3)))
         (anju-test-keymap
          swap-kmap
          "Swap"
          4
          (lambda (items)
            (let* ((item0 (seq-elt items 0))
                   (item1 (seq-elt items 1))
                   (item2 (seq-elt items 2))
                   (item3 (seq-elt items 3)))
              (anju-test-menu-item
               item0
               "↑"
               #'windmove-swap-states-up
               "Swap window up")
              (anju-test-menu-item
               item1
               "↓"
               #'windmove-swap-states-down
               "Swap window down")
              (anju-test-menu-item
               item2
               "←"
               #'windmove-swap-states-left
               "Swap window left")
              (anju-test-menu-item
               item3
               "→"
               #'windmove-swap-states-right
               "Swap window right")))))))))

;; (ert-deftest test-anju-window-under-mouse ()
;;   "Test for `anju-window-under-mouse'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-popup-window-management-menu ()
;;   "Test for `anju-popup-window-management-menu'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-popup-buffer-menu ()
;;   "Test for `anju-popup-buffer-menu'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-temporary-buffer-filter ()
;;   "Test for `anju-temporary-buffer-filter'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-info-buffer-filter ()
;;   "Test for `anju-info-buffer-filter'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-help-buffer-filter ()
;;   "Test for `anju-help-buffer-filter'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-buffer-list-menu-items ()
;;   "Test for `anju-buffer-list-menu-items'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-mode-line--set-bindings ()
;;   "Test for `anju-mode-line--set-bindings'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(provide 'test-anju-mode-line)
;;; test-anju-mode-line.el ends here
