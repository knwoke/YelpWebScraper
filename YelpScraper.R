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

#define URL to scrape
url <- "https://www.yelp.com/biz/katzs-delicatessen-new-york?sort_by=date_asc"
#download.file(url, destfile = "scrapedpage.html", quiet=TRUE)

#convert URL into scrappable object
page <- read_html(url)

df_final <- list()

#define pagination element
pageNums <- page %>% 
  html_elements(xpath = "//div[@aria-label='Pagination navigation']") %>%
  html_text() %>% 
  str_extract('of \\d+') %>% 
  str_remove('of ') %>% 
  as.numeric()

#create a sequence based on the number of pages
#used in the URL to move from one page to the other 
pageSequence <- seq(from = 0, to = (pageNums * 10)-10, by=10)

#beginning of for look
for(i in pageSequence) {
  
#format URL to scrape the correct page  
  url <- sprintf("https://www.yelp.com/biz/katzs-delicatessen-new-york?start=%d&sort_by=date_asc", i)
  
  page <- read_html(url)
  
#scrape usernames from URL 
  usernames <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = ".//a[starts-with(@href, '/user_details')]") %>%
    html_text() %>%
    replace(!nzchar(usernames), NA)

#scrape locations from URL
 locations <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = ".//span[@class=' css-qgunke']") %>%
    html_text() %>%
    .[.!="Location"]%>% 
    replace(!nzchar(locations), NA)

 #scrape comments from URL
  comments <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' margin-b2')]") %>%
    html_elements(xpath = "(.//p[starts-with(@class, 'comment')])[1]") %>%
    html_text() %>%
    replace(!nzchar(comments), NA)

 #scrape ratins from url
  ratings <- page %>%
    html_elements(xpath = "//li[starts-with(@class, ' margin-b5')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, '  border')]") %>%
    html_elements(xpath = "(.//div[contains(@aria-label, 'star rating')])[1]") %>%
    html_attr("aria-label") %>%
    str_remove_all(" star rating") %>%
    as.numeric() %>%
    replace(!nzchar(ratings), NA)

#scrape dates from URL
  the_dates <- page %>%
    html_elements(xpath = "//li[starts-with(@class, ' margin-b5')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, '  border')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-chan6m'])[1]") %>%
    html_text() %>%
    replace(!nzchar(the_dates), NA)
 
 #scrape number of followers from URL
  number_of_followers <- page %>%
    html_elements(xpath = "(//ul[contains(@class, 'list__09f24')])") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-1fnccdf'])[1]") %>%
    html_text() %>%
    as.numeric() %>%
    replace(!nzchar(number_of_followers), NA)
  
 #scrape number of reviews from URL
  number_of_reviews <- page %>%
    html_elements(xpath = "(//ul[contains(@class, 'list__09f24')])") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-1fnccdf'])[2]") %>%
    html_text() %>%
    as.numeric() %>%
    replace(!nzchar(number_of_reviews), NA)

  #appsloveworld.com/r/100/72/scraping-with-rvest-complete-with-nas-when-tag-is-not-present
  #https://stackoverflow.com/questions/64867505/how-to-write-na-for-missing-results-in-rvest-if-there-was-no-content-in-node-wi
  
  #combine scrapped elements into a list
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
  
  #convert the list into a dataframe
  df_new_table <- as.data.frame(df_new)
  
  #append the dataframe to master dataframe
  df_final <- rbindlist(list(df_final, df_new_table))
  
  #introduce random sleep time to mitigate IP banning
  Sys.sleep(sample(c(75,90), 1))
}



  
