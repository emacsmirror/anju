;;; anju-mode-line.el --- Anju Mode Line Customization  -*- lexical-binding: t; -*-

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

(defcustom anju-mode-line-buffer-list-function #'anju--buffer-list
  "Function that populates the mode line buffer name popup menu.

Assign this variable to a function that returns a value that conforms to
the “MENU” parameter of `popup-menu'.

This setting allows for customization of the buffer list (or any other
menu content) when the mode line buffer name (identifier) is
clicked (typically with mouse 1).

Users who wish define their own menu should override this value with
their own function. It is highly recommended that such users look at the
source to `anju--buffer-list' as a start to defining their own menu
function."
  :type 'function
  :group 'anju)


;; -------------------------------------------------------------------
;; Mode Line Customization

(easy-menu-define anju-window-management-menu nil
  "Keymap for mouse window management menu."
  '(nil
    ["×" mouse-delete-window
     :visible (not (one-window-p t))
     :help "Delete window"]

    ["Split →" split-window-horizontally
     :help "Split right"]

    ["Split ↓" split-window-vertically
     :help "Split below"]

    ("Swap"
     :visible (and (eq (selected-window) (anju-window-under-mouse)) (not (one-window-p t)))
     ["↑" windmove-swap-states-up
      :visible (window-in-direction 'above)
      :help "Swap window up"]

     ["↓" windmove-swap-states-down
      :visible (window-in-direction 'below)
      :help "Swap window down"]

     ["←" windmove-swap-states-left
      :visible (window-in-direction 'left)
      :help "Swap window left"]

     ["→" windmove-swap-states-right
      :visible (window-in-direction 'right)
      :help "Swap window right"])))


(defun anju-window-under-mouse ()
  "Return the live window under the current mouse pointer.

Derived from code found at URL
`https://emacs.stackexchange.com/questions/21497/how-to-find-the-window-under-the-mouse-pointer'."
  (interactive)
  (let* ((mouse-pos (mouse-position))
         (frame (car mouse-pos))
         (x (cadr mouse-pos))
         (y (cddr mouse-pos))
         (window (window-at x y frame)))
    window))

;; (easy-menu-add-item anju-window-management-menu nil anju-windmove-swap-menu)

(defun anju-popup-window-management-menu (click)
  "Popup mouse window management with CLICK."
  (interactive "e")
  (popup-menu anju-window-management-menu click))

(defun anju-popup-buffer-menu (click)
  "Popup mouse buffer navigation with CLICK."
  (interactive "e")
  (popup-menu (funcall anju-mode-line-buffer-list-function) click))

(defun anju-temporary-buffer-filter (buf)
  "Return t if BUF name is has pattern *<name>*."
  (let ((bufname (string-trim (buffer-name buf))))
    (not
     (or
      (string-match-p "^\\*.*\\*$" bufname)
      (string-match-p "^\\*info\\*\\(<[[:digit:]]*>\\)*$" bufname)))))

(defun anju-info-buffer-filter (buf)
  "Return t if BUF is an Info buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'Info-mode)))

(defun anju-help-buffer-filter (buf)
  "Return t if BUF is an Info buffer."
  (with-current-buffer buf
    (eq (derived-mode-p major-mode) 'help-mode)))

(defun anju--buffer-list ()
  "Vector of menu items to populate `anju-popup-buffer-menu'."
  (interactive)

  (let* ((open-buffers (buffer-list))
         (plain-buffers (seq-filter #'anju-temporary-buffer-filter open-buffers))
         (info-buffers (seq-filter #'anju-info-buffer-filter open-buffers))
         (help-buffers (seq-filter #'anju-help-buffer-filter open-buffers))
         (plain-buffers (seq-take plain-buffers 7))

         (buffer-items (mapcar (lambda (buf)
                                 (vector (format "%s" (buffer-name buf))
                                         `(lambda () (interactive) (switch-to-buffer ,buf))
                                         :visible (and (eq (selected-window) (anju-window-under-mouse)))))
                               (append plain-buffers info-buffers help-buffers)))

         (menu-items (append buffer-items
                             '("---")
                             '(["Set Selected" mouse-set-point
                                :visible (not (and (eq (selected-window) (anju-window-under-mouse))))
                                :help "Set window at point as selected"]

                               ["← Previous" previous-buffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "Previous Buffer"]

                               ["→ Next" next-buffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "Next buffer"]

                               ["≣ List All Buffers" ibuffer
                                :visible (and (eq (selected-window) (anju-window-under-mouse)))
                                :help "List all buffers"]))))
      menu-items))




(defun anju-mode-line--set-bindings ()
  "Set Anju bindings."
  (keymap-set mode-line-buffer-identification-keymap
              "<mode-line> <mouse-1>"
              #'anju-popup-buffer-menu)

  (keymap-global-set "<mode-line> <double-mouse-1>" #'anju-toggle-one-window)

  ;; (keymap-global-set "<vertical-scroll-bar> <mouse-3>"
  ;;                    #'mouse-split-window-vertically)

  (keymap-global-set "<mode-line> <down-mouse-3>"
                     #'anju-popup-window-management-menu))


(provide 'anju-mode-line)
;;; anju-mode-line.el ends here
