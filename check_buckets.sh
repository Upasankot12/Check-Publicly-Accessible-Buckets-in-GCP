#!/bin/bash

# List of GCP project IDs
PROJECTS=("hfc-housing-finance")
OUTPUT_CSV="public_buckets.csv"

# Add CSV header
echo "Project,Bucket,Public Access" > $OUTPUT_CSV

# Function to check public access
check_public_access() {
    BUCKET=$1
    PROJECT=$2
    if gsutil iam get gs://$BUCKET 2>/dev/null | grep -q 'allUsers\|allAuthenticatedUsers'; then
        echo "$PROJECT,gs://$BUCKET,Public" >> $OUTPUT_CSV
    else
        echo "$PROJECT,gs://$BUCKET,Private" >> $OUTPUT_CSV
    fi
}

# Iterate through each project
for PROJECT in "${PROJECTS[@]}"; do
    gcloud config set project $PROJECT
    gsutil ls | while read BUCKET; do
        check_public_access "$(basename $BUCKET)" $PROJECT
    done
done

echo "Results saved to $OUTPUT_CSV"
