#!/bin/bash
set -e

# generate-job-summary.sh - Script to generate job summary from Dev Proxy reports
# Usage: ./generate-job-summary.sh [summary_file]

summary_file="$1"

if [ -z "$summary_file" ]; then
  echo "No summary file specified, skipping job summary generation"
  exit 0
fi

echo "Generating job summary..."

# Find all report files containing "Reporter" in the filename
report_files=($(find . -maxdepth 1 -name "*Reporter*" -type f))

if [ ${#report_files[@]} -eq 0 ]; then
  echo "No Dev Proxy reports found in working directory"
  exit 0
fi

echo "Found ${#report_files[@]} Dev Proxy report(s)"

# Start writing to the summary file
echo "# Dev Proxy Reports" >> "$summary_file"
echo "" >> "$summary_file"

# Process each report file
for report_file in "${report_files[@]}"; do
  filename=$(basename "$report_file")
  echo "Processing report: $filename"
  
  # Check if this is the only report (to add 'open' attribute)
  if [ ${#report_files[@]} -eq 1 ]; then
    echo "<details open>" >> "$summary_file"
  else
    echo "<details>" >> "$summary_file"
  fi
  
  echo "<summary>$filename</summary>" >> "$summary_file"
  echo "" >> "$summary_file"
  cat "$report_file" >> "$summary_file"
  echo "" >> "$summary_file"
  echo "</details>" >> "$summary_file"
  echo "" >> "$summary_file"
done

echo "Job summary generated successfully at: $summary_file"
