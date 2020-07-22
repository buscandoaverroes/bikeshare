/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
| File: construct.do															|
| Date: May, 2020																		|
| Author: buscandoaverroes																|
| Description: constructs all variables for datasets before april 2020		 			|
| ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/


						/* - - - - - - - - - - - - - - - - - - - -
									Table of Contents
							1. Load
							2. variable construction


						 - - - - - - - - - - - - - - - - - - - - */


	* settings
	local source 				= 0

	* locals
	local date 					startdate enddate
	local dt 					start

	local dropvars 				startdate enddate membertype
	local april2020dropvars		ride_id rideable_type started_at ended_at start_station_id end_station_id start_lat start_lng end_lat end_lng member_casual elapsedtime

/*		- - - - -
						 ||		1.	Import the 	.dta file	||
						 												- - - - -				*/



		foreach file of global pre {

			/*use 			"${mastData}/${`file'}.dta" ///
								, clear*/
			import delimited ///
					using "${raw}/${`file'}.csv" ///
					, clear


			preserve




/*		- - - - -
							 ||		2.	Variable Construction 	||
							 												- - - - -				*/


								* ||	 value labels 	|| *

	cap la def 			month 	1 "January" ///
							2 "February" ///
							3 "March" ///
							4 "April" ///
							5 "May" ///
							6 "June" ///
							7 "July" ///
							8 "August" ///
							9 "September" ///
							10 "October" ///
							11 "November" ///
							12 "December"

	cap la def 			dow 	0 "Sunday" ///
							1 "Monday" ///
							2 "Tuesday" ///
							3 "Wednesday" ///
							4 "Thursday" ///
							5 "Friday" ///
							6 "Saturday"

	cap la def 			qtr 	1 "Spring" ///
							2 "Summer" ///
							3 "Fall" ///
							4 "Winter"



								/*||		Time variables  	||*


	if ("`file'" == "d2020m4" | "`file'" == "d2020m5" | "`file'" != "d2020m6") {

								*||		Begin alternate code for April 2020 	||*
									/* we have to account for the varname changes in april 2020.
									 	we also will save this as a different file BEFORE that of
										the local pattern to preserve gps coordinates. Also, there is
										no duration variable so we must construct one. */

								if "`file'" == "d2020m4" {
										save 		"${mastData}/april2020gps.dta" ///
													, replace
									}
									/* close save april gps loop */




															*||			Dates			||*

									// begin loop
									foreach v in started_at ended_at {

										// reset the local
										local dt 	start

										if `v' == ended {

											// change the tag
											local dt end
										}

									// generate a %tC variable that accounts for leap seconds
									gen 			double datetime`dt' ///
													= Clock(`v', "YMD hms")

									format 			datetime`dt' %tC

									// generate a %td variable (without time)
									gen 			date`dt' = date(`v', "YMD###")
									format 			date`dt' %td

									// generate year, mo, day etc
									gen				year`dt' = year(date`dt')
									gen 			month`dt' : month = month(date`dt')
									gen 			day`dt' = day(date`dt')

									gen 			hour`dt' = hh(datetime`dt')
									gen 			min`dt' = mm(datetime`dt')

									gen 			quarter`dt' : qtr = quarter(date`dt')
									gen 			week`dt' = week(date`dt')
									gen 			dow`dt' : dow = dow(date`dt')
									gen 			doy`dt' = doy(date`dt')

									// var labels
									la var 			datetime`dt' 	"`dt' date and time"
									la var 			date`dt' 		"`dt' date"
									la var 			year`dt' 		"`dt' year"
									la var 			month`dt' 		"`dt' month"
									la var 			day`dt' 		"`dt' day"
									la var 			hour`dt' 		"`dt' hour"
									la var 			min`dt' 		"`dt' minute"
									la var 			quarter`dt'		"`dt' quarter of year"
									la var 			week`dt' 		"`dt' week of year"
									la var 			dow`dt' 		"`dt' day of week"
									la var 			doy`dt' 		"`dt' day of year"



									}

												* ||	 Units of Time	 || *

									// generate duration variable

										// subtract start and end
										gen 		elapsedtime = datetimeend - datetimestart
										format 		elapsedtime %tC

									// minutes
									gen 			min = minutes(elapsedtime)

									// hours
									gen 			hour = hours(elapsedtime)


									// labels
									label var 		min "Duration in Minutes"
									label var 		hour "Duration in Hours"

									// compress + format
									recast 			float ///
													min hour ///
													, force

									format 			%9.2f ///
													min hour





															*||		Member Type		||*

									// make sure there are only two member types
									levelsof 		member_casual
									assert 			r(r) == 2 	| r(r) == 3

									// define label, but do not use
									la def 			mbr 0 "Guest" ///
														1 "Member" ///
														2 "Unknown"

									// gen inicator var without above label (shown as 1 or 0)
									gen 			int member = (member_casual == "member")
									label var 		member "Indicator for Member vs Non-Member"




								***		variable maniuplation *****

								// rename
								rename 				(start_station_name end_station_name) 	/* old varnames */ ///
													(startstation endstation)				/* mainstream varnames */





								// drop
									drop 			`april2020dropvars'





									save 			"${mastData}/${`file'}.dta" ///
														, replace
														/* this replaces the file it imports */


								}

								*||		end alternate code for April 2020 	||*/







