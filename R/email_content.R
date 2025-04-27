pacman::p_load(httr, jsonlite, glue, dplyr, lubridate, purrr)

generate_puppy_story_with_image = function(pups_df) {
  
  api_key = Sys.getenv("GPT_API_KEY")
  if(api_key == "") stop("GPT_API_KEY not set in .Renviron")
  
  openai_url = "https://api.openai.com/v1/chat/completions"
  
  # Scrape puppy images
  pup_images = pups_df %>% rowwise() %>% mutate(
    image_url = scrape_puppy_image(url)$result$image_url
  ) %>% ungroup()
  
  # Group puppy details
  puppy_details_df = pup_images %>% 
    mutate(shop_link = paste0("<a href='", url, "'>View Puppy</a>")) %>%
    select(name, breed, dob, gender, active, shedding, age, image_url, shop_link)
  
  emails = list()
  
  for(i in 1:nrow(puppy_details_df)){
    pup = puppy_details_df[i,]
    
    # GPT Vision API call to explicitly ignore background and verify breed visually
    messages = list(
      list(role = "system", content = glue("Provide a factual description of the puppy based solely on the image provided, explicitly ignoring the background, in an endearing tone highlighting their attributes. Explicitly state the breed you see and confirm whether it matches the provided breed '{pup$breed}'.")),
      list(role = "user", content = list(
        list(type = "image_url", image_url = list(url = pup$image_url))
      ))
    )
    
    response = POST(
      openai_url,
      add_headers(Authorization = paste("Bearer", api_key)),
      content_type_json(),
      encode = "json",
      body = list(
        model = "gpt-4o",
        messages = messages,
        temperature = 0.0,
        max_tokens = 150
      )
    )
    
    stop_for_status(response)
    image_description = content(response, "parsed")$choices[[1]]$message$content
    
    email_body = glue(
      "<html><body>",
      "<p><strong>Name:</strong> {pup$name}</p>",
      "<p><strong>Breed:</strong> {pup$breed}</p>",
      "<p><strong>Date of Birth:</strong> {format(pup$dob, '%B %d, %Y')}</p>",
      "<p><strong>Gender:</strong> {pup$gender}</p>",
      "<p><strong>Age:</strong> {round(pup$age, 1)} months</p>",
      "<p><strong>Active Level:</strong> {pup$active}</p>",
      "<p><strong>Shedding Level:</strong> {pup$shedding}</p>",
      "<p><strong>Description based on image (Breed verification included):</strong> {image_description}</p>",
      "<img src='{pup$image_url}' alt='Puppy Image' style='max-width:600px;height:auto;'/>",
      "<p>{pup$shop_link}</p>",
      "</body></html>"
    )
    
    emails[[i]] = email_body
  }
  
  # Combine all emails clearly
  full_email_body = paste(emails, collapse = "<hr>")
  
  return(full_email_body)
}

# Final wrapper to generate email content
create_email_content = function(filtered_pups_df, breed_regex) {
  pup_count = nrow(filtered_pups_df)
  
  if (pup_count == 0) {
    return(glue("No puppies matching breed regex '{breed_regex}' found today."))
  }
  
  story = generate_puppy_story_with_image(filtered_pups_df)
  
  email_body = glue(
    "<html><body>",
    "<p>🐾 <strong>Adoption Alert</strong> 🐾</p>",
    "{story}",
    "<p>🔗 <a href='https://thepetshopinc.com/available-puppies'>Meet All Available Puppies</a></p>",
    "<p>Adoption Date: {Sys.Date()}</p>",
    "</body></html>"
  )
  
  return(email_body)
}
