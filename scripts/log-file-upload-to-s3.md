
# upload the log file to s3 use aws cli

```bash
#!/bin/bash

# Configuration
LOCAL_DIRECTORY="/var/log"
S3_BUCKET_NAME="your-s3-bucket-name"
FILE_PATTERN="openvpnas.log.*.gz"

# Check if the AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI could not be found, please install it first."
    exit 1
fi

# Function to upload a file to S3
upload_to_s3() {
    local file_path="$1"
    local s3_path="$2"
    
    if aws s3 cp "$file_path" "s3://$S3_BUCKET_NAME/$s3_path"; then
        echo "Uploaded $file_path to s3://$S3_BUCKET_NAME/$s3_path"
        return 0
    else
        echo "Failed to upload $file_path"
        return 1
    fi
}

# Function to delete a local file
delete_local_file() {
    local file_path="$1"
    
    if rm "$file_path"; then
        echo "Deleted local file $file_path"
        return 0
    else
        echo "Failed to delete local file $file_path"
        return 1
    fi
}

# Main script
find "$LOCAL_DIRECTORY" -type f -name "$FILE_PATTERN" | while read -r file; do
    file_name=$(basename "$file")
    # Extract date from file name
    date_str=${file_name#"openvpnas.log."}
    date_str=${date_str%%.*}
    # Create S3 folder structure based on date
    s3_folder=$(date -d "$date_str" +"%Y/%m/%d")
    s3_path="$s3_folder/$file_name"
    
    if upload_to_s3 "$file" "$s3_path"; then
        delete_local_file "$file"
    fi
done

echo "File transfer and deletion process completed."

```
