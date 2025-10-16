scrape_puppy_details = safely(function(link) {
  Sys.sleep(.5)
  puppy_page = read_html(link)

  puppy_info = puppy_page %>%
    html_elements(".elementor-icon-list-text") %>%
    html_text2() %>%
    as_tibble() %>%
    filter(str_detect(value, "^(Breed|Name|DOB|Gender|Activ|Shedding|Breed known to be|Dam USDA)")) %>%
    separate(value, into = c("field", "detail"), sep = ":\\s*|\\s\\#", extra = "merge") %>%
    pivot_wider(names_from = field, values_from = detail) %>% 
    rename_with(~ .x %>%
                  str_squish() %>%
                  str_replace("Activ.*", "Active") %>%
                  str_replace("Shedd.*", "Shedding") %>%
                  str_replace("Dam.*", "Dam USDA"),
                everything())
  
  expected_cols = c("Name", "Breed", "DOB", "Gender", "Active", "Shedding", "Breed known to be", "Dam USDA")
  missing_cols = setdiff(expected_cols, names(puppy_info))
  puppy_info[missing_cols] = NA
  
  puppy_info %>%
    mutate(URL = link) %>%
    select(URL, Name, Breed, DOB, Gender, Active, Shedding, `Breed known to be`, `Dam USDA`)
})

fetch_all_puppy_details = function(main_url) {
  page = read_html(main_url)

  all_links = page %>%
    html_elements("a") %>%
    html_attr("href") %>%
    unique() %>%
    discard(is.na)

  available_puppies = all_links %>%
    as_tibble() %>%
    filter(grepl('portfolio', value)) %>%
    pull(value)

  puppy_details = map_dfr(available_puppies, ~{
    result = scrape_puppy_details(.x)
    if (!is.null(result$error)) {
      base::message("Failed to scrape: ", .x, " | Error: ", result$error)
      return(NULL)
    }
    result$result
  })

  return(puppy_details)
}

scrape_puppy_image = safely(function(link) {
  puppy_page = read_html(link)
  
  image_url = puppy_page %>%
    html_element("meta[property='og:image']") %>%
    html_attr("content")
  
  if(is.na(image_url) || image_url == "") stop("No image found at link: ", link)
  
  return(tibble(URL = link, image_url = image_url))
})
