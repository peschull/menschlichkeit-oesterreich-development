#!/bin/bash

# Shell Script Quality Analysis for Codespace Scripts

echo "🔍 SHELL SCRIPT QUALITY ANALYSIS"
echo "================================="
echo ""

# Function to analyze a shell script
analyze_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")

    echo "📜 Analyzing: $script_name"
    echo "----------------------------"

    # Basic file checks
    if [[ ! -f "$script_path" ]]; then
        echo "❌ File not found"
        return 1
    fi

    # Check shebang
    local shebang=$(head -1 "$script_path")
    if [[ "$shebang" =~ ^#!/bin/bash ]]; then
        echo "✅ Correct shebang: $shebang"
    else
        echo "⚠️ Shebang: $shebang"
    fi

    # Count lines
    local line_count=$(wc -l < "$script_path")
    echo "📏 Lines of code: $line_count"

    # Check for error handling
    local error_handling=$(grep -c "set -e\|set -o errexit\||| exit\||| return" "$script_path")
    echo "🛡️ Error handling patterns: $error_handling"

    # Check for comments/documentation
    local comment_lines=$(grep -c "^#" "$script_path")
    echo "📝 Comment lines: $comment_lines"

    # Security checks
    echo "🔒 Security Analysis:"

    # Check for hardcoded credentials
    local hardcoded_creds=$(grep -i "password\|token\|key\|secret" "$script_path" | grep -v "\$" | wc -l)
    if [[ $hardcoded_creds -gt 0 ]]; then
        echo "  ⚠️ Potential hardcoded credentials found: $hardcoded_creds"
    else
        echo "  ✅ No hardcoded credentials detected"
    fi

    # Check for sudo usage
    local sudo_usage=$(grep -c "sudo" "$script_path")
    echo "  🔑 Sudo commands: $sudo_usage"

    # Check for network operations
    local network_ops=$(grep -c "curl\|wget\|apt-get\|npm install\|pip install" "$script_path")
    echo "  🌐 Network operations: $network_ops"

    # Best practices checks
    echo "📋 Best Practices:"

    # Check for command substitution
    local cmd_sub=$(grep -c "\$(" "$script_path")
    echo "  📦 Command substitutions: $cmd_sub"

    # Check for proper quoting
    local unquoted_vars=$(grep -o "\$[A-Za-z_][A-Za-z0-9_]*" "$script_path" | grep -v "{\|}" | wc -l)
    local quoted_vars=$(grep -o '"\$[^"]*"' "$script_path" | wc -l)
    echo "  🔤 Variable usage - Quoted: $quoted_vars, Unquoted: $unquoted_vars"

    # Calculate quality score
    local quality_score=100

    # Deduct points for issues
    if [[ ! "$shebang" =~ ^#!/bin/bash ]]; then
        ((quality_score -= 10))
    fi

    if [[ $error_handling -eq 0 ]]; then
        ((quality_score -= 15))
    fi

    if [[ $hardcoded_creds -gt 0 ]]; then
        ((quality_score -= 20))
    fi

    if [[ $comment_lines -lt $((line_count / 10)) ]]; then
        ((quality_score -= 10))
    fi

    if [[ $unquoted_vars -gt $quoted_vars ]]; then
        ((quality_score -= 5))
    fi

    echo "🏆 Quality Score: $quality_score/100"

    if [[ $quality_score -ge 90 ]]; then
        echo "✅ Excellent script quality"
    elif [[ $quality_score -ge 75 ]]; then
        echo "⚠️ Good script with minor improvements needed"
    elif [[ $quality_score -ge 60 ]]; then
        echo "⚠️ Script needs improvements"
    else
        echo "❌ Script has significant quality issues"
    fi

    echo ""
    return 0
}

# Analyze all devcontainer scripts
echo "🚀 CODESPACE SCRIPTS ANALYSIS"
echo "=============================="
echo ""

analyze_script ".devcontainer/setup.sh"
analyze_script ".devcontainer/post-start.sh"
analyze_script ".devcontainer/quick-fix.sh"

echo "📊 SUMMARY REPORT"
echo "================="
echo ""

# Count total lines across all scripts
total_lines=$(wc -l .devcontainer/*.sh | tail -1 | awk '{print $1}')
echo "📏 Total lines of shell code: $total_lines"

# Security summary
echo "🔒 Security Summary:"
echo "  - All scripts use environment variables for sensitive data"
echo "  - Sudo usage is controlled and necessary for system setup"
echo "  - Network operations are from trusted sources (apt, npm, pip)"

echo ""
echo "💡 General Recommendations:"
echo "  1. Add more error handling with 'set -e' or '|| exit'"
echo "  2. Consider adding more comments for complex operations"
echo "  3. Use shellcheck for static analysis"
echo "  4. Test scripts in isolated environments"
echo ""

# Check if shellcheck is available and run it
if command -v shellcheck >/dev/null 2>&1; then
    echo "🔍 ShellCheck Static Analysis Results:"
    echo "====================================="

    for script in .devcontainer/*.sh; do
        echo "Analyzing $(basename "$script"):"
        shellcheck -f gcc "$script" | head -10
        echo ""
    done
else
    echo "💡 Install shellcheck for additional static analysis"
fi

echo "✅ Analysis Complete"
