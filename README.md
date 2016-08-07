# twitter-account-analysis
Analysis of an Individual Twitter Account

## Overview
Twitter is a social media platform that's often used as a tool to promote a brand or organization. However, it's 
not always obvious which actions on social media result in the best return. Advanced analytics can reveal insights to
optimize social media efforts.

## Goals
Create a template analysis that can be repeated and reused to assist organizations in the local Hampton Roads area, such 
as @NorfolkVA, @NPSchools, @NorfolkDowntown, @NorfolkPD.

## Project Roadmap
[Twitter Analysis Trello Board](https://trello.com/b/GtFYXDgy/twitter-account-analysis)

## Data Source
Data obtained through [Twitter APIs](https://dev.twitter.com/rest/public)

## Sample Scripts
Inspiration for the sample scripts have been taken from the following sources:

 - http://blog.revolutionanalytics.com/2016/01/twitter-sentiment.html
 - http://juliasilge.com/blog/Ten-Thousand-Tweets/
 
## Getting Started with R
This project has been created and initialized with Packrat (a package management system for enhanced reprodicibility
in R). This means that if you need additional libraries, just run `install.packages()` and the resulting 
packages will be installed in the packrat library so that other users will have exactly the same configuration
as you! Plus, this won't mess with your existing set of installed packages on your personal computer. Here is a 
simple workflow with Packrat:

```
> install.packages('xml2')
> packrat::snapshot(prompt = FALSE)
Adding these packages to packrat:
         _      
    xml2   1.0.0
```