"# Mi Repositorio"

## Configuration

This project uses a `config.json` file to store Google Sheets API credentials and the Spreadsheet ID. This file is intentionally not tracked by Git and you will need to create it yourself.

### Creating `config.json`

1.  Create a file named `config.json` in the root directory of the project.
2.  Paste the following structure into the file:

    ```json
    {
      "type": "service_account",
      "project_id": "YOUR_PROJECT_ID",
      "private_key_id": "YOUR_PRIVATE_KEY_ID",
      "private_key": "YOUR_PRIVATE_KEY_PEM_FORMAT",
      "client_email": "YOUR_CLIENT_EMAIL",
      "client_id": "YOUR_CLIENT_ID",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "YOUR_CLIENT_X509_CERT_URL",
      "universe_domain": "googleapis.com",
      "spreadsheet_id": "YOUR_SPREADSHEET_ID"
    }
    ```

### Obtaining Credentials

*   **Google Service Account Credentials (`type`, `project_id`, etc.):**
    1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
    2.  Select your project or create a new one.
    3.  Navigate to "IAM & Admin" > "Service Accounts".
    4.  Create a new service account or use an existing one.
    5.  Grant this service account appropriate permissions to access Google Sheets (e.g., "Editor" role on the target Sheet, or a more restrictive role if applicable).
    6.  Create a key for the service account (JSON type). Download the JSON key file.
    7.  The contents of this downloaded JSON file correspond to the fields in `config.json`.
        *   `private_key`: Ensure this is the full private key string, often including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`. It might require replacing newline characters `\n` with actual newlines if you are copying it manually. It's generally safer to copy-paste directly from the downloaded JSON file.
*   **Spreadsheet ID (`spreadsheet_id`):**
    1.  Open your Google Sheet in the browser.
    2.  The URL will look something like: `https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit#gid=SHEET_GID`
    3.  Copy the `SPREADSHEET_ID` part from the URL.

**Important:** Ensure the `config.json` file is never committed to your version control system (Git). The provided `.gitignore` file should already prevent this.
