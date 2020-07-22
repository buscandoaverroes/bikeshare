/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
| File: import1.do															|
| Date: May, 2020																		|
| Author: buscandoaverroes																|
| Description: plays around with importing a sample file  		 			|
| ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/


						/* - - - - - - - - - - - - - - - - - - - -
									Table of Contents
							1. Import and save as .dta


						 - - - - - - - - - - - - - - - - - - - - */

						 /* Note that this will eventually be converted into a loop. */

	* settings
	local source 				= 0

	*

/*		- - - - -
						 ||		Import the sample file		||
						 												- - - - -				*/


	if `source' == 0 {

		foreach file of global datasets {

			import delimited ///
					using "${raw}/${`file'}.csv" ///
					, clear

			save 		"${mastData}/${`file'}.dta", replace
		}

	}
