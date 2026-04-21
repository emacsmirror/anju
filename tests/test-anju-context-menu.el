;;; test-anju-context-menu.el --- Context Menu Tests  -*- lexical-binding: t; -*-

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
(require 'anju-context-menu)
(require 'anju-test-utils)

(ert-deftest test-anju-org-table-region-menu ()
  "Test `anju-org-table-region-menu'."

  (anju-test-keymap anju-org-table-region-menu
                    "Org Table Region"
                    3
                    (lambda (items)
                      (let ((cut-item (seq-elt items 0))
                            (copy-item (seq-elt items 1))
                            (paste-item (seq-elt items 2)))

                        (anju-test-menu-item cut-item
                                             "Cut"
                                             #'org-table-cut-region
                                             "Cut Org table region")

                        (anju-test-menu-item copy-item
                                             "Copy"
                                             #'org-table-copy-region
                                             "Copy Org table region")

                        (anju-test-menu-item paste-item
                                             "Paste"
                                             #'org-table-paste-rectangle
                                             "Paste Org table region")))))


(ert-deftest test-anju-context-window-management-menu ()
  "Test `anju-context-window-management-menu'."

  (anju-test-keymap
   anju-context-window-management-menu
   "Window"
   4
   (lambda (items)
     (let ((delete-window-item (seq-elt items 0))
           (split-horizontal-item (seq-elt items 1))
           (split-vertical-item (seq-elt items 2))
           (swap-menu (seq-elt items 3)))
       (anju-test-menu-item delete-window-item
                            "×"
                            #'delete-window
                            "Delete window")

       (anju-test-menu-item split-horizontal-item
                            "Split →"
                            #'mouse-split-window-horizontally
                            "Split right at mouse point")

       (anju-test-menu-item split-vertical-item
                            "Split ↓"
                            #'mouse-split-window-vertically
                            "Split below at mouse point")

       (let ((swap-kmap (seq-elt swap-menu 3)))
         (anju-test-keymap
          swap-kmap
          "Swap"
          4
          (lambda (items)
            (let ((up-item (seq-elt items 0))
                  (down-item (seq-elt items 1))
                  (left-item (seq-elt items 2))
                  (right-item (seq-elt items 3)))
              (anju-test-menu-item up-item
                                   "↑"
                                   #'windmove-swap-states-up
                                   "Swap window up")

              (anju-test-menu-item down-item
                                   "↓"
                                   #'windmove-swap-states-down
                                   "Swap window down")

              (anju-test-menu-item left-item
                                   "←"
                                   #'windmove-swap-states-left
                                   "Swap window left")

              (anju-test-menu-item right-item
                                   "→"
                                   #'windmove-swap-states-right
                                   "Swap window right")))))))))


;; (ert-deftest test-anju-occur-selected-region ()
;;   "Test for `anju-occur-selected-region'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-at-org-table-p ()
;;   "Test for `anju-at-org-table-p'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-dired-duplicate-file ()
;;   "Test for `anju-dired-duplicate-file'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-org-stored-links-p ()
;;   "Test for `anju-org-stored-links-p'."
;;   ;; Untested
;; )

;; (ert-deftest test-anju-yank-markdown-as-org ()
;;   "Test for `anju-yank-markdown-as-org'."
;;   ;; Untested
;; )

(ert-deftest test-anju-context-menu-region-extension ()
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-region-extension
   3
   (lambda (items)
     (let ((item0 (seq-elt items 0))
           (item1 (seq-elt items 1))
           (item2 (seq-elt items 2)))
       (anju-test-menu-item
        item0
        "Paste Last Org Link"
        #'org-insert-last-stored-link
        "Insert the last link stored in org-stored-links")

       (anju-test-menu-item
        item1
        "Paste Markdown as Org"
        #'anju-yank-markdown-as-org
        "Convert clipboard (latest yank) of Markdown text to Org, then paste")

       (anju-test-menu-item
        item2
        "Paste Media"
        #'yank-media
        "Paste (yank) media")))))

(ert-deftest test-anju-filename-from-path ()
  "Test for `anju-filename-from-path'."

  (should (string-equal (anju-filename-from-path "~/mary/jane.org")
                        "jane.org")))

(ert-deftest test-anju-context-menu-dired ()
  "Test for `anju-context-menu-dired'."
  (dired "~/Projects/elisp/anju/")
  (anju-test-context-menu-function
   #'anju-context-menu-dired
   "hi there"
   15
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Rename to…"
        #'dired-do-rename
        "Rename or move file")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Copy to…"
        #'dired-do-copy
        "Copy file")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Symlink…"
        #'dired-do-relsymlink
        "Make relative symlink")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Toggle Thumbnail"
        #'image-dired-dired-toggle-marked-thumbs
        "Toggle thumbnails in front of marked file names in the Dired buffer")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format "Duplicate “%s”" (anju-filename-from-path (dired-get-filename))))
        #'anju-dired-duplicate-file
        "Duplicate selected item")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format "Insert “%s” View"
                      (anju-filename-from-path (dired-get-filename))))
        #'dired-maybe-insert-subdir
        "Insert subdir (sub-directory)")

       (anju-test-menu-item (seq-elt items (cl-incf i)) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Move to Trash…"
        #'dired-do-delete
        "Delete all marked files")

       (anju-test-menu-item (seq-elt items (cl-incf i)) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format
               "%s “%s” View"
               (if (dired-subdir-hidden-p
                    (dired-current-directory))
                   "Show" "Hide")
               (anju-filename-from-path
                (directory-file-name
                 (dired-current-directory)))))
        #'dired-hide-subdir
        "Toggle hide subdir (sub-directory)")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (format
               "Remove “%s” View"
               (anju-filename-from-path
                (directory-file-name
                 (dired-current-directory)))))
        #'dired-kill-subdir
        "Kill subdir (sub-directory)")

       (should (string-equal (seq-elt (seq-elt items (cl-incf i)) 2) "Sort By"))

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Omit Mode"
        #'dired-omit-mode
        "Omit mode")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Hide Details"
        #'dired-hide-details-mode
        "Hide directory details")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "📁 Dired…"
        #'dired
        "Open Dired"))))
  (kill-buffer))

