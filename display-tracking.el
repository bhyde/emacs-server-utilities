; -*- mode: emacs-lisp lexical-binding:t -*-

(defun synch-display ()
  (interactive)
  (setenv "DISPLAY" (frame-parameter nil 'display))
  (when (eq 'shell-mode major-mode)
    (comint-send-string (get-buffer-process (current-buffer))
                        (concat "export DISPLAY=" (getenv "DISPLAY") "\n"))))

(defun with-display-of-current-frame-if-any-1 (lambda)
  (let* ((old-display (getenv "DISPLAY"))
         (new-display (or (frame-parameter nil 'display)
                          old-display)))
    (unwind-protect
        (progn
          (setenv "DISPLAY" new-display)
          (message new-display)
          (funcall lambda))
      (setenv "DISPLAY" old-display))))

(defmacro with-display-of-current-frame-if-any (null-args &rest body)
  (assert (null null-args))
   `(with-display-of-current-frame-if-any-1 '(lambda () ,@body)))

(defadvice start-process (around start-process-around)
  (with-display-of-current-frame-if-any ()
    ad-do-it))

(defadvice call-process (around call-process-around)
  (with-display-of-current-frame-if-any ()
    ad-do-it))

(defadvice call-process-region (around call-process-region-around)
  (with-display-of-current-frame-if-any ()
    ad-do-it))

(defun display-tracking (&optional disable)
  (interactive "P")
  (ad-deactivate 'start-process)
  (ad-deactivate 'call-process)
  (ad-deactivate 'call-process-region)
  (unless disable
    (ad-activate 'start-process)
    (ad-activate 'call-process)
    (ad-activate 'call-process-region)))
