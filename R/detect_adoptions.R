detect_adoptions = function(con, table_header = "puppies") {
  
  available_dataset = "available_puppies"
  adopted_dataset = "adopted"
  
  today_table = paste0(gsub('-', '_', Sys.Date()), "_", table_header)
  yesterday_table = paste0(gsub('-', '_', Sys.Date() - 1), "_", table_header)
  
  today_query = glue::glue("
    SELECT meta_date as new_date, url, name, breed, dob, gender, active, shedding, breed_known_to_be, dam_usda, breeder_type, age FROM `the-pet-shop-easton.{available_dataset}.{today_table}`
  ")
  
  yesterday_query = glue::glue("
    SELECT meta_date as origin_date, url, name, breed, dob, gender, active, shedding, breed_known_to_be, dam_usda, breeder_type, age FROM `the-pet-shop-easton.{available_dataset}.{yesterday_table}`
  ")
  
  today_df = tryCatch(
    dbSendQuery(con, statement = today_query) %>% dbFetch(n = -1),
    error = function(e) {
      stop("Today's table not found in BigQuery: ", today_table)
    }
  )
  
  yesterday_df = tryCatch(
    dbSendQuery(con, statement = yesterday_query) %>% dbFetch(n = -1),
    error = function(e) {
      stop("Yesterday's table not found in BigQuery: ", yesterday_table)
    }
  )
  
  adoption_status_df = yesterday_df %>%
    anti_join(today_df, by = c("url","name", "breed", "dob","gender","active","shedding","breed_known_to_be","dam_usda","breeder_type")) %>%
    mutate(
      adoption_date = Sys.Date(),
      status = "Adopted"
    )
  
  if (nrow(adoption_status_df) == 0) {
    message("No adoptions detected today.")
    return(NULL)
  }
  
  adopted_table_name = paste0(gsub('-', '_', Sys.Date()), "_", adopted_dataset)
  
  adopted_bq_table = bq_table(
    project = "the-pet-shop-easton",
    dataset = adopted_dataset,
    table = adopted_table_name
  )
  
  bq_table_upload(
    x = adopted_bq_table,
    values = adoption_status_df,
    fields = as_bq_fields(adoption_status_df),
    nskip = 1,
    source_format = "CSV",
    create_disposition = "CREATE_IF_NEEDED",
    write_disposition = "WRITE_TRUNCATE"
  )
  
  print(adoption_status_df)
  message("Adoption status uploaded successfully to table: ", adopted_table_name)
}