(ert-deftest test-anju-context-menu-scratch ()
  "Test for `anju-context-menu-scratch'."

  (anju-test-context-menu-function
   #'anju-context-menu-scratch
   "Scratch"
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))
       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Scratch"
        #'scratch-buffer
        "Switch to the *scratch* buffer")))))


(ert-deftest test-anju-context-menu-dictionary ()
  "Test for `anju-context-menu-dictionary'."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-dictionary
   1
   (lambda (items)
     (let ((item0 (seq-elt items 0)))
       (anju-test-menu-item
        item0
        (lambda () (format "Look Up “%s”" (substring-no-properties (thing-at-point 'word))))
        #'dictionary-search-word-at-mouse
        "Look up selected region in dictionary")))

   (lambda (filename description)
     (insert "Hi There\nImma going fishing.\n")
     (save-buffer)
     (goto-char (point-min))
     (mark-word)
     (activate-mark))))

(ert-deftest test-anju-context-menu-org-mode-heading ()
  "Test for `anju-context-menu-org-mode' when point is in heading."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   7
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Clock In"
        #'org-clock-in
        "Clock in")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Clock Out"
        #'org-clock-out
        "Clock out")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote →"
        #'org-do-demote
        "Demote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote ←"
        #'org-do-promote
        "Promote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote Subtree →"
        #'org-demote-subtree
        "Demote heading subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote Subtree ←"
        #'org-promote-subtree
        "Promote heading subtree")))
   (lambda (filename description)
     (insert "* heading 1")
     (goto-char (point-min))
     (save-buffer))))


(ert-deftest test-anju-context-menu-org-mode-list-item ()
  "Test for `anju-context-menu-org-mode' when point is in list item."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote →"
        #'org-indent-item
        "Demote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote ←"
        #'org-outdent-item
        "Promote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote Subtree →"
        #'org-indent-item-tree
        "Demote item subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote Subtree ←"
        #'org-outdent-item-tree
        "Promote item subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (if (org-at-item-checkbox-p)
                  "To Item"
                "To Checkbox"))
        #'casual-org-toggle-list-to-checkbox
        "Toggle Item/Checkbox")))
   (lambda (filename description)
     (insert "- item 1")
     (goto-char (point-min))
     (save-buffer))))

(ert-deftest test-anju-context-menu-org-mode-checkbox-item ()
  "Test for `anju-context-menu-org-mode' when point is in list item."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   7
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote →"
        #'org-indent-item
        "Demote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote ←"
        #'org-outdent-item
        "Promote")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Demote Subtree →"
        #'org-indent-item-tree
        "Demote item subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Promote Subtree ←"
        #'org-outdent-item-tree
        "Promote item subtree")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "In-Progress"
        #'casual-org-checkbox-in-progress
        "Change checkbox state to in-progress [-]")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        (lambda () (if (org-at-item-checkbox-p)
                  "To Item"
                "To Checkbox"))
        #'casual-org-toggle-list-to-checkbox
        "Toggle Item/Checkbox")))
   (lambda (filename description)
     (insert "- [ ] item 1")
     (goto-char (point-min))
     (save-buffer))))

(ert-deftest test-anju-context-menu-org-mode-table ()
  "Test for `anju-context-menu-org-mode' when point is in table."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-org-mode
   7
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2))   ; anju-org-table-region-menu
            (item3 (seq-elt items 3))
            (item4 (seq-elt items 4))
            (item5 (seq-elt items 5))
            (item6 (seq-elt items 6)))

       (anju-test-menu-item item0 "--")

       (anju-test-menu-item
        item1
        (lambda () (casual-org-table--reference-dwim))
        #'casual-org-table-copy-reference-dwim
        "Copy Org table reference (field or range) into kill ring via mouse")

       ;;  bypass testing item2

       (anju-test-menu-item
        item3
        "Show Coordinates"
        #'org-table-toggle-coordinate-overlays
        "Toggle the display of row/column numbers in tables")

       (anju-test-menu-item
        item4
        "Recalculate"
        #'anju-org-table-recalculate
        "Recalculate table")

       (anju-test-menu-item
        item5
        "Edit Table Formulas"
        #'org-table-edit-formulas
        "Edit the formulas of the current table in a separate buffer")

       (anju-test-menu-item
        item6
        "Run gnuplot"
        #'org-plot/gnuplot
        "Plot table using gnuplot")))

   (lambda (filename description)
     (insert "| a | b | c |\n|---|---|---|\n| 1 | 2 | 3 |\n")
     (goto-char 1)
     (save-buffer))))

(ert-deftest test-anju-context-menu-buffers ()
  "Test for `anju-context-menu-buffers'."

  (anju-test-context-menu-function
   #'anju-context-menu-buffers
   "Dummy"
   4
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2))
            (item3 (seq-elt items 3)))

       (anju-test-menu-item item0 "--")

       (anju-test-menu-item
        item1
        "← Buffer"
        #'previous-buffer
        "Go to previous buffer")

       (anju-test-menu-item
        item2
        "→ Buffer"
        #'next-buffer
        "Go to next buffer")

       (anju-test-menu-item
        item3
        "≣ List All Buffers"
        #'ibuffer
        "List all buffers")))))

(ert-deftest test-anju-context-menu-narrow-region ()
  "Test for `anju-context-menu-narrow' when editing a region."

  (anju-test-context-menu-function-with-filetype
   ".txt"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        (lambda () (anju-menu-label "Narrow Region"))
        #'narrow-to-region
        "Restrict editing in this buffer to the current region")))

   (lambda (filename description)
     (insert "Hi There\nImma going fishing.\n")
     (save-buffer)
     (push-mark (point-min) t t)
     (goto-char (point-max))
     (activate-mark))))


(ert-deftest test-anju-context-menu-narrow-elisp ()
  "Test for `anju-context-menu-narrow' when editing an Elisp file."

  (anju-test-context-menu-function-with-filetype
   ".el"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Narrow to defun"
        #'narrow-to-defun
        "Restrict editing in this buffer to the current defun")
       ))

   (lambda (filename description)
     (insert "(defun cold ()\n (message \"hi\"))\n")
     (save-buffer)
     (goto-char (point-min)))))

(ert-deftest test-anju-context-menu-narrow-org ()
  "Test for `anju-context-menu-narrow' when editing an Org file."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Narrow to subtree"
        #'org-narrow-to-subtree
        "Restrict editing in this buffer to the current subtree")))

   (lambda (filename description)
     (insert "* Hi There\n")
     (save-buffer)
     (goto-char (point-min)))))

(ert-deftest test-anju-context-menu-narrow-markdown ()
  "Test for `anju-context-menu-narrow' when editing a Markdown file."

  (anju-test-context-menu-function-with-filetype
   ".md"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Narrow to subtree"
        #'markdown-narrow-to-subtree
        "Restrict editing in this buffer to the current subtree")))

   (lambda (filename description)
     (insert "# Hi There\n")
     (save-buffer)
     (goto-char (point-min))
     (goto-char (point-max)))))

