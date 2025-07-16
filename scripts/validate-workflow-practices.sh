#!/bin/bash

# Validate workflow best practices
# This script checks that:
# 1. Only workflows in .github/workflows/ use local actions (./action-name)
# 2. Only workflows in .github/workflows/ use actions/checkout

set -e

echo "🔍 Validating workflow best practices..."

# Find all YAML files that could be workflows
workflow_files=$(find . -name ".git" -prune -o -name "*.yml" -print -o -name "*.yaml" -print)

violations=0
allowed_workflows_dir="./.github/workflows/"
local_actions=("./install" "./setup" "./start" "./stop" "./record-start" "./record-stop" "./chromium-cert")

# Function to check if a file is a GitHub Actions workflow
is_workflow_file() {
    local file="$1"
    # Check if file contains workflow indicators
    if grep -q "^on:" "$file" || grep -q "^jobs:" "$file"; then
        return 0
    fi
    return 1
}

# Function to check if file is in allowed directory
is_in_allowed_dir() {
    local file="$1"
    if [[ "$file" == $allowed_workflows_dir* ]]; then
        return 0
    fi
    return 1
}

# Function to check for local action usage
check_local_actions() {
    local file="$1"
    local found_violations=0
    
    for action in "${local_actions[@]}"; do
        if grep -q "uses: $action" "$file"; then
            echo "❌ VIOLATION: $file uses local action '$action' but is not in $allowed_workflows_dir"
            found_violations=1
        fi
    done
    
    return $found_violations
}

# Function to check for actions/checkout usage
check_checkout_usage() {
    local file="$1"
    
    if grep -q "uses: actions/checkout" "$file"; then
        echo "❌ VIOLATION: $file uses 'actions/checkout' but is not in $allowed_workflows_dir"
        return 1
    fi
    
    return 0
}

echo "📋 Checking workflow files..."

for file in $workflow_files; do
    # Skip if not a workflow file
    if ! is_workflow_file "$file"; then
        continue
    fi
    
    echo "🔍 Checking workflow: $file"
    
    # If in allowed directory, skip validation
    if is_in_allowed_dir "$file"; then
        echo "✅ $file is in allowed directory"
        continue
    fi
    
    echo "⚠️  $file is NOT in allowed directory - checking for violations..."
    
    # Check for violations
    if ! check_local_actions "$file"; then
        violations=$((violations + 1))
    fi
    
    if ! check_checkout_usage "$file"; then
        violations=$((violations + 1))
    fi
done

echo ""
if [ $violations -eq 0 ]; then
    echo "✅ All workflow files follow best practices!"
    echo "📋 Summary:"
    echo "   - Only workflows in $allowed_workflows_dir use local actions (./action-name)"
    echo "   - Only workflows in $allowed_workflows_dir use actions/checkout"
else
    echo "❌ Found $violations violation(s) of workflow best practices!"
    echo ""
    echo "📋 Rules:"
    echo "   - Only workflows in $allowed_workflows_dir should use local actions (./action-name)"
    echo "   - Only workflows in $allowed_workflows_dir should use actions/checkout"
    echo ""
    echo "💡 To fix violations:"
    echo "   - Move workflows to $allowed_workflows_dir, or"
    echo "   - Use published actions (dev-proxy-tools/actions/action-name@version) instead of local actions"
    echo "   - Remove actions/checkout usage from workflows outside $allowed_workflows_dir"
    exit 1
fi