;;; anju-style-text.el --- Style Text Menus -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Charles Choi

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
(require 'org)
(require 'markdown-mode)
(require 'anju-utils)

(defun anju-style-mode-supported-p ()
  "Predicate to test mode is supported by `anju-style-text'."
  (or (derived-mode-p 'org-mode) (derived-mode-p 'markdown-mode)))

(defun anju-style-bold ()
  "Mark region bold for modes which are supported by `anju-style-text'."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))

  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ?*))
    ('markdown-mode (markdown-insert-bold))
    (m nil)))

(defun anju-style-italic ()
  "Mark region italic for modes which are supported by `anju-style-text'."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))

  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ?/))
    ('markdown-mode (markdown-insert-italic))
    (m nil)))

(defun anju-style-code ()
  "Mark region code for modes which are supported by `anju-style-text'."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))

  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ?~))
    ('markdown-mode (markdown-insert-code))
    (m nil)))

(defun anju-style-underline ()
  "Mark region underline for Org mode."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))
  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ?_))
    (m nil)))

(defun anju-style-verbatim ()
  "Mark region verbatim for Org mode."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))
  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ?=))
    (m nil)))

(defun anju-style-strike-through ()
  "Mark region strike-through for modes which are supported by `anju-style-text'."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))

  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ?+))
    ('markdown-mode (markdown-insert-strike-through))
    (m nil)))

(defun anju-style-remove ()
  "Remove marked region."
  (interactive)
  (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))

  (pcase (derived-mode-p major-mode)
    ('org-mode (org-emphasize ? ))
    (m nil)))

(defun anju-style-dwim ()
  "DWIM emphasize text for modes supported by `anju-style-text'.

This command will appropriately style either a region or the text
the point is in depending on whether the current major mode is
Org or Markdown. Selection of the emphasis style is done by
mini-buffer command completion.

If no region is defined, then the text amount is considered to be
a balanced expression (sexp). A balanced expression is used as it
can cover most cases of applying the style to text that is
contiguous without spaces."
  (interactive)
  (let* ((styles (list "bold" "italic" "code"
                       "underline" "verbatim" "strike" "remove"))
         (choice (car (completing-read-multiple "Style: " styles))))
    (when (not (use-region-p))
      (beginning-of-thing 'sexp)
      (mark-sexp))
    (cond
     ((string= choice "bold") (anju-style-bold))
     ((string= choice "italic") (anju-style-italic))
     ((string= choice "code") (anju-style-code))
     ((string= choice "verbatim") (anju-style-verbatim))
     ((string= choice "underline") (anju-style-underline))
     ((string= choice "strike") (anju-style-strike-through))
     ((string= choice "remove")
      (if (derived-mode-p 'org-mode)
          (org-emphasize ? )
        (message "remove not supported for Markdown.")))
     (t (message "ERROR: undefined choice: %s" choice)))))

(easy-menu-define anju-style-menu nil
  "Keymap for Emphasize Menu."
  '("Style"
    :enable (and (use-region-p) (not buffer-read-only))
    ["Bold" anju-style-bold
     :visible (anju-style-mode-supported-p)
     :help "Bold selected region"]
    ["Italic" anju-style-italic
     :visible (anju-style-mode-supported-p)
     :help "Italic selected region"]
    ["Code" anju-style-code
     :visible (anju-style-mode-supported-p)
     :help "Code selected region"]
    ["Underline" anju-style-underline
     :visible (derived-mode-p 'org-mode)
     :help "Underline selected region"]
    ["Verbatim" anju-style-verbatim
     :visible (derived-mode-p 'org-mode)
     :help "Verbatim selected region"]
    ["Strike Through" anju-style-strike-through
     :visible (anju-style-mode-supported-p)
     :help "Strike-through selected region"]
    ["Remove" anju-style-remove
     :visible (and (derived-mode-p 'org-mode) visible-mode)
     :help "Strike-through selected region"]))

(provide 'anju-style-text)

;;; anju-style-text.el ends here
