#!/usr/bin/env python3

import smtplib
import os

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Email parameters
env_name        = os.environ.get("ENV_NAME") 
smtp_server     = os.environ.get("SMTP_SERVER")
smtp_port       = os.environ.get("SMTP_PORT")
sender_email    = os.environ.get("SMTP_USER")
sender_password = os.environ.get("SMTP_PASSWORD")
pipeline_name   = os.environ.get("CI_PIPELINE_NAME")
project_name    = os.environ.get("CI_PROJECT_NAME")
release_version = os.environ.get("CURRENT_RELEASE_VERSION")
pipeline_url    = os.environ.get("CI_PIPELINE_URL")
release_branch  = os.environ.get("CI_COMMIT_REF_NAME")
release_commit  = os.environ.get("CI_COMMIT_SHORT_SHA")
release_creator = os.environ.get("GITLAB_USER_NAME")

# Email lists
receiver_emails = ['jinojoe@mail.com']
cc_emails       = ['jjino@mail.com']

# Combine receiver and cc emails
all_recipients = receiver_emails + cc_emails

# Create the email message
message = MIMEMultipart()
message['From'] = sender_email
message['To'] = ', '.join(receiver_emails)
message['Cc'] = ', '.join(cc_emails)
message['Subject'] = f'{env_name} Deployment Approval'

# HTML content for the email
html_content = f"""
<!DOCTYPE html>
<html>
<head>
  <title>Deployment Approval Notification</title>
  <style>
    body {{
      font-family: Arial, sans-serif;
      padding: 20px;
    }}
    .container {{
      max-width: 600px;
      margin: 0 auto;
    }}
    .notification {{
      padding: 20px;
      background-color: #f8f8f8;
      border: 1px solid #ccc;
      border-radius: 5px;
      margin-bottom: 20px;
    }}
    .button-container {{
      text-align: center;
      margin-top: 10px;
    }}
    .approve-button, .reject-button {{
      padding: 10px 20px;
      margin: 5px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      text-decoration: none;
      display: inline-block;
      color: white;
      font-weight: bold;
    }}
    .approve-button {{
      background-color: #4CAF50;
      margin-right: 10px;
    }}
    .reject-button {{
      background-color: #f44336;
    }}
  </style>
</head>
<body>
  <div class="container">
    <div class="notification">
      <h2>Deployment Approval Request</h2>
      <p>A deployment request is awaiting your approval. Please review the details and take appropriate action.</p>
      <p><strong>Deployment Details:</strong></p>
      <ul>
        <li><strong>Project Name:</strong> {project_name} </li>
        <li><strong>Pipeline Name:</strong> {pipeline_name} </li>
        <li><strong>Release Creator:</strong> {release_creator} </li>
        <li><strong>Release Version:</strong> {release_version} </li>
        <li><strong>Release Commit:</strong> {release_commit} </li>
        <li><strong>Release Branch:</strong> {release_branch} </li>
      </ul>
      <div class="button-container">        
        <a href="{pipeline_url}" class="approve-button">Approve</a>
        <a href="{pipeline_url}" class="reject-button">Reject</a></div>
    </div>
  </div>
</body>
</html>
"""

html_part = MIMEText(html_content, 'html')
message.attach(html_part)

# Connect to the SMTP server and send the email
try:
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()  # If using TLS
    server.login(sender_email, sender_password)
    server.sendmail(sender_email, all_recipients, message.as_string())
    server.quit()
    print("Email sent successfully")
except Exception as e:
    print(f"Error: {str(e)}")
