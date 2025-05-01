pacman::p_load(tidyverse, rvest, janitor, httr, readxl, bigrquery, googleAuthR, lubridate, cronR, shinyFiles, gmailr)

setwd("/Users/cujo253/Documents/the-pet-shop-easton")

readRenviron(".Renviron")

source("/Users/cujo253/Documents/the-pet-shop-easton/R/authenticate.R")
source("/Users/cujo253/Documents/the-pet-shop-easton/R/scraping.R")
source("/Users/cujo253/Documents/the-pet-shop-easton/R/cleaning.R")
source("/Users/cujo253/Documents/the-pet-shop-easton/R/bigquery_upload.R")
source("/Users/cujo253/Documents/the-pet-shop-easton/R/detect_adoptions.R")
source("/Users/cujo253/Documents/the-pet-shop-easton/R/email_content.R")
source("/Users/cujo253/Documents/the-pet-shop-easton/R/send_email.R")

# Execute script
url = "https://thepetshopinc.com/available-puppies"

con = authenticate_bq_and_google()

raw_puppy_data = fetch_all_puppy_details(url)
parsed_puppy_data = parse_puppy_details(raw_puppy_data)

upload_to_bq(parsed_puppy_data, "puppies", con)

detect_adoptions(con, table_header = "puppies")

breed_regex = "(dachs|basset)"

pups_of_interest = filter_puppies_by_breed(parsed_puppy_data, breed_regex)

email_body = create_email_content(pups_of_interest, breed_regex)

if (nrow(pups_of_interest) > 0) {
  send_email_alert(
    subject = paste0(Sys.Date(), " Puppy Breed Alert"),
    email_content = email_body
  )
} else {
  base::message("No matching puppies found. No email sent.")
}


