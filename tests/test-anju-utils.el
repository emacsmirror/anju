;;; test-anju-utils.el --- Test Utils                -*- lexical-binding: t; -*-

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
(require 'anju-utils)
(require 'anju-test-utils)

(ert-deftest test-anju-reconfigure-context-menu-functions-enable ()
  "Test for `anju-reconfigure-context-menu-functions-enable'."
  (should (boundp anju-reconfigure-context-menu-functions-enable)))

(ert-deftest test-anju-reconfigure-main-menu-enable ()
  "Test for `anju-reconfigure-main-menu-enable'."
  (should (boundp anju-reconfigure-main-menu-enable)))

(ert-deftest test-anju-unset-legacy-mouse-bindings-enable ()
  "Test for `anju-unset-legacy-mouse-bindings-enable'."
  (should (boundp anju-unset-legacy-mouse-bindings-enable)))

(ert-deftest test-anju-mode-line-bindings-enable ()
  "Test for `anju-mode-line-bindings-enable'."
  (should (boundp anju-mode-line-bindings-enable)))

(ert-deftest test-anju-reconfigure-main-menu-hook ()
  "Test for `anju-reconfigure-main-menu-hook'."
  (should (eq 'cons (type-of anju-reconfigure-main-menu-hook))))

(ert-deftest test-anju--frame-register-alist ()
  "Test for `anju--frame-register-alist'."
  (should (boundp anju--frame-register-alist)))

(ert-deftest test-anju-help-menu-remove-emacs-tutorial ()
  "Test for `anju-help-menu-remove-emacs-tutorial'."
  (should (boundp anju-help-menu-remove-emacs-tutorial)))

(ert-deftest test-anju-buffer-list-filter-functions ()
  "Test for `anju-buffer-list-filter-functions'."
  (should (eq 'cons
              (type-of anju-buffer-list-filter-functions)))

  (let* ((tests '(anju-buffer-list-plain-filter
                  anju-buffer-list-eshell-filter
                  anju-buffer-list-shell-filter
                  anju-buffer-list-info-filter
                  anju-buffer-list-help-filter))
         (keys (map-keys anju-buffer-list-filter-functions)))

    (mapc (lambda (test)
            (should (member test keys)))
          tests)))


;; (ert-deftest test-anju-utils--command-in-new-frame ()
;;   "Test for `anju-utils--command-in-new-frame'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-utils--unset-legacy-mouse-bindings ()
;;   "Test for `anju-utils--unset-legacy-mouse-bindings'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-menu-label ()
;;   "Test for `anju-menu-label'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-middle-truncate ()
;;   "Test for `anju-middle-truncate'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(ert-deftest test-anju-transform-text-menu ()
  "Test for `anju-transform-text-menu'."

  (anju-test-keymap anju-transform-text-menu
                    "Transform Text"
                    3
                    (lambda (items)
                      (let* ((item0 (seq-elt items 0))
                             (item1 (seq-elt items 1))
                             (item2 (seq-elt items 2)))

                        (anju-test-menu-item
                         item0
                         "Make Upper Case"
                         #'upcase-region
                         "Convert selected region to upper case")

                        (anju-test-menu-item
                         item1
                         "Make Lower Case"
                         #'downcase-region
                         "Convert selected region to lower case")

                        (anju-test-menu-item
                         item2
                         "Capitalize"
                         #'capitalize-region
                         "Convert the selected region to capitalized form")))))

;; (ert-deftest test-anju--scrub-frame-register-list ()
;;   "Test for `anju--scrub-frame-register-list'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju--new-register-id ()
;;   "Test for `anju--new-register-id'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju--window-configuration-to-register ()
;;   "Test for `anju--window-configuration-to-register'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

;; (ert-deftest test-anju-toggle-one-window ()
;;   "Test for `anju-toggle-one-window'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested")))

(provide 'test-anju-utils)
;;; test-anju-utils.el ends here
