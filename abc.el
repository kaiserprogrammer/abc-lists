(defvar abc-dir "~/.abc/")

(defun abc (theme)
  (interactive "sThema: ")
  (find-file (abc-filename theme))
  (insert theme "\n")
  (let ((abc (loop for i from 0 below 26
                   append (list (+ i 65) (string-to-char " ") (string-to-char "\n")))))
    (insert (concat abc)))
  (abc-mode)
  (start-abc-timer 90)
  (abc-mode-line))

(defun abc-mode-line ()
  (let ((pos (position 'mode-line-modes mode-line-format)))
    (setq mode-line-format
          (append (subseq mode-line-format 0 pos)
                  (list (list :eval '(format-time-string "%ss " (time-subtract abc-start-time (current-time)))))
                  (subseq mode-line-format pos)))))

(defvar abc-keywords (list "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"))
(defvar abc-keywords-regexp (regexp-opt abc-keywords 'words))
(defvar abc-font-lock-keywords
  `((,abc-keywords-regexp . font-lock-keyword-face)))

(setq abc-inserting nil)

(define-derived-mode abc-mode fundamental-mode
  "ABC"
  (setq font-lock-defaults '((abc-font-lock-keywords)))
  (defadvice self-insert-command (after positioning (n) activate)
    (when (string= mode-name "ABC")
      (when (not abc-inserting)
        (when (= 1 (length (word-at-point)))
          (let ((start-char (elt (word-at-point) 0)))
            (delete-char -1)
            (goto-abc start-char)))))))

(defun goto-abc (char)
  (goto-char 0)
  (next-line)
  (search-forward-regexp (concat "^" (list (upcase char))))
  (end-of-line)
  (setq abc-inserting t)
  (insert char)
  (setq abc-inserting nil))

(defun abc-filename (theme)
  (concat abc-dir theme (format-time-string "_%Y_%m_%d_%H_%M")))

(defun start-abc-timer (sec)
  (setq abc-start-time (time-add (current-time) (list 0 sec 0)))
  (run-with-timer sec nil (lambda ()
                            (font-lock-mode -1))))

(provide 'abc-mode)
