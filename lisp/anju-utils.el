;;; anju-utils.el --- Anju Utilities                 -*- lexical-binding: t; -*-

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
(require 'map)
(require 'mouse)
(require 'register)
(require 'window)
(require 'easymenu)
(require 'windmove)

(defgroup anju nil
  "Group settings for Anju, a package that customizes mouse menus and bindings.

If `anju-init' is run, it will make Anju-specific additions to
`context-menu-functions', provided that `context-menu-functions' has not
been set by `customize-variable'.

To customize the context menu, look at `context-menu-functions'."
  :group 'convenience)

(defcustom anju-reconfigure-context-menu-functions-enable t
  "If non-nil, reconfigure the hook `context-menu-functions'.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs. It is also recommended to audit any changes made
to the `context-menu-functions' hook in your Emacs initialization file."
  :type 'boolean
  :group 'anju)

(defcustom anju-reconfigure-main-menu-enable t
  "If non-nil, reconfigure the main menu.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-unset-legacy-mouse-bindings-enable t
  "If non-nil, unset legacy mouse bindings.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-mode-line-bindings-enable t
  "If non-nil, configure mode line to use Anju bindings.

To return to behavior that is not modified by Anju, set this value to
nil and restart Emacs."
  :type 'boolean
  :group 'anju)

(defcustom anju-reconfigure-main-menu-hook
  '(anju-main-menu--reconfigure-bookmarks
    anju-main-menu--reconfigure-text-mode
    anju-main-menu--reconfigure-help)
  "Main menu mode hooks to run in `anju-init'."
  :type 'hook
  :options '(anju-main-menu--reconfigure-bookmarks
             anju-main-menu--reconfigure-text-mode
             anju-main-menu--reconfigure-help)
  :group 'anju)

(defvar anju--frame-register-alist nil
  "Internal dictionary for frames used by `anju-toggle-one-window'.")

(defmacro anju-context-menu-item-separator (menu key)
  "Add single line separator to MENU with KEY."
  `(define-key-after ,menu [,key]
     '(menu-item "--single-line")))

(defun anju-utils--command-in-new-frame (cmd)
  "Invoke CMD in a new frame.
This command creates a new frame populated by CMD."
  (other-frame-prefix)
  (call-interactively cmd))

(defun anju-utils--unset-legacy-mouse-bindings ()
  "Unset Emacs legacy mouse keybindings."
  (keymap-global-unset "<mode-line> C-<mouse-2>" t)
  (keymap-global-unset "<vertical-scroll-bar> C-<mouse-2>" t)
  (keymap-global-unset "<horizontal-scroll-bar> C-<mouse-2>" t)
  (keymap-global-unset "<vertical-line> C-<mouse-2>" t)
  (keymap-global-unset "<right-divider> C-<mouse-2>" t)
  (keymap-global-unset "<bottom-divider> C-<mouse-2>" t)
  (keymap-global-unset "<mode-line> <mouse-2>" t)
  (keymap-global-unset "<mode-line> <mouse-3>" t)
  (keymap-global-unset "<mode-line> <double-mouse-1>" t)
  (keymap-unset mode-line-buffer-identification-keymap "<mode-line> <mouse-1>" t)
  (keymap-unset mode-line-buffer-identification-keymap "<mode-line> <mouse-3>" t))

(defun anju-menu-label (prefix &optional max extent)
  "Generate context menu label with region string prepended by PREFIX.

- MAX defines the truncation length of the region.
- EXTENT defines the length of the truncated string to show from start,
  end of region.

The truncation is done “Apple-style” using `anju-middle-truncate'."
  (let* ((start (region-beginning))
         (end (region-end))
         (rstring (buffer-substring-no-properties start end)))

    (catch 'anju-middle-truncate-exception
        (anju-middle-truncate rstring prefix max extent))))

(defun anju-middle-truncate (rstring prefix &optional max extent)
  "Middle truncate RSTRING prepended by PREFIX.

Implementation of middle (Apple-style) truncation, where RSTRING is
truncated in the middle instead of the right end of its content.

- RSTRING is the source string (typically a region) to be truncated.
- PREFIX is a string to prepend the truncated string.
- MAX defines the truncation length.
- EXTENT defines the length of the truncated string to show from start,
  end of region.

This idea came from Scott Jenson as detailed in the URL
`https://www.linkedin.com/posts/scottjenson_one-of-my-earliest-ux-wins-was-for-mac-system-activity-7275265246053720064-Ozha'."
  (let* ((max (if (not max) 30 max))
         (extent (if (not extent) 12 extent))
         (rlist (string-split rstring "\n")))

    (unless (>= (- (/ max 2) 2) extent)
      (let ((msg (format
                  "ERROR: extent (%d) and max (%d) should \
conform to extent <= (max/2) - 2"
                  extent max)))
        (throw 'anju-middle-truncate-exception msg)))

    (if (> (length rlist) 1)
        (let* ((first (nth 0 rlist))
               (first (if (> (length first) max)
                          (substring first 0 extent)
                        first))
               (last (car (last rlist)))
               (last (if (> (length last) max)
                         (substring last (* -1 extent))
                       last))
               (last (string-trim-left last))
               (last (if (string-equal last "")
                         "␤"
                       last))
               (first (if (string-equal (string-trim first) "")
                         "␣"
                       first)))
          (format "%s “%s…%s”" prefix first last))

      (if (> (length rstring) max)
          (let* ((first (substring rstring 0 extent))
                 (last (string-trim-left (substring rstring (* -1 extent)))))
            (format "%s “%s…%s”" prefix first last))
        (format "%s “%s”" prefix rstring)))))


(easy-menu-define anju-transform-text-menu nil
  "Keymap for Transform Text submenu."
  '("Transform Text"
    :enable (and (use-region-p) (not buffer-read-only))
    ["Make Upper Case" upcase-region
     :help "Convert selected region to upper case"]
    ["Make Lower Case" downcase-region
     :help "Convert selected region to lower case"]
    ["Capitalize" capitalize-region
     :help "Convert the selected region to capitalized form"]))


;; -------------------------------------------------------------------
;; Delete Window Logic

(defun anju--scrub-frame-register-list ()
  "Scrub `anju--frame-register-alist'."
  (let ((frames (seq-filter (lambda (f) (frame-live-p f)) (frame-list)))
        (keys (map-keys anju--frame-register-alist)))
    (mapc (lambda (key)
            (if (not (member key frames))
                (map-delete anju--frame-register-alist key)))
          keys)))

;; TODO: Audit
(defun anju--new-register-id ()
  "Generate new register identifier."
  (let ((test t)
        (register-id nil))
    (while test
      (setq register-id (+ 8000 (random 1000))) ; TODO: need to parameterize?
      (unless (member register-id (map-values anju--frame-register-alist))
        (setq test nil)))

    (if anju--frame-register-alist
        (setq anju--frame-register-alist
              (map-insert anju--frame-register-alist (selected-frame) register-id))
      (setq anju--frame-register-alist (list `(,(selected-frame) . ,register-id))))
    register-id))

(defun anju--window-configuration-to-register ()
  "Set register identifier."
  (let* ((cache-register-id (map-elt anju--frame-register-alist (selected-frame)))
         (register-id (if cache-register-id
                          cache-register-id
                        (anju--new-register-id))))
    (window-configuration-to-register register-id)))


(defun anju-toggle-one-window (&optional window interactive)
  "Make WINDOW fill its frame.
- INTERACTIVE is passed to `delete-other-windows'."
  (interactive "i\np")
  (anju--scrub-frame-register-list)
  (if (one-window-p t)
      (progn
        (let ((register-id (map-elt anju--frame-register-alist (selected-frame))))
          (if register-id
              (jump-to-register register-id)))
        ;; (message "Returning to last window configuration")
        )
    (progn
      (anju--window-configuration-to-register)
      (delete-other-windows window interactive))))

(provide 'anju-utils)
;;; anju-utils.el ends here
