install.packages("rtools")
install.packages("tidyverse")
install.packages("rvest")
install.packages("data.table")
install.packages("rlist")
install.packages("magrittr")
install.packages("stringr")
install.packages("tryCatchLog")
install.packages("rlang")
installed.packages("dplyr")

# load the necessary packages
library(tidyverse)
library(rvest)
library(data.table)
library(rlist)
library(magrittr)
library(stringr)

url <- "https://www.yelp.com/biz/katzs-delicatessen-new-york?sort_by=date_asc"
#download.file(url, destfile = "scrapedpage.html", quiet=TRUE)

page <- read_html(url)

df_final <- list()

pageNums <- page %>% 
  html_elements(xpath = "//div[@aria-label='Pagination navigation']") %>%
  html_text() %>% 
  str_extract('of \\d+') %>% 
  str_remove('of ') %>% 
  as.numeric()

pageSequence <- seq(from = 0, to = (pageNums * 10)-10, by=10)

for(i in pageSequence) {
  
  url <- sprintf("https://www.yelp.com/biz/katzs-delicatessen-new-york?start=%d&sort_by=date_asc", i)
  
  page <- read_html(url)
  
  usernames <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = ".//a[starts-with(@href, '/user_details')]") %>%
    html_text() %>%
    replace(!nzchar(usernames), NA)

 locations <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = ".//span[@class=' css-qgunke']") %>%
    html_text() %>%
    .[.!="Location"]%>% 
    replace(!nzchar(locations), NA)

  comments <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' margin-b2')]") %>%
    html_elements(xpath = "(.//p[starts-with(@class, 'comment')])[1]") %>%
    html_text() %>%
    replace(!nzchar(comments), NA)
  
  ratings <- page %>%
    html_elements(xpath = "//li[starts-with(@class, ' margin-b5')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, '  border')]") %>%
    html_elements(xpath = "(.//div[contains(@aria-label, 'star rating')])[1]") %>%
    html_attr("aria-label") %>%
    str_remove_all(" star rating") %>%
    as.numeric() %>%
    replace(!nzchar(ratings), NA)

  the_dates <- page %>%
    html_elements(xpath = "//li[starts-with(@class, ' margin-b5')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, '  border')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-chan6m'])[1]") %>%
    html_text() %>%
    replace(!nzchar(the_dates), NA)
  
  number_of_followers <- page %>%
    html_elements(xpath = "(//ul[contains(@class, 'list__09f24')])") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-1fnccdf'])[1]") %>%
    html_text() %>%
    as.numeric() %>%
    replace(!nzchar(number_of_followers), NA)
  
  number_of_reviews <- page %>%
    html_elements(xpath = "(//ul[contains(@class, 'list__09f24')])") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-1fnccdf'])[2]") %>%
    html_text() %>%
    as.numeric() %>%
    replace(!nzchar(number_of_reviews), NA)

  #appsloveworld.com/r/100/72/scraping-with-rvest-complete-with-nas-when-tag-is-not-present
  #https://stackoverflow.com/questions/64867505/how-to-write-na-for-missing-results-in-rvest-if-there-was-no-content-in-node-wi
  
  df_new <- list(
                  username = usernames,
                  #helpful = helpful,
                  #thanks = thanks,
                  #lovethis = lovethis,
                  date = the_dates,
                  location = locations,
                  rating = ratings,
                  numberoffollowers = number_of_followers,
                  numberofreviews = number_of_reviews,
                  comment = comments
                  )
  
  df_new_table <- as.data.frame(df_new)
  
  df_final <- rbindlist(list(df_final, df_new_table))
  
  Sys.sleep(sample(c(75,90), 1))
}



  
