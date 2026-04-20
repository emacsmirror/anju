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

(ert-deftest test-anju-main-menu--reconfigure-file ()
  (anju-main-menu--reconfigure-file)

  (let ((swap-map (lookup-key global-map [menu-bar file Swap\ Window])))
    (should swap-map)
    (should (eq (car swap-map) 'keymap))))

(ert-deftest test-anju-main-menu--reconfigure-options ()
  (anju-main-menu--reconfigure-options)

  (let ((cua-mode (lookup-key global-map [menu-bar options cua-mode])))
    (should (not cua-mode))))


;; -------------------------------------------------------------------

(defun test--anju-transpose-menu (kmap)
  (anju-test-keymap
   kmap
   "Transpose ⇄"
   7
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Characters"
        #'transpose-chars
        "Interchange characters around point, moving forward one character.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Words"
        #'transpose-words
        "Interchange words around point, leaving point at end of them.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Lines"
        #'transpose-lines
        "Exchange current line and previous line, leaving point after both.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sentences"
        #'transpose-sentences
        "Interchange the current sentence with the next one.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Paragraphs"
        #'transpose-paragraphs
        "Interchange the current paragraph with the next one.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Regions"
        #'transpose-regions
        "region STARTR1 to ENDR1 with STARTR2 to ENDR2.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Balanced Expressions (sexps)"
        #'transpose-sexps
        "Like C-t (‘transpose-chars’), but applies to balanced \
expressions (sexps).")))))

(ert-deftest test-anju-transpose-menu ()
  (test--anju-transpose-menu anju-transpose-menu))


;; -------------------------------------------------------------------

(defun test--anju-move-text-menu (kmap)
  (anju-test-keymap
   kmap
   "Move Text"
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Word →"
        #'casual-editkit-move-word-forward
        "Move word to the right of point forward one word.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Word ←"
        #'casual-editkit-move-word-backward
        "Move word to the right of point backward one word.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sentence →"
        #'casual-editkit-move-sentence-forward
        "Move sentence to the right of point forward one sentence.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Sentence ←"
        #'casual-editkit-move-sentence-backward
        "Move sentence to the right of point backward one sentence.")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Balanced Expression (sexp) →"
        #'casual-editkit-move-sexp-forward
        "Move balanced expression (sexp) to the right of point forward \
one sexp.")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Balanced Expression (sexp) ←"
        #'casual-editkit-move-sexp-backward
        "Move balanced expression (sexp) to the right of point backward \
one sexp.")))))

(ert-deftest test-anju-move-text-menu ()
  (test--anju-move-text-menu anju-move-text-menu))



;; -------------------------------------------------------------------
(defun test--anju-delete-space-menu (kmap)
  (anju-test-keymap
   kmap
   "Delete"
   8
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Join Line"
        #'join-line
        "Join this line to previous and fix up \
whitespace at join")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Just One Space"
        #'just-one-space
        "Delete all spaces and tabs around point, leaving \
one space.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Delete Horizontal Space"
        #'delete-horizontal-space
        "Delete all spaces and tabs around point.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Delete Blank Lines"
        #'delete-blank-lines
        "On blank line, delete all surrounding blank lines, \
leaving just one.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Whitespace Cleanup"
        #'whitespace-cleanup
        "Cleanup some blank problems in all buffer or at region.")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Delete Trailing Whitespace"
        #'delete-trailing-whitespace
        "Delete trailing whitespace between START and END.")


       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Zap up to…"
        #'zap-up-to-char
        "Kill up to, but not including occurrence of CHAR")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Zap to…"
        #'zap-to-char
        "Kill up to and including occurrence of CHAR")))))

(ert-deftest test-anju-delete-space-menu ()
  (test--anju-move-text-menu anju-move-text-menu))


;; -------------------------------------------------------------------

(ert-deftest test-anju-main-menu--reconfigure-edit ()
  (anju-main-menu--reconfigure-edit)

  (let ((rgrep-item (lookup-key global-map [menu-bar edit search rgrep]))
        (transpose-menu (easy-menu-get-map global-map '(menu-bar edit Transpose\ ⇄)))
        (move-text-menu (easy-menu-get-map global-map '(menu-bar edit Move\ Text)))
        (delete-menu (easy-menu-get-map global-map '(menu-bar edit Delete))))

    (should (eq rgrep-item 'rgrep))
    (test--anju-transpose-menu transpose-menu)
    (test--anju-move-text-menu move-text-menu)
    (test--anju-delete-space-menu delete-menu)))

(ert-deftest test-anju-main-menu--reconfigure-bookmarks ()
  "Test for `anju-main-menu--reconfigure-bookmarks'."
  (anju-main-menu--reconfigure-bookmarks)

  ;; casual-bookmarks-main-menu is external

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
