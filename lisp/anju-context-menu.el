;;; anju-context-menu.el --- Anju Context Menu Customization  -*- lexical-binding: t; -*-

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
(require 'mouse)
(require 'dired)
(require 'org)
(require 'org-table)
(require 'ol)
(require 'yank-media)
(require 'anju-utils)
(require 'anju-style-text)
(require 'casual-dired)
(require 'casual-org)
(require 'casual-ediff)

(easy-menu-define anju-org-table-region-menu nil
  "Key map for Org table region sub-menu."
  '("Org Table Region"
    ["Cut"
     org-table-cut-region
     :enable (and (bound-and-true-p rectangle-mark-mode) (use-region-p))
     :help "Cut Org table region"]

    ["Copy"
     org-table-copy-region
     :enable (and (bound-and-true-p rectangle-mark-mode) (use-region-p))
     :help "Copy Org table region"]

    ["Paste"
     org-table-paste-rectangle
     :help "Paste Org table region"]))

(easy-menu-define anju-context-window-management-menu nil
  "Keymap for mouse window management menu."
  '("Window"
    ["×" delete-window
     :visible (not (one-window-p t))
     :help "Delete window"]

    ["Split →" mouse-split-window-horizontally
     :help "Split right at mouse point"]

    ["Split ↓" mouse-split-window-vertically
     :help "Split below at mouse point"]

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

(defun anju-occur-selected-region ()
  "Occur selected region."
  (interactive)
  (let* ((start (region-beginning))
         (end (region-end))
         (regex (buffer-substring-no-properties start end)))
    (occur regex)))

(defun anju-at-org-table-p ()
  "Predicate if point is in an Org table."
  (or (org-at-table-p) (org-at-TBLFM-p)))

(defun anju-yank-media-p ()
  "Predicate if media (images, HTML and the like) is in the clipboard.

This is built using the implementation of `yank-media'."
  (interactive)
  (unless yank-media--registered-handlers
    (user-error "The `%s' mode hasn't registered any handlers" major-mode))
  (let ((all-types nil))
    (pcase-dolist (`(,handled-type . ,handler)
                   yank-media--registered-handlers)
      (dolist (type (yank-media--find-matching-media handled-type))
        (push (cons type handler) all-types)))
    (if all-types t nil)))

(defun anju-dired-duplicate-file ()
  "Duplicate the current file in Dired."
  (interactive)
  (when (derived-mode-p 'dired-mode)
    (let* ((filename (dired-get-filename))
           (target (concat (file-name-sans-extension filename)
                           " copy"
                           (file-name-extension filename t))))
      (message target)
      (if (file-directory-p filename)
          (copy-directory filename target)
        (copy-file filename target)))))

(defun anju-org-stored-links-p ()
  "Predicate if `org-stored-links' is populated.
Return t if populated, nil otherwise."
  (if (> (length org-stored-links) 0)
      t
    nil))

(defun anju-yank-markdown-as-org ()
  "Yank Markdown text as Org.

This command will convert Markdown text in the top of the `kill-ring'
and convert it to Org using the pandoc utility."
  (interactive)
  (save-excursion
    (with-temp-buffer
      (yank)
      (shell-command-on-region
       (point-min) (point-max)
       "pandoc -f markdown -t org --wrap=preserve" t t)
      (kill-region (point-min) (point-max)))
    (yank)))


;; -------------------------------------------------------------------
;; Region Extension Context Menu
(defun anju-context-menu-region-extension (menu click)
  "Region menu using MENU and CLICK."

  (save-excursion
    (mouse-set-point click)
    (when (derived-mode-p 'org-mode)
      (easy-menu-add-item menu nil
                          ["Paste Last Org Link"
                           org-insert-last-stored-link
                           :visible (and (not buffer-read-only) (anju-org-stored-links-p))
                           :help "Insert the last link stored in org-stored-links"]
                          "Clear")

      (easy-menu-add-item menu nil
                          ["Paste Markdown as Org"
                           anju-yank-markdown-as-org
                           :visible (not buffer-read-only)
                           :help "Convert clipboard (latest yank) of Markdown text to Org, then paste"]
                          "Clear")

      (easy-menu-add-item menu nil
                          ["Paste Media"
                           yank-media
                           :visible (and (not buffer-read-only)
                                         (display-graphic-p)
                                         (derived-mode-p 'org-mode)
                                         (anju-yank-media-p))
                           :help "Paste (yank) media"]
                          "Clear")))
  menu)

(defun anju-filename-from-path (path)
  "Extract filename from full PATH."
  (let* ((extension (file-name-extension path))
         (base (file-name-base path)))
    (if extension
        (concat base "." extension)
      base)))


;; -------------------------------------------------------------------
;; Dired Context Menu

(defun anju-context-menu-dired (menu click)
  "Context menu hook function for Dired commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'dired-mode)
    (save-excursion
      (when (mouse-posn-property (event-start click) 'dired-filename)
        (easy-menu-add-item menu nil
                            ["Rename to…"
                             dired-do-rename
                             :help "Rename or move file"])

        (easy-menu-add-item menu nil
                            ["Copy to…"
                             dired-do-copy
                             :help "Copy file"])

        (easy-menu-add-item menu nil
                            ["Symlink…"
                             dired-do-relsymlink
                             :help "Make relative symlink"])

        (easy-menu-add-item menu nil
                            ["Toggle Thumbnail"
                             image-dired-dired-toggle-marked-thumbs
                             :visible (string-match-p (image-file-name-regexp)
                                                      (dired-get-filename))
                             :help "Toggle thumbnails in front of marked \
file names in the Dired buffer."])

        (easy-menu-add-item
         menu
         nil
         ["Duplicate"
          anju-dired-duplicate-file
          :label (format "Duplicate “%s”"
                         (anju-filename-from-path (dired-get-filename)))

          :help "Duplicate selected item"])

        ;; (easy-menu-add-item menu nil
        ;;                     ["Change Mode…"
        ;;                      dired-do-chmod
        ;;                      :help "Change mode of file (chmod)"])

        (easy-menu-add-item menu nil
                            ["Insert Subdir"
                             dired-maybe-insert-subdir
                             :label (format "Insert “%s” View"
                                            (anju-filename-from-path (dired-get-filename)))
                             :visible (file-directory-p
                                       (dired-file-name-at-point))
                             :help "Insert subdir (sub-directory)"])

        (anju-context-menu-item-separator menu trash-separator)

        (easy-menu-add-item menu nil
                            ["Move to Trash…"
                             dired-do-delete
                             :visible (file-writable-p
                                       (dired-file-name-at-point))
                             :help "Delete all marked files."])

        (anju-context-menu-item-separator menu dired-separator))

      (mouse-set-point click)

      (easy-menu-add-item menu nil
                          ["Toggle Subdir View"
                           dired-hide-subdir
                           :label (format
                                   "%s “%s” View"
                                   (if (dired-subdir-hidden-p
                                        (dired-current-directory))
                                       "Show" "Hide")
                                   (anju-filename-from-path
                                    (directory-file-name
                                     (dired-current-directory))))
                           :visible (and (dired-current-directory)
                                         (> (line-number-at-pos) 1) ; hack!
                                         (> (- (length dired-subdir-alist) 1) 0)
                                         (not (dired-file-name-at-point)))
                           :help "Toggle hide subdir (sub-directory)"])

      (easy-menu-add-item menu nil
                          ["Remove Subdir"
                           dired-kill-subdir
                           :label (format
                                   "Remove “%s” View"
                                   (anju-filename-from-path
                                    (directory-file-name
                                     (dired-current-directory))))
                           :visible (and (dired-current-directory)
                                         (> (line-number-at-pos) 1) ; hack!
                                         (> (- (length dired-subdir-alist) 1) 0)
                                         (not (dired-file-name-at-point)))
                           :help "Kill subdir (sub-directory)"])

      (easy-menu-add-item menu nil casual-dired-sort-menu)

      (easy-menu-add-item menu nil
                          ["Omit Mode"
                           dired-omit-mode
                           :style toggle
                           :selected dired-omit-mode
                           :help "Omit mode"])

      (easy-menu-add-item menu nil
                          ["Hide Details"
                           dired-hide-details-mode
                           :style toggle
                           :selected dired-hide-details-mode
                           :help "Hide directory details"])

      (easy-menu-add-item menu nil
                          ["📁 Dired…"
                           dired
                           :help "Open Dired"])))
  menu)


(defun anju-context-menu-scratch (menu click)
  "Context menu hook function for journal commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (and (not (anju-at-org-table-p))
               (not (use-region-p)))
      (anju-context-menu-item-separator menu journal-separator)
      (easy-menu-add-item menu nil ["Scratch"
                                    scratch-buffer
                                    :help "Switch to the *scratch* buffer."])))
  menu)

(defun anju-org-table-recalculate ()
  "Recalculate an Org table."
  (interactive)
  (org-table-recalculate 4))

(defun anju-context-menu-org-mode (menu click)
  "Context menu hook function for Org mode commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)

    (when (derived-mode-p 'org-mode)
      (anju-context-menu-item-separator menu org-separator)
      (when (org-at-heading-p)

        (easy-menu-add-item menu nil
                            ["Clock In"
                             org-clock-in
                             :visible (not (org-clocking-p))
                             :help "Clock in"])

        (easy-menu-add-item menu nil
                            ["Clock Out"
                             org-clock-out
                             :visible (org-clocking-p)
                             :help "Clock out"])

        (easy-menu-add-item menu nil
                            ["Demote →"
                             org-do-demote
                             :help "Demote"])

        (easy-menu-add-item menu nil
                            ["Promote ←"
                             org-do-promote
                             :help "Promote"])

        (easy-menu-add-item menu nil
                            ["Demote Subtree →"
                             org-demote-subtree
                             :help "Demote heading subtree"])

        (easy-menu-add-item menu nil
                            ["Promote Subtree ←"
                             org-promote-subtree
                             :help "Promote heading subtree"]))

      (when (org-at-item-p)
        (easy-menu-add-item menu nil
                            ["Demote →"
                             org-indent-item
                             :help "Demote"])

        (easy-menu-add-item menu nil
                            ["Promote ←"
                             org-outdent-item
                             :help "Promote"])

        (easy-menu-add-item menu nil
                            ["Demote Subtree →"
                             org-indent-item-tree
                             :help "Demote item subtree"])

        (easy-menu-add-item menu nil
                            ["Promote Subtree ←"
                             org-outdent-item-tree
                             :help "Promote item subtree"])

        (if (org-at-item-checkbox-p)
            (easy-menu-add-item menu nil
                            ["In-Progress"
                             casual-org-checkbox-in-progress
                             :help "Change checkbox state to in-progress [-]"]))

        (easy-menu-add-item menu nil
                            ["Toggle List/Checkbox"
                             casual-org-toggle-list-to-checkbox
                             :label (if (org-at-item-checkbox-p)
                                        "To Item"
                                      "To Checkbox")
                             :help "Toggle Item/Checkbox"]))

      (when (anju-at-org-table-p)
        (easy-menu-add-item menu nil
                            ["Table Cell Info"
                             casual-org-table-copy-reference-dwim
                             :label (casual-org-table--reference-dwim)
                             :help "Copy Org table reference (field or range) into kill ring via mouse"])

        (easy-menu-add-item menu nil anju-org-table-region-menu)

        (easy-menu-add-item menu nil
                            ["Show Coordinates"
                             org-table-toggle-coordinate-overlays
                             :style toggle
                             :selected org-table-coordinate-overlays
                             :help "Toggle the display of row/column numbers in tables"])

        (easy-menu-add-item menu nil
                            ["Recalculate"
                             anju-org-table-recalculate
                             :help "Recalculate table"])

        (easy-menu-add-item menu nil
                            ["Edit Table Formulas"
                             org-table-edit-formulas
                             :help "Edit the formulas of the current table in a separate buffer."])

        ;; (easy-menu-add-item menu nil cc/insert-org-plot-menu)
        (easy-menu-add-item menu nil ["Run gnuplot"
                                      org-plot/gnuplot
                                      :help "Plot table using gnuplot"]))))
  menu)

(defun anju-context-menu-buffers (menu click)
  "Context menu hook function for buffers commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (and (not (use-region-p))
               (not (anju-at-org-table-p)))
      (anju-context-menu-item-separator menu buffer-navigation-separator)
      (easy-menu-add-item menu nil ["← Buffer"
                                    previous-buffer
                                    :help "Go to previous buffer"])

      (easy-menu-add-item menu nil ["→ Buffer"
                                    next-buffer
                                    :help "Go to next buffer"])

      (easy-menu-add-item menu nil ["≣ List All Buffers"
                                    ibuffer
                                    :help "List all buffers"])))
  menu)

(defun anju-context-menu-narrow (menu click)
  "Context menu hook function for narrow commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (and (not (anju-at-org-table-p)) (not (derived-mode-p 'Info-mode)))
      (anju-context-menu-item-separator menu narrow-separator)
      (cond ((use-region-p)
             (easy-menu-add-item menu nil
                                 ["Narrow Region" narrow-to-region
                                  :label (anju-menu-label "Narrow Region")
                                  :help "Restrict editing in this buffer \
to the current region"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'prog-mode))
             (easy-menu-add-item menu nil
                                 ["Narrow to defun" narrow-to-defun
                                  :help "Restrict editing in this buffer \
to the current defun"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'org-mode))
             (easy-menu-add-item menu nil
                                 ["Narrow to subtree" org-narrow-to-subtree
                                  :help "Restrict editing in this buffer \
to the current subtree"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'markdown-mode))
             (easy-menu-add-item menu nil
                                 ["Narrow to subtree" markdown-narrow-to-subtree
                                  :help "Restrict editing in this buffer \
to the current subtree"])))

      (when (and (buffer-narrowed-p) (not (derived-mode-p 'Info-mode)))
        (easy-menu-add-item menu nil
                            ["Widen buffer" widen
                             :help "Remove narrowing restrictions \
from current buffer"]))))
  menu)


(defun anju-context-menu-open-in (menu click)
  "Context menu hook function for open-in commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (and (not (use-region-p))
               (not (anju-at-org-table-p))
               (buffer-file-name)
               (not (derived-mode-p 'dired-mode)))

      (anju-context-menu-item-separator menu open-in-separator)
      (easy-menu-add-item menu nil
                          ["📁 Open in Dired"
                           dired-jump-other-window
                           :help "Open file in Dired"])))
  menu)


(defun anju-context-menu-vc (menu click)
  "Context menu hook function for version control commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (and (vc-responsible-backend default-directory t)
               (not (derived-mode-p 'magit-status-mode))
               (not (use-region-p))
               (not (anju-at-org-table-p)))

      (anju-context-menu-item-separator menu vc-separator)

      (when (package-installed-p 'magit)
        (require 'magit)
        (if (buffer-file-name)
            (easy-menu-add-item
             menu nil
             ["Magit Dispatch…"
              magit-file-dispatch
              :help "Show the status of the current Git repository in a buffer"])
          (easy-menu-add-item
           menu nil
           ["Magit Status"
            magit-status
            :help "Show the status of the current Git repository in a buffer"])))

      (easy-menu-add-item
       menu nil
       ["Ediff revision…"
        casual-ediff-revision-from-menu
        :visible (and (bound-and-true-p buffer-file-name)
                      (vc-registered (buffer-file-name)))
        :help "Ediff this file with revision"])))
  menu)

(defun anju-context-menu-region (menu click)
  "Context menu hook function for region commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (use-region-p)
      (anju-context-menu-item-separator menu transform-text-separator)
      (easy-menu-add-item menu nil
                          ["Occur"
                           anju-occur-selected-region
                           :label (anju-menu-label "Occur")
                           :help "Show all lines in the current buffer \
containing a match for selected word"])

      (if (or (and (derived-mode-p 'org-mode) (not (anju-at-org-table-p)))
              (derived-mode-p 'markdown-mode))
          (easy-menu-add-item menu nil anju-style-menu))

      (easy-menu-add-item menu nil anju-transform-text-menu)

      (if (or (derived-mode-p 'prog-mode) (derived-mode-p 'org-mode))
          (easy-menu-add-item menu nil
                              ["Toggle Comment"
                               comment-dwim
                               :visible (not buffer-read-only)
                               :help "Toggle comment on selected region"]))

      (easy-menu-add-item menu nil
                          ["Write Region…"
                           write-region
                           :help "Write current region into specified file"])))
  menu)


(defun anju-context-menu-markup (menu click)
  "Context menu hook function for markup commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (save-excursion
    (mouse-set-point click)
    (when (not (use-region-p))
      (pcase (derived-mode-p major-mode)
        ('org-mode
         (when (not (anju-at-org-table-p))
           (anju-context-menu-item-separator menu org-mode-operations-separator)
           (easy-menu-add-item menu nil
                               ["Toggle Images"
                                casual-org-toggle-images
                                :help "Toggle images"])

           (easy-menu-add-item menu nil
                               ["Show Markup"
                                visible-mode
                                :style toggle
                                :selected visible-mode
                                :help "Toggle making all invisible text \
temporarily visible (Visible mode)"])))

        ('markdown-mode
         (anju-context-menu-item-separator menu markdown-mode-operations-separator)
         (easy-menu-add-item menu nil
                             ["Hide Markup"
                              markdown-toggle-markup-hiding
                              :style toggle
                              :selected markdown-hide-markup
                              :help "Toggle the display or hiding of markup"]))
        (m nil))))
  menu)


(defun anju-context-menu-wordcount (menu click)
  "Context menu hook function for wordcount commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (save-excursion
    (mouse-set-point click)
    (when (and (derived-mode-p 'text-mode) (not (anju-at-org-table-p)))
      (anju-context-menu-item-separator menu count-words-separator)
      (easy-menu-add-item menu nil ["Count Words"
                                    count-words
                                    :help "Count words"])))
  menu)


(defun anju-context-menu-window (menu click)
  "Context menu hook function for wordcount commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (ignore click)

  (save-excursion
    (anju-context-menu-item-separator menu context-window--separator)
    (easy-menu-add-item menu nil anju-context-window-management-menu))
  menu)

(defun anju-context-menu--insert-into-context-menu-functions (source target)
  "Insert SOURCE before TARGET in `context-menu-functions'.

This function provides finer grained control in inserting a context menu
function into `context-menu-functions' over `add-hook'."
  (let* ((s (default-value 'context-menu-functions))
         (i (seq-position s target)))

    (setq s (append (seq-subseq s 0 i)
                    (cons source (seq-subseq s i))))
    (setq-default context-menu-functions s)))

(defun anju-context-menu--remove-from-context-menu-functions (target)
  "Remove TARGET in `context-menu-functions'."
  (let* ((s (default-value 'context-menu-functions)))
    (setq s (remove target s))
    (setq-default context-menu-functions s)))

(defun anju-reconfigure-context-menu-functions ()
  "Reconfigure `context-menu-functions'."
  (interactive)
  (when (not (get 'context-menu-functions 'saved-value))
    (mapc (lambda (fn)
            (if (not (member fn context-menu-functions))
                (add-hook 'context-menu-functions fn)))
          (reverse '(anju-context-menu-dired
                     anju-context-menu-org-mode
                     anju-context-menu-scratch
                     anju-context-menu-buffers
                     anju-context-menu-region
                     anju-context-menu-narrow
                     anju-context-menu-open-in
                     anju-context-menu-vc
                     anju-context-menu-markup
                     anju-context-menu-wordcount
                     anju-context-menu-window))))

  (if (member #'context-menu-middle-separator context-menu-functions)
      (anju-context-menu--insert-into-context-menu-functions #'anju-context-menu-region-extension
                                                             #'context-menu-middle-separator))
  (if (member #'context-menu-minor context-menu-functions)
      (anju-context-menu--remove-from-context-menu-functions #'context-menu-minor))
  (if (member #'context-menu-local context-menu-functions)
      (anju-context-menu--remove-from-context-menu-functions #'context-menu-local))
  (if (member #'context-menu-middle-separator context-menu-functions)
      (anju-context-menu--remove-from-context-menu-functions #'context-menu-middle-separator)))

(defun anju-reset-context-menu-functions ()
  "Reset `context-menu-functions'."
  (interactive)
  (mapc (lambda (fn)
          (anju-context-menu--remove-from-context-menu-functions fn))
        (reverse '(anju-context-menu-dired
                   anju-context-menu-org-mode
                   anju-context-menu-scratch
                   anju-context-menu-buffers
                   anju-context-menu-narrow
                   anju-context-menu-open-in
                   anju-context-menu-region-extension
                   anju-context-menu-vc
                   anju-context-menu-region
                   anju-context-menu-markup
                   anju-context-menu-wordcount
                   anju-context-menu-window))))

(provide 'anju-context-menu)
;;; anju-context-menu.el ends here
