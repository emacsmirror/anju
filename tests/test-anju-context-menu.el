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


;; -------------------------------------------------------------------
;; Context Menu: Region Extension

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


;; -------------------------------------------------------------------
;; Context Menu: Dired

(ert-deftest test-anju-context-menu-dired ()
  "Test for `anju-context-menu-dired'."
  (dired "~/Projects/elisp/anju/")
  (anju-test-context-menu-function
   #'anju-context-menu-dired
   "hi there"
   14
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
        "Copy name"
        #'dired-copy-filename-as-kill
        "Copy names of marked (or next ARG) files into the kill ring")

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


(ert-deftest test-anju-context-menu-dired-subdir ()
  "Test for `anju-context-menu-dired' subdir commands."
  (dired "~/Projects/elisp/anju/")
  (dired-goto-file (expand-file-name "~/Projects/elisp/anju/tests"))
  (dired-maybe-insert-subdir (expand-file-name "~/Projects/elisp/anju/tests"))
  (dired-goto-subdir (expand-file-name "~/Projects/elisp/anju/tests"))
  (anju-test-context-menu-function
   #'anju-context-menu-dired
   "hi there"
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
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

       )))
  (kill-buffer))


;; -------------------------------------------------------------------
;; Context Menu: Scratch Buffer

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



;; -------------------------------------------------------------------
;; Context Menu: Dictionary

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



;; -------------------------------------------------------------------
;; Context Menu: Emacs Lisp Mode

(defun test--anju-edebug-mode-menu (kmap)
  "Test for `anju-edebug-mode-menu'."
  (anju-test-keymap
   kmap
   "Mode"
   5
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Step"
        #'edebug-step-mode
        "Stop at the next stop point encountered")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Go to ●"
        #'edebug-go-mode
        "Run until the next breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Continue"
        #'edebug-continue-mode
        "Pause one second at each breakpoint, and then continue")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Next"
        #'edebug-next-mode
        "Stop at the next stop point encountered after an expression")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Trace"
        #'edebug-trace-mode
        "Pause (normally one second) at each Edebug stop point")))))

(ert-deftest test-anju-edebug-mode-menu ()
  "Test for `anju-edebug-mode-menu'."
  (test--anju-edebug-mode-menu anju-edebug-mode-menu))


(defun test--anju-edebug-breakpoint-menu (kmap)
  "Test for `anju-edebug-breakpoint-menu'."
  (anju-test-keymap
   kmap
   "Breakpoint"
   5
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Set Breakpoint ●"
        #'edebug-set-breakpoint
        "Set breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Set Conditional ⦿"
        #'edebug-set-conditional-breakpoint
        "Set conditional breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Next ●"
        #'edebug-next-breakpoint
        "Next breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Unset ●"
        #'edebug-unset-breakpoint
        "Unset breakpoint")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Unset all ●"
        #'edebug-unset-breakpoints
        "Unset all breakpoints")))))


(ert-deftest test-anju-edebug-breakpoint-menu ()
  "Test for `anju-edebug-breakpoint-menu'."
  (test--anju-edebug-breakpoint-menu anju-edebug-breakpoint-menu))


(defun test--anju-edebug-sexp-menu (kmap)
  "Test for `anju-edebug-sexp-menu'."
  (anju-test-keymap
   kmap
   "Sexp"
   3
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item
        (seq-elt items i)
        "Forward"
        #'edebug-forward-sexp
        "Forward sexp")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Step-in"
        #'edebug-step-in
        "Step in sexp")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Step-out"
        #'edebug-step-out
        "Step out sexp")))))


(ert-deftest test-anju-edebug-sexp-menu ()
  "Test for `anju-edebug-sexp-menu'."
  (test--anju-edebug-sexp-menu anju-edebug-sexp-menu))

(defun test--anju-hideshow-menu (kmap)
  "Test for `anju-hideshow-menu'."
  (anju-test-keymap
   kmap
   "Hide/Show"
   3
   (lambda (items)
     (let ((i 0))
       (cl-letf  (((symbol-function 'hs-already-hidden-p) (lambda () t)))
        (anju-test-menu-item
        (seq-elt items i)
        (lambda () (if (hs-already-hidden-p) "Show Block" "Hide Block"))
        #'hs-toggle-hiding
        "Toggle hiding"))

       (cl-letf  (((symbol-function 'hs-already-hidden-p) (lambda () nil)))
        (anju-test-menu-item
        (seq-elt items i)
        (lambda () (if (hs-already-hidden-p) "Show Block" "Hide Block"))
        #'hs-toggle-hiding
        "Toggle hiding"))

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Hide All"
        #'hs-hide-all
        "Hide all")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Show All"
        #'hs-show-all
        "Show all")))))

(ert-deftest test-anju-hideshow-menu ()
  "Test for `anju-hideshow-menu'."
  (test--anju-hideshow-menu anju-hideshow-menu))

(ert-deftest test-anju-context-menu-elisp ()
  "Test for `anju-context-menu-elisp'."

  (let ((elfile (expand-file-name "../tests/anju-elisp-edebug-examples.el")))
   (anju-test-context-menu-function-with-filetype
    ".el"
    #'anju-context-menu-elisp
    10
    (lambda (items)
      (let ((i 0))
        (anju-test-menu-item (seq-elt items i) "--")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Eval Last Sexp"
         #'eval-last-sexp
         "Evaluate sexp before point; print value in the echo area")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Eval “%s”" (anju-form-name-at-point)))
         #'eval-defun
         "Evaluate the top level form point is in")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Edebug “%s”" (anju-form-name-at-point)))
         #'anju-edebug-defun
         "Evaluate the top level form point is in, stepping through with Edebug")


        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (if (use-region-p) "Eval Region" "Eval Buffer"))
         #'elisp-eval-region-or-buffer
         "Evaluate region or buffer")

        (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
          (test--anju-hideshow-menu kmap))

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Rename “%s”" (thing-at-point 'symbol)))
         #'xref-find-references-and-replace
         "Rename xref symbol")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         (lambda () (format "Test “%s”" (anju-form-name-at-point)))
         #'anju-ert-run-test-at-point
         "ERT")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Extract 𝜆…"
         #'anju-extract-lambda-to-defun
         "Convert lambda expression into a function")

        (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Eval Expression…"
         #'eval-expression
         "Evaluate expression and print result in mini-buffer")))

    (lambda (filename description)
      (insert-file-contents elfile)
      (save-buffer)
      (goto-char (point-min))
      (search-forward "foo")))))

