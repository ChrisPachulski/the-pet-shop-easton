# 🐾 The Pet Shop Easton: Puppy Emails and Sales Tracking

This repository contains R scripts tailored specifically to support our personal project of tracking available puppies at The Pet Shop in Easton, PA. The project helps ensure we never miss another chance at adopting our favorite breeds—especially after that near miss when I almost convinced my wife we needed another dog, only to find the adorable little pup already spoken for. A Sunday well-spent to avoid missing out on future dachshund or basset hound opportunities!

## 🎯 Goals

- **Puppy Notifications:** Automatically check for puppies matching our preferences, retrieve their images and details, and send timely notifications via email.
- **Sales Tracking:** Regularly record and store puppy availability data, enabling analysis of sales trends and adoption patterns over time.

## 🔧 How It Works

The project workflow involves:

1. **Web Scraping:** Extract current puppy details and images directly from [The Pet Shop's website](https://thepetshopinc.com/available-puppies).
2. **Image Analysis:** Leverage OpenAI's GPT-4 Vision API to generate accurate, breed-verified descriptions based on puppy images.
3. **Email Notifications:** Format these details clearly and email them to us immediately when matching puppies become available.
4. **Data Logging:** Store daily puppy availability data in Google BigQuery for historical tracking and analysis.

## 📌 Project Structure

- `scraping.R`: Extracts puppy details and images from the website.
- `generate_puppy_story_with_image.R`: Uses GPT-4 to provide descriptive summaries based on images.
- `send_email.R`: Manages sending of email notifications.
- `upload_to_bq.R`: Uploads the scraped data to BigQuery for long-term storage and analysis.

## 🔑 Environment Variables

Ensure these are set in `.Renviron`:

- `GPT_API_KEY`: Your OpenAI GPT-4 API key.
- `TPSE_GMAIL_OAUTH_JSON`: Path to Gmail OAuth JSON.
- `TPSE_GMAIL_TOKEN`: Path to Gmail token.
- `TPSE_ALERT_EMAIL`: Comma-separated emails for notifications.
- `TPSE_ALERT_FROM`: Email address for sending notifications.

## 📈 Analytics

Data collected allows us to:

- Understand adoption cycles and trends.
- Monitor breed popularity and turnover rates.
- Assess overall shop performance and sales patterns over time.

---

Built with ❤️ in R to ensure we never again miss the perfect pup.



