/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
| File: append.do																		|
| Date: May, 2020																		|
| Author: buscandoaverroes																|
| Description: appends all the constructed datasets				 		 				|
| ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/


						/* - - - - - - - - - - - - - - - - - - - -
									Table of Contents
							1. load first dataset
							2. append loop


						 - - - - - - - - - - - - - - - - - - - - */

						 /* Note that this will eventually be converted into a loop. */
	* settings
	local 	source 				= 0

	* macros
	local 	order				id member ///
								yearstart monthstart daystart hourstart minstart ///
								min hour ///
								startstationnumber endstationnumber ///
								startstation endstation ///
								yearend monthend dayend hourend minend
/*
	global 	first			`"d2010"'							// the first file loaded in 1.
	global 	rest 			: list datasets - first 		// the rest of the datasets
*/
	macro list

/*		- - - - -
						 ||		1.	Import first .dta file	||
						 												- - - - -				*/


		use		"${mastData}/${d2010}.dta" , clear
		preserve



/*		- - - - -
						 ||		2.	append loop 	||
						 												- - - - -				*/

		foreach file of global rest {

			append using 	"${mastData}/${`file'}.dta" ///
								, nolabel nonotes

		}



		* Id generate
		gen 				id = _n
		la var 				id "Unique Ride ID"


		* order
		order 				`order'


		* Save and export (.dta file takes up like 8 gb...)

		if 	(0)	{
		save 				"${master}"	///
								, replace
		}

			// csv takes up much less 
		export delimited 	///
							using	${delim} ///
							, replace



		restore

		clear
