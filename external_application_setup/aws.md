# AWS IAM Setup for OWID CSV Ingestion and Snowflake Access

> **Overview:**
>
> 1. **CI Ingest Path** — an IAM User (`dbt-ingest-user`) with minimal S3 permissions ingests the OWID CSV via a GitHub Action.
> 2. **Snowflake Read Path** — an IAM Role (`SnowflakeCovidDataReader`) assumed by Snowflake to securely *read* the ingested CSV via a Storage Integration.
> 3. **Separation of Concerns** — no shared credentials, least-privilege for each identity, and all policies are customer-managed for auditability.

This document outlines the AWS identities, policies, and roles required to:

1. Upload (ingest) the OWID COVID data CSV via GitHub Actions.
2. Allow Snowflake to securely read that CSV via a Storage Integration.

---

## 1. IAM User: `dbt-ingest-user`

* **Purpose**: Authenticates your GitHub Action runner to upload the CSV to S3.
* **Credentials**: Long-term access key & secret, stored in GitHub Secrets.

### Attached Policy: `dbt-ingest-s3-policy`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::<your-bucket-name>",
        "arn:aws:s3:::<your-bucket-name>/owid/*"
      ]
    }
  ]
}
```

* **Why**: Grants only the minimum permissions needed for CI to manage the CSV in the `owid/` prefix.

---

## 2. IAM Role: `SnowflakeCovidDataReader`

* **Purpose**: Assumed by Snowflake (via STS) to **read** the CSV files.
* **No long-term keys**: Access is via assume-role, using an ExternalId for security.

### Trust Policy (who can assume)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<your-Snowflake-account-id>:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "<your-Snowflake-external-id>"
        }
      }
    }
  ]
}
```

### Permissions Policy: `SnowflakeCovidDataReadPolicy`

````json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::<your-bucket-name>",
        "arn:aws:s3:::<your-bucket-name>/owid/*"
      ]
    }
  ]
}
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::ramsaier-covid-data-us-east",
        "arn:aws:s3:::ramsaier-covid-data-us-east/owid/*"
      ]
    }
  ]
}
````

* **Why**: Restricts Snowflake to only list and read the CSV data under `owid/`, with no write or delete access.

---

## Folder Layout Example

```
aws/
├── iam/
│   ├── users/
│   │   └── dbt-ingest-user.json            # IAM User definition
│   └── roles/
│       └── SnowflakeCovidDataReader.json   # IAM Role definition
├── policies/
│   ├── dbt-ingest-s3-policy.json
│   └── SnowflakeCovidDataReadPolicy.json
└── README.md                               # This document
```

---

### Key Benefits

* **Least privilege**: CI user can only write; Snowflake role can only read.
* **No leaked keys**: Snowflake uses assume-role; only GitHub stores long-term keys.
* **Auditable**: All permissions are in customer-managed policies for easy review.

---

*Eric Ramsaier*
*2025-05-15*
