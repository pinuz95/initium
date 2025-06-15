#!/bin/bash

# Project-specific utilities for initium

# Quick memory review
memory() {
    echo "=== Memory Bank Status ==="
    for file in memory-bank/*.txt; do
        echo "📄 $(basename $file):"
        head -3 "$file" | sed 's/^/  /'
        echo
    done
}

# Update this-week.txt
week() {
    code memory-bank/this-week.txt
}

# Quick commit with memory update
commit() {
    local msg="${1:-Update project}"
    echo "$(date): $msg" >> memory-bank/this-week.txt
    git add .
    git commit -m "$msg"
}

# Run tests (to be customized per project)
test() {
    echo "Running tests for initium..."
    # Add test commands here
}