* begin "normal" loop


	// minutes
	gen 			min = duration / 60

	// hours
	gen 			hour = min / 60

	// labels
	label var 		min "Duration in Minutes"
	label var 		hour "Duration in Hours"

	// compress + format
	recast 			float ///
					min hour ///
					, force

	format 			%9.2f ///
					min hour





							*||			Dates			||*

	// begin date loop
	foreach v in startdate enddate {

		// reset the local
		local dt 	start

		if `v' == enddate {

			// change the tag
			local dt end
		}

	// generate a %tC variable that accounts for leap seconds
	gen 			double datetime`dt' ///
					= Clock(`v', "YMD hms")

	format 			datetime`dt' %tC

	// generate a %td variable (without time)
	gen 			date`dt' = date(`v', "YMD###")
	format 			date`dt' %td

	// generate year, mo, day etc
	gen				year`dt' = year(date`dt')
	gen 			month`dt' : month = month(date`dt')
	gen 			day`dt' = day(date`dt')

	gen 			hour`dt' = hh(datetime`dt')
	gen 			min`dt' = mm(datetime`dt')

	gen 			quarter`dt' = quarter(date`dt')
	gen 			week`dt' = week(date`dt')
	gen 			dow`dt' : dow = dow(date`dt')
	gen 			doy`dt' = doy(date`dt')

	// var labels
	la var 			datetime`dt' 	"`dt' date and time"
	la var 			date`dt' 		"`dt' date"
	la var 			year`dt' 		"`dt' year"
	la var 			month`dt' 		"`dt' month"
	la var 			day`dt' 		"`dt' day"
	la var 			hour`dt' 		"`dt' hour"
	la var 			min`dt' 		"`dt' minute"
	la var 			quarter`dt'		"`dt' quarter of year"
	la var 			week`dt' 		"`dt' week of year"
	la var 			dow`dt' 		"`dt' day of week"
	la var 			doy`dt' 		"`dt' day of year"


	}
	* end date loop





							*||		Member Type		||*

	// make sure there are only two member types
	levelsof 		membertype
	assert 			r(r) == 2 	| r(r) == 3

	// define label, but don't use
	la def 			mbr 0 "Guest/Unknown" ///
						1 "Member" ///
						2 "Unknown"

						// really hsould change member type here to binary

	// gen var indicator var
	gen 			int member = (membertype == "Member")
	label var 		member "Indicator for Member vs Non-Member"






***		drop variables *****

	drop 			`dropvars'




	save 			"${mastData}/${`file'}.dta" ///
						, replace
						/* this replaces the file it imports */

	restore

	clear 


		}
		* close file loop
