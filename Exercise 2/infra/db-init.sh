#!/bin/bash

# Run terraform apply
echo "Running terraform apply..."
terraform apply -auto-approve

# Check if terraform apply was successful
if [ $? -eq 0 ]; then
  echo "Terraform apply was successful."

  # Execute SQL against the database
  echo "Executing SQL file against the database..."
  # Replace 'your-db-endpoint' and 'your-database-name' with your actual database endpoint and name
  # Replace 'your-username' and 'your-password' with your database username and password
  mysql -h your-db-endpoint -u your-username -p'your-password' your-database-name < your-sql-file.sql

  # Check if SQL execution was successful
  if [ $? -eq 0 ]; then
    echo "SQL file executed successfully."
  else
    echo "Error: SQL execution failed."
  fi
else
  echo "Error: Terraform apply failed. Check the Terraform logs for details."
fi
