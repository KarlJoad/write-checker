;;; write-checker --- Various academic writing checkers -*- lexical-binding:t; coding:utf-8 -*-

;; Copyright (C) 2026 Raven Hallsby

;; Author: Raven Hallsby <raven@hallsby.com>
;; Maintainer: Raven Hallsby <raven@hallsby>

;; Homepage: https://github.com/KarlJoad/write-checker
;; Keywords: Writing

;; Package-Version: 0.0.1-git
;; Package-Requires: ((emacs "18.0"))
;; TODO: Determine minimum Emacs version
;; occur Probably introduced at or before Emacs version 18.

;; SPDX-License-Identifier: GPL-3.0-or-later

;; write-checker is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; write-checker is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with tla+-mode.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; write-check performs several useful checks on your writings.
;; The major checks performs are weasel words, passive voice, and duplicate
;; words. The exact implementations are influenced by
;; <http://matt.might.net/articles/shell-scripts-for-passive-voice-weasel-words-duplicates/>.
;;
;; write-check also provides a minor-mode that highlights some of these problems
;; inline while you are writing.
;;
;; write-check is fairly language-agnostic, but its author and sources were
;; developed in and for English. Your mileage may vary with other languages.

;;; Code:
(eval-when-compile (require 'rx))

(defgroup write-checker nil
  "Various academic writing supports."
  :tag "write-checker"
  :group 'languages
  :prefix "write-checker-"
  :version "29.1"
  :link '(custom-manual "(write-checker) Top")
  :link '(info-link "(write-checker) Customization")
  :link '(url-link "https://github.com/KarlJoad/write-checker")
  :link '(emacs-commentary-link :tag "Commentary" "write-checker.el")
  :link '(emacs-library-link :tag "Lisp File" "write-checker.el"))


;;;
;;; Weasel words
;;;

(defcustom write-checker-weasel-regexps
  '("many" "various" "very" "fairly" "several" "extremely"
    "exceedingly" "quite" "remarkably" "few" "surprisingly"
    "mostly" "largely" "huge" "tiny" "((are\\|is) a number)"
    "excellent" "interestingly" "significantly"
    "substantially" "clearly" "vast" "relatively" "completely")
  "List of regexps that write-checker should consider \"weasel words\"."
  :group 'write-checker
  :type '(repeat regexp))

;; TODO: Add ability to exclude words and/or lines from the search.
;; Particularly, we want to ignore comment lines

(defcustom write-checker--weasel-tooltip
  "Weasel word: consider removing or replacing"
  "Message to show for weasel words."
  :group 'write-checker
  :type 'string)

(defface write-checker--weasel-face
  '((((supports :underline (:style wave)))
     :underline (:style wave :color "DarkOrange"))
    (((class color) (background light))
     (:inherit font-lock-warning-face :background "moccasin"))
    (((class color) (background dark))
     (:inherit font-lock-warning-face :background "DarkOrange")))
  "Default font face weasel words found by write-checker."
  :group 'write-checker)

(defun write-checker--weasel-font-lock-keywords-regexp ()
  "Generate regexp that matches the defined weasel words.

See `weasel-checker-weasel-regexps' for which regexps will be font-locked."
  (concat "\\b\\(?:"
          (regexp-opt write-checker-weasel-regexps)
          "\\)\\b"))

(defun write-checker--weasel-font-lock-keywords ()
  "Font-lock rules for weasel words."
  `((,(write-checker--weasel-font-lock-keywords-regexp)
     0
     '(face write-checker--weasel-face help-echo ,write-checker--weasel-tooltip)
     prepend)))

;;;###autoload
(defun write-checker-weasel (start end)
  "Check for \"weasel words\" in the region between START and END.

If no region is active, the whole buffer is checked.

The set of weasel words is defined by `write-checker-weasel-regexps'."
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list (point-min) (point-max))))
  ;; FIXME: occur's regexp string matching only does character matching!
  ;; We want to do whole-word matching, i.e. we want the regexp "is" to match
  ;; the whole word "is" and NOT the 'i s' in "this".
  ;; TODO: Perhaps this should use #'compilation-start?
  ;; (compilation-start (string-join commands " ") #'grep-mode)
  ;; TODO: Perhaps we just use the normal searching mechanisms?
  ;; `#'search-forward-regexp'?
  (occur (string-join write-checker-weasel-regexps "\\|")
         list-matching-lines-default-context-lines
         `((,start . ,end))))


;;;
;;; Passive phrasing
;;;

(defcustom write-checker-passive-verb-regexps
  '("am" "are" "were" "being" "is" "been" "was" "be")
  "foo"
  :group 'write-checker
  :type '(repeat regexp))

(defcustom write-checker-passive-adverb-regexps
  '("awoken"
    "been" "born" "beat"
    "become" "begun" "bent"
    "beset" "bet" "bid"
    "bidden" "bound" "bitten"
    "bled" "blown" "broken"
    "bred" "brought" "broadcast"
    "built" "burnt" "burst"
    "bought" "cast" "caught"
    "chosen" "clung" "come"
    "cost" "crept" "cut"
    "dealt" "dug" "dived"
    "done" "drawn" "dreamt"
    "driven" "drunk" "eaten" "fallen"
    "fed" "felt" "fought" "found"
    "fit" "fled" "flung" "flown"
    "forbidden" "forgotten"
    "foregone" "forgiven"
    "forsaken" "frozen"
    "gotten" "given" "gone"
    "ground" "grown" "hung"
    "heard" "hidden" "hit"
    "held" "hurt" "kept" "knelt"
    "knit" "known" "laid" "led"
    "leapt" "learnt" "left"
    "lent" "let" "lain" "lighted"
    "lost" "made" "meant" "met"
    "misspelt" "mistaken" "mown"
    "overcome" "overdone" "overtaken"
    "overthrown" "paid" "pled" "proven"
    "put" "quit" "read" "rid" "ridden"
    "rung" "risen" "run" "sawn" "said"
    "seen" "sought" "sold" "sent"
    "set" "sewn" "shaken" "shaven"
    "shorn" "shed" "shone" "shod"
    "shot" "shown" "shrunk" "shut"
    "sung" "sunk" "sat" "slept"
    "slain" "slid" "slung" "slit"
    "smitten" "sown" "spoken" "sped"
    "spent" "spilt" "spun" "spit"
    "split" "spread" "sprung" "stood"
    "stolen" "stuck" "stung" "stunk"
    "stridden" "struck" "strung"
    "striven" "sworn" "swept"
    "swollen" "swum" "swung" "taken"
    "taught" "torn" "told" "thought"
    "thrived" "thrown" "thrust"
    "trodden" "understood" "upheld"
    "upset" "woken" "worn" "woven"
    "wed" "wept" "wound" "won"
    "withheld" "withstood" "wrung"
    "written")
  "blah"
  :group 'write-checker
  :type '(repeat regexp))

;;;###autoload
(defun write-checker-passive (start end)
  "Check for passive phrasing in the region between START and END.

If no region is active, the whole buffer is checked.

A passive phrase id determined by the sequence of regexps from
`write-checker-passive-verbs-regexps' and
 `write-checker-passive-adverbs-regexps'."
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list (point-min) (point-max))))
  ;; FIXME: occur's regexp string matching only does character matching!
  ;; We want to do whole-word matching, i.e. we want the regexp "is" to match
  ;; the whole word "is" and NOT the 'i s' in "this".
  ;; TODO: Perhaps this should use #'compilation-start?
  ;; (compilation-start (string-join commands " ") #'grep-mode)
  ;; TODO: Perhaps we just use the normal searching mechanisms?
  ;; `#'search-forward-regexp'?
  (occur (concat "\\b\\(?:"
                 (string-join write-checker-passive-verb-regexps "\\|")
                 "\\)\\([[:space:]]\\|\\s<\\|\\s>\\)+\\(?:"
                 (string-join write-checker-passive-adverb-regexps "\\|")
                 "\\)\\b")
         list-matching-lines-default-context-lines
         `((,start . ,end))))

(defcustom write-checker--passive-tooltip
  "Passive word: consider removing or replacing"
  "Message to show for passive words."
  :group 'write-checker
  :type 'string)

(defface write-checker--passive-face
  '((((supports :underline (:style wave)))
     :underline (:style wave :color "Blue"))
    (((class color) (background light))
     (:inherit font-lock-warning-face :background "moccasin"))
    (((class color) (background dark))
     (:inherit font-lock-warning-face :background "DarkOrange")))
  "Default font face passive words found by write-checker."
  :group 'write-checker)

(defun write-checker--passive-font-lock-keywords-regexp ()
  "Generate regexp that matches the defined passive words.

See `passive-checker-passive-regexps' for which regexps will be font-locked."
  (concat "\\b\\(?:"
          (regexp-opt write-checker-passive-verb-regexps)
          "\\([[:space:]]\\|\\s<\\|\\s>\\)+"
          (regexp-opt write-checker-passive-adverb-regexps)
          "\\)\\b"))

(defun write-checker--passive-font-lock-keywords ()
  "Font-lock rules for passive words."
  `((,(write-checker--passive-font-lock-keywords-regexp)
     0
     '(face write-checker--passive-face help-echo ,write-checker--passive-tooltip)
     prepend)))


;;;
;;; Duplicate word checker
;;;

;;;###autoload
(defun write-checker-duplicates (start end)
  "Find duplicate adjacent words in the region between START and END.

If no region is active, the whole buffer is checked."
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (list (point-min) (point-max))))
  (save-excursion
    (goto-char start)
    (let ((last-word ""))
      (while (re-search-forward "\\b\\w+\\b" end t)
        ;; The point is now at the end of the found word which means the loop
        ;; automatically moves forward on the next iteration.
        (let* ((word-start (match-beginning 0))
               (word-end (match-end 0))
               (word-text (buffer-substring word-start word-end)))
          (cond
           ;; FIXME: Finding a punctuation character should reset the last word.
           ;; Using a duplicate word across punctuation is fine.
           ;; ((regexp-match word-text "^\\W+$")
           ;;  (setq last-word ""))
           ;; FIXME: We should skip whitespace.
           ;; ((regexp-match word-text "^\\s*$") 'nil)
           ((string-equal-ignore-case word-text last-word)
            ;; TODO: Actually do something useful with the found duplicate!
            (message (format "%s:%s Duplicate: %s"
                             (buffer-name)
                             (line-number-at-pos)
                             word-text)))
           (t (setq last-word word-text))))))
    (message "Finished looking for duplicates!")))

(defcustom write-checker--duplicates-tooltip
  "Duplicates detected"
  "Message to show for duplicated words."
  :group 'write-checker
  :type 'string)

(defface write-checker--duplicate-face
  '((((supports :underline (:style wave)))
     :underline (:style wave :color "Red"))
    (((class color) (background light))
     (:inherit font-lock-warning-face :background "moccasin"))
    (((class color) (background dark))
     (:inherit font-lock-warning-face :background "DarkOrange")))
  "Default font face duplicate words found by write-checker."
  :group 'write-checker)

(defvar write-checker--duplicate-regexp
  "\\b\\([[:word:]]+\\)\\([[:space:]]\\|\\s<\\|\\s>\\)+\\1\\b"
  "Regular expression for detecting duplicate words.")

(defun write-checker--duplicate-font-lock-keywords-matcher (limit)
  "Case-insensitive regexp duplicate matching for font-locking until LIMIT."
  (let ((case-fold-search 't))
    (re-search-forward write-checker--duplicate-regexp limit t)))

(defun write-checker--duplicate-font-lock-keywords ()
  "Font-lock rules for duplicate words."
  `((write-checker--duplicate-font-lock-keywords-matcher
     0
     '(face write-checker--duplicate-face
       help-echo write-checker--duplicate-tooltip)
     prepend)))


;;;
;;; Minor-mode
;;;
;;; This minor-mode does font-locking for the matches that will be returned by
;;; the functions above.
;;;

(defun write-checker--mode-enable ()
  "Enable the minor mode's things."
  (font-lock-add-keywords
   'nil
   (write-checker--weasel-font-lock-keywords) 't)
  (font-lock-add-keywords
   'nil
   (write-checker--passive-font-lock-keywords) 't)
  (font-lock-add-keywords
   'nil
   (write-checker--duplicate-font-lock-keywords) 't))

(defun write-checker--mode-disable ()
  "Disable the minor mode's things."
  (font-lock-remove-keywords 'nil (write-checker--weasel-font-lock-keywords))
  (font-lock-remove-keywords 'nil (write-checker--passive-font-lock-keywords))
  (font-lock-remove-keywords 'nil (write-checker--duplicate-font-lock-keywords)))

;;;###autoload
(define-minor-mode write-checker-mode
  "Font-lock (colorize) issues with writing in the buffer."
  :init-value 'nil
  :lighter " write-checker"
  :require 'write-checker
  :group 'write-checker
  (if write-checker-mode
      (write-checker--mode-enable)
    (write-checker--mode-disable))
  (font-lock-mode 1))

;;;###autoload
(define-globalized-minor-mode write-checker-global-mode
  write-checker-mode
  write-checker-mode
  :group 'write-checker)

(provide 'write-checker)
;;; write-checker.el ends here
