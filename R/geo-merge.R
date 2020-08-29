# ---------------------------------------------------------#
# merge bks with bks.key, generate more vars   ----
# ---------------------------------------------------------#

# create minidatasets 
m.bks <- bks[1:10000,]

# bks: join by startstation

# match to start   
# bks.key: key = cbs_station_name
bks2 <- inner_join(m.bks, bks.key, # keep all obs in bks
                   by = c("startstation" = "cbs_station_name")
)
# add suffix to indicate start
colnames(bks2)[34:48] <- paste0("s", sep = '.', colnames(bks2)[34:48])

# match to endstation   
# bks.key: key = cbs_station_name
bks3 <- inner_join(bks2, bks.key, # keep all obs in bks
                   by = c("endstation" = "cbs_station_name")
)
# add suffix to indicate start
colnames(bks3)[49:63] <- paste0("e", sep = '.', colnames(bks3)[49:63])
## %% up to here this works, try on full dataset






# key station number 
bks2 <- inner_join(bks, bks.key, # keep all obs in bks
                   by = c("startstationnumber" = "newid"),
                   suffix
) 
# something fishy with strings here, see if you can go into keycreate.R and 
# port over some of the station ids. 
# 'names' attribute [29736751] must be the same length as the vector [28874997]

####################### join full dataset 
# match to start   

bks2 <- left_join(bks, bks.key, # keep all obs in bks
                   by = c("startstation" = "cabi.")
)
# add suffix to indicate start
colnames(bks2)[34:48] <- paste0("s", sep = '.', colnames(bks2)[34:48])
# %% run up to here. 
# match to endstation   
# bks.key: key = cbs_station_name
bks3 <- inner_join(bks2, bks.key, # keep all obs in bks
                   by = c("endstation" = "cbs_station_name")
)
# add suffix to indicate start
colnames(bks3)[49:63] <- paste0("e", sep = '.', colnames(bks3)[49:63])



# why does bks lose observations as we merge?  