;;; test-anju-style-text.el --- Style text tests     -*- lexical-binding: t; -*-

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
(require 'anju-style-text)
(require 'anju-test-utils)

(ert-deftest test-anju-style-mode-supported-p ()
  "Test for `anju-style-mode-supported-p'."
  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (should (anju-style-mode-supported-p))))

  (anju-test-file-testbench
   ".md"
   (lambda (tempfile-name description)
     (should (anju-style-mode-supported-p)))))

(defun test-anju-style-file-setup (fn buf)
  "Insert BUF into file, then run FN.

Inserts BUF into file, selects the first word as a region, then runs FN on it."
  (insert buf)
  (goto-char (point-min))
  (push-mark (point-min) t t)
  (mark-word)
  (activate-mark)
  (funcall fn)
  (save-buffer)
  (goto-char (point-min)))

(ert-deftest test-anju-style-bold ()
  "Test for `anju-style-bold'."
  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-bold "mary jane\n")
     (should (search-forward "*mary*"))))

  (anju-test-file-testbench
   ".md"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-bold "mary jane\n")
     (should (search-forward "**mary**")))))

(ert-deftest test-anju-style-italic ()
  "Test for `anju-style-italic'."
  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-italic "mary jane\n")
     (should (search-forward "/mary/"))))

  (anju-test-file-testbench
   ".md"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-italic "mary jane\n")
     (should (search-forward "*mary*"))))
  )

(ert-deftest test-anju-style-code ()
  "Test for `anju-style-code'."

  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-code "mary jane\n")
     (should (search-forward "~mary~"))))

  (anju-test-file-testbench
   ".md"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-code "mary jane\n")
     (should (search-forward "`mary`")))))

(ert-deftest test-anju-style-underline ()
  "Test for `anju-style-underline'."
  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-underline "mary jane\n")
     (should (search-forward "_mary_")))))

(ert-deftest test-anju-style-verbatim ()
  "Test for `anju-style-verbatim'."
  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-verbatim "mary jane\n")
     (should (search-forward "=mary=")))))

(ert-deftest test-anju-style-strike-through ()
  "Test for `anju-style-strike-through'."

  (anju-test-file-testbench
   ".org"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-strike-through "mary jane\n")
     (should (search-forward "+mary+"))))

  (anju-test-file-testbench
   ".md"
   (lambda (tempfile-name description)
     (test-anju-style-file-setup #'anju-style-strike-through "mary jane\n")
     (should (search-forward "~~mary~~"))))
  )

;; (ert-deftest test-anju-style-remove ()
;;   "Test for `anju-style-remove'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-style-dwim ()
;;   "Test for `anju-style-dwim'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(ert-deftest test-anju-style-menu ()
  "Test for `anju-style-menu'."

  (anju-test-keymap
   anju-style-menu
   "Style"
   7
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2))
            (item3 (seq-elt items 3))
            (item4 (seq-elt items 4))
            (item5 (seq-elt items 5))
            (item6 (seq-elt items 6)))

       (anju-test-menu-item item0 "Bold" #'anju-style-bold "Bold selected region")
       (anju-test-menu-item item1 "Italic" #'anju-style-italic "Italic selected region")
       (anju-test-menu-item item2 "Code" #'anju-style-code "Code selected region")
       (anju-test-menu-item item3 "Underline" #'anju-style-underline "Underline selected region")
       (anju-test-menu-item item4 "Verbatim" #'anju-style-verbatim "Verbatim selected region")
       (anju-test-menu-item item5 "Strike Through" #'anju-style-strike-through "Strike-through selected region")
       (anju-test-menu-item item6 "Remove" #'anju-style-remove "Remove markup from selected region")))))

(provide 'test-anju-style-text)
;;; test-anju-style-text.el ends here
