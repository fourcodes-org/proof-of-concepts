# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Update the package lists and install Squid
RUN apt update && apt install -y squid

# Copy the Squid configuration file
COPY squid.conf /etc/squid/squid.conf

# Expose the Squid port
EXPOSE 3128

# Run the Squid service when the container starts
CMD ["squid", "-N"]
