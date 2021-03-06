(defun slither ()
  (format t "~%~%Welcome to Slitherlink!~%")
  (format t "The goal of the game is to create a single continuous loop around the board without crosssing while also bordering all the numbers with the required number of lines as indicated by the number as on the grid.~%")
  (format t "The moves can be made using triplets of two numbers and a letter separated by blanks.~%")
  (format t "The two numbers indicate the row and column and the letter indicates top (T), bottom (B), left (L) and right (R).~%")
  (format t "For example, \"1 2 L\" points to the 1st row, 2nd column box's left line. If a line already exists, entering that position removes that line.~%")
  (format t "You can enter \"q\" as a move to quit the board at any time.~%~%")
  (loop while (y-or-n-p "Play Slitherlink?")
		do (if (y-or-n-p "Load game automatically?")
			(progn
				(format t "board1.txt")
				(probe-file "board1.txt")
				(play-game (read-board "board1.txt")))
			(progn
				(format t "Please enter a file name.")
				(format t "(No quotes, i.e. board.txt not \"board.txt\")")
				(play-game (read-board (loop-for-valid-file)))))))

(defun read-board (file)
  (with-open-file (stream file)
    (loop for row = (read-line stream nil nil)
       while row
       collecting row into strings
       finally (return (convert-board strings)))))

(defun loop-for-valid-file ()
  (loop for file = (read-line *query-io*)
     until (probe-file file)
     do (format t "Incorrect file name. ~S does not exist.~%Please enter a new filename. " file)
     finally (return file)))

(defun play-game (board)
  (format t "~%~%Starting game!~%~%")
  (let ((moves nil)
	(starting-time (get-universal-time)))
    (loop
       (display board) 
       (loop for move = (input-move) 
	   do (when (string-equal "q" (string-trim " " move))
	       (format t "Exiting from this board.~%")
	       (return-from play-game))
	   do (when (string-equal "solve" (string-trim " " move))
			(format t "Solving...~%")
			(time (solve board))
			(return-from play-game))
	  do (setf move (interpret-input move board))
	  until move
	  finally (progn
		    (push move moves)
		    (place-move move board)))
       (if (check board)
	   (progn
	     (format t "You Win!~%")
	     (print-winning-moves (nreverse moves))
	     (format t " In ~D seconds.~%~%" (- (get-universal-time) starting-time))
	     (return))))))

(defun input-move ()
  (format *query-io* "Where would you like to add a line or remove a line from?~%")
  (format *query-io* "Moves must be in a triplet with a space as a separator: ")
  (read-line *query-io*))

(defun print-winning-moves (moves)
  (format t "Your moves in order were:")
  (loop for move in moves
     :do (format t "~& ~A~&" move)))

(defun display (board)
  (format t "~&")
  (loop for row from 0 to (array-dimension board 0)
     :do (loop for column from 0 to (array-dimension board 1)
	    :do (cond ((= row 0) 
		   (cond ((= 0 column)
			  (format t "   "))
			 ((oddp column)
			  (format t "  "))
			 ((evenp column) 
			  (format t "~3D " (/ column 2)))))
		  ((= column 0) 
		   (cond ((oddp row)
			  (format t "    "))
			 ((evenp row)
			  (format t "~3D " (/ row 2)))))
		  ((and (> row 0) (> column 0)) 
		   (format t "~3A" (aref board (1- row) (1- column))))))
     :do (format t "~2&")))

