;;; anju-test-utils.el --- Anju Test Utils           -*- lexical-binding: t; -*-

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
(require 'seq)
(require 'ert)

(defvar anju-test-fail-uncovered-tests t
  "If non-nil then uncovered tests will fail.")

(defun anju-test-menu-item (item istr &optional command hstr)
  "Test menu ITEM from a keymap.

- ITEM : menu item
- ISTR : item description or line spec (not to be confused with :label)
- COMMAND: item command
- HSTR : item :help value"

  (let ((item-type (seq-elt item 1))
        (item-str (seq-elt item 2)))
    (should (eq item-type 'menu-item))

    (if (eq (length item) 3)
        (should (and (stringp item-str)
                     (string-equal item-str istr)))
      (let* ((item-cmd (seq-elt item 3))
             (item-slots (seq-subseq item 4))
             (item-help (map-elt item-slots :help)))
        (should (eq item-cmd command))
        (if (and (stringp item-str) (stringp istr))
            (should (string-equal item-str istr))
          (should (string-equal (eval item-str) (funcall istr))))

        (should (string-equal item-help hstr))))))

(defun anju-test-keymap (kmap description count fn)
  "Test keymap.

- KMAP : keymap
- DESCRIPTION : name of keymap
- COUNT : count of menu items
- FN : function with a list of menu items as the argument

This function."

  (let* ((kmap2 (if (eq (type-of kmap) 'symbol) (copy-keymap kmap) kmap))
         (osym (car kmap2))
         (kmap-description (if description (seq-elt kmap2 1)))
         (items (if description
                    (seq-subseq kmap2 2)
                  (seq-subseq kmap2 1))))

    (should (eq osym 'keymap))
    (if description
        (should (string-equal kmap-description description)))
    (should (eq (length items) count))

    (funcall fn items)))

(defun anju-test-file-testbench (extension fn &optional description)
  "Setup testbench using tempfile with EXTENSION.

- EXTENSION : set temporary file name extension
- FN : function taking arguments (tempfile-name description)
- DESCRIPTION : identifier for mock keymap"

  (let* ((tempfile-name (make-temp-file "test-anju-" nil extension))
         (description (if description description "Hi There"))
         (find-file-hook nil))

    (find-file tempfile-name)
    (unwind-protect
        (funcall fn tempfile-name description)
      (kill-buffer)
      (delete-file tempfile-name))))

(defun anju-test-context-menu-function-with-filetype (extension cmf count fn &optional filefn)
  "Test context menu.
- EXTENSION : tempfile extension
- CMF : context menu function
- COUNT: Count of menu items
- FN : function with a list of menu items as the argument"

  (anju-test-file-testbench
   extension
   (lambda (tempfile-name description)
     "TEMPFILE-NAME DESCRIPTION."
     (if filefn
         (funcall filefn tempfile-name description))
     (anju-test-context-menu-function cmf description count fn))))

(defun anju-test-context-menu-function (cmf description count fn)
  "Test CMF with DESCRIPTION COUNT FN."
  (easy-menu-define kmap nil "Dummy Docstring." (list description))
  (let ((kmap (funcall cmf kmap nil)))
       (anju-test-keymap
        kmap
        description
        count
        fn)))


(provide 'anju-test-utils)
;;; anju-test-utils.el ends here
