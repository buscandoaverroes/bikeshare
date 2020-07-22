/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
| File: bikeshare_Mother.do																|
| Date: May, 2020																		|
| Author: buscandoaverroes																|
| Description: the master script for exploration of Capital Bikeshare project 			|
| ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/



*iefolder*0*StandardSettings****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           - Install packages needed to run all dofiles called
   *            by this master dofile.
   *           - Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*iefolder*0*End_StandardSettings************************************************
*iefolder will not work properly if the line above is edited


	if (0) {

   *Install all packages that this project requires:
   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
   local user_commands ietoolkit estout mdesc blindschemes
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }

   *Standardize settings accross users
   ieboilstart, version(15.1)          //Set the version number to the oldest version used by anyone in the project team
   `r(version)'                        //This line is needed to actually set the version from the command above
	}
*iefolder*1*FolderGlobals*******************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           - Set the global box to point to the project folder
   *            on each collaborator's computer.
   *           - Set other locals that point to other folders of interest.
   *
   * ******************************************************************** *

   * Users
   * -----------

   *User Number:
   * You                     1    // buscandoaverroes

   *Set this value to the user currently using this file
   global user  1

   * Root folder globals
   * ---------------------

   if $user == 1 {
       global dataWorkFolder 	"/Volumes/Al-Hakem-II/Datasets/bks"
	   global scripts			"/Volumes/Al-Hakem-II/Scripts/bikeshare/stata"
   }



* These lines are used to test that the name is not already used (do not edit manually)
*round**************************************************************************
*untObs*************************************************************************
*subFld*************************************************************************
*iefolder will not work properly if the lines above are edited



*iefolder*1*FolderGlobals*subfolder*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData"
   global raw 					 "$dataWorkFolder/raw"

*iefolder*1*FolderGlobals*encrypted*********************************************
*iefolder will not work properly if the line above is edited

   global encryptFolder          "$dataWorkFolder/EncryptedData"

*iefolder*1*FolderGlobals*endRounds*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*StandardGlobals*****************************************************
*iefolder will not work properly if the line above is edited

   * Set all non-folder path globals that are constant accross
   * the project. Examples are conversion rates used in unit
   * standardization, different sets of control variables,
   * adofile paths etc.

   do "${scripts}/global_setup.do"


*iefolder*2*End_StandardGlobals*************************************************
*iefolder will not work properly if the line above is edited


*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DOFILE
   *
   *           - When survey rounds are added, this section will
   *            link to the master dofile for that round.
   *           - The default is that these dofiles are set to not
   *            run. It is rare that all round-specfic master dofiles
   *            are called at the same time; the round specific master
   *            dofiles are almost always called individually. The
   *            exception is when reviewing or replicating a full project.
   *
   * ******************************************************************** *



	* runs the import file: warning, takes ~ 10 min
   if (0) {
	   do 	"${scripts}/import1.do"
   }


   if (0) {
	   do 	"${scripts}/construct-2019.do"
   }

   if (1) {
	   do 	"${scripts}/construct-2020.do"
   }

   if (1) {
	   do 	"${scripts}/append.do"
   }

   if (0) {
	   do 	"${scripts}/compress.do"
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited
