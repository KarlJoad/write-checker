;;; write-checker --- Various academic writing checkers -*- lexical-binding:t; coding:utf-8 -*-

;; Copyright (C) 2026 Raven Hallsby

;; Author: Raven Hallsby <raven@hallsby.com>
;; Maintainer: Raven Hallsby <raven@hallsby>

;; Homepage: https://github.com/KarlJoad/write-checker
;; Keywords: Writing

;; Package-Version: 0.0.1-git
;; Package-Requires: ((emacs "29.4"))
;; TODO: Determine minimum Emacs version

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

(provide 'write-checker)
;;; write-checker.el ends here
