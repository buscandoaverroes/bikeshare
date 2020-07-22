/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
| File: compress.do															|
| Date: May, 2020																		|
| Author: buscandoaverroes																|
| Description: makes a smaller-sized file to test code; precursor to parallelization  	|
| ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/


							/* - - - - - - - - - - - - - - - - - - - -
										Table of Contents
								1. Load
								2. select construction


							 - - - - - - - - - - - - - - - - - - - - */

	/*
				This code will select one observation from each station id during each year
				to ensure some level of span across the actual data, while keeping the dataset small

																									*/



* settings

* locals



/*		- - - - -
								 ||		1.	Import the 	master file	||
																				- - - - -				*/



	use 			${master}			///
									, clear





/*		- - - - -
								 ||		2.	select data from each year 	||
																				- - - - -				*/

	// generate random variable, sort
	gen double 			rand = runiform()

	sort 				yearstart startstationnumber rand

	// keep by first obs in group of year, number
	by 	yearstart startstationnumber :		keep if _n == 1





	* save
	if (0) {
		save 				${tinymaster} , replace

	}
