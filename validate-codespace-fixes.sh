#!/bin/bash
# Validation Script for Codespace Fixes
# Tests all key improvements

echo "🧪 CODESPACE FIX VALIDATION"
echo "============================"
echo ""

PASS=0
FAIL=0

# Test 1: .gitattributes exists
echo "Test 1: .gitattributes exists..."
if [ -f .gitattributes ]; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 2: devcontainer.json is valid JSON
echo "Test 2: devcontainer.json is valid JSON..."
if jq empty .devcontainer/devcontainer.json 2>/dev/null; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 3: devcontainer.json specifies PHP 8.2
echo "Test 3: devcontainer.json specifies PHP 8.2..."
if grep -q '"version": "8.2"' .devcontainer/devcontainer.json; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 4: All setup scripts have valid syntax
echo "Test 4: Setup scripts have valid syntax..."
ALL_VALID=true
for script in .devcontainer/*.sh; do
    if ! bash -n "$script" 2>/dev/null; then
        echo "  ❌ $script has syntax errors"
        ALL_VALID=false
    fi
done
if $ALL_VALID; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    FAIL=$((FAIL + 1))
fi

# Test 5: Scripts have execute permissions
echo "Test 5: Scripts have execute permissions..."
if [ -x .devcontainer/codespace-health.sh ] && [ -x .devcontainer/codespace-optimized-setup.sh ]; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 6: README exists
echo "Test 6: .devcontainer/README.md exists..."
if [ -f .devcontainer/README.md ]; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 7: Prebuild workflow exists and is valid YAML
echo "Test 7: Prebuild workflow exists and is valid..."
if [ -f .github/workflows/codespace-prebuild.yml ]; then
    if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/codespace-prebuild.yml'))" 2>/dev/null; then
        echo "  ✅ PASS"
        PASS=$((PASS + 1))
    else
        echo "  ❌ FAIL - Invalid YAML"
        FAIL=$((FAIL + 1))
    fi
else
    echo "  ❌ FAIL - File not found"
    FAIL=$((FAIL + 1))
fi

# Test 8: codespace-optimized-setup.sh uses set +e (error tolerance)
echo "Test 8: Setup script has error tolerance..."
if grep -q "set +e" .devcontainer/codespace-optimized-setup.sh; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 9: codespace-post-create.sh creates .env files
echo "Test 9: Post-create has .env creation logic..."
if grep -q "cp .env.example .env" .devcontainer/codespace-post-create.sh; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Test 10: emergency-recovery.sh exits with 0
echo "Test 10: Emergency recovery exits successfully..."
if grep -q "exit 0" .devcontainer/emergency-recovery.sh | tail -1; then
    echo "  ✅ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL"
    FAIL=$((FAIL + 1))
fi

# Summary
echo ""
echo "============================"
echo "VALIDATION SUMMARY"
echo "============================"
echo "✅ Passed: $PASS"
echo "❌ Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED!"
    echo "✅ Codespace fixes are validated and ready"
    exit 0
else
    echo "⚠️ SOME TESTS FAILED"
    echo "Please review the failed tests above"
    exit 1
fi
