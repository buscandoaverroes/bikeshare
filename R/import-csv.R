# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Name: import-csv.R
# Description: imports raw data files, appends to same year object
#
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #




                            #---------------------#
                            # import csv's        # ----
                            #---------------------#
                            
                            
                            # 2010 ----
            r2010 <- read_csv(file.path(raw, "2010/2010-capitalbikeshare-tripdata"),
                                       col_names = TRUE, 
                                       na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
                            # 2011 ----
            r2011 <- read_csv(file.path(raw, "2011/2011-capitalbikeshare-tripdata.csv"),
                                       col_names = TRUE, 
                                       na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
            
            
            
                            # 2012 ----
            r2012q1 <- read_csv(file.path(raw, "2012/2012Q1-capitalbikeshare-tripdata.csv"),
                                       col_names = TRUE, 
                                       na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2012q2 <- read_csv(file.path(raw, "2012/2012Q2-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2012q3 <- read_csv(file.path(raw, "2012/2012Q3-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2012q4 <- read_csv(file.path(raw, "2012/2012Q4-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
            
                            # 2013 ----
            r2013q1 <- read_csv(file.path(raw, "2013/2013Q1-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2013q2 <- read_csv(file.path(raw, "2013/2013Q2-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2013q3 <- read_csv(file.path(raw, "2013/2013Q3-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2013q4 <- read_csv(file.path(raw, "2013/2013Q4-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
            
                            # 2014 ----
            r2014q1 <- read_csv(file.path(raw, "2014/2014Q1-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2014q2 <- read_csv(file.path(raw, "2014/2014Q2-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2014q3 <- read_csv(file.path(raw, "2014/2014Q3-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2014q4 <- read_csv(file.path(raw, "2014/2014Q4-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
                            # 2015 ----
            r2015q1 <- read_csv(file.path(raw, "2015/2015Q1-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2015q2 <- read_csv(file.path(raw, "2015/2015Q2-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2015q3 <- read_csv(file.path(raw, "2015/2015Q3-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2015q4 <- read_csv(file.path(raw, "2015/2015Q4-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
            
                            # 2016 ----
            r2016q1 <- read_csv(file.path(raw, "2016/2016Q1-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2016q2 <- read_csv(file.path(raw, "2016/2016Q2-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2016q3 <- read_csv(file.path(raw, "2016/2016Q3-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2016q4 <- read_csv(file.path(raw, "2016/2016Q4-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
           
            
                            # 2017 ----
            r2017q1 <- read_csv(file.path(raw, "2017/2017Q1-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2017q2 <- read_csv(file.path(raw, "2017/2017Q2-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2017q3 <- read_csv(file.path(raw, "2017/2017Q3-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            r2017q4 <- read_csv(file.path(raw, "2017/2017Q4-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            
                                         
                            # 2018 ----
            r2018m1 <- read_csv(file.path(raw, "2018/201801-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m2 <- read_csv(file.path(raw, "2018/201802-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m3 <- read_csv(file.path(raw, "2018/201803-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m4 <- read_csv(file.path(raw, "2018/201804-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m5 <- read_csv(file.path(raw, "2018/201805-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m6 <- read_csv(file.path(raw, "2018/201806-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m7 <- read_csv(file.path(raw, "2018/201807-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m8 <- read_csv(file.path(raw, "2018/201808-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m9 <- read_csv(file.path(raw, "2018/201809-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m10 <- read_csv(file.path(raw, "2018/201810-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m11 <- read_csv(file.path(raw, "2018/201811-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2018m12 <- read_csv(file.path(raw, "2018/201812-capitalbikeshare-tripdata.csv"),
                                         col_names = TRUE, 
                                         na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
            
                            # 2019 ----
            r2019m1 <- read_csv(file.path(raw, "2019/201901-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2019m2 <- read_csv(file.path(raw, "2019/201902-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2019m3 <- read_csv(file.path(raw, "2019/201903-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2019m4 <- read_csv(file.path(raw, "2019/201904-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2019m5 <- read_csv(file.path(raw, "2019/201905-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2019m6 <- read_csv(file.path(raw, "2019/201906-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            ) 
            r2019m7 <- read_csv(file.path(raw, "2019/201907-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            ) 
            r2019m8 <- read_csv(file.path(raw, "2019/201908-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            ) 
            r2019m9 <- read_csv(file.path(raw, "2019/201909-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            ) 
            r2019m10 <- read_csv(file.path(raw, "2019/201910-capitalbikeshare-tripdata.csv"),
                                 col_names = TRUE, 
                                 na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2019m11 <- read_csv(file.path(raw, "2019/201911-capitalbikeshare-tripdata.csv"),
                                 col_names = TRUE, 
                                 na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            ) 
            r2019m12 <- read_csv(file.path(raw, "2019/201912-capitalbikeshare-tripdata.csv"),
                                 col_names = TRUE, 
                                 na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
                  
                            # 2020 ----
            r2020m1 <- read_csv(file.path(raw, "2020/202001-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2020m2 <- read_csv(file.path(raw, "2020/202002-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2020m3 <- read_csv(file.path(raw, "2020/202003-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2020m4 <- read_csv(file.path(raw, "2020/202004-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2020m5 <- read_csv(file.path(raw, "2020/202005-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            r2020m6 <- read_csv(file.path(raw, "2020/202006-capitalbikeshare-tripdata.csv"),
                                col_names = TRUE, 
                                na = c("", " ", "  ") # set 0, 1 or 2 spaces as NA
            )
            
            
            
            
            
            
            
                        #---------------------#
                        #append raw data to yr ----
                        #---------------------#
        # years 2010 and 2011 are already in a year 
            
r2012 <- bind_rows(r2012q1, r2012q2, r2012q3, r2012q4)
r2013 <- bind_rows(r2013q1, r2013q2, r2013q3, r2013q4)
r2014 <- bind_rows(r2014q1, r2014q2, r2014q3, r2014q4)
r2015 <- bind_rows(r2015q1, r2015q2, r2015q3, r2015q4)
r2016 <- bind_rows(r2016q1, r2016q2, r2016q3, r2016q4)
r2017 <- bind_rows(r2017q1, r2017q2, r2017q3, r2017q4)
r2018 <- bind_rows(r2018m1, r2018m2, r2018m3, r2018m4, r2018m5, r2018m6,
                   r2018m7, r2018m8, r2018m9, r2018m10,r2018m11,r2018m12)
r2019 <- bind_rows(r2019m1, r2019m2, r2019m3, r2019m4, r2019m5, r2019m6,
                   r2019m7, r2019m8, r2019m9, r2019m10,r2019m11,r2019m12)
r2020 <- bind_rows(r2020m1, r2020m2, r2020m3, r2020m4, r2020m5, r2020m6)

            
            