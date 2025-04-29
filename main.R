pacman::p_load(tidyverse, rvest, janitor, httr, readxl, bigrquery, googleAuthR, lubridate, cronR, shinyFiles)

source("R/authenticate.R")
source("R/scraping.R")
source("R/cleaning.R")
source("R/bigquery_upload.R")
source("R/detect_adoptions.R")
source("R/email_content.R")
source("R/send_email.R")

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
  message("No matching puppies found. No email sent.")
}


