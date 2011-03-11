;;;; misc.lisp

(in-package :ants-bot)


;;; Functions

(defun distance (x1 y1 x2 y2)
  (let* ((dx (abs (- x1 x2)))
         (dy (abs (- y1 y2)))
         (minx (min dx (- (cols *state*) dx)))
         (miny (min dy (- (rows *state*) dy))))
    (sqrt (+ (* minx minx) (* miny miny)))))


(defun end-of-turn ()
  (format (output *state*) "~&go~%")
  (force-output (output *state*)))


(defun errmsg (&rest args)
  (format *error-output* (with-output-to-string (s)
                           (dolist (a args)
                             (princ a s)))))


(defun logmsg (&rest args)
  (when *verbose*
    (format (log-stream *state*) (apply #'mkstr args))
    (force-output (log-stream *state*))))


(defun move-ant (ant-x ant-y direction)
  (if (not (member direction '(:north :east :south :west)))
      (errmsg "[move-ant] Illegal direction: " direction)
      (format (output *state*) "~&o ~D ~D ~A~%" ant-y ant-x
              (case direction
                (:north "N")
                (:east  "E")
                (:south "S")
                (:west  "W")))))


(defun new-location (src-x src-y direction)
  (if (not (member direction '(:north :east :south :west)))
      (progn (errmsg "[new-location] Illegal direction: " direction)
             (list src-x src-y))
      (let ((dst-x (cond ((equal direction :east)
                          (if (>= (+ src-x 1) (cols *state*))
                              0
                              (+ src-x 1)))
                         ((equal direction :west)
                          (if (<= src-x 0)
                              (- (cols *state*) 1)
                              (- src-x 1)))
                         (t src-x)))
            (dst-y (cond ((equal direction :north)
                          (if (<= src-y 0)
                              (- (rows *state*) 1)
                              (- src-y 1)))
                         ((equal direction :south)
                          (if (>= (+ src-y 1) (rows *state*))
                              0
                              (+ src-y 1)))
                         (t src-y))))
        (list dst-x dst-y))))


(defun turn-time-remaining ()
  (- (+ (turn-start-time *state*) (turn-time *state*))
     (wall-time)))


(defun turn-time-used ()
  (- (wall-time) (turn-start-time *state*)))


(defun water? (x y direction)
  (let ((nl (new-location x y direction)))
    (= 1 (aref (game-map *state*) (elt nl 1) (elt nl 0)))))