(ert-deftest test-anju-context-menu-elisp-edebug-mode ()
  "Test for `anju-context-menu-elisp'."
  (cl-letf (((symbol-function 'anju-edebug-mode-p) (lambda () t)))
    (let ((elfile (expand-file-name "../tests/anju-elisp-edebug-examples.el")))
      (anju-test-context-menu-function-with-filetype
       ".el"
       #'anju-context-menu-elisp
       12
       (lambda (items)
         (let ((i 0))
           (anju-test-menu-item (seq-elt items i) "--")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Step"
            #'edebug-step-mode
            "Step")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Here"
            #'edebug-goto-here
            "Here")

           (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-edebug-mode-menu kmap))

           (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-edebug-sexp-menu kmap))

           (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-edebug-breakpoint-menu kmap))

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Eval…"
            #'edebug-eval-expression
            "Eval expression")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Previous"
            #'edebug-previous-result
            "Previous result")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Suspend Edebug"
            #'edebug-view-outside
            "Suspend Edebug, run edebug-where to resume")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Watchlist"
            #'edebug-visit-eval-list
            "Open watchlist")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Stop execution"
            #'edebug-stop
            "Stop Edebug execution, useful for exiting from trace or continue loop")

           (anju-test-menu-item
            (seq-elt items (cl-incf i))
            "Exit"
            #'edebug-top-level-nonstop
            "Quit Edebug Nonstop")))

       (lambda (filename description)
         (insert-file-contents elfile)
         (save-buffer)
         (goto-char (point-min))
         (search-forward "foo"))))))

(ert-deftest test-anju-context-menu-edebug-eval ()
  "Test for `anju-context-menu-edebug-eval'."

  (anju-test-context-menu-function-with-filetype
   ".el"
   #'anju-context-menu-edebug-eval
   6
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")

       (anju-test-menu-item
        (seq-elt items (cl-incf i))
        "Add symbol"
        #'edebug-update-eval-list
        "In the watchlist, type in symbol or sexp to add")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Delete symbol"
         #'edebug-delete-eval-item
         "Place point on symbol or sexp to delete")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Eval last sexp"
         #'edebug-eval-last-sexp
         "Eval last sexp")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Insert last sexp"
         #'edebug-eval-print-last-sexp
         "Insert (print) eval of last sexp into watchlist")

       (anju-test-menu-item
         (seq-elt items (cl-incf i))
         "Resume"
         #'edebug-where
         "Resume code stepping")))

   (lambda (filename description)
     (edebug-eval-mode)))



)



;; -------------------------------------------------------------------
;; Context Menu: Org Mode

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

(ert-deftest test-anju-org-table-region-menu ()
  "Test `anju-org-table-region-menu'."

  (anju-test-keymap
   anju-org-table-region-menu
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


;; -------------------------------------------------------------------
;; Context Menu: Buffer Navigation/Management


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


;; -------------------------------------------------------------------
;; Context Menu: Narrow/Widen

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


;; -------------------------------------------------------------------
;; Context Menu: Open in…

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


;; -------------------------------------------------------------------
;; Context Menu: VC/Magit

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


;; -------------------------------------------------------------------
;; Context Menu: Region Operations

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


;; -------------------------------------------------------------------
;; Context Menu: Show Markup/Toggle Images

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


;; -------------------------------------------------------------------
;; Context Menu: Word Count

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


;; -------------------------------------------------------------------
;; Context Menu: Window Management

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


;; -------------------------------------------------------------------
;; Context Menu: Rectangle Commands

(ert-deftest test-anju-context-menu-rectangle ()
  "Test for `anju-context-menu-rectangle'."

  (anju-test-context-menu-function-with-filetype
   ".txt"
   #'anju-context-menu-rectangle
   2
   (lambda (items)
     (let ((i 0))
       (anju-test-menu-item (seq-elt items i) "--")
       (let ((kmap (seq-elt (seq-elt items (cl-incf i)) 3)))
             (test--anju-rectangle-menu kmap))))

   (lambda (filename description)
     (insert "hey they\nclittiak\nwhat is goin on?\n")
     (save-buffer)
     (transient-mark-mode)
     (goto-char (point-min))
     (rectangle-mark-mode)
     (goto-char (point-max))
     (activate-mark))))

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
