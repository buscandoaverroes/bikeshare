# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: compress.R
# Description: compresses the .dta file into R, hopefully faster.
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #


                        # ---- Import the dta file ----


      if (size == 1) {

    bks2 <- read.dta13(file.path(tiny),
                      convert.factors = TRUE,
                      nonint.factors = TRUE) # keep the factor labels for all

      }


      if (size == 2) {

    bks <- read.dta13(file.path(master),
                        convert.factors = TRUE,
                        nonint.factors = TRUE) # keep the factor labels for all

      }


      if (size == 3) {

        bks <- data.table::fread(file.path(csv),
                                 header = TRUE,
                                 na.strings = ".",  # tell characters to be read as missing
                                 stringsAsFactors = TRUE,
                                 showProgress = TRUE,
                                 data.table = FALSE
                                 ) # return data frame, not table

        saveRDS(bks, file.path(MasterData, "motherdata.Rda"))
      }
