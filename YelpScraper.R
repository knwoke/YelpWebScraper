#install the necessary packages
install.packages("rtools")
install.packages("tidyverse")
install.packages("rvest")
install.packages("data.table")
install.packages("rlist")
install.packages("magrittr")
install.packages("stringr")
install.packages("tryCatchLog")

# load the necessary packages
library(tidyverse)
library(rvest)
library(data.table)
library(rlist)
library(magrittr)
library(stringr)

#defining the url for the scraper
url <- "https://www.yelp.com/biz/katzs-delicatessen-new-york?sort_by=date_asc"

#read the HTML data into dataframe
page <- read_html(url)

df_final <- list()

#identify the page navigation element on Yelp and convert this to a number
pageNums <- page %>% 
  html_elements(xpath = "//div[@aria-label='Pagination navigation']") %>%
  html_text() %>% 
  str_extract('of \\d+') %>% 
  str_remove('of ') %>% 
  as.numeric()

#incrementing the page navigation element
pageSequence <- seq(from = 0, to = (pageNums * 10)-10, by=10)

for(i in pageSequence) {
  
  #convering the url into an iterable function
  url <- sprintf("https://www.yelp.com/biz/katzs-delicatessen-new-york?start=%d&sort_by=date_asc", i)
  
  #convert HTML element into dataframe
  page <- read_html(url)
  
  #scraping the necessary elements
  # usernames <- page %>%
  #   html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>%
  #   html_elements(xpath = ".//a[starts-with(@href, '/user_details')]") %>%
  #   html_text()%>%

  locations <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = ".//span[@class=' css-qgunke']") %>%
    html_text() %>%
    .[.!="Location"]
  
  comments <- page %>%
    html_elements(xpath = "//div[starts-with(@class, ' margin')]") %>%
    html_elements(xpath = "(.//p[starts-with(@class, 'comment')])[1]") %>%
    html_text()
  
  ratings <- page %>%
    html_elements(xpath = "//ul[starts-with(@class, ' undefined')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' margin')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' arrange')]") %>%
    html_elements(xpath = ".//span[starts-with(@class, ' display')]") %>%
    html_elements(xpath = "(.//div[contains(@aria-label, 'star rating')])[1]") %>%
    html_attr("aria-label") %>%
    str_remove_all(" star rating") %>%
    as.numeric()

  the_dates <- page %>%
    html_elements(xpath = "//ul[starts-with(@class, ' undefined')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, '  border')]") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' margin')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-chan6m'])[1]") %>%
    html_text()
  
  number_of_followers <- page %>%
    html_elements(xpath = "(//ul[contains(@class, 'list__09f24')])") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-1fnccdf'])[1]") %>%
    html_text() %>%
    as.numeric()
  
  number_of_reviews <- page %>%
    html_elements(xpath = "(//ul[contains(@class, 'list__09f24')])") %>%
    html_elements(xpath = ".//div[starts-with(@class, ' user-passport')]") %>%
    html_elements(xpath = "(.//span[@class = ' css-1fnccdf'])[2]") %>%
    html_text() %>%
    as.numeric()

#putting the scrapped elements into a dataframe
  df_new <- list (date = the_dates,
                  location = locations,
                  rating = ratings,
                  numberoffollowers = number_of_followers,
                  numberofreviews = number_of_reviews,
                  comment = comments)
  
  df_new_table <- as.data.frame(df_new)
  
  df_final <- rbindlist(list(df_final, df_new_table))
  
  Sys.sleep(sample(c(45,60), 1))
}


  
