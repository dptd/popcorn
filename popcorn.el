;;; popcorn.el --- Fetch movie information from TheMovieDB

;; Author: dptd <dptd@protonmail.com>
;; Keywords: movies

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;; Popcorn uses TheMovieDB database to display information about movies.
;; https://www.themoviedb.org/

;;; Code:
(require 'json)

;; Custom Variables
(defgroup popcorn nil
  "Your movies database interface."
  :group 'convenience
  :prefix "popcorn-")

(defcustom popcorn-api-key ""
  "Key used to access TMDB's API."
  :type 'string)

;; Interactive Function
(defun popcorn (title)
  "Displays information about TITLE in a new buffer."
  (interactive "sMovie title: ")
  (if (string= "" title)
      (message "Title cannot be empty.")
    (popcorn-display title)))

;; Implementation
(defun popcorn-display (title)
  "Displays information about TITLE."
  (popcorn-movie-window-org-print popcorn-test-movie))

(cl-defstruct (popcorn-movie (:constructor popcorn-movie-create))
  "Structure for representing single movie."
  poster title rating votes released runtime url budget revenue imdb tagline overview)

;; Prints
(defun popcorn-movie-temporary-window-print (movie)
  "Display results for MOVIE."
  (message (cl-concatenate 'string
			"   Title: " (popcorn-movie-title movie) "\n"
			"  Rating: " (number-to-string (popcorn-movie-rating movie)) " (" (number-to-string (popcorn-movie-votes movie)) " votes)\n"
			"Released: " (popcorn-movie-released movie) "\n"
			" Runtime: " (number-to-string (popcorn-movie-runtime movie)) " minutes\n"
			" Website: " (popcorn-movie-url movie) "\n"
			"  Budget: $" (number-to-string (popcorn-movie-budget movie)) "\n"
			" Revenue: $" (number-to-string (popcorn-movie-revenue movie)) "\n"
			"    IMDB: http://www.imdb.com/title/" (popcorn-movie-imdb movie) "\n"
			" Tagline: " (popcorn-movie-tagline movie) "\n"
			"Overview: " (popcorn-movie-overview movie) "\n")))

(defun popcorn-movie-window-print (movie)
  "Display results for MOVIE."
  (switch-to-buffer-other-window "popcorn")
  (insert (cl-concatenate 'string
		       "   Title: " (popcorn-movie-title movie) "\n"
		       "  Rating: " (number-to-string (popcorn-movie-rating movie)) " (" (number-to-string (popcorn-movie-votes movie)) " votes)\n"
		       "Released: " (popcorn-movie-released movie) "\n"
		       " Runtime: " (number-to-string (popcorn-movie-runtime movie)) " minutes\n"
		       " Website: " (popcorn-movie-url movie) "\n"
		       "  Budget: $" (number-to-string (popcorn-movie-budget movie)) "\n"
		       " Revenue: $" (number-to-string (popcorn-movie-revenue movie)) "\n"
		       "    IMDB: http://www.imdb.com/title/" (popcorn-movie-imdb movie) "\n"
		       " Tagline: " (popcorn-movie-tagline movie) "\n"
		       "Overview: " (popcorn-movie-overview movie) "\n"))
  (read-only-mode)
  (goto-char (point-min))
  (toggle-truncate-lines -1))

(defun popcorn-movie-window-org-print (movie)
  "Display results for MOVIE in org-mode."
  (switch-to-buffer-other-window "popcorn")
  (org-mode)
  (popcorn-kbd)
  (insert (concatenate 'string
		       "   *Title:* " (popcorn-movie-title movie) "\n"
		       "  *Rating:* " (number-to-string (popcorn-movie-rating movie)) " (" (number-to-string (popcorn-movie-votes movie)) " votes)\n"
		       "*Released:* " (popcorn-movie-released movie) "\n"
		       " *Runtime:* " (number-to-string (popcorn-movie-runtime movie)) " minutes\n"
		       " *Website:* " (popcorn-movie-url movie) "\n"
		       "  *Budget:* $" (number-to-string (popcorn-movie-budget movie)) "\n"
		       " *Revenue:* $" (number-to-string (popcorn-movie-revenue movie)) "\n"
		       "    *IMDB:* http://www.imdb.com/title/" (popcorn-movie-imdb movie) "\n"
		       " *Tagline:* \"/" (popcorn-movie-tagline movie) "/\"\n"
		       "*Overview:* =" (popcorn-movie-overview movie) "="))
  (read-only-mode)
  (goto-char (point-min))
  (toggle-truncate-lines -1))

;; Popcorn key-bindings (result buffer)
(defun popcorn-open-imdb ()
  (interactive)
  (open-url "IMDB"))

(defun popcorn-open-website ()
  (interactive)
  (open-url "Website"))

(defun popcorn-open-url (txt)
  (let ((current-position (point)))
    (search-forward txt)
    (forward-word)
    (org-open-at-point)
    (goto-char current-position)))

(defun popcorn-close-buffer ()
  (interactive)
  (delete-window)
  (kill-buffer "popcorn"))

(defun popcorn-kbd ()
  (local-set-key (kbd "q") 'close-buffer)
  (local-set-key (kbd "n") 'next-line)
  (local-set-key (kbd "p") 'previous-line)
  (local-set-key (kbd "i") 'open-imdb)
  (local-set-key (kbd "w") 'open-website))

;; Testing
(defvar popcorn-test-movie
  (popcorn-movie-create :poster nil
			:title "TestTitle"
			:rating 8
			:votes 42
			:released "2019.10.30"
			:runtime 120
			:url "http://www.duckduckgo.com"
			:budget 100
			:revenue 50
			:imdb "tt0078748"
			:tagline nil
			:overview "Test overview."))

(provide 'popcorn)
;;; popcorn.el ends here
