;;; keymap-tests.el --- Test suite for src/keymap.c -*- lexical-binding: t -*-

;; Copyright (C) 2015-2020 Free Software Foundation, Inc.

;; Author: Juanma Barranquero <lekktu@gmail.com>

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(require 'ert)

(ert-deftest describe-buffer-bindings/header-in-current-buffer ()
  "Header should be inserted into the current buffer.
https://debbugs.gnu.org/39149#31"
  (with-temp-buffer
    (describe-buffer-bindings (current-buffer))
    (should (string-match (rx bol "key" (+ space) "binding" eol)
                          (buffer-string)))))

(ert-deftest describe-buffer-bindings/returns-nil ()
  "Should return nil."
  (with-temp-buffer
    (should (eq (describe-buffer-bindings (current-buffer)) nil))))

(ert-deftest keymap-store_in_keymap-XFASTINT-on-non-characters ()
  "Check for bug fixed in \"Fix assertion violation in define-key\",
commit 86c19714b097aa477d339ed99ffb5136c755a046."
  (let ((def (lookup-key Buffer-menu-mode-map [32])))
    (unwind-protect
        (progn
          (should-not (eq def 'undefined))
          ;; This will cause an assertion violation if the bug is present.
          ;; We could run an inferior Emacs process and check for the return
          ;; status, but in some environments an assertion failure triggers
          ;; an abort dialog that requires user intervention anyway.
          (define-key Buffer-menu-mode-map [(32 . 32)] 'undefined)
          (should (eq (lookup-key Buffer-menu-mode-map [32]) 'undefined)))
      (define-key Buffer-menu-mode-map [32] def))))

(ert-deftest keymap-where-is-internal-test ()
  "Make sure we don't crash when `where-is-preferred-modifier' is not a symbol."
  (should
   (equal (let ((where-is-preferred-modifier "alt"))
            (where-is-internal 'execute-extended-command global-map t))
          [#x8000078])))

(provide 'keymap-tests)

;;; keymap-tests.el ends here
