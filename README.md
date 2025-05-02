# 🐾 The Pet Shop Easton – Automation System

This repository automates daily tracking, analysis, and notifications of available puppies at [The Pet Shop Easton](https://thepetshopinc.com/available-puppies).

## 📦 Project Structure

```
the-pet-shop-easton/
├── main.R
├── .Renviron
├── R/
│   ├── authenticate.R
│   ├── scraping.R
│   ├── cleaning.R
│   ├── bigquery_upload.R
│   ├── detect_adoptions.R
│   ├── email_content.R
│   ├── send_email.R
│   └── track_pups_of_interest.R
└── README.md
```

## 🚀 Features

- **Daily Scraping**: Fetches current puppy listings from the website.
- **Data Cleaning**: Processes and standardizes scraped data.
- **BigQuery Integration**: Uploads daily data to Google BigQuery into three distinct datasets (`available_puppies`, `pups_of_interest`, and `adopted`) with date-stamped tables.
- **Adoption Detection**: Identifies and logs adopted puppies by comparing consecutive days.
- **Interest Tracking**: Monitors specific breeds over consecutive days, assigning a `day_count`.
- **Email Notifications**: Sends alerts for new puppies of interest.

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/ChrisPachulski/the-pet-shop-easton.git
cd the-pet-shop-easton
```

### 2. Install R Dependencies

Ensure R is installed. Then install required packages:

```r
install.packages("pacman")
pacman::p_load(tidyverse, rvest, janitor, httr, readxl, bigrquery, googleAuthR, lubridate, cronR, shinyFiles, gmailr)
```

### 3. Configure Environment Variables

Create a `.Renviron` file in the root directory with:

```
BQ_SERVICE_ACCOUNT=path/to/your/service-account.json
TPSE_GMAIL_OAUTH_JSON=path/to/your/gmail-oauth.json
TPSE_GMAIL_TOKEN=path/to/your/gmail-token.rds
TPSE_ALERT_EMAIL=recipient@example.com
TPSE_ALERT_FROM=sender@example.com
```

### 4. Authenticate Services

Authentication handled via `authenticate.R` script using provided credentials.

## 🗓️ Daily Workflow

### Run `main.R`

Orchestrates:

- Authenticates services.
- Scrapes and cleans data.
- Uploads data to BigQuery datasets (`available_puppies`, `pups_of_interest`, and `adopted`).
- Detects adoptions.
- Filters puppies of interest.
- Tracks consecutive appearances and assigns `day_count`.
- Sends email alerts (`day_count == 1`).

### Automate with Cron

Set up cron to automate `main.R` daily. Example (8 AM daily):

```bash
0 8 * * * Rscript /path/to/the-pet-shop-easton/main.R
```

## 📊 BigQuery Table Structure

- **Datasets**:
  - `available_puppies`
  - `pups_of_interest`
  - `adopted`
- **Tables**:
  - `YYYY_MM_DD_puppies` (available_puppies)
  - `YYYY_MM_DD_pups_of_interest` (pups_of_interest)
  - `YYYY_MM_DD_adopted` (adopted)

## 📧 Email Notifications

- Sent via `gmailr`.
- Puppies with `day_count == 1` included.
- Emails include details and images.

## 🛠️ Contributing

Contributions welcome! Fork and submit pull requests.

## 📄 License

Licensed under MIT.

---

Contact: [Chris Pachulski](mailto:your.email@example.com).



