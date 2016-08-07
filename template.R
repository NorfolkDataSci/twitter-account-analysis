
# turn off stringsAsFactors because they make text analysis hard

options(stringsAsFactors = FALSE)

# load packages

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(twitteR))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(plyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(dplyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggplot2))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggthemes))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggrepel))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(scales))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(lubridate))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(network))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(sna))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(xml2))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(twitteR))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(qdap))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(tm))))

# Authenticate against the Twitter API ----------------------------------------------------------------------------------------
# Check with administrator about running a one time script 
# that will provide your system with the appropriate API Keys

# authenticate against twitter using your api keys
setup_twitter_oauth(consumer_key = Sys.getenv("TWITTER_CONSUMER_KEY"), 
                    consumer_secret = Sys.getenv("TWITTER_CONSUMER_SECRET"), 
                    access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"), 
                    access_secret = Sys.getenv("TWITTER_ACCESS_SECRET"))
token <- get("oauth_token", twitteR:::oauth_cache) #Save the credentials info
token$cache()


# Pull down tweets of a person of interest ----------------------------------------------------------------------------------------

# determine a twitter user that you are interested in
user_of_interest <- getUser('NorfolkVA')

# pull down the last 3200 tweets
tweets <- userTimeline(user_of_interest, n=3200, maxID=NULL, sinceID=NULL, includeRts=FALSE, excludeReplies=FALSE)

# saving tweets if there is no online access
saveRDS(tweets, './data/tweets.Rds')
# loading tweets from file
tweets <- readRDS('./data/tweets.Rds')


# Cleaning the tweets from unescaped HTML ----------------------------------------------------------------------------------------

# tweets come across with certain html characters encoded
# for example, the ampersand (&) symbol comes across as amp;
# we need to unescape those characters
# taken from http://stackoverflow.com/questions/5060076/convert-html-character-entity-encoding-in-r
unescape_xml <- function(str){
  xml2::xml_text(xml2::read_xml(paste0("<x>", str, "</x>")))
}
unescape_html <- function(str){
  xml2::xml_text(xml2::read_html(paste0("<x>", str, "</x>")))
}

# create the unescaped version
tweets <- lapply(tweets, FUN=function(x){x$text <- unescape_html(x$text);return(x)})


# Calculate tweet emotional polarity -----------------------------------------------------------------------------------------------

polarity <- lapply(tweets, function(tweet) {
              txt <- tweet$text
              # strip sentence enders so each tweet is analyzed as a sentence,
              # and +'s which muck up regex
              txt <- gsub('(\\.|!|\\?)\\s+|(\\++)', ' ', txt)
              # strip URLs
              txt <- gsub(' http[^[:blank:]]+', '', txt)
              # calculate polarity
              return(polarity(txt))
            })
retweet_data <- data.frame(text = sapply(tweets, FUN=function(x){x$text}), 
                           retweetCount = sapply(tweets, FUN=function(x){x$retweetCount}), 
                           emotionalValence = sapply(polarity, function(x) x$all$polarity))


# Do happier tweets get retweeted more? ----------------------------------------------------------------------------------------

ggplot(retweet_data, aes(x = emotionalValence, 
                         y = retweetCount)) +
  geom_point(position = 'jitter') +
  geom_smooth(span = 1) +
  scale_x_continuous(breaks = pretty_breaks(6)) +
  scale_y_continuous(breaks = pretty_breaks(6)) +
  labs(x="Tweet Emotion (negative to positive)", y="Retweets Count") +
  ggtitle('Count of Retweets by Message Emotion') + 
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14, face="bold"),
        plot.title = element_text(color="black", face="bold", size=24, hjust=0))

plot(retweet_data$emotionalValence, retweet_data$retweetCount)
identify(retweet_data$emotionalValence, retweet_data$retweetCount, labels=retweet_data$text)

retweet_data[29,]
retweet_data[55,]
retweet_data[83,]

# Who is retweeting whom? ------------------------------------------------------------------------------------------------------

# pull down tweets this time INCLUDING retweets
tweets_inc_retweets <- userTimeline(user_of_interest, n=3200, maxID=NULL, sinceID=NULL, includeRts=TRUE, excludeReplies=FALSE)
tweets_df <- twListToDF(tweets_inc_retweets)

# Split into retweets and original tweets
sp <- split(tweets_df, tweets_df$isRetweet)

# Extract the retweets and pull the original author's screenname
rt <- mutate(sp[['TRUE']], sender = substr(text, 5, regexpr(':', text) - 1))

el <- as.data.frame(cbind(sender = tolower(rt$sender), 
                          receiver = tolower(rt$screenName)))
el <- count(el, sender, receiver) 
rtnet <- network(el, matrix.type = 'edgelist', directed = TRUE, 
                ignore.eval = FALSE, names.eval = 'num')

# Get names of only those who were retweeted to keep labeling reasonable
vlabs  <- rtnet %v% 'vertex.names'
vlabs[degree(rtnet, cmode = 'outdegree') == 0] <- NA
col3 <- RColorBrewer::brewer.pal(3, 'Paired')
par(mar = c(0, 0, 3, 0))
plot(rtnet, label = vlabs, label.pos = 5, label.cex = .8, 
     vertex.cex = log(degree(rtnet)) + .5, vertex.col = col3[1],
     edge.lwd = 'num', edge.col = 'gray70', main = '@NorfolkVA Retweet Network')


# Determine retweeter reach to see if there are some real influencers in our network ----------------------------------------

el$sender_followers <- NA
for (i in 1:nrow(el)){
  try({el$sender_followers[i] <- getUser(el$sender[i])$followersCount})
}

nas_removed_dat <- el %>% 
  na.omit() %>% 
  filter(n >= 2, 
         sender_followers >= 5)

ggplot(nas_removed_dat, aes(sender_followers, n)) +
  geom_point(color = 'red') +
  scale_x_continuous(trans = log_trans(), breaks=c(100, 1000, 10000, 50000)) +
  geom_text_repel(aes(label = nas_removed_dat$sender)) +
  ggtitle('Followers Count for @NorfolkVA Retweeters') + 
  labs(x="Follower Count of Retweeter (log scale)", y="Retweets Count") +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14, face="bold"),
        plot.title = element_text(color="black", face="bold", size=24, hjust=0))

