# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: construct.R
# Description: Takes raw rdata files and does some magic.
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

library(lubridate)


                            #---------------------#
                            #    load data        =============================
                            #---------------------#

# load csv 
bks <- data.table::fread(
   file.path(raw, "bks-import.csv"),
   header = TRUE,
   na.strings = "" 
)


# make names object 
names_bks <- 
   as_tibble(names(bks)) %>%
   gather()
 

# make subsample for easy processing
# note: here I don't set the seed because I actually want a difference each time.
sample <- bks %>%
   mutate(r = runif(nrow(.)) ) %>% # make random variable
   arrange(r) %>%
   filter(row_number() <= 1000) # keep only first 1000 rows

saveRDS(sample, file.path(processed, "sample.Rda")) # save as RDA




 

                             #---------------------#
                             #   New Variables      ====================================
                             #---------------------#


# create duration for bks2020.2
sample$dur <-lubridate::as.duration(bks2020.2$`End date` - bks2020.2$`Start date`)


# Change factor levels to member/guest binary----




# check factor levels of membership type, bike type
bks2020.2 <- 
 mutate(bks2020.2,
        `Member type` = fct_recode(`Member type`,
                                   "Member" = "member",
                                   "Guest" = "casual"),
        `Bike type` = fct_recode(`Bike type`,
                                 "Electric" = "electric_bike",
                                 "Classic"  = "docked_bike")
        
 )
