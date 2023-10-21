#!/usr/bin/env python3
import smtplib
import os

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Email parameters
smtp_server     = "smtp.gmail.com"
smtp_port       = 25
sender_email    = "smtp@gmail.com"
env_name        = os.environ.get("RELEASE_ENVIRONMENTNAME") 
pipeline_name   = os.environ.get("RELEASE_ARTIFACTS__AZUREDATAFACTORY_REPOSITORY_NAME")
project_name    = os.environ.get("BUILD_PROJECTNAME")
pipeline_url    = os.environ.get("RELEASE_RELEASEWEBURL")
release_branch  = os.environ.get("BUILD_SOURCEBRANCHNAME")
release_commit  = os.environ.get("RELEASE_ARTIFACTS__AZUREDATAFACTORY_BUILDNUMBER")
release_creator = os.environ.get("RELEASE_DEPLOYMENT_REQUESTEDFOREMAIL")
receiver_email  = os.environ.get("RECEIVER_EMAIL")
cc_email        = os.environ.get("CC_EMAIL") 


receiver_emails = receiver_email.split(',')
cc_emails = cc_email.split(',')


# Create the email message
message = MIMEMultipart()
message['From'] = sender_email
message['To'] = ", ".join(receiver_emails)
message['Cc'] = ", ".join(cc_emails)
message['Subject'] = f'{env_name}'

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
        <li><strong>Project Name:</strong>    {project_name} </li>
        <li><strong>Pipeline Name:</strong>   {pipeline_name} </li>
        <li><strong>Release Creator:</strong> {release_creator} </li>
        <li><strong>Release version:</strong>  {release_commit} </li>
        <li><strong>Release Branch:</strong>  {release_branch} </li>
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
    server.starttls()
    # server.login(sender_email, sender_password)
    server.sendmail(sender_email, receiver_emails + cc_emails, message.as_string())
    server.quit()
    print({"statusCode": 200, "status": "Success"})
except Exception as e:
    print({"statusCode": 400, "status": str(e)})
