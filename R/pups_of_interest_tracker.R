track_and_upload_pups_of_interest <- function(pups_of_interest, con) {
  
  today_date <- gsub("-", "_", Sys.Date())
  yesterday_date <- gsub("-", "_", Sys.Date() - 1)
  
  # Today's and yesterday's table names clearly referencing pups_of_interest ONLY
  today_table_name <- "_pups_of_interest"
  yesterday_table_name <- paste0(yesterday_date, "_pups_of_interest")
  
  # Query yesterday's pups_of_interest table if exists
  yesterday_pups <- tryCatch(
    DBI::dbGetQuery(con, glue::glue("
      SELECT url, day_count FROM `the-pet-shop-easton.pups_of_interest.{yesterday_table_name}`
    ")),
    error = function(e) tibble(url = character(), day_count = integer())
  )
  
  # Assign correct day_count values
  pups_with_day_count <- pups_of_interest %>%
    left_join(yesterday_pups, by = "url") %>%
    mutate(day_count = case_when(
      is.na(day_count) ~ 1,      # First appearance
      day_count >= 7 ~ 1,        # Reset after reaching 7
      TRUE ~ day_count + 1       # Increment consecutive days
    ))
  
  # Upload today's pups_of_interest table clearly
  upload_to_bq(pups_with_day_count, "pups_of_interest", today_table_name, con)
  
  # Only those with day_count == 1 proceed to email
  pups_with_day_count %>% filter(day_count == 1)
}

