   * ******************************************************************** *
   *
   *       SET UP STANDARDIZATION GLOBALS AND OTHER CONSTANTS
   *
   *           - Set globals used all across the project
   *           - It is bad practice to define these at multiple locations
   *
   * ******************************************************************** *

   * ******************************************************************** *
   * Set all conversion rates used in unit standardization
   * ******************************************************************** *

   **Define all your conversion rates here instead of typing them each
   * time you are converting amounts, for example - in unit standardization.
   * We have already listed common conversion rates below, but you
   * might have to add rates specific to your project, or change the target
   * unit if you are standardizing to other units than meters, hectares,
   * and kilograms.

   *Standardizing length to meters
       global foot     = 0.3048
       global mile     = 1609.34
       global km       = 1000
       global yard     = 0.9144
       global inch     = 0.0254

   *Standardizing area to hectares
       global sqfoot   = (1 / 107639)
       global sqmile   = (1 / 258.999)
       global sqmtr    = (1 / 10000)
       global sqkmtr   = (1 / 100)
       global acre     = 0.404686

   *Standardizing weight to kilorgrams
       global pound    = 0.453592
       global gram     = 0.001
       global impTon   = 1016.05
       global usTon    = 907.1874996
       global mtrTon   = 1000

   * ******************************************************************** *
   * Set global lists of variables
   * ******************************************************************** *


   	gl		datasets 	`"d2010 d2011 d2012q1 d2012q2 d2012q3 d2012q4 d2013q1 d2013q2 d2013q3 d2013q4 d2014q1 d2014q2 d2014q3 d2014q4 d2015q1 d2015q2 d2015q3 d2015q4 d2016q1 d2016q2 d2016q3 d2016q4 d2017q1 d2017q2 d2017q3 d2017q4 d2018m1 d2018m2 d2018m3 d2018m4 d2018m5 d2018m6 d2018m7 d2018m8 d2018m9 d2018m10 d2018m11 d2018m12 d2019m1 d2019m2 d2019m3 d2019m4 d2019m5 d2019m6 d2019m7 d2019m8 d2019m9 d2019m10 d2019m11 d2019m12 d2020m1 d2020m2 d2020m3 d2020m4 d2020m5 d2020m5"'
	gl 		first 		`"d2010"'
	gl 		rest 		d2011 d2012q1 d2012q2 d2012q3 d2012q4 d2013q1 d2013q2 d2013q3 d2013q4 d2014q1 d2014q2 d2014q3 d2014q4 d2015q1 d2015q2 d2015q3 d2015q4 d2016q1 d2016q2 d2016q3 d2016q4 d2017q1 d2017q2 d2017q3 d2017q4 d2018m1 d2018m2 d2018m3 d2018m4 d2018m5 d2018m6 d2018m7 d2018m8 d2018m9 d2018m10 d2018m11 d2018m12 d2019m1 d2019m2 d2019m3 d2019m4 d2019m5 d2019m6 d2019m7 d2019m8 d2019m9 d2019m10 d2019m11 d2019m12 d2020m1 d2020m2 d2020m3 d2020m4 d2020m5 d2020m6
	gl 		pre 		d2010 d2011 d2012q1 d2012q2 d2012q3 d2012q4 d2013q1 d2013q2 d2013q3 d2013q4 d2014q1 d2014q2 d2014q3 d2014q4 d2015q1 d2015q2 d2015q3 d2015q4 d2016q1 d2016q2 d2016q3 d2016q4 d2017q1 d2017q2 d2017q3 d2017q4 d2018m1 d2018m2 d2018m3 d2018m4 d2018m5 d2018m6 d2018m7 d2018m8 d2018m9 d2018m10 d2018m11 d2018m12 d2019m1 d2019m2 d2019m3 d2019m4 d2019m5 d2019m6 d2019m7 d2019m8 d2019m9 d2019m10 d2019m11 d2019m12 d2020m1 d2020m2 d2020m3	/*before coding change*/
	gl 		post 		d2020m4 d2020m5 d2020m6			/*after coding change*/





   * ******************************************************************** *
   * Direct Files
   * ******************************************************************** *

	* master
	gl 		master 		`"${mastData}/full/master.dta"'
	gl 		tinymaster	`"${mastData}/full/tinymaster.dta"'
	gl 		delim		`"${mastData}/full/master.csv"'



   * ******************************************************************** *
   * File Path suffixes
   * ******************************************************************** *

	global 	d2019 		`"${mastData}/2019"'



	* 2010
	gl 		d2010 		`"2010/2010-capitalbikeshare-tripdata"'

	* 2011
	gl 		d2011 		`"2011/2011-capitalbikeshare-tripdata"'

	* 2012
	gl 		d2012q1 	`"2012/2012Q1-capitalbikeshare-tripdata"'
	gl 		d2012q2 	`"2012/2012Q2-capitalbikeshare-tripdata"'
	gl 		d2012q3 	`"2012/2012Q3-capitalbikeshare-tripdata"'
	gl 		d2012q4 	`"2012/2012Q4-capitalbikeshare-tripdata"'


	* 2013
	gl 		d2013q1 	`"2013/2013Q1-capitalbikeshare-tripdata"'
	gl 		d2013q2 	`"2013/2013Q2-capitalbikeshare-tripdata"'
	gl 		d2013q3 	`"2013/2013Q3-capitalbikeshare-tripdata"'
	gl 		d2013q4 	`"2013/2013Q4-capitalbikeshare-tripdata"'


	* 2014
	gl 		d2014q1 	`"2014/2014Q1-capitalbikeshare-tripdata"'
	gl 		d2014q2 	`"2014/2014Q2-capitalbikeshare-tripdata"'
	gl 		d2014q3 	`"2014/2014Q3-capitalbikeshare-tripdata"'
	gl 		d2014q4 	`"2014/2014Q4-capitalbikeshare-tripdata"'

	* 2015
	gl 		d2015q1 	`"2015/2015Q1-capitalbikeshare-tripdata"'
	gl 		d2015q2 	`"2015/2015Q2-capitalbikeshare-tripdata"'
	gl 		d2015q3 	`"2015/2015Q3-capitalbikeshare-tripdata"'
	gl 		d2015q4 	`"2015/2015Q4-capitalbikeshare-tripdata"'


	* 2016
	gl 		d2016q1 	`"2016/2016Q1-capitalbikeshare-tripdata"'
	gl 		d2016q2 	`"2016/2016Q2-capitalbikeshare-tripdata"'
	gl 		d2016q3 	`"2016/2016Q3-capitalbikeshare-tripdata"'
	gl 		d2016q4 	`"2016/2016Q4-capitalbikeshare-tripdata"'

	* 2017
	gl 		d2017q1 	`"2017/2017Q1-capitalbikeshare-tripdata"'
	gl 		d2017q2 	`"2017/2017Q2-capitalbikeshare-tripdata"'
	gl 		d2017q3 	`"2017/2017Q3-capitalbikeshare-tripdata"'
	gl 		d2017q4 	`"2017/2017Q4-capitalbikeshare-tripdata"'


	* 2018
	gl 		d2018m1 	`"2018/201801_capitalbikeshare_tripdata"'
	gl 		d2018m2 	`"2018/201802-capitalbikeshare-tripdata"'
	gl 		d2018m3 	`"2018/201803-capitalbikeshare-tripdata"'
	gl 		d2018m4 	`"2018/201804-capitalbikeshare-tripdata"'
	gl 		d2018m5 	`"2018/201805-capitalbikeshare-tripdata"'
	gl 		d2018m6 	`"2018/201806-capitalbikeshare-tripdata"'
	gl 		d2018m7 	`"2018/201807-capitalbikeshare-tripdata"'
	gl 		d2018m8 	`"2018/201808-capitalbikeshare-tripdata"'
	gl 		d2018m9 	`"2018/201809-capitalbikeshare-tripdata"'
	gl 		d2018m10 	`"2018/201810-capitalbikeshare-tripdata"'
	gl 		d2018m11 	`"2018/201811-capitalbikeshare-tripdata"'
	gl 		d2018m12 	`"2018/201812-capitalbikeshare-tripdata"'


	* 2019
	gl 		d2019m1 	`"2019/201901-capitalbikeshare-tripdata"'
	gl 		d2019m2 	`"2019/201902-capitalbikeshare-tripdata"'
	gl 		d2019m3 	`"2019/201903-capitalbikeshare-tripdata"'
	gl 		d2019m4 	`"2019/201904-capitalbikeshare-tripdata"'
	gl 		d2019m5 	`"2019/201905-capitalbikeshare-tripdata"'
	gl 		d2019m6 	`"2019/201906-capitalbikeshare-tripdata"'
	gl 		d2019m7 	`"2019/201907-capitalbikeshare-tripdata"'
	gl 		d2019m8 	`"2019/201908-capitalbikeshare-tripdata"'
	gl 		d2019m9 	`"2019/201909-capitalbikeshare-tripdata"'
	gl 		d2019m10 	`"2019/201910-capitalbikeshare-tripdata"'
	gl 		d2019m11 	`"2019/201911-capitalbikeshare-tripdata"'
	gl 		d2019m12 	`"2019/201912-capitalbikeshare-tripdata"'


	*2020
	gl 		d2020m1 	`"2020/202001-capitalbikeshare-tripdata"'
	gl 		d2020m2 	`"2020/202002-capitalbikeshare-tripdata"'
	gl 		d2020m3 	`"2020/202003-capitalbikeshare-tripdata"'
	gl 		d2020m4 	`"2020/202004-capitalbikeshare-tripdata"'
	gl 		d2020m5		`"2020/202005-capitalbikeshare-tripdata"'
	gl 		d2020m6		`"2020/202006-capitalbikeshare-tripdata"'
