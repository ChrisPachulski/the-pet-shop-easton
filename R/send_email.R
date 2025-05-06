send_email_alert = function(subject, email_content) {
  
  oauth_path    <- Sys.getenv("TPSE_GMAIL_OAUTH_JSON")
  token_dir     <- Sys.getenv("TPSE_GMAIL_TOKEN_DIR")
  email_account <- Sys.getenv("TPSE_ALERT_FROM")
  to_email      <- Sys.getenv("TPSE_ALERT_EMAIL")
  
  gm_auth_configure(path = oauth_path)
  
  # Explicitly use gmailr/gargle caching correctly without causing a new auth
  options(gargle_oauth_cache = token_dir)
  
  # Explicitly load the correct token without new scopes or browser auth
  gm_auth(email = email_account)
  
  if (to_email == "" || email_account == "") {
    stop("Email configuration missing in .Renviron.")
  }
  
  # Parse multiple recipients
  to_emails_vec <- unlist(strsplit(to_email, "\\s*,\\s*"))
  
  email_message <- gm_mime() %>%
    gm_to(to_emails_vec) %>%
    gm_from(email_account) %>%
    gm_subject(subject) %>%
    gm_html_body(email_content)
  
  tryCatch({
    gm_send_message(email_message)
    base::message("✅ Email sent successfully.")
  }, error = function(e) {
    base::message("🚨 Error sending email: ", e$message)
  })
}



