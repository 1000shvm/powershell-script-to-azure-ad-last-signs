# 🔐 Microsoft Graph User Sign-In Activity Export Script

This PowerShell script automates the collection of **user sign-in activity** from Microsoft Azure AD using the **Microsoft Graph API**.  
It helps administrators track when users last signed in, which is useful for **auditing, compliance, inactive account cleanup, and security monitoring**.  

---

## ✨ Features
✅ Connects to Microsoft Graph via **secure app authentication** (client credentials).  
✅ Reads a list of **user UPNs (email addresses)** from a CSV file.  
✅ Retrieves **sign-in activity details** for each user:
- `Display Name`
- `User Principal Name (UPN)`
- `Last Interactive Sign-In DateTime`
- `Last Non-Interactive Sign-In DateTime`

✅ Handles **pagination** automatically (beyond 999 users).  
✅ Exports results into a structured **CSV report** for easy review.  
✅ Can be customized for reporting inactive accounts, MFA adoption, or security audits.  

---

## 🛠️ Prerequisites

### 1. App Registration in Microsoft Azure AD
You must register an application in your tenant to use client credentials:

1. Go to **[Entra Admin Center](https://portal.azure.com/)**.  
2. Navigate to:  
   **Identity → Applications → App registrations → New registration**  
3. Record the following:
   - **Tenant ID**
   - **Client ID**
   - **Client Secret** (create under Certificates & Secrets)  
4. Assign Microsoft Graph **Application API permissions**:
   - `AuditLog.Read.All`
   - `Directory.Read.All`
   - `User.Read.All`
5. **Grant admin consent** to finalize permissions.

---

### 2. Environment Requirements
- **PowerShell 5.1+** or **PowerShell 7+**
- **Internet access** (to reach Microsoft Graph API)
- Proper **file paths** for CSV input/output

---

### 3. Input File (`TW.csv`)
A plain CSV file containing **userPrincipalNames (UPNs)**, one per line.

Example:
```csv
user1@domain.com
user2@domain.com
user3@domain.com
```

---

## 📜 Script Workflow

### 🔑 1. Authentication
The function `Auth()` requests an **OAuth2 token** from Microsoft Identity Platform:

```powershell
$ReqTokenBody = @{
  Grant_Type    = 'client_credentials'
  client_id     = $ClientId
  client_Secret = $Secretid
  Scope         = 'https://graph.microsoft.com/.default'
}
```

Returns:  
- `access_token` → Used in all API requests.

---

### 🌐 2. Query Microsoft Graph
Calls the `/beta/users` endpoint with selected fields:

```
https://graph.microsoft.com/beta/users?$top=999&$select=displayName,userPrincipalName,signInActivity
```

- Retrieves **999 users per page**.
- Supports **pagination** with `@odata.nextLink`.

---

### 📊 3. Filtering
Matches only the UPNs found in your `TW.csv`:

```powershell
$r.value | Where-Object {($_.userPrincipalName -in $user)}
```

---

### 📂 4. Export Results
Exports results to `TW2.csv` with columns:
- `DisplayName`
- `UserPrincipalName`
- `LastSignInDateTime`
- `LastNonInteractiveSignInDateTime`

Example output:

| DisplayName | UserPrincipalName    | LastSignInDateTime     | LastNonInteractiveSignInDateTime |
|-------------|----------------------|------------------------|----------------------------------|
| Alice Wong  | alice@domain.com     | 2025-08-01T13:45:22Z   | 2025-08-01T08:12:03Z             |
| John Smith  | john@domain.com      | 2025-07-28T17:10:11Z   | 2025-07-28T09:00:45Z             |

---

## ▶️ Usage

1. Update script variables with your credentials:
   ```powershell
   $TenantId = '<Your Tenant ID>'
   $ClientId = '<Your Client ID>'
   $Secretid = '<Your Client Secret>'
   ```

2. Place `TW.csv` in the path defined in the script:
   ```
   C:\Users\<username>\Desktop\TW.csv
   ```

3. Run the script in PowerShell:
   ```powershell
   .\Export-UserSignIns.ps1
   ```

4. Review the output in:
   ```
   C:\Users\<username>\Desktop\TW2.csv
   ```

---

## 🧰 Troubleshooting

| Issue | Possible Cause | Fix |
|-------|----------------|-----|
| **Access Denied / Insufficient Permissions** | App registration missing API permissions | Ensure `AuditLog.Read.All`, `Directory.Read.All`, and `User.Read.All` are added and admin consent is granted |
| **Empty CSV Output** | No UPNs in `TW.csv` match tenant users | Check UPNs in `TW.csv` for typos |
| **Token Request Fails** | Invalid Tenant ID, Client ID, or Secret | Verify values copied from App Registration |
| **File Path Error** | Hardcoded paths don’t exist | Update paths in the script (`TW.csv`, `TW2.csv`) |

---

## 🔒 Security Notes
- **Never commit Tenant ID, Client ID, or Client Secret to GitHub**.  
- Store secrets securely in:
  - Azure Key Vault
  - Environment Variables
  - Encrypted password vaults
- Rotate client secrets regularly.

---

## 📂 Repository Structure
```
/Export-UserSignIns
│── Export-UserSignIns.ps1   # Main script
│── README.md                # Documentation
```


---

## 📜 License
This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.
