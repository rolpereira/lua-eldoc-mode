;;; lua-eldoc-mode-test.el --- ert tests for lua-eldoc-mode-test  -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Rolando Pereira

;; Author: Rolando Pereira <finalyugi@sapo.pt>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Some unit code tests for lua-eldoc-mode-test

;;; Code:

(require 'ert)
(require 'lua-eldoc-mode)

(ert-deftest help-after-call ()
  (with-temp-buffer
    (insert "string.format")
    (should (string= (lua-eldoc-mode-help-at-point)
              "string.format (formatstring, ...)"))))

(ert-deftest help-after-call-with-whitespace ()
  (with-temp-buffer
    (insert "string.format ")
    (should (string= (lua-eldoc-mode-help-at-point)
              "string.format (formatstring, ...)"))))

(ert-deftest help-after-call-with-parenthesis ()
  (with-temp-buffer
    (insert "string.format(")
    (should (string= (lua-eldoc-mode-help-at-point)
              "string.format (formatstring, ...)"))))

(ert-deftest help-after-call-with-parenthesis-and-whitespace ()
  (with-temp-buffer
    (insert "string.format( ")
    (should (string= (lua-eldoc-mode-help-at-point)
              "string.format (formatstring, ...)")))
  (with-temp-buffer
    (insert "string.format (")
    (should (string= (lua-eldoc-mode-help-at-point)
              "string.format (formatstring, ...)"))))

(ert-deftest help-after-every-call ()
  (mapc (lambda (function)
          (with-temp-buffer
            (insert function)
            (should-not (null (lua-eldoc-mode-help-at-point)))))
    (mapcar #'car lua-eldoc-mode-standard-functions)))

(ert-deftest help-after-file-call ()
  (with-temp-buffer
    (insert "file:close")
    (should (null (lua-eldoc-mode-help-at-point))))
  (with-temp-buffer
    (insert "foo:close")
    (should (null (lua-eldoc-mode-help-at-point)))))

(ert-deftest point-shouldnt-move-after-help ()
  (with-temp-buffer
    (insert "string.len")
    (let ((old-point (point)))
      (lua-eldoc-mode-help-at-point)
      (should (eq old-point (point))))))

(ert-deftest help-in-string-methods ()
  (with-temp-buffer
    (insert "local foo = 'test'\nfoo:len()")
    (should (string= (lua-eldoc-mode-help-at-point)
              "[string]:len ()")))
  ;; Test with something similar to
  ;;
  ;;     foo:len()
  ;;        :len()
  ;;
  ;; Even though this code is non-sensical, I just want to test if
  ;; lua-eldoc-mode works with a line that contains only a method.  
  (with-temp-buffer
    (insert "local foo = 'test'\nfoo:len()\n:len()")
    (should (string= (lua-eldoc-mode-help-at-point)
              "[string]:len ()"))))

(ert-deftest help-in-first-line-before-lua-code ()
  (with-temp-buffer
    (insert "\nstring.len")
    ;; `point' is currently in front of "len", eldoc should work as
    ;; normal
    (should (string= (lua-eldoc-mode-help-at-point)
              "string.len (s)"))
    (goto-char (point-min))
    ;; Don't throw an error when the first line of the buffer is empty
    ;; and `point' is in that line.
    (should (null (lua-eldoc-mode-help-at-point)))))



(provide 'lua-eldoc-mode-test)
;;; lua-eldoc-mode-test.el ends here