(ert-deftest test-anju-context-menu-narrow-narrowed ()
  "Test for `anju-context-menu-narrow' when editing an Elisp file."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-narrow
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Widen buffer"
        #'widen
        "Remove narrowing restrictions from current buffer")
       ))

   (lambda (filename description)
     (insert "* Hi There\n\n* Whats Up\n")
     (save-buffer)
     (goto-char (point-min))
     (org-narrow-to-subtree))))

(ert-deftest test-anju-context-menu-open-in ()
  "Test for `anju-context-menu-open-in'."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-open-in
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "📁 Open in Dired"
        #'dired-jump-other-window
        "Open file in Dired")))))

(ert-deftest test-anju-context-menu-vc-file ()
  "Test for `anju-context-menu-vc'."

  (find-file "~/Projects/elisp/anju/README.org")
  (anju-test-context-menu-function
   #'anju-context-menu-vc
   "hi there"
   3
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Magit Dispatch…"
        #'magit-file-dispatch
        "Show the status of the current Git repository in a buffer")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Ediff revision…"
        #'casual-ediff-revision-from-menu
        "Ediff this file with revision"))))

  (kill-buffer))

(ert-deftest test-anju-context-menu-vc-dired ()
  "Test for `anju-context-menu-vc'."
  (dired "~/Projects/elisp/anju/")
  (anju-test-context-menu-function
   #'anju-context-menu-vc
   "hi there"
   3
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2)))
       (anju-test-menu-item item0 "--")

       (anju-test-menu-item
        item1
        "Magit Status"
        #'magit-status
        "Show the status of the current Git repository in a buffer")

       (anju-test-menu-item
        item2
        "Ediff revision…"
        #'casual-ediff-revision-from-menu
        "Ediff this file with revision"))))

  (kill-buffer))

(ert-deftest test-anju-context-menu-region ()
  "Test for `anju-context-menu-region'."

  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-region
   6
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2))
            (item3 (seq-elt items 3))
            (item4 (seq-elt items 4))
            (item5 (seq-elt items 5)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        (lambda () (anju-menu-label "Occur"))
        #'anju-occur-selected-region
        "Show all lines in the current buffer \
containing a match for selected word")

       (should (string-equal (seq-elt item2 2) "Style"))
       (should (string-equal (seq-elt item3 2) "Transform Text"))

       (anju-test-menu-item
        item4
        "Toggle Comment"
        #'comment-dwim
        "Toggle comment on selected region")

       (anju-test-menu-item
        item5
        "Write Region…"
        #'write-region
        "Write current region into specified file")))

   (lambda (filename description)
     (insert "* Hi There\nImma going fishing.\n")
     (save-buffer)
     (push-mark (point-min) t t)
     (goto-char (point-max))
     (activate-mark))))

(ert-deftest test-anju-context-menu-markup ()
  "Test for `anju-context-menu-markup'."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-markup
   3
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1))
            (item2 (seq-elt items 2)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Toggle Images"
        #'casual-org-toggle-images
        "Toggle images")

       (anju-test-menu-item
        item2
        "Show Markup"
        #'visible-mode
        "Toggle making all invisible text \
temporarily visible (Visible mode)"
        )))))

(ert-deftest test-anju-context-menu-wordcount ()
  "Test for `anju-context-menu-wordcount'."
  (anju-test-context-menu-function-with-filetype
   ".org"
   #'anju-context-menu-wordcount
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (anju-test-menu-item
        item1
        "Count Words"
        #'count-words
        "Count words")))))

(ert-deftest test-anju-context-menu-window ()
  "Test for `anju-context-menu-window'."

  (anju-test-context-menu-function
   #'anju-context-menu-window
   "Stub Text"
   2
   (lambda (items)
     (let* ((item0 (seq-elt items 0))
            (item1 (seq-elt items 1)))

       (anju-test-menu-item item0 "--")
       (should (string-equal (seq-elt item1 2) "Window"))))))

;; (ert-deftest test-anju-context-menu--insert-into-context-menu-functions ()
;;   "Test for `anju-context-menu--insert-into-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-context-menu--remove-from-context-menu-functions ()
;;   "Test for `anju-context-menu--remove-from-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-reconfigure-context-menu-functions ()
;;   "Test for `anju-reconfigure-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

;; (ert-deftest test-anju-reset-context-menu-functions ()
;;   "Test for `anju-reset-context-menu-functions'."
;;   (should (unless anju-test-fail-uncovered-tests "Untested"))
;;   )

(provide 'test-anju-context-menu)
;;; test-anju-context-menu.el ends here
