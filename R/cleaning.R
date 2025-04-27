parse_puppy_details = function(df) {
  df %>%
    clean_names() %>%
    mutate(
      dam_usda = str_trim(dam_usda),
      breeder_type = case_when(
        str_detect(dam_usda, "^\\d{2}-[A-Z]-\\d{4,}$") ~ "USDA Formatted (Unverified)",
        str_to_upper(dam_usda) %in% c("N/A", "NA", "") ~ "NA",
        str_detect(dam_usda, "^(TPX|TS|WS|NP|DN|E|F|C|MOABA|ILABA|OKABA|MNABA|OHICA|INABA)[_A-Z0-9]+") ~ "Internal Breeder ID",
        str_detect(str_to_lower(dam_usda), "hobby") ~ "Hobby",
        TRUE ~ "Uncategorized"
      ),
      meta_date = now(tzone = "America/New_York"),
      dob = mdy(dob),
      age = time_length(interval(dob, meta_date), "month"),
      dob = if_else(age >= 12, dob %m+% years(1), dob),
      age = time_length(interval(dob, meta_date), "month"),
      gender = str_to_title(gender)
    ) %>%
    select(meta_date, everything())
}

filter_puppies_by_breed = function(df, breed_regex) {
  df %>%
    filter(str_detect(breed, regex(breed_regex, ignore_case = TRUE)))
}