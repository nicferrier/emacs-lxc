;;; lxc.el --- lxc integration with Emacs

;; Copyright (C) 2014  Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Keywords: processes
;; Version: 0.0.1
;; Url: https://github.com/nicferrier/emacs-lxc

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

;; Some simple tools for dealing with LXC containers in Emacs.

;;; Code:

(defconst lxc/list-command
  "sudo lxc-ls --fancy-format name,state,pid,ipv4 --fancy"
  "The command we use for listing containers.")

(defun lxc/list ()
  "Make the list of containers using `lxc/list-command.'"
  (let ((cmd lxc/list-command))
    (->> (-drop 2 (split-string (shell-command-to-string cmd) "\n"))
      (-filter (lambda (s) (> (length s) 0)))
      (-map (lambda (s)
              (-filter
               (lambda (s) (> (length s) 0))
               (split-string s " ")))))))

(defun lxc/table-entrys ()
  "Make the table entries for `tabulated-list-mode'."
  (-map (lambda (e)
          (list (car e) (apply 'vector e)))
   (lxc/list)))

(define-derived-mode
    lxc-list-table-mode tabulated-list-mode "LXC containers"
    "Major mode for listing your LXC containers."
    (setq tabulated-list-entries 'lxc/table-entrys)
    ;; This is wrong! it needs to be derived from display-time-world-list
    (setq tabulated-list-format
          (loop for col in (list "name" "state" "pid" "IP")
             vconcat (list (list col 20 nil))))
    (tabulated-list-init-header))

(defun list-lxc ()
  "Show the list of LXC containers you have."
  (interactive)
  (with-current-buffer (get-buffer-create "*lxc-list*")
    (lxc-list-table-mode)
    (tabulated-list-print)
    (switch-to-buffer (current-buffer))))

(provide 'lxc)
;;; lxc.el ends here
