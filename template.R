
# turn off stringsAsFactors because they make text analysis hard

options(stringsAsFactors = FALSE)

# load packages

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('twitteR'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('plyr'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('dplyr'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('ggplot2'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('lubridate'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('network'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('sna'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('xml2'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('twitteR'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('qdap'))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library('tm'))))

setup_twitter_oauth(consumer_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXX", 
                    consumer_secret = "XXXXXXXXXXXXXXXXXXXXXXXXXXX", 
                    access_token = "XXXXXXXXXXXXXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXX", 
                    access_secret = "XXXXXXXXXXXXXXXXXXXXXXXXXXX")
token <- get("oauth_token", twitteR:::oauth_cache) #Save the credentials info
token$cache()

# taken from http://stackoverflow.com/questions/5060076/convert-html-character-entity-encoding-in-r
unescape_xml <- function(str){
  xml2::xml_text(xml2::read_xml(paste0("<x>", str, "</x>")))
}

unescape_html <- function(str){
  xml2::xml_text(xml2::read_html(paste0("<x>", str, "</x>")))
}

#
user_of_interest <- getUser('NorfolkVA')

#
userTimeline(user_of_interest, n=20, maxID=NULL, sinceID=NULL, includeRts=FALSE, 
             excludeReplies=FALSE)
homeTimeline(n=25, maxID=NULL, sinceID=NULL)
mentions(n=25, maxID=NULL, sinceID=NULL)
retweetsOfMe(n=25, maxID=NULL, sinceID=NULl)