;;; tts.lisp -- Common Lisp interface to Emacspeak speech servers
;;; $Author: tv.raman.tv $
;;; Description: Interface Common Lisp to Emacspeak TTS servers
;;; Keywords: AsTeR, Emacspeak, Audio Desktop
;;; { Copyright:

;;; Copyright (C) 2011, T. V. Raman<raman@cs.cornell.edu>
;;; All Rights Reserved.
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING. If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; }
;;; { Introduction:

;;; Commentary:
;;; Interface Common Lisp to Emacspeak TTS servers

;;; }
(in-package :tts)
(export '(
          tts-speak  tts-letter tts-stop  tts-force 
          tts-open tts-close))
;;; { Setup:

;;; A TTS structure holds the engine name, process handle, and input/output streams.
(defstruct tts engine process input output )

(defvar *emacspeak* "/usr/share/emacs/site-lisp/emacspeak/"
  "Root of Emacspeak installation.")

(defun tts-dtk-exp ()
  "Return name of dtk-exp server."
  (declare (special *emacspeak*))
  (concatenate 'string *emacspeak* "servers/dtk-exp"))

(defun tts-outloud ()
  "Outloud tcl server"
  (declare (special *emacspeak*))
  (concatenate 'string *emacspeak* "servers/outloud"))

(defun tts-32-outloud ()
  "Return location of 32-outloud server."
  (declare (special *emacspeak*))
  (concatenate 'string *emacspeak* "servers/32-outloud"))

(defvar *tts*
  (make-tts :engine (tts-32-outloud))
  "Handle to tts server connection.")

(proclaim '(inline tts))
(defun tts ()
  "Return handle to TTS server."
  (declare (special *tts*))
  *tts*)

;;; }
;;; {Internal Functions

(defun tts-open ()
  "Open a TTS session."
  (let ((handle (tts)))
    (setf(tts-input handle)
         (ext:make-pipe-output-stream (tts-engine handle) :buffered nil))))

(defun tts-close ()
  "Close a TTS session."
  (let ((handle (tts)))
    (when (tts-input handle)
      (close (tts-input handle)))
    (setf (tts-input handle) nil)))

(defun tts-queue (text)
  "Queue text to speak."
  (let ((i (tts-input (tts))))
    (unless i (setq i (tts-open)))
    (format i "q {~s}~%" text) 
    (finish-output i)))

(defun tts-force ()
  "Speak all queued text."
  (let ((i (tts-input (tts))))
    (format i "d~%" )
    (finish-output i)))

;;; }
;;; {Exported Functions

(defun tts-stop ()
  "Stop speech."
  (let ((i (tts-input (tts))))
    (format i "s~%")
    (finish-output i)))

(defun tts-speak (text)
  "Speak text."
  (unless (tts-input (tts)) (tts-open))
  (let ((i (tts-input (tts))))
    (format i "q {~s}~%" text)
    (format i "d~%")
    (finish-output i)))

(defun tts-speak-list (lines)
  "Speak an arbitrary number of lines."
  (tts-stop)
  (mapc 'tts-queue lines)
  (tts-force))

(defun tts-letter (text)
  "Speak letter."
  (unless (tts-input (tts)) (tts-open))
  (let ((i (tts-input (tts))))
    (format i "l ~s~%" text)
    (finish-output i)))

;;; }
(provide 'tts)

;;; { end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;; }