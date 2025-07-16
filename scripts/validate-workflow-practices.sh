#!/bin/bash

# Validate workflow best practices
# This script checks that:
# 1. Only workflows in .github/workflows/ use local actions (./action-name)
# 2. Only workflows in .github/workflows/ use actions/checkout
# 
# It uses a baseline file to grandfather existing violations

set -e

echo "🔍 Validating workflow best practices..."

# Find all YAML files that could be workflows
workflow_files=$(find . -name ".git" -prune -o -name "*.yml" -print -o -name "*.yaml" -print)

violations=0
new_violations=0
allowed_workflows_dir="./.github/workflows/"
local_actions=("./install" "./setup" "./start" "./stop" "./record-start" "./record-stop" "./chromium-cert")
baseline_file="./scripts/workflow-practices-baseline.txt"

# Load baseline violations
declare -A baseline_violations
if [[ -f "$baseline_file" ]]; then
    echo "📋 Loading baseline violations from $baseline_file"
    while IFS=':' read -r file_path violation_type; do
        # Skip comments and empty lines
        if [[ "$file_path" =~ ^[[:space:]]*# ]] || [[ -z "$file_path" ]]; then
            continue
        fi
        # Trim whitespace
        file_path=$(echo "$file_path" | xargs)
        violation_type=$(echo "$violation_type" | xargs)
        
        baseline_violations["$file_path:$violation_type"]=1
    done < "$baseline_file"
fi

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

# Function to check if violation is in baseline
is_baseline_violation() {
    local file="$1"
    local violation_type="$2"
    local key="$file:$violation_type"
    
    if [[ -n "${baseline_violations[$key]}" ]]; then
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
            if is_baseline_violation "$file" "local_action"; then
                echo "⚠️  BASELINE: $file uses local action '$action' (grandfathered)"
            else
                echo "❌ NEW VIOLATION: $file uses local action '$action' but is not in $allowed_workflows_dir"
                new_violations=$((new_violations + 1))
            fi
            found_violations=1
        fi
    done
    
    return $found_violations
}

# Function to check for actions/checkout usage
check_checkout_usage() {
    local file="$1"
    
    if grep -q "uses: actions/checkout" "$file"; then
        if is_baseline_violation "$file" "checkout"; then
            echo "⚠️  BASELINE: $file uses 'actions/checkout' (grandfathered)"
        else
            echo "❌ NEW VIOLATION: $file uses 'actions/checkout' but is not in $allowed_workflows_dir"
            new_violations=$((new_violations + 1))
        fi
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
if [ $new_violations -eq 0 ]; then
    echo "✅ No new violations found! All workflow files follow best practices."
    if [ $violations -gt 0 ]; then
        echo "📋 Found $violations grandfathered violation(s) from baseline"
    fi
    echo "📋 Summary:"
    echo "   - Only workflows in $allowed_workflows_dir use local actions (./action-name)"
    echo "   - Only workflows in $allowed_workflows_dir use actions/checkout"
else
    echo "❌ Found $new_violations NEW violation(s) of workflow best practices!"
    if [ $violations -gt $new_violations ]; then
        echo "📋 Found $((violations - new_violations)) grandfathered violation(s) from baseline"
    fi
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