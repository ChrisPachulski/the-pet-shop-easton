upload_to_bq = function(df, table_header, con) {
  table_name = paste0(gsub('-','_',(Sys.Date()-1)),"_",table_header)
  mybq = bq_table(
    project = "the-pet-shop-easton",
    dataset = "available_puppies",
    table = table_name
  )

  bq_table_upload(
    x = mybq,
    values = df,
    fields = as_bq_fields(df),
    nskip = 1,
    source_format = "CSV",
    create_disposition = "CREATE_IF_NEEDED",
    write_disposition = "WRITE_TRUNCATE"
  )

  message("BQ Available Puppies Upload Successful!")
}

