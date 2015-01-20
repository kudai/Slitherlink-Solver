Welcome the the README.txt for Kushagra Udai's implementation of Slitherlink.

==========================================================================================

SlitherLink is a simple puzzle game of which, the rules are described as follows:

The quote below is from SlitherLink's exact description copied from their website:
"The rules are simple. You have to draw lines between the dots to form a single loop 
without crossings or branches. The numbers indicate how many lines surround it."

To accomplish this monumental task, the following will explain how, implementation wise, things 
need to be set up to play this implementation of the game.


Content sections are in this order:
	How to execute this game
	Seeing the game rules
	Making a board
	Selecting a board to play
	Starting a game
	Making a move
	Winning the game

==========================================================================================

How to execute this game:
Extract the zip file which this README.txt is in to any path. Let's call this pathname.

Open GNU C-LISP, enter 
(cd "pathname")
(complile-file "slither.lisp")
(load "slither")

This should execute the game.
	
==========================================================================================
Seeing the game rules:

	Game rules can be found in the README.txt file paired with the Silther implementation.
	
	Game rules are displayed when the game is executed.
	
		Welcome to Slitherlink!
		The goal of the game is to create a single continuous loop around the board with
		out crosssing while also bordering all the numbers with the required number of lines
		as indicated by the number as on the grid.
		The moves can be made using triplets of two numbers and a letter separated by blanks.
		The two numbers indicate the row and column and the letter indicates top (T), 
		bottom (B), left (L) and right (R).
		For example, "1 2 L" points to the 1st row, 2nd column box's left line. If a line
		already exists, entering that position removes that line.
		You can enter "q" as a move to quit the board at any time.
		
==========================================================================================
Making a board:

	Boards are structured as a a list. Each sublist is the rows, in order from top to
	bottom, with their contents being each element (or tile) in the corresponding column 
	of that row. Tiles that have a number should be specified with that number 
	(0, 1, 2, or 3). Tiles that have no number should be specified with the space char.

	Once a board is made, it can be saved as a file and be read by the game which allows the user to input the board filename.

	Example of making a board:
33
  
	This is the default board called testboard.txt (which is part of the zip this game comes with). All boards files must be placed in the same folder as the slitherlink code.	

==========================================================================================
Selecting a board to play:

	Many boards can be made, but only one map can be the game board at a time. 
	To select a game board, start the game, as outlined in How to execture this game, enter y, enter n and then enter the filename of the board.	
	
	Play Slitherlink? (y/n) y
	Load game automatically? (y/n) n	
	<o quotes, i.e. board.txt not "board.txt")testboard.txt

	Starting game!

			1    2
	
		+     +     +

	1    3     3

		+     +     +

	2

    +     +     +

==========================================================================================
Starting the default game:
	
	To start the default game board, start the game, as outlined in How to execture this game, enter y, enter y and you're ready to play.
		
		Play Slitherlink? (y/n) y
		Load game automatically? (y/n) y
		testboard.txtArray of 5 x 5 made.
		
		Starting game!
		
			1    2
		
		+     +     +

	1    3     3

		+     +     +

	2

		+     +     +

Where would you like to add a line or remove a line from?
Moves must be in a triplet with a space as a separator:
	
==========================================================================================	
Making a move:

	After starting a game, you will be prompted to make a move.
	Entering q will allow you to exit the game board.
	
	To enter a move, specify the row number, column number, and the side you would like 
	the lined to be placed (T top, L left, B bottom, R right)
	
		Where would you like to add a line or remove a line from?
		Moves must be in a triplet with a space as a separator: 1 1 R
		1    2

		+     +     +

	1    3   |  3

		+     +     +

	2
	
		+     +     +
		
	Entering 1 2 L would have resulted  in the same move.
==========================================================================================
Winning a game:

	A game is won by completing the board following the Slithelink rules.
	The game should correctly determine if you have completed the board successfully.
	
	A list of all the moves will be printed, when you win the game.
	
	You Win!
	Your moves in order were:
	(1 1 t)
	(1 1 b)
	(1 1 l)
	(1 2 t)
	(1 2 b)
	(1 2 r)
	In 274 seconds.

	Play Slitherlink? (y/n)
	
================================== Thanks for playing! ==================================

- Kushagra Udai.
UFID: 0937-7483
