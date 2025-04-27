authenticate_bq_and_google = function() {
  service_account_file = Sys.getenv("BQ_SERVICE_ACCOUNT")
  if (service_account_file == "") {
    stop("Service account file path not set. Please set BQ_SERVICE_ACCOUNT in your .Renviron file.")
  }
  gar_auth_service(service_account_file)
  bq_auth(path = service_account_file)

  con = dbConnect(
    bigrquery::bigquery(),
    project = "the-pet-shop-easton",
    dataset = "available_puppies",
    billing = "the-pet-shop-easton"
  )
  options(scipen = 20)
  return(con)
}

