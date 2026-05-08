;;; anju-elisp-edebug-examples.el --- Elisp examples  -*- lexical-binding: t; -*-

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
(require 'ert)

(defun foo (a b)
  "Foo function for A and B."
  (let ((a (bar a 2))
        (b (bar b 3)))
    (message "a %d, b %d" a b)
    (+ a b)))

(defun bar (x y)
  "Multiply X and Y."
  (* x y))

(foo 2 4)

(mapcar (lambda (x) (+ x 2)) '(1 2 3 4 5))

(seq-reduce (lambda (x y) (+ x y)) (number-sequence 0 9) 0)

(ert-deftest test-foo ()
  (should (eq 16 (foo 2 4))))

;;; anju-elisp-edebug-examples.el ends here