(defun convert-board (strings)
  (defvar board nil)
  (setf board (make-array-board (list (length strings) (length (car strings)))))
    (loop for row from 0 to (1- (array-dimension board 0))
       :for row-string = nil 
       :when (oddp row) :do (setf row-string (elt strings (/ (1- row) 2)))
       :do (loop for column from 0 to (1- (array-dimension board 1))
	      :do (cond ((vertex-check row column) 
			 (setf (aref board row column) #\+))
			((face-check row column) 
			 (setf (aref board row column)
			       (if (parse-integer (string (elt row-string (/ (1- column) 2))) :junk-allowed t) 
				   (parse-integer (string (elt row-string (/ (1- column) 2))) :junk-allowed t)
				   #\Space))) 
			((line-check row column) 
			 (setf (aref board row column) #\Space)))))
    board)

(defun vertex-check (x y)
  (and (evenp x) (evenp y)))

(defun face-check (x y)
  (and (oddp x) (oddp y)))

(defun line-check (x y)
  (oddp (+ x y)))

(defun make-array-board (dimensions)
  (let* ((row-x (actual-size (car dimensions)))
    (column-y (actual-size (cadr dimensions))))
  (make-array (list row-x column-y) :initial-element #\Space)))

(defun actual-size (num)
  (1+ (* 2 num)))

(defun interpret-input (string board)
	(let ((input-move (split string)))
	(if (= 3 (length input-move))
		(if (and (if (numberp (parse-integer (car input-move) :junk-allowed t))
			(row-check (parse-integer (car input-move)) board)
			nil)
			(if (numberp (parse-integer (cadr input-move) :junk-allowed t))
				(column-check (parse-integer (cadr input-move)) board)
				nil)
			(if (= 1 (length (caddr input-move)))
				(side-check (character (caddr input-move)))
				nil))
			(progn
				(list (parse-integer (car input-move))
				(parse-integer (cadr input-move))
				(character (caddr input-move))))
			nil)
		nil)))

(defun side-check (char)
	(case char
	(#\t t)
	(#\b t)
	(#\l t)
	(#\r t)
	(#\T t)
	(#\B t)
	(#\L t)
	(#\R t)))

(defun row-check (x board)
	(if (and (> x 0)
		(<= x (/ (1- (array-dimension board 0)) 2)))
	t
	nil))

(defun column-check (y board)
	(if (and (> y 0)
	(<= y (/ (1- (array-dimension board 1)) 2)))
	t
	nil))
	
(defun rowp (x board)
	(if (and (>= x 0) (< x (array-dimension board 0)))
	t
	nil))

(defun columnp (y board)
	(if (and (>= y 0) (< y (array-dimension board 1)))
	t
	nil))

(defun place-move (to-place board)
	(let ((placex (1+ (* 2 (1- (car to-place)))))
			(placey (1+ (* 2 (1- (cadr to-place)))))
			(placec (char-downcase (caddr to-place))))
	(cond ((char= #\t placec)
		(if (char= (aref board (1- placex) placey) #\Space)
			(setf (aref board (1- placex) placey) #\-)
			(setf (aref board (1- placex) placey) #\Space)))	
	((char= #\b placec)
		(if (char= (aref board (1+ placex) placey) #\Space)
			(setf (aref board (1+ placex) placey) #\-)
			(setf (aref board (1+ placex) placey) #\Space)))
	((char= #\l placec)
		(if (char= (aref board placex (1- placey)) #\Space)
			(setf (aref board placex (1- placey)) #\|)
			(setf (aref board placex (1- placey)) #\Space)))
	((char= #\r placec)
		(if (char= (aref board placex (1+ placey)) #\Space)
			(setf (aref board placex (1+ placey)) #\|)
			(setf (aref board placex (1+ placey)) #\Space))))))

(defun split (input)
	(loop for char across input
			if(not(equal char #\Space))
			collect (string char)))

(defun check (view)
	(let ((x-limit (array-dimension view 0))
			(y-limit (array-dimension view 1))
			(x 1)
			(y 1)
			(return-val T))	
	(loop
		(loop
			(if (not (check-space view x y) )
				(return-from check nil))
			(incf x 2)
			(when (> x (1- x-limit))
			(progn
				(setf x 1)
				(return))))
		(incf y 2)
		(when (> y (1- y-limit))
			(return)))
	(setf x 0)
	(setf y 0)
	(loop
		(loop
		(if (not (or (= (edge-count board x y) 2) (= (edge-count board x y) 0)))
			(setf return-val nil))
			(incf x 2)
			(when (> x (1- x-limit))
			(progn
				(setf x 0)
				(return))))
		(incf y 2)
		(when (> y (1- y-limit))
			(return)))
	(if(not return-val)
		(return-from check nil))
	(if(not (check-single-loop view))
		(return-from check nil))
	T))

(defun check-space (view x y)
	(let ((goal (aref view x y)))
	(if (numberp goal)
	(progn
		(if (= (edge-count view x y) goal) T nil))
	T)))

(defun edge-count (board x y)
	(let ((edge 0)
			(x-limit (array-dimension board 0))
			(y-limit (array-dimension board 1)))
	(declare (type fixnum x-limit y-limit))
	(if (not (< (1- x) 0))
		(if (is-line board (the fixnum (1- x)) y )
			(incf edge)))
	(if (not (< (1- y) 0))
		(if (is-line board x (the fixnum (1- y)))
			(incf edge)))
	(if (not (> (1+ x) (1- x-limit)))
		(if (is-line board (the fixnum (1+ x)) y)
			(incf edge)))
	(if (not (> (1+ y) (1- y-limit)))
		(if (is-line board x (the fixnum (1+ y)))
			(incf edge)))
	edge))

(defun x-count (board x y)
	(let ((xc 0)
			(x-limit (array-dimension board 0))
			(y-limit (array-dimension board 1)))
	(declare (type fixnum x-limit y-limit))
	(if (not (< (1- x) 0))
		(if (is-x board (the fixnum (1- x)) y )
			(incf xc)))
	(if (not (< (1- y) 0))
		(if (is-x board x (the fixnum (1- y)))
			(incf xc)))
	(if (not (> (1+ x) (1- x-limit)))
		(if (is-x board (the fixnum (1+ x)) y)
			(incf xc)))
	(if (not (> (1+ y) (1- y-limit)))
		(if (is-x board x (the fixnum (1+ y)))
			(incf xc)))
	xc))
	
(defun possible-edge-count(board x y)
	(let ((remains 4)
			(x-limit (array-dimension board 0))
			(y-limit (array-dimension board 1)))
		(if(or (= x 0) (= x (1- x-limit)))
			(setf remains (1- remains)))
		(if(or (= y 0) (= y (1- y-limit)))
			(setf remains (1- remains)))
		remains))

(defun is-line (view x y)
	(let ((char (aref view x y)))
	(declare (type character char))
	(case char
		(#\| t)
		(#\- t)
		(#\Space nil)
		(#\x nil))))

(defun is-x (view x y)
	(let ((char (aref view x y)))
	(declare (type character char))
	(case char
		(#\x t)
		(#\| nil)
		(#\- nil)
		(#\Space nil))))

(defun is-space (view x y)
	(let ((char (aref view x y)))
	(declare (type character char))
	(case char
		(#\x nil)
		(#\| nil)
		(#\- nil)
		(#\Space t))))

(defun check-single-loop(board)
	(let* ((loop-position-list nil)
			(i 0)
			(j 1))
	(loop while (and (not (is-line board i j)) (< i (array-dimension board 0)))
	do (loop while (and (not (is-line board i j)) (< j (array-dimension board 1)))
			do(setq j (+ j 2)))
		(setq j (mod i 2))
		(setq i (+ i 1)))
	(setq loop-position-list (get-loop board loop-position-list i j))
	(setq i 0)
	(setq j 1)
	(loop while (< i (array-dimension board 0))
		do (loop while (< j (array-dimension board 1))
			do (if(is-line board i j)
				(if(not (check-loop loop-position-list (list i j)))
					(return-from check-single-loop nil)))
			(setq j (+ j 2)))
		(setq j (mod i 2))
		(setq i (+ i 1)))
		T))

(defun check-loop(loop-list to-check)
	(loop for line in loop-list
		do (if(and (equal (car line) (car to-check)) (equal (cadr line) (cadr to-check)))
			(return-from check-loop T)))
	nil)

(defun get-loop(board loop-list x y &optional (from-x -1) (from-y -1))
	(let ((x-limit (array-dimension board 0))
			(y-limit (array-dimension board 1)))
		(cond ((check-loop loop-list (list x y))
					(return-from get-loop loop-list))
			(T
				(setq loop-list (append loop-list (list (list x y))))
				(if (and (not (< (1- x) 0)) (not (< (1- y) 0)))
					(if (and (is-line board (1- x) (1- y)) (or (/= (1- x) from-x) (/= (1- y) from-y)))
						(setq loop-list (get-loop board loop-list (1- x) (1- y) x y))))
				(if (and (not (< (1- x) 0)) (< (1+ y) y-limit))
					(if (and (is-line board (1- x) (1+ y)) (or (/= (1- x) from-x) (/= (1+ y) from-y)))
						(setq loop-list (get-loop board loop-list (1- x) (1+ y) x y))))
				(if (and (< (1+ x) x-limit) (not (< (1- y) 0)))
					(if (and (is-line board (1+ x) (1- y)) (or (/= (1+ x) from-x) (/= (1- y) from-y)))
						(setq loop-list (get-loop board loop-list (1+ x) (1- y) x y))))
				(if (and (< (1+ x) x-limit) (< (1+ y) y-limit))
					(if (and (is-line board (1+ x) (1+ y)) (or (/= (1+ x) from-x) (/= (1+ y) from-y)))
						(setq loop-list (get-loop board loop-list (1+ x) (1+ y) x y))))
				(cond ((equal (aref board x y) #\|)
					(if(not (< (- x 2) 0))
						(if (and (is-line board (- x 2) y) (/= (- x 2) from-x))
							(setq loop-list (get-loop board loop-list (- x 2) y x y))))
					(if(< (+ x 2) x-limit)
						(if (and (is-line board (+ 2 x) y) (/= (+ 2 x) from-x))
							(setq loop-list (get-loop board loop-list (+ 2 x) y x y)))))
				((equal (aref board x y) #\-)
					(if(not (< (- y 2) 0))
						(if (and (is-line board x (- y 2)) (/= (- y 2) from-y))
							(setq loop-list (get-loop board loop-list x (- y 2) x y))))
					(if(< (+ y 2) y-limit)
						(if (and (is-line board x (+ 2 y)) (/= (+ 2 y) from-y))
							(setq loop-list (get-loop board loop-list x (+ 2 y) x y))))))
				(return-from get-loop loop-list)))))
				
(defun solve(board)
	(let ((start nil)
		(flag 1)
		(count 0))
		(clean board)
		(corners board)
		(zeros board)
		(zero3 board)
		(defvar dfscount)
		(loop while (> flag 0)
			do(setf flag 0)
			(setf flag (satisfied board))
			(setf flag (+ flag (satisfy board)))
			(incf count))
	(format t "~%The board after ~S iterations of pruning is: ~%" count) 
	(display board)
	(setf start (find-start board))
	(start-dfs board (car start) (cadr start))
	(format t "~%~%The board was solved after ~S iterations of DFS. The solved board is: ~%" dfscount) 
	(cleanX board)
	(display board)
))

(defun clean(board)
	(let ((i 0)
		(j 1))
		(loop while (< i (array-dimension board 0))
			do (loop while (< j (array-dimension board 1))
				do (setf (aref board i j) #\Space)
				(setf j (+ j 2)))
			(setf j (mod i 2))
			(setf i (+ i 1)))))

(defun cleanX(board)
	(let ((i 0)
		(j 1))
		(loop while (< i (array-dimension board 0))
			do (loop while (< j (array-dimension board 1))
				do (if(equal (aref board i j) #\x)
					(setf (aref board i j) #\Space))
				(setf j (+ j 2)))
			(setf j (mod i 2))
			(setf i (+ i 1)))))
			
(defun zeros(board)
	(let ((i 1)
		(j 1)
		(x-limit (array-dimension board 0))
		(y-limit (array-dimension board 1)))
		(loop while (< i x-limit)
			do (loop while (< j y-limit)
				do (if(numberp(aref board i j))
					(progn
						(if(= (aref board i j) 0)
							(progn
								(setf (aref board i (- j 1)) #\x)
								(setf (aref board i (+ j 1)) #\x)
								(setf (aref board (- i 1) j) #\x)
								(setf (aref board (+ i 1) j) #\x)
								(if(= (- i 1) 0)
									(progn 
										(if(>= (- j 2) 0)
											(setf (aref board (1- i) (- j 2)) #\x))
										(if(< (+ j 2) y-limit)
											(setf (aref board (1- i) (+ j 2)) #\x))))
								(if(= (+ i 1) (1- x-limit))
									(progn 
										(if(>= (- j 2) 0)
											(setf (aref board (1+ i) (- j 2)) #\x))
										(if(< (+ j 2) y-limit)
											(setf (aref board (1+ i) (+ j 2)) #\x))))
								(if(= (- j 1) 0)
									(progn 
										(if(>= (- i 2) 0)
											(setf (aref board (- i 2) (1- j)) #\x))
										(if(< (+ i 2) x-limit)
											(setf (aref board (+ i 2) (1- j)) #\x))))
								(if(= (+ j 1) (1- y-limit))
									(progn 
										(if(>= (- i 2) 0)
											(setf (aref board (- i 2) (1+ j)) #\x))
										(if(< (+ i 2) x-limit)
											(setf (aref board (+ i 2) (1+ j)) #\x))))))))
				(setf j (+ j 2)))
			(setf j 1)
			(setf i (+ i 1)))))

(defun corners(board)
	(let ((x-limit (array-dimension board 0))
		(y-limit (array-dimension board 1)))
		(if(numberp (aref board 1 1))
			(progn
				(if(= (aref board 1 1) 0)
					(progn
						(setf (aref board 0 3) #\x)
						(setf (aref board 3 0) #\x)))
				(if(= (aref board 1 1) 1)
					(progn
						(setf (aref board 0 1) #\x)
						(setf (aref board 1 0) #\x)))
				(if(= (aref board 1 1) 2)
					(progn
						(setf (aref board 0 3) #\-)
						(setf (aref board 3 0) #\|)))
				(if(= (aref board 1 1) 3)
					(progn
						(setf (aref board 0 1) #\-)
						(setf (aref board 1 0) #\|)))))
		(if(numberp (aref board 1 (- y-limit 2)))
			(progn
			(if(= (aref board 1 (- y-limit 2)) 0)
				(progn
					(setf (aref board 0 (- y-limit 4)) #\x)
					(setf (aref board 3 (- y-limit 1)) #\x)))
			(if(= (aref board 1 (- y-limit 2)) 1)
				(progn
					(setf (aref board 0 (- y-limit 2)) #\x)
					(setf (aref board 1 (- y-limit 1)) #\x)))
			(if(= (aref board 1 (- y-limit 2)) 2)
				(progn
					(setf (aref board 0 (- y-limit 4)) #\-)
					(setf (aref board 3 (- y-limit 1)) #\|)))
			(if(= (aref board 1 (- y-limit 2)) 3)
				(progn
					(setf (aref board 0 (- y-limit 2)) #\-)
					(setf (aref board 1 (- y-limit 1)) #\|)))))
		(if(numberp (aref board (- x-limit 2) 1))
			(progn		
				(if(= (aref board (- x-limit 2) 1) 0)
					(progn
						(setf (aref board (- x-limit 1) 3) #\x)
						(setf (aref board (- x-limit 4) 0) #\x)))
				(if(= (aref board (- x-limit 2) 1) 1)
					(progn
						(setf (aref board (- x-limit 1) 1) #\x)
						(setf (aref board (- x-limit 2) 0) #\x)))
				(if(= (aref board (- x-limit 2) 1) 2)
					(progn
						(setf (aref board (- x-limit 1) 3) #\-)
						(setf (aref board (- x-limit 4) 0) #\|)))
				(if(= (aref board (- x-limit 2) 1) 3)
					(progn
						(setf (aref board (- x-limit 1) 1) #\-)
						(setf (aref board (- x-limit 2) 0) #\|)))))
		(if(numberp (aref board (- x-limit 2) (- y-limit 2)))
			(progn		
				(if(= (aref board (- x-limit 2) (- y-limit 2)) 0)
					(progn
						(setf (aref board (- x-limit 1) (- y-limit 4)) #\x)
						(setf (aref board (- x-limit 4) (- y-limit 1)) #\x)))
				(if(= (aref board (- x-limit 2) (- y-limit 2)) 1)
					(progn
						(setf (aref board (- x-limit 1) (- y-limit 2)) #\x)
						(setf (aref board (- x-limit 2) (- y-limit 1)) #\x)))
				(if(= (aref board (- x-limit 2) (- y-limit 2)) 2)
					(progn
						(setf (aref board (- x-limit 1) (- y-limit 4)) #\-)
						(setf (aref board (- x-limit 4) (- y-limit 1)) #\|)))
				(if(= (aref board (- x-limit 2) (- y-limit 2)) 3)
					(progn
						(setf (aref board (- x-limit 1) (- y-limit 2)) #\-)
						(setf (aref board (- x-limit 2) (- y-limit 1)) #\|)))))))
						
(defun zero3(board)
	(let ((x 1)
		(y 1)
		(x-zero 0)
		(y-zero 0)
		(x-limit (array-dimension board 0))
		(y-limit (array-dimension board 1))
		(flag 0))
		(loop while (< x x-limit)
			do (loop while (< y y-limit)
				do (if(numberp(aref board x y))
						(progn
							(if(= (aref board x y) 3)
								(progn
									(if(and (not(< (- x 2) 0)) (numberp (aref board (- x 2) y)))
										(if(= (aref board (- x 2) y) 0)
											(setq flag 1)))
									(if(and (< (+ x 2) x-limit) (numberp (aref board (+ x 2) y)))
										(if(= (aref board (+ x 2) y) 0)
											(setq flag 1)))
									(if(and (not(< (- y 2) 0)) (numberp (aref board x (- y 2))))
										(if(= (aref board x (- y 2)) 0)
											(setq flag 1)))
									(if(and (< (+ y 2) x-limit) (numberp (aref board x (+ y 2))))
										(if(= (aref board x (+ y 2)) 0)
											(setq flag 1)))
									(if(and (not(< (- x 2) 0)) (numberp (aref board (- x 2) y)))
										(if(= (aref board (- x 2) y) 3)
											(progn
												(setf (aref board (- x 3) y) #\-)
												(setf (aref board (- x 1) y) #\-)
												(setf (aref board (+ x 1) y) #\-))))
									(if(and (not(< (- y 2) 0)) (numberp (aref board x (- y 2))))
										(if(= (aref board x (- y 2)) 3)
											(progn
												(setf (aref board x (- y 3)) #\|)
												(setf (aref board x (- y 1)) #\|)
												(setf (aref board x (+ y 1)) #\|))))
									(if(and (>= (- x 2) 0) (>= (- y 2) 0) (numberp (aref board (- x 2) (- y 2))) (= (aref board (- x 2) (- y 2)) 0))
										(progn
											(setf flag (+ flag 2))
											(setf x-zero (- x 2))
											(setf y-zero (- y 2))))
									(if(and (>= (- x 2) 0) (< (+ y 2) y-limit) (numberp (aref board (- x 2) (+ y 2))) (= (aref board (- x 2) (+ y 2)) 0))
										(progn
											(setf flag (+ flag 2))
											(setf x-zero (- x 2))
											(setf y-zero (+ y 2))))
									(if(and (< (+ x 2) x-limit) (>= (- y 2) 0) (numberp (aref board (+ x 2) (- y 2))) (= (aref board (+ x 2) (- y 2)) 0))
										(progn
											(setf flag (+ flag 2))
											(setf x-zero (+ x 2))
											(setf y-zero (- y 2))))
									(if(and (< (+ x 2) x-limit) (< (+ y 2) y-limit) (numberp (aref board (+ x 2) (+ y 2))) (= (aref board (+ x 2) (+ y 2)) 0))
										(progn
											(setf flag (+ flag 2))
											(setf x-zero (+ x 2))
											(setf y-zero (+ y 2))))
									(if(and (>= (- x 2) 0) (>= (- y 2) 0) (numberp (aref board (- x 2) (- y 2))) (= (aref board (- x 2) (- y 2)) 3))
										(progn
											(setf (aref board (1+ x) y) #\-)
											(setf (aref board x (1+ y)) #\|)
											(setf (aref board (- x 3) (- y 2)) #\-)
											(setf (aref board (- x 2) (- y 3)) #\|)))
									(if(and (< (+ x 2) x-limit) (>= (- y 2) 0) (numberp (aref board (+ x 2) (- y 2))) (= (aref board (+ x 2) (- y 2)) 3))
										(progn
											(setf (aref board (1- x) y) #\-)
											(setf (aref board x (1+ y)) #\|)
											(setf (aref board (- x 3) (- y 2)) #\-)
											(setf (aref board (- x 2) (- y 3)) #\|)))
									(if(or (= flag 1) (= flag 3))
										(progn
										(if(not(equal (aref board x (- y 1)) #\x))
											(setf (aref board x (- y 1)) #\|))
										(if(not(equal (aref board x (+ y 1)) #\x))
											(setf (aref board x (+ y 1)) #\|))
										(if(not(equal (aref board (- x 1) y) #\x))
											(setf (aref board (- x 1) y) #\-))
										(if(not(equal (aref board (+ x 1) y) #\x))
											(setf (aref board (+ x 1) y) #\-))
										(setf flag (1- flag))))
									(if(> flag 0)
										(progn
										(setf (aref board (/ (+ x x-zero) 2) y) #\-)
										(setf (aref board x (/ (+ y y-zero) 2)) #\|)
										(setf flag (- flag 2))))))))
				(setq y (+ y 2)))
			(setq y 1)
			(setq x (+ x 1)))))

(defun satisfied(board)
	(let ((x 1)
		(y 1)
		(flag 0)
		(xc 0)
		(linec 0)
		(remains 0)
		(x-limit (array-dimension board 0))
		(y-limit (array-dimension board 1)))
		(loop while (< x x-limit)
			do(loop while (< y y-limit)
				do(setf xc (x-count board x y))
				(setf linec (edge-count board x y))
				(setf remains (- 4 xc))
				(setf remains (- remains linec))
					(if(and (numberp (aref board x y)) (check-space board x y) (> remains 0))
						(progn
							(if(not (is-line board (+ x 1) y))
								(progn 
									(incf flag)
									(setf (aref board (+ x 1) y) #\x)))
							(if(not (is-line board (- x 1) y))
								(progn 
									(incf flag)
									(setf (aref board (- x 1) y) #\x)))
							(if(not (is-line board x (+ y 1)))
								(progn 
									(incf flag)
									(setf (aref board x (+ y 1)) #\x)))
							(if(not (is-line board x (- y 1)))
								(progn 
									(incf flag)
									(setf (aref board x (- y 1)) #\x)))))
						(setf y (+ y 2)))
					(setf y 1)
					(setf x (+ x 2)))
		(setf x 0)
		(setf y 0)
		(loop while (< x x-limit)
			do(loop while (< y y-limit)
				do(setf xc (x-count board x y))
				(setf linec (edge-count board x y))
				(setf remains (- (possible-edge-count board x y) xc))
				(setf remains (- remains linec))
					(if(and (= (edge-count board x y) 2) (> remains 0))
						(progn
							(if(and (rowp (+ x 1) board) (not (is-line board (+ x 1) y)))
								(progn 
									(incf flag)
									(setf (aref board (+ x 1) y) #\x)))
							(if(and (rowp (- x 1) board) (not (is-line board (- x 1) y)))
								(progn 
									(incf flag)
									(setf (aref board (- x 1) y) #\x)))
							(if(and (columnp (+ y 1) board) (not (is-line board x (+ y 1))))
								(progn 
									(incf flag)
									(setf (aref board x (+ y 1)) #\x)))
							(if(and (columnp (- y 1) board) (not (is-line board x (- y 1))))
								(progn 
									(incf flag)
									(setf (aref board x (- y 1)) #\x)))))
						(setf y (+ y 2)))
					(setf y 0)
					(setf x (+ x 2)))
	(return-from satisfied flag)))

(defun satisfy(board)
(let ((x 1)
		(y 1)
		(flag 0)
		(x-limit (array-dimension board 0))
		(y-limit (array-dimension board 1))
		(xc 0)
		(linec 0)
		(remains 0))
		(loop while (< x x-limit)
			do(loop while (< y y-limit)
				do(setf xc (x-count board x y))
				(setf linec (edge-count board x y))
				(setf remains (- 4 xc))
				(setf remains (- remains linec))
				(if(numberp (aref board x y))
					(progn
						(if(and (= xc (- 4 (aref board x y))) (> remains 0))
							(progn
								(if(not (is-x board (+ x 1) y))
									(progn 
										(incf flag)
										(setf (aref board (+ x 1) y) #\-)))
								(if(not (is-x board (- x 1) y))
									(progn 
										(incf flag)
										(setf (aref board (- x 1) y) #\-)))
								(if(not (is-x board x (+ y 1)))
									(progn 
										(incf flag)
										(setf (aref board x (+ y 1)) #\|)))
								(if(not (is-x board x (- y 1)))
									(progn 
										(incf flag)
										(setf (aref board x (- y 1)) #\|)))))))
				(if(and(= linec 3) (> remains 0))
					(progn
						(if(not (is-line board (+ x 1) y))
							(progn 
								(incf flag)
								(setf (aref board (+ x 1) y) #\x)))
						(if(not (is-line board (- x 1) y))
							(progn
								(incf flag)
								(setf (aref board (- x 1) y) #\x)))
						(if(not (is-line board x (+ y 1)))
							(progn
								(incf flag)
								(setf (aref board x (+ y 1)) #\x)))
						(if(not (is-line board x (- y 1)))
							(progn 
								(incf flag)
								(setf (aref board x (- y 1)) #\x)))))
				(setf y (+ y 2)))
			(setf y 1)
			(setf x (+ x 2)))
		(setf x 0)
		(setf y 0)
		(loop while (< x x-limit)
			do(loop while (< y y-limit)
				do(setf xc (x-count board x y))
				(setf linec (edge-count board x y))
				(setf remains (- (possible-edge-count board x y) xc))
				(setf remains (- remains linec))
				(if(and(= linec 1) (= remains 1))
						(progn
							(if(and (rowp (+ x 1) board) (is-space board (+ x 1) y))
								(progn 
									(incf flag)
									(setf (aref board (+ x 1) y) #\|)))
							(if(and (rowp (- x 1) board) (is-space board (- x 1) y))
								(progn 
									(incf flag)
									(setf (aref board (- x 1) y) #\|)))
							(if(and (columnp (+ y 1) board) (is-space board x (+ y 1)))
								(progn 
									(incf flag)
									(setf (aref board x (+ y 1)) #\-)))
							(if(and (columnp (- y 1) board) (is-space board x (- y 1)))
								(progn 
									(incf flag)
									(setf (aref board x (- y 1)) #\-)))))
				(if(= (- (possible-edge-count board x y) xc) 1)
						(progn
							(if(and (rowp (+ x 1) board) (is-space board (+ x 1) y))
								(progn 
									(incf flag)
									(setf (aref board (+ x 1) y) #\x)))
							(if(and (rowp (- x 1) board) (is-space board (- x 1) y))
								(progn 
									(incf flag)
									(setf (aref board (- x 1) y) #\x)))
							(if(and (columnp (+ y 1) board) (is-space board x (+ y 1)))
								(progn 
									(incf flag)
									(setf (aref board x (+ y 1)) #\x)))
							(if(and (columnp (- y 1) board) (is-space board x (- y 1)))
								(progn 
									(incf flag)
									(setf (aref board x (- y 1)) #\x)))))
				(setf y (+ y 2)))
			(setf y 0)
			(setf x (+ x 2)))
	(return-from satisfy flag)))
					
(defun find-start(board)
	(let ((x 0)
			(y 0)
			(x-limit (array-dimension board 0))
			(y-limit (array-dimension board 1)))
			(loop while (< x x-limit)
				do(loop while (< y y-limit)
					do(if (= (edge-count board x y) 2)
						(return-from find-start (list x y)))
						(setf y (+ y 2)))
					(setf y 0)
					(setf x (+ x 2)))
			(return-from find-start nil)))

(defun start-dfs(board start-x start-y)
	(defvar dfscount 0)
	(defvar al nil)
	(setf dfscount 0)
	(setf al nil)
	(dfs start-x start-y))

(defun dfs(x y &optional (from-x -1) (from-y -1))
	(let ((flag 0)
			(won nil)
			(looplist nil))
	(setf dfscount (+ dfscount 1))
	(if(and (= (edge-count board x y) 2) (check board))
		(progn
		(setf won t)
		(return-from dfs t)))
	(if(> (edge-count board x y) 2)
		(progn
			(backtrack)
			(return-from dfs nil)))
	(if(equal won t)
		(return-from dfs t))
	(if(and (rowp (1- x) board) (columnp (1- y) board) (numberp (aref board (1- x) (1- y))) (> (edge-count board (1- x) (1- y)) (aref board (1- x) (1- y))))
		(progn
			(backtrack)
			(return-from dfs nil)))
	(if(equal won t)
		(return-from dfs t))
	(if(and (rowp (1+ x) board) (columnp (1- y) board) (numberp (aref board (1+ x) (1- y))) (> (edge-count board (1+ x) (1- y)) (aref board (1+ x) (1- y))))
		(progn
			(backtrack)
			(return-from dfs nil)))
	(if(equal won t)
		(return-from dfs t))
	(if(and (rowp (1- x) board) (columnp (1+ y) board) (numberp (aref board (1- x) (1+ y))) (> (edge-count board (1- x) (1+ y)) (aref board (1- x) (1+ y))))
		(progn
			(backtrack)
			(return-from dfs nil)))
	(if(equal won t)
		(return-from dfs t))
	(if(and (rowp (1+ x) board) (columnp (1+ y) board) (numberp (aref board (1+ x) (1+ y))) (> (edge-count board (1+ x) (1+ y)) (aref board (1+ x) (1+ y))))
		(progn
			(backtrack)
			(return-from dfs nil)))
	(if(equal won t)
		(return-from dfs t))
	(if(and (or (/= (+ x 2) from-x) (/= y from-y)) (rowp (+ x 2) board) (is-line board (+ x 1) y))
		(progn
			(setf flag 1)
			(setf al (append (list nil) al))
			(setf won (dfs (+ x 2) y x y))))
	(if(equal won t)
		(return-from dfs t))
	(if(and (or (/= (- x 2) from-x) (/= y from-y)) (rowp (- x 2) board) (is-line board (- x 1) y))
		(progn
			(setf flag 1)
			(setf al (append (list nil) al))
			(setf won (dfs (- x 2) y x y))))
	(if(equal won t)
		(return-from dfs t))
	(if(and (or (/= x from-x) (/= (+ y 2) from-y)) (columnp (+ y 2) board) (is-line board x (+ y 1)))
		(progn
			(setf flag 1)
			(setf al (append (list nil) al))
			(setf won (dfs x (+ y 2) x y))))
	(if(equal won t)
		(return-from dfs t))
	(if(and (or (/= x from-x) (/= (- y 2) from-y)) (columnp (- y 2) board) (is-line board x (- y 1)))
		(progn
			(setf flag 1)
			(setf al (append (list nil) al))
			(setf won (dfs x (- y 2) x y))))
	(if(equal won t)
		(return-from dfs t))
	(if(= flag 0)
		(progn
			(if(and (or (/= (+ x 2) from-x) (/= y from-y)) (rowp (+ x 2) board) (not (equal #\x (aref board (1+ x) y))))
				(progn
					(setf (aref board (1+ x) y) #\|)
					(setf al (append (list (list (1+ x) y)) al))
					(if(= (edge-count board (+ x 2) y) 2)
						(progn
							(setf looplist (get-loop board looplist (1+ x) y))
							(if(and(check-if-loop looplist) (not(check board)))
								(backtrack)
								(setf won (dfs (+ x 2) y x y)))
							(setf looplist nil))
						(setf won (dfs (+ x 2) y x y)))))
			(if(equal won t)
				(return-from dfs t))
			(if(and (or (/= (- x 2) from-x) (/= y from-y)) (rowp (- x 2) board) (not (equal #\x (aref board (1- x) y))))
				(progn
					(setf (aref board (1- x) y) #\|)
					(setf al (append (list (list (1- x) y)) al))
					(if(= (edge-count board (- x 2) y) 2)
						(progn
							(setf looplist (get-loop board looplist (1- x) y))
							(if(and(check-if-loop looplist) (not(check board)))
								(backtrack)
								(setf won (dfs (- x 2) y x y)))
							(setf looplist nil))
						(setf won (dfs (- x 2) y x y)))))
			(if(equal won t)
				(return-from dfs t))
			(if(and (or (/= x from-x) (/= (+ y 2) from-y)) (columnp (+ y 2) board) (not (equal #\x (aref board x (1+ y)))))
				(progn
					(setf (aref board x (1+ y)) #\-)
					(setf al (append (list (list x (1+ y))) al))
					(if(= (edge-count board x (+ y 2)) 2)
						(progn
							(setf looplist (get-loop board looplist x (1+ y)))
							(if(and(check-if-loop looplist) (not(check board)))
								(backtrack)
								(setf won (dfs x (+ y 2) x y)))
							(setf looplist nil))
						(setf won (dfs x (+ y 2) x y)))))
			(if(equal won t)
				(return-from dfs t))
			(if(and (or (/= x from-x) (/= (- y 2) from-y)) (columnp (- y 2) board) (not (equal #\x (aref board x (1- y)))))
				(progn
					(setf (aref board x (1- y)) #\-)
					(setf al (append (list (list x (1- y))) al))
					(if(= (edge-count board x (- y 2)) 2)
						(progn
							(setf looplist (get-loop board looplist x (1- y)))
							(if(and(check-if-loop looplist) (not(check board)))
								(backtrack)
								(setf won (dfs x (- y 2) x y)))
							(setf looplist nil))
						(setf won (dfs x (- y 2) x y)))))
			(if(equal won t)
				(return-from dfs t))))
	(backtrack)
	(return-from dfs won)))

(defun backtrack()
	(if(not (equal al nil))
		(progn
		(if(not(equal (car al) nil))
		(setf (aref board (car (car al)) (cadr (car al))) #\Space))
		(setf al (cdr al)))))

(defun check-if-loop(looplist)
(let ((len (list-length looplist))
		(x (car (car looplist)))
		(y (cadr (car looplist)))
		(x-limit (array-dimension board 0))
		(y-limit (array-dimension board 1))
		(revlist (reverse looplist))
		(xr nil)
		(yr nil))
		(setf xr (car (car revlist)))
		(setf yr (cadr (car revlist)))
		(if(< len 3)
		(return-from check-if-loop nil))
		(if (and (not (< (1- x) 0)) (not (< (1- y) 0)) (is-line board (1- x) (1- y)))
			(if(and(= (1- x) xr) (= (1- y) xr))
				(return-from check-if-loop t)))
		(if (and (not (< (1- x) 0)) (< (1+ y) y-limit) (is-line board (1- x) (1+ y)))
			(if(and(= (1- x) xr) (= (1+ y) yr))
				(return-from check-if-loop t)))
		(if (and (< (1+ x) x-limit) (not (< (1- y) 0)) (is-line board (1+ x) (1- y)))
				(if(and(= (1+ x) xr) (= (1- y) yr))
				(return-from check-if-loop t)))
		(if (and (< (1+ x) x-limit) (< (1+ y) y-limit) (is-line board (1+ x) (1+ y)))
				(if(and(= (1+ x) xr) (= (1+ y) yr))
				(return-from check-if-loop t)))
		(cond ((equal (aref board x y) #\|)
			(if(and (not (< (- x 2) 0)) (is-line board (- x 2) y))
				(if(and(= (- x 2) xr) (= y yr))
					(return-from check-if-loop t)))
			(if(and (<(+ x 2) x-limit) (is-line board (+ x 2) y))
				(if(and(= (+ x 2) xr) (= y yr))
					(return-from check-if-loop t))))
		((equal (aref board x y) #\-)
			(if(and(not (< (- y 2) 0)) (is-line board x (- y 2)))
				(if(and(= x xr) (= (- y 2) yr))
					(return-from check-if-loop t)))
			(if(and (< (+ y 2) y-limit) (is-line board  x (+ y 2)))
				(if(and(= x xr) (= (+ y 2) yr))
					(return-from check-if-loop t)))))
		(return-from check-if-loop nil)))		

(slither)