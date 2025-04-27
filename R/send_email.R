send_email_alert = function(subject, email_content) {
  
  library(gmailr)
  library(stringr)
  
  oauth_path = Sys.getenv("TPSE_GMAIL_OAUTH_JSON")
  token_path = Sys.getenv("TPSE_GMAIL_TOKEN")
  to_email = Sys.getenv("TPSE_ALERT_EMAIL")
  from_email = Sys.getenv("TPSE_ALERT_FROM")
  
  if (oauth_path == "" | token_path == "" | to_email == "" | from_email == "") {
    stop("OAuth or email configuration missing in .Renviron.")
  }
  
  gm_auth_configure(path = oauth_path)
  gm_auth(token = gm_token_read(token_path))
  
  # Split the comma-separated string into a vector of emails
  to_emails_vec = str_split(to_email, "\\s*,\\s*")[[1]]
  
  email_message = gm_mime() %>%
    gm_to(to_emails_vec) %>%
    gm_from(from_email) %>%
    gm_subject(subject) %>%
    gm_html_body(email_content)
  
  tryCatch({
    gm_send_message(email_message)
    base::message("✅ Email sent successfully.")
  }, error = function(e) {
    base::message("🚨 Error sending email: ", e$message)
  })
}

