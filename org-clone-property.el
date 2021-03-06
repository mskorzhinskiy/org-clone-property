;;; org-clone-property.el --- auto-clone org-mode trees -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Mikhail Skorzhisnkii
;;
;; Author: Mikhail Skorzhisnkii <http://github/rasmi>
;; Maintainer: Mikhail Skorzhisnkii <mskorzhinskiy@eml.cc>
;; Created: January 09, 2021
;; Modified: January 09, 2021
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/rasmi/org-clone-property
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  description
;;
;;; Code:

(require 'org)

(defcustom org-clone-trigger-keywords (list "DONE")
  "A list of keywrods triggering insertion of clock entry."
  :group 'org
  :type '(list string))

(defcustom org-clone-trigger-times-property "CLONE_TIMES"
  "Property name that controls how many copies do."
  :group 'org
  :type 'string)

(defcustom org-clone-trigger-shift-property "CLONE_SHIFT"
  "Property name that controls what time shift."
  :group 'org
  :type 'string)

(defun org-clone-property (change-plist)
  "Clone a tree if new todo state is from `org-clone-trigger-keywords'.

This function is meant to be called only as a hook function for
task blocker hook and CHANGE-PLIST contains a description of what
will be done."
  (when (member (plist-get change-plist :to) org-clone-trigger-keywords)
    (let ((times-prop (org-entry-get (point) org-clone-trigger-times-property))
          (shift-prop (org-entry-get (point) org-clone-trigger-shift-property)))
      (when (and times-prop
                 shift-prop)
        (org-entry-delete (point) org-clone-trigger-times-property)
        (org-entry-delete (point) org-clone-trigger-shift-property)
        (org-clone-subtree-with-time-shift (string-to-number times-prop) shift-prop)
        (save-excursion
          (dotimes (_ (string-to-number times-prop))
            (org-forward-heading-same-level nil))
          (org-entry-put (point) org-clone-trigger-times-property times-prop)
          (org-entry-put (point) org-clone-trigger-shift-property shift-prop)))))
  ;; Always return true, as it's not really a blocker.
  t)

;;;###autoload
(defun org-clone-property-load ()
  "Install property hook."
  (add-hook 'org-blocker-hook
            #'org-clone-property))

;;;###autoload
(defun org-clone-property-unload ()
  "Uninstall property hook."
  (remove-hook 'org-blocker-hook
               #'org-clone-property))

(provide 'org-clone-property)
;;; org-clone-property.el ends here
