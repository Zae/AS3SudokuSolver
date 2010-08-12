/**
 * This basic sudokusolver uses a 3 dimensional vector to store the sudoku and
 * the suggestions database.
 * 
 * There are 2 methods currently used by the solver
 * + Remainders
 * 	- Check if there is only 1 suggestion left every cell.
 * + Occurences
 * 	- See how often all values occur in a row, column and block, if there is 1 occurence, find the
 * 	fill the cell with this value.
 * 		
 * @author Ezra Pool <ezra@tsdme.nl>
 * @license GPLv3
 * @version 1.0
 */
package nl.tsdme.sudokusolver 
{
	/**
	 * Sudokusolver class
	 * @author Ezra Pool <ezra@tsdme.nl>
	 */
	public class SudokuSolver
	{
		/**
		 * The variable that holds the entire sudoku and suggestions database
		 * as a single 3 dimensional vector. The last dimension is actually a
		 * plain array, because it holds the value of the cell in the 0 position
		 * and the suggestion database from 1 to 9 as Boolean values.
		 * 
		 * @internal
		 */
		private var _sudoku:Vector.<Vector.<Array>>;
		/**
		 * Constructor for the SudokuSolver class.
		 * @author Ezra Pool <ezra@tsdme.nl>
		 */
		public function SudokuSolver() 
		{
			var i:int;
			var j:int;
			//
			//Initialize the vector in 3 dimensions.
			_sudoku = new Vector.<Vector.<Array>>(9, true);
			for (i = 0; i < 9; i++) {
				_sudoku[i] = new Vector.<Array>(9, true);
				for (j  = 0; j < 9; j++) {
					_sudoku[i][j] = new Array();
				}
			}
		}
		/**
		 * Main function to start the calculations.
		 * Call this after inserting a sudoku by calling parseLongString
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return Boolean If the calculation was successful.
		 */
		public function solve():Boolean {
			var i:int;
			var x:int;
			var y:int;
			//
			InitializeSuggestionsDatabase();
			
			/*
			 * We keep calling the solveCell method while the function keeps
			 * returning true.
			 */
			var solveAnotherCell:Boolean=true;
			while (solveAnotherCell) {
				solveAnotherCell = this.solveCell();
			}
			/*
			 * Find out if there are any zero's in the resulting
			 * sudoku, if there are this means the calculations
			 * got stuck and we failed.
			 */
			for (i = 0; i < 9 * 9; i++) {
				x = i % 9;
				y = i / 9;
				if (_sudoku[y][x][0] == 0) {
					//we were unabled to solve the sudoku :-(
					return false;
				}
			}
			//validate, check if there are no duplicates, etc...
			/*
			 * TODO Write some code that validates the sudoku, to see
			 * if there are no mistakes. If there are no mistakes,
			 * return true.
			 */
			return true;
		}
		/**
		 * Initialize the suggestions database.
		 * 
		 * First we fill the database with ALL suggestions and after
		 * that we find out for every row, column and block which
		 * values have already been found and remove those from
		 * the suggestions database.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @internal
		 */
		private function InitializeSuggestionsDatabase():void {
			var i:int;
			var j:int;
			var k:int;
			var x:int;
			var y:int;
			var z:int;
			var bx:int;
			var by:int;
			
			//First set all possibilities to true
			for (i = 0; i < 9 * 9; i++) {
				x = i % 9;
				y = i / 9;
				for (z = 1; z < 10; z++) {
					_sudoku[y][x][z] = true;
				}
			}
			//first search the rows
			var foundInRow:Vector.<Boolean>;
			for (i = 0; i < 9; i++) {
				foundInRow = new Vector.<Boolean>(10, true);
				//set all to false
				for (j = 1; j < 10; j++) {
					foundInRow[j] = false;
				}
				//find all already found values
				for (j = 0; j < 9; j++) {
					if(_sudoku[i][j][0] > 0){
						foundInRow[_sudoku[i][j][0]] = true;
					}
				}
				//update the suggestions
				for (j = 0; j < 9; j++) {
					for (k = 1; k < 10; k++) {
						if(_sudoku[i][j][0] > 0 || foundInRow[k]){
							_sudoku[i][j][k] = false;
						}
					}
				}
			}
			//then we search the columns
			var foundInColumn:Vector.<Boolean>;
			for (i = 0; i < 9; i++) {
				foundInColumn = new Vector.<Boolean>(10, true);
				//set all to false;
				for (j = 1; j < 10; j++) {
					foundInColumn[j] = false;
				}
				//find all already found values
				for (j = 0; j < 9; j++) {
					if (_sudoku[j][i][0] > 0) {
						foundInColumn[_sudoku[j][i][0]] = true;
					}
				}
				//update the suggestions
				for (j = 0; j < 9; j++) {
					for (k = 1; k < 10; k++) {
						if (_sudoku[j][i][0] > 0 || foundInColumn[k]) {
							_sudoku[j][i][k] = false;
						}
					}
				}
			}
			
			//then we search the block
			var foundInBlock:Vector.<Boolean>;
			for (i = 0; i < 9; i++) {
				bx = i % 3;
				by = i / 3;
				
				//set all to false;
				foundInBlock = new Vector.<Boolean>(10, true);
				for (j = 1; j < 10; j++){
					foundInBlock[j] = false;
				}
				//find all already found values
				for (j = 0; j < 9; j++) {
					x = (j % 3) + (bx * 3);
					y = (j / 3) + (by * 3);
					if (_sudoku[y][x][0] > 0) {
						foundInBlock[_sudoku[y][x][0]] = true;
					}
				}
				//update the suggestions
				for (j = 0; j < 9; j++) {
					x = (j % 3) + (bx * 3);
					y = (j / 3) + (by * 3);
					for (k = 1; k < 10; k++) {
						if (_sudoku[y][x][0] > 0 || foundInBlock[k]) {
							_sudoku[y][x][k] = false;
						}
					}
				}
				
			}
		}
		/**
		 * This method is called by the solve method everytime the function keeps
		 * returning true, if we return false, it means we can't solve any
		 * more cells.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return Boolean Return if we could successfully solve another cell.
		 * @internal
		 */
		private function solveCell():Boolean {
			/**
			 * Try all the methods for solving a cell, if they all fail,
			 * we are stuck and need to return false.
			 */
			if (findRemainders() || solveRow()  || solveColumn() || solveBlock()) {
				return true;
			}
			return false;
		}
		/**
		 * Main method for solving by checking for occurrences in rows.
		 * 
		 * We check every value for every row, if there is 1 occurrence in
		 * a row, we find the cell and fill the cell with this value.
		 * After this we update the suggestions database and return true.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return Boolean Return true if we solved a cell.
		 * @internal
		 */
		private function solveRow():Boolean {
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			var x:int;
			var y:int;
			var bx:int;
			var by:int;
			var vect:Vector.<Boolean>;
			
			//first we loop over the rows
			for (i = 0; i < 9; i++) {
				//and then the suggestionslist
				for (j = 1; j < 10; j++) {
					vect = new Vector.<Boolean>(9, true);
					//fill the vector with the occurrences.
					for (k = 0; k < 9; k++) {
						vect[k] = _sudoku[i][k][j];
					}
					//if there is only one occurrence
					if (xor(vect)) {
						//loop over all of them to see which cell
						for (k = 0; k < 9; k++) {
							if (vect[k]) {
								//and update it!
								_sudoku[i][k][0] = j;
								//Update the suggestions database
								//set all suggestions to false on this cell
								for (l = 1; l < 10; l++) {
									_sudoku[i][k][l] = false;
								}
								//thee same row and column
								for (l = 0; l < 9; l++) {
									_sudoku[i][l][j] = false;
									_sudoku[l][k][j] = false;
								}
								//then the same block
								bx = k / 3;
								by = i / 3;
								for (l = 0; l < 9; l++) {
									x = (l % 3) + (bx * 3);
									y = (l / 3) + (by * 3);
									_sudoku[y][x][j] = false;
								}
								
								//return true if we solved a cell
								return true;
							}
						}
					}
				}
			}
			
			//return false if we failed to solve any cells this run
			return false;
		}
		/**
		 * Main method for solving by checking for occurrences in columns.
		 * 
		 * We check every value for every column, if there is 1 occurrence in
		 * a column, we find the cell and fill the cell with this value.
		 * After this we update the suggestions database and return true.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return Boolean Return true if we solved a cell.
		 * @internal
		 */
		private function solveColumn():Boolean {
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			var x:int;
			var y:int;
			var bx:int;
			var by:int;
			var vect:Vector.<Boolean>;
			
			//first we loop over the columns
			for (i = 0; i < 9; i++) {
				//and then the suggestionslist
				for (j = 1; j < 10; j++) {
					vect = new Vector.<Boolean>(9, true);
					//fill the vector with the occurrences.
					for (k = 0; k < 9; k++) {
						vect[k] = _sudoku[k][i][j];
					}
					//if there is only one occurrence
					if (xor(vect)) {
						//loop over all of them to see which cell
						for (k = 0; k < 9; k++) {
							if (vect[k]) {
								//and update it!
								_sudoku[k][i][0] = j;
								//Update the suggestions database
								//set all suggestions to false on this cell
								for (l = 1; l < 10; l++) {
									_sudoku[k][i][l] = false;
								}
								//the same row and column
								for (l = 0; l < 9; l++) {
									_sudoku[k][l][j] = false;
									_sudoku[l][i][j] = false;
								}
								//then the same block
								bx = i / 3;
								by = k / 3;
								for (l = 0; l < 9; l++) {
									x = (l % 3) + (bx * 3);
									y = (l / 3) + (by * 3);
									_sudoku[y][x][j] = false;
								}
								
								//return true if we solved a cell
								return true;
							}
						}
					}
				}
			}
			
			//return false if we failed to solve any cells this run
			return false;
		}
		/**
		 * Main method for solving by checking for occurrences in blocks.
		 * 
		 * We check every value for every block, if there is 1 occurrence in
		 * a block, we find the cell and fill the cell with this value.
		 * After this we update the suggestions database and return true.
		 * 
		 * This function uses a lot of modulus calculations to split the
		 * sudoku up in 9 blocks and 9 cells per block.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return Boolean Return true if we solved a cell.
		 * @internal
		 */
		private function solveBlock():Boolean {
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			var x:int;
			var y:int;
			var bx:int;
			var by:int;
			var vect:Vector.<Boolean>;
			
			//First we loop over the blocks
			for (i = 0; i < 9; i++) {
				bx = i % 3;
				by = i / 3;
				//and then the suggestionslist
				for (j = 1; j < 10; j++){
					vect = new Vector.<Boolean>(9, true);
					//fill the vector with the occurrences.
					for (k = 0; k < 9; k++) {
						x = (k % 3) + (bx * 3);
						y = (k / 3) + (by * 3);
						vect[k] = _sudoku[y][x][j];
					}
					//if there is only one occurrence
					if (xor(vect)) {
						//loop over all of them to see which cell
						for (k = 0; k < 9; k++) {
							if (vect[k]) {
								x = (k % 3) + (bx * 3);
								y = (k / 3) + (by * 3);
								//and update it!
								_sudoku[y][x][0] = j;
								//Update the suggestions database
								//set all suggestions to false on this cell
								for (l = 1; l < 9; l++) {
									_sudoku[y][x][l] = false;
								}
								//the same row and column
								for (l = 0; l < 9; l++) {
									_sudoku[y][l][j] = false;
									_sudoku[l][x][j] = false;
								}
								
								//then the same block
								for (l = 0; l < 9; l++) {
									x = (l % 3) + (bx * 3);
									y = (l / 3) + (by * 3);
									_sudoku[y][x][j] = false;
								}
								
								//return true if we solved a cell
								return true;
							}
						}
					}
				}
			}
			return false;
		}
		/**
		 * Main method for solving by checking for suggestions in cells.
		 * 
		 * We check every value for every cell, if there is 1 suggestion in
		 * a cell, we know this is the correct value for this cell.
		 * After this we update the suggestions database and return true.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return Boolean Return true if we solved a cell.
		 * @internal
		 */
		private function findRemainders():Boolean {
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			var x:int;
			var y:int;
			var bx:int;
			var by:int;
			var vect:Vector.<Boolean>;
			
			//Loop over the rows
			for (i = 0; i < 9; i++) {
				//then over the columns
				for (j = 0; j < 9; j++) {
					vect = new Vector.<Boolean>(10, true);
					//fill the vector with the suggestions in this cell.
					for (k = 1; k < 10; k++) {
						vect[k] = _sudoku[i][j][k];
					}
					//if we find only one suggestion
					if (xor(vect)) {
						//we loop over all the suggestions
						for (k = 1; k < 10; k++) {
							if (vect[k]) {
								//and update it!
								_sudoku[i][j][0] = k;
								//Update the suggestions database
								//set all suggestions to false on this cell
								for (l = 1; l < 10; l++) {
									_sudoku[i][j][l] = false;
								}
								//the same row and column
								for (l = 0; l < 9; l++) {
									_sudoku[i][l][k] = false;
									_sudoku[l][j][k] = false;
								}
								//then the same block
								bx = j / 3;
								by = i / 3;
								for (l = 0; l < 9; l++) {
									x = (l % 3) + (bx * 3);
									y = (l / 3) + (by * 3);
									_sudoku[y][x][k] = false;
								}
								//return true if we solved a cell
								return true;
							}
						}
					}
				}
			}
			return false;
		}
		/**
		 * Function to load the sudoku into memory.
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @param	longString String A string that has all the values
		 * for the sudoku, all empty fields should be a zero (0).
		 */
		public function parseLongString(longString:String):void {
			var i:int;
			var x:int;
			var y:int;
			
			/*
			 * Loop over every character in the string and load
			 * them into the 3 dimensional vector.
			 */
			for (i = 0; i < 9 * 9; i++) {
				x = i % 9;
				y = i / 9;
				_sudoku[y][x][0] = int(longString.substr(i, 1));
			}
		}
		/**
		 * Function to get the sudoku from the vector
		 * as a string. All empty field are zero's (0).
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @return String The sudoku as a string, all empty field are zero (0).
		 */
		public function toLongString():String {
			var i:int;
			var j:int;
			//
			var result:String = new String();
			for (i = 0; i < 9; i++) {
				for (j = 0; j < 9; j++) {
					result += _sudoku[i][j][0].toString();
				}
			}
			return result;
		}
		/**
		 * XOR's a vector of Booleans's
		 * 
		 * @author Ezra Pool <ezra@tsdme.nl>
		 * @param	array Vector.<Boolean> Vector of Booleans.
		 * @return Boolean Returns true if only one is true else false
		 * @internal
		 */
		private function xor(array:Vector.<Boolean>):Boolean {
			var i:int;
			var trueCount:int = 0;
			//
			for (i = 0; i < array.length; i++) {
				// If item is true, and trueCount is < 1, increments count
				// Else, xor fails
				if (array[i]) {
					if (trueCount < 1) {
						trueCount++;
					} else {
						return false;
					}
				}
			}
			// Returns true if there was exactly 1 true item
			return trueCount == 1;
		}
	}
}