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
(require 'dictionary)
(require 'elisp-mode)
(require 'hideshow)
(require 'edebug)
(require 'yank-media)
(require 'anju-utils)
(require 'anju-style-text)
(require 'casual-dired)
(require 'casual-org)
(require 'casual-ediff)


;; -------------------------------------------------------------------
;; Context Menu: Dired

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

(defun anju-context-menu-dired (menu click)
  "Context menu hook function for Dired commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'dired-mode)
    (mouse-set-point click)
    (save-excursion
      (when (dired-file-name-at-point)
        (easy-menu-add-item menu nil
                            [dired-do-rename
                             dired-do-rename
                             :label "Rename to…"
                             :help "Rename or move file"])

        (easy-menu-add-item menu nil
                            [dired-do-copy
                             dired-do-copy
                             :label "Copy to…"
                             :help "Copy file"])

        (easy-menu-add-item menu nil
                            [dired-do-relsymlink
                             dired-do-relsymlink
                             :label "Symlink…"
                             :help "Make relative symlink"])

        (easy-menu-add-item menu nil
                            [dired-copy-filename-as-kill
                             dired-copy-filename-as-kill
                             :label "Copy name"
                             :help "Copy names of marked (or next ARG) files \
into the kill ring"])

        (easy-menu-add-item menu nil
                            [image-dired-dired-toggle-marked-thumbs
                             image-dired-dired-toggle-marked-thumbs
                             :label "Toggle Thumbnail"
                             :visible (string-match-p (image-file-name-regexp)
                                                      (dired-get-filename))
                             :help "Toggle thumbnails in front of marked \
file names in the Dired buffer"])

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
                            [dired-maybe-insert-subdir
                             dired-maybe-insert-subdir
                             :label "Insert Subdir"
                             :label (format "Insert “%s” View"
                                            (anju-filename-from-path (dired-get-filename)))
                             :visible (file-directory-p
                                       (dired-file-name-at-point))
                             :help "Insert subdir (sub-directory)"])
        (anju-context-menu-item-separator menu trash-separator)

        (easy-menu-add-item menu nil
                            [dired-do-delete
                             dired-do-delete
                             :label "Move to Trash…"
                             :visible (file-writable-p
                                       (dired-file-name-at-point))
                             :help "Delete all marked files"])

        (anju-context-menu-item-separator menu dired-separator))

      ;; (mouse-set-point click)

      (when (not (dired-file-name-at-point))
        (easy-menu-add-item menu nil
                            [dired-hide-subdir
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
                            [dired-kill-subdir
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
                             :help "Kill subdir (sub-directory)"]))

      (easy-menu-add-item menu nil casual-dired-sort-menu)

      (easy-menu-add-item menu nil
                          [dired-omit-mode
                           dired-omit-mode
                           :label "Omit Mode"
                           :style toggle
                           :selected dired-omit-mode
                           :help "Omit mode"])

      (easy-menu-add-item menu nil
                          [dired-hide-details-mode
                           dired-hide-details-mode
                           :label "Hide Details"
                           :style toggle
                           :selected dired-hide-details-mode
                           :help "Hide directory details"])

      (easy-menu-add-item menu nil
                          [dired dired
                           :label "📁 Dired…"
                           :help "Open Dired"])))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Scratch Buffer

(defun anju-context-menu-scratch (menu click)
  "Context menu hook function for journal commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (not (anju-at-org-table-p))
             (not (use-region-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu journal-separator)
      (easy-menu-add-item menu nil [scratch-buffer
                                    scratch-buffer
                                    :label "Scratch"
                                    :help "Switch to the *scratch* buffer"])))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Org Mode

(defun anju-at-org-table-p ()
  "Predicate if point is in an Org table."
  (or (org-at-table-p) (org-at-TBLFM-p)))

(defun anju-org-stored-links-p ()
  "Predicate if `org-stored-links' is populated.
Return t if populated, nil otherwise."
  (if (> (length org-stored-links) 0)
      t
    nil))

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

(defun anju-org-table-recalculate ()
  "Recalculate an Org table."
  (interactive)
  (org-table-recalculate 4))

(defun anju-context-menu-org-mode (menu click)
  "Context menu hook function for Org mode commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'org-mode)
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu org-separator)
      (when (org-at-heading-p)

        (easy-menu-add-item menu nil
                            [org-clock-in
                             org-clock-in
                             :label "Clock In"
                             :visible (not (org-clocking-p))
                             :help "Clock in"])

        (easy-menu-add-item menu nil
                            [org-clock-out
                             org-clock-out
                             :label "Clock Out"
                             :visible (org-clocking-p)
                             :help "Clock out"])

        (easy-menu-add-item menu nil
                            [org-do-demote
                             org-do-demote
                             :label "Demote →"
                             :help "Demote"])

        (easy-menu-add-item menu nil
                            [org-do-promote
                             org-do-promote
                             :label "Promote ←"
                             :help "Promote"])

        (easy-menu-add-item menu nil
                            [org-demote-subtree
                             org-demote-subtree
                             :label "Demote Subtree →"
                             :help "Demote heading subtree"])

        (easy-menu-add-item menu nil
                            [org-promote-subtree
                             org-promote-subtree
                             :label "Promote Subtree ←"
                             :help "Promote heading subtree"]))

      (when (org-at-item-p)
        (easy-menu-add-item menu nil
                            [org-indent-item
                             org-indent-item
                             :label "Demote →"
                             :help "Demote"])

        (easy-menu-add-item menu nil
                            [org-outdent-item
                             org-outdent-item
                             :label "Promote ←"
                             :help "Promote"])

        (easy-menu-add-item menu nil
                            [org-indent-item-tree
                             org-indent-item-tree
                             :label "Demote Subtree →"
                             :help "Demote item subtree"])

        (easy-menu-add-item menu nil
                            [org-outdent-item-tree
                             org-outdent-item-tree
                             :label "Promote Subtree ←"
                             :help "Promote item subtree"])

        (if (org-at-item-checkbox-p)
            (easy-menu-add-item menu nil
                                [casual-org-checkbox-in-progress
                                 casual-org-checkbox-in-progress
                                 :label "In-Progress"
                                 :help "Change checkbox state to in-progress [-]"]))

        (easy-menu-add-item menu nil
                            [casual-org-toggle-list-to-checkbox
                             casual-org-toggle-list-to-checkbox
                             :label (if (org-at-item-checkbox-p)
                                        "To Item"
                                      "To Checkbox")
                             :help "Toggle Item/Checkbox"]))

      (when (anju-at-org-table-p)
        (easy-menu-add-item menu nil
                            [casual-org-table-copy-reference-dwim
                             casual-org-table-copy-reference-dwim
                             :label (casual-org-table--reference-dwim)
                             :help "Copy Org table reference (field or range) into kill ring via mouse"])

        (easy-menu-add-item menu nil anju-org-table-region-menu)

        (easy-menu-add-item menu nil
                            [org-table-toggle-coordinate-overlays
                             org-table-toggle-coordinate-overlays
                             :label "Show Coordinates"
                             :style toggle
                             :selected org-table-coordinate-overlays
                             :help "Toggle the display of row/column numbers in tables"])

        (easy-menu-add-item menu nil
                            [anju-org-table-recalculate
                             anju-org-table-recalculate
                             :label "Recalculate"
                             :help "Recalculate table"])

        (easy-menu-add-item menu nil
                            [org-table-edit-formulas
                             org-table-edit-formulas
                             :label "Edit Table Formulas"
                             :help "Edit the formulas of the current table in a separate buffer"])

        ;; (easy-menu-add-item menu nil cc/insert-org-plot-menu)
        (easy-menu-add-item menu nil [org-plot/gnuplot
                                      org-plot/gnuplot
                                      :label "Run gnuplot"
                                      :help "Plot table using gnuplot"]))))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Emacs Lisp Mode


(defun anju-form-name-at-point ()
  "Name of form at point."
  (save-excursion
    (beginning-of-defun)
    (let* ((fn (list-at-point))
           (form-name (seq-elt fn 1)))
      (if (symbolp form-name)
          form-name))))

(defun anju-form-delaration-at-point ()
  "Declaration of form at point as string."
  (save-excursion
    (beginning-of-defun)
    (let* ((fn (list-at-point))
           (form-declaration (seq-elt fn 0)))
      (if (symbolp form-declaration)
          form-declaration))))


(defun anju-point-in-ertdeftest-p ()
  "Predicate if point is in an ERT test."
  (string-equal "ert-deftest" (anju-form-delaration-at-point)))

(defun anju-ert-run-test-at-point ()
  "Run the ERT test at point."
  (interactive)
  (let ((test-name (anju-form-name-at-point)))
        ;; (message "ERT: %s" test-name)
        (ert test-name)))


(defun anju-edebug-mode-p ()
  "Predicate if `edebug-mode' is on."
  (if edebug-mode t nil))

(defun anju-edebug-defun ()
  "Convenience function to instrument function for Edebug."
  (interactive)
  (setq current-prefix-arg '(4))
  (call-interactively #'eval-defun))

(easy-menu-define anju-edebug-mode-menu nil
  "Keymap for Edebug mode menu."
  '("Mode"
    ["Step" edebug-step-mode
     :help "Stop at the next stop point encountered"]

    ["Go to ●" edebug-go-mode
     :help "Run until the next breakpoint"]

    ["Continue" edebug-continue-mode
     :help "Pause one second at each breakpoint, and then continue"]

    ["Next" edebug-next-mode
     :help "Stop at the next stop point encountered after an expression"]

    ["Trace" edebug-trace-mode
     :help "Pause (normally one second) at each Edebug stop point"]))


(easy-menu-define anju-edebug-breakpoint-menu nil
  "Keymap for Edebug breakpoint menu."
  '("Breakpoint"

    ["Set Breakpoint ●" edebug-set-breakpoint
     :help "Set breakpoint"]

    ["Set Conditional ⦿" edebug-set-conditional-breakpoint
     :help "Set conditional breakpoint"]

    ["Next ●" edebug-next-breakpoint
     :help "Next breakpoint"]

    ["Unset ●" edebug-unset-breakpoint
     :help "Unset breakpoint"]

    ["Unset all ●" edebug-unset-breakpoints
     :help "Unset all breakpoints"]))


(easy-menu-define anju-edebug-sexp-menu nil
  "Keymap for Edebug breakpoint menu."
  '("Sexp"

    ["Forward" edebug-forward-sexp
     :help "Forward sexp"]

    ["Step-in" edebug-step-in
     :help "Step in sexp"]

    ["Step-out" edebug-step-out
     :help "Step out sexp"]))


(easy-menu-define anju-hideshow-menu nil
  "Keymap for hideshow menu."
  '("Hide/Show"
    :visible hs-minor-mode

    [hs-toggle-hiding
     hs-toggle-hiding
     :label (if (hs-already-hidden-p) "Show Block" "Hide Block")
     :help "Toggle hiding"]

    ["Hide All" hs-hide-all
     :enable (not (hs-already-hidden-p))
     :help "Hide all"]

    ["Show All" hs-show-all
     :help "Show all"]))

(defun anju-context-menu-elisp (menu click)
  "Context menu hook function for Elisp commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (derived-mode-p 'emacs-lisp-mode)
             (not (derived-mode-p 'edebug-eval-mode)))

    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu emacs-lisp-separator)

      (if (anju-edebug-mode-p)
          (progn
            (easy-menu-add-item menu nil
                                ["Step" edebug-step-mode
                                 :help "Step"])

            (easy-menu-add-item menu nil
                                ["Here" edebug-goto-here
                                 :help "Here"])

            (easy-menu-add-item menu nil
                                anju-edebug-mode-menu)


            (easy-menu-add-item menu nil
                                anju-edebug-sexp-menu)

            (easy-menu-add-item menu nil
                                anju-edebug-breakpoint-menu)

            (easy-menu-add-item menu nil
                                ["Eval…" edebug-eval-expression
                                 :help "Eval expression"])

            (easy-menu-add-item menu nil
                                ["Previous" edebug-previous-result
                                 :help "Previous result"])

            (easy-menu-add-item menu nil
                                ["Suspend Edebug" edebug-view-outside
                                 :help "Suspend Edebug, run edebug-where to resume"])

            (easy-menu-add-item menu nil
                                ["Watchlist" edebug-visit-eval-list
                                 :help "Open watchlist"])

            (easy-menu-add-item menu nil
                                ["Stop execution" edebug-stop
                                 :help "Stop Edebug execution, useful for exiting from trace or continue loop"])

            (easy-menu-add-item menu nil
                                ["Exit" edebug-top-level-nonstop
                                 :help "Quit Edebug Nonstop"]))

        (easy-menu-add-item
         menu nil
         [eval-last-sexp
          eval-last-sexp
          :label "Eval Last Sexp"
          :help "Evaluate sexp before point; print value in the echo area"])

        (easy-menu-add-item
         menu nil
         [eval-defun
          eval-defun
          :label (format "Eval “%s”" (anju-form-name-at-point))
          :visible (anju-form-name-at-point)
          :help "Evaluate the top level form point is in"])

        (easy-menu-add-item
         menu nil
         [anju-edebug-defun
          anju-edebug-defun
          :label (format "Edebug “%s”" (anju-form-name-at-point))
          :visible (anju-form-name-at-point)
          :help "Evaluate the top level form point is in, stepping through with Edebug"])

        (easy-menu-add-item
         menu nil
         [elisp-eval-region-or-buffer
          elisp-eval-region-or-buffer
          :label (if (use-region-p) "Eval Region" "Eval Buffer")
          :help "Evaluate region or buffer"])

        (easy-menu-add-item
         menu nil
         anju-hideshow-menu)

        (easy-menu-add-item
         menu nil
         [xref-find-references-and-replace
          xref-find-references-and-replace
          :label (format "Rename “%s”" (thing-at-point 'symbol))
          :visible (let ((thing (thing-at-point 'symbol)))
                     (and thing
                          (not (string-match-p "^[-+]?[[:digit:]]*\\.?[[:digit:]]+$" thing))
                          (not (member (substring-no-properties thing) '("lambda" "nil")))))
          :help "Rename xref symbol"])

        (easy-menu-add-item
         menu nil
         [anju-ert-run-test-at-point
          anju-ert-run-test-at-point
          :label (format "Test “%s”" (anju-form-name-at-point))
          :visible (anju-point-in-ertdeftest-p)
          :help "ERT"])

        (easy-menu-add-item
         menu nil
         [anju-extract-lambda-to-defun
          anju-extract-lambda-to-defun
          :label "Extract 𝜆…"
          :visible (anju-point-on-lambda-p)
          :help "Convert lambda expression into a function"])

        (easy-menu-add-item
         menu nil
         [eval-expression
          eval-expression
          :label "Eval Expression…"
          :help "Evaluate expression and print result in mini-buffer"]))))
  menu)


(defun anju-context-menu-edebug-eval (menu click)
  "Context menu hook function for Edebug eval mode.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (derived-mode-p 'edebug-eval-mode)

    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu edebug-eval-separator)

      (easy-menu-add-item
       menu nil
       [edebug-update-eval-list
        edebug-update-eval-list
        :label "Add symbol"
        :help "In the watchlist, type in symbol or sexp to add"])

      (easy-menu-add-item
       menu nil
       [edebug-delete-eval-item
        edebug-delete-eval-item
        :label "Delete symbol"
        :help "Place point on symbol or sexp to delete"])

      (easy-menu-add-item
       menu nil
       [edebug-eval-last-sexp
        edebug-eval-last-sexp
        :label "Eval last sexp"
        :help "Eval last sexp"])

      (easy-menu-add-item
       menu nil
       [edebug-eval-print-last-sexp
        edebug-eval-print-last-sexp
        :label "Insert last sexp"
        :help "Insert (print) eval of last sexp into watchlist"])

      (easy-menu-add-item
       menu nil
       [edebug-where
        edebug-where
        :label "Resume"
        :help "Resume code stepping"])))
menu)

(defun anju-point-on-lambda-p ()
  "Predicate if point is on a lambda symbol."
  (let* ((thing (thing-at-point 'symbol))
         (thing (if thing (substring-no-properties thing) nil)))
    (and thing (string-equal "lambda" thing))))

(defun anju-extract-lambda-to-defun (arg)
  "Extract lambda expression at point to defun named ARG.

When the point is on a lambda symbol, this command will prompt for a
function name ARG and will convert the lambda expression into a defun.
The new defun is not evaluated.

This converted function is put into a temporary buffer ‘*ARG*’ for
subsequent editing while the original lambda expression is replaced with
a reference to the new defun ARG."

  (interactive "sExtract lambda as: ")

  (if (anju-point-on-lambda-p)
      (progn
        (save-excursion
          (let* ((lfn (list-at-point))
                 (lfn-body (seq-subseq lfn 1))
                 (newfn ())
                 (newfn (push (intern arg) newfn))
                 (newfn (push 'defun newfn))
                 (newfn (append newfn lfn-body))
                 (lexp (prin1-to-string newfn))
                 (bufname (format "*%s*" arg))
                 (buf (get-buffer-create bufname)))

            (with-current-buffer (current-buffer)
              (switch-to-buffer-other-window buf)
              (emacs-lisp-mode)
              (insert lexp)
              (goto-char (point-min)))))

        (let ((delete-pair-blink-delay 0))
          (backward-up-list)
          (kill-sexp)
          (insert (format "#'%s" arg))
          (backward-sexp)))
    (message "not on lambda")))


;; -------------------------------------------------------------------
;; Context Menu: Buffer Navigation/Management

(defun anju-context-menu-buffers (menu click)
  "Context menu hook function for buffers commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (not (use-region-p))
             (not (anju-at-org-table-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu buffer-navigation-separator)
      (easy-menu-add-item menu nil [previous-buffer
                                    previous-buffer
                                    :label "← Buffer"
                                    :help "Go to previous buffer"])

      (easy-menu-add-item menu nil [next-buffer
                                    next-buffer
                                    :label "→ Buffer"
                                    :help "Go to next buffer"])

      (easy-menu-add-item menu nil [ibuffer
                                    ibuffer
                                    :label "≣ List All Buffers"
                                    :help "List all buffers"])))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Narrow/Widen

(defun anju-context-menu-narrow (menu click)
  "Context menu hook function for narrow commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (not (anju-at-org-table-p)) (not (derived-mode-p 'Info-mode)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu narrow-separator)
      (cond ((use-region-p)
             (easy-menu-add-item menu nil
                                 [narrow-to-region narrow-to-region
                                  :label (anju-menu-label "Narrow Region")
                                  :help "Restrict editing in this buffer \
to the current region"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'prog-mode))
             (easy-menu-add-item menu nil
                                 [narrow-to-defun narrow-to-defun
                                  :label "Narrow to defun"
                                  :help "Restrict editing in this buffer \
to the current defun"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'org-mode))
             (easy-menu-add-item menu nil
                                 [org-narrow-to-subtree org-narrow-to-subtree
                                  :label "Narrow to subtree"
                                  :help "Restrict editing in this buffer \
to the current subtree"]))

            ((and (not (buffer-narrowed-p)) (derived-mode-p 'markdown-mode))
             (easy-menu-add-item menu nil
                                 [markdown-narrow-to-subtree
                                  markdown-narrow-to-subtree
                                  :label "Narrow to subtree"
                                  :help "Restrict editing in this buffer \
to the current subtree"])))

      (when (and (buffer-narrowed-p) (not (derived-mode-p 'Info-mode)))
        (easy-menu-add-item menu nil
                            [widen widen
                             :label "Widen buffer"
                             :help "Remove narrowing restrictions \
from current buffer"]))))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Open in…

(defun anju-context-menu-open-in (menu click)
  "Context menu hook function for open-in commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (and (not (use-region-p))
             (not (anju-at-org-table-p))
             (buffer-file-name)
             (not (derived-mode-p 'dired-mode)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu open-in-separator)
      (easy-menu-add-item menu nil
                          [dired-jump-other-window dired-jump-other-window
                           :label "📁 Open in Dired"
                           :help "Open file in Dired"])))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: VC/Magit

(defun anju-context-menu-vc (menu click)
  "Context menu hook function for version control commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (vc-responsible-backend default-directory t)
             (not (use-region-p))
             (not (anju-at-org-table-p)))

    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu vc-separator)

      (when (and (package-installed-p 'magit)
                 (not (derived-mode-p 'magit-status-mode)))
        (require 'magit)
        (if (buffer-file-name)
            (easy-menu-add-item
             menu nil
             [magit-file-dispatch magit-file-dispatch
              :label "Magit Dispatch…"
              :help "Show the status of the current Git repository in a buffer"])
          (easy-menu-add-item
           menu nil
           [magit-status magit-status
            :label "Magit Status"
            :help "Show the status of the current Git repository in a buffer"])))

      (easy-menu-add-item
       menu nil
       [casual-ediff-revision-from-menu casual-ediff-revision-from-menu
        :label "Ediff revision…"
        :visible (and (bound-and-true-p buffer-file-name)
                      (vc-registered (buffer-file-name)))
        :help "Ediff this file with revision"])))
  menu)



;; -------------------------------------------------------------------
;; Context Menu: Region Operations

(defun anju-occur-selected-region ()
  "Occur selected region."
  (interactive)
  (let* ((start (region-beginning))
         (end (region-end))
         (regex (buffer-substring-no-properties start end)))
    (occur regex)))

(defun anju-context-menu-region (menu click)
  "Context menu hook function for region commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (use-region-p)
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu transform-text-separator)
      (easy-menu-add-item menu nil
                          [anju-occur-selected-region anju-occur-selected-region
                           :label (anju-menu-label "Occur")
                           :help "Show all lines in the current buffer \
containing a match for selected word"])

      (if (or (and (derived-mode-p 'org-mode) (not (anju-at-org-table-p)))
              (derived-mode-p 'markdown-mode))
          (easy-menu-add-item menu nil anju-style-menu))

      (easy-menu-add-item menu nil anju-transform-text-menu)

      (if (or (derived-mode-p 'prog-mode) (derived-mode-p 'org-mode))
          (easy-menu-add-item menu nil
                              [comment-dwim comment-dwim
                               :label "Toggle Comment"
                               :visible (not buffer-read-only)
                               :help "Toggle comment on selected region"]))

      (easy-menu-add-item menu nil
                          [write-region write-region
                           :label "Write Region…"
                           :help "Write current region into specified file"])))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Region Extension

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

(defun anju-context-menu-region-extension (menu click)
  "Region menu using MENU and CLICK."

  (when (derived-mode-p 'org-mode)
    (save-excursion
      (mouse-set-point click)
      (easy-menu-add-item menu nil
                          [org-insert-last-stored-link
                           org-insert-last-stored-link
                           :label "Paste Last Org Link"
                           :visible (and (not buffer-read-only) (anju-org-stored-links-p))
                           :help "Insert the last link stored in org-stored-links"]
                          "Clear")

      (easy-menu-add-item menu nil
                          [anju-yank-markdown-as-org
                           anju-yank-markdown-as-org
                           :label "Paste Markdown as Org"
                           :visible (not buffer-read-only)
                           :help "Convert clipboard (latest yank) of Markdown text to Org, then paste"]
                          "Clear")

      (easy-menu-add-item menu nil
                          [yank-media
                           yank-media
                           :label "Paste Media"
                           :visible (and (not buffer-read-only)
                                         (display-graphic-p)
                                         (anju-yank-media-p))
                           :help "Paste (yank) media"]
                          "Clear")))
  menu)



;; -------------------------------------------------------------------
;; Context Menu: Show Markup/Toggle Images

(defun anju-context-menu-markup (menu click)
  "Context menu hook function for markup commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (not (use-region-p))
             (member (derived-mode-p major-mode) '(org-mode markdown-mode)))
    (save-excursion
      (mouse-set-point click)
      (pcase (derived-mode-p major-mode)
        ('org-mode
         (anju-context-menu-item-separator menu org-mode-operations-separator)
         (easy-menu-add-item menu nil
                             [casual-org-toggle-images
                              casual-org-toggle-images
                              :label "Toggle Images"
                              :help "Toggle images"])

         (easy-menu-add-item menu nil
                             [visible-mode
                              visible-mode
                              :label "Show Markup"
                              :style toggle
                              :selected visible-mode
                              :help "Toggle making all invisible text \
temporarily visible (Visible mode)"]))

        ('markdown-mode
         (anju-context-menu-item-separator menu markdown-mode-operations-separator)
         (easy-menu-add-item menu nil
                             [markdown-toggle-markup-hiding
                              markdown-toggle-markup-hiding
                              :label "Hide Markup"
                              :style toggle
                              :selected markdown-hide-markup
                              :help "Toggle the display or hiding of markup"]))
        (m nil))))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Word Count

(defun anju-context-menu-wordcount (menu click)
  "Context menu hook function for wordcount commands.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."
  (when (and (derived-mode-p 'text-mode) (not (anju-at-org-table-p)))
    (save-excursion
      (mouse-set-point click)
      (anju-context-menu-item-separator menu count-words-separator)
      (easy-menu-add-item menu nil [count-words count-words
                                    :label "Count Words"
                                    :help "Count words"])))
  menu)


;; -------------------------------------------------------------------
;; Context Menu: Dictionary

(defun anju-context-menu-dictionary (menu click)
  "Context menu hook function for the dictionary command.

- MENU: menu
- CLICK: event

This function is intended to be hooked into `context-menu-functions'."

  (when (use-region-p)
    (save-excursion
      (mouse-set-point click)
      (easy-menu-add-item
       menu nil
       ["Look Up"
        dictionary-search-word-at-mouse
        :label (format "Look Up “%s”" (substring-no-properties (thing-at-point 'word)))
        :help "Look up selected region in dictionary"])))
  menu)



;; -------------------------------------------------------------------
;; Context Menu: Window Management

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


;; -------------------------------------------------------------------
;; Context Menu: Utility and Setup Functions

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
                     anju-context-menu-elisp
                     anju-context-menu-edebug-eval
                     anju-context-menu-scratch
                     anju-context-menu-buffers
                     anju-context-menu-region
                     anju-context-menu-dictionary
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
                   anju-context-menu-elisp
                   anju-context-menu-edebug-eval
                   anju-context-menu-scratch
                   anju-context-menu-buffers
                   anju-context-menu-narrow
                   anju-context-menu-open-in
                   anju-context-menu-region-extension
                   anju-context-menu-vc
                   anju-context-menu-dictionary
                   anju-context-menu-region
                   anju-context-menu-markup
                   anju-context-menu-wordcount
                   anju-context-menu-window))))

(provide 'anju-context-menu)
;;; anju-context-menu.el ends here
