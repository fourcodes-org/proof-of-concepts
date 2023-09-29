# Use the official Python image as the base image
FROM python:3.8

# ENV ENV_NAME="dev"
# ENV SMTP_SERVER='smtp.gmail.com'
# ENV SMTP_USER='demo@gmail.com'
# ENV SMTP_PASSWORD='password'
# ENV SMTP_PORT=587
# ENV CI_PIPELINE_NAME = "demo"
# ENV CI_PROJECT_NAME = "demo"
# ENV CURRENT_RELEASE_VERSION = "demo"
# ENV CI_PIPELINE_URL = "demo"
# ENV CI_COMMIT_REF_NAME = "demo"
# ENV CI_COMMIT_SHORT_SHA = "demo"
# ENV GITLAB_USER_NAME = "demo"

# Set the working directory in the container
WORKDIR /app

# Copy the Python script into the container
COPY main.py /app/

# Command to run the script when the container starts
CMD ["python", "main.py"]
