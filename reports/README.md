# Sixam Mart Unified Reporting & Test Standard

> **Notice for Developers & Autonomous AI Agents:**  
> This directory (`/reports`) is the official, unified repository for test execution logs, production bug audits, and system health reports. All human developers and AI pair-programmers MUST follow the standards described here to ensure deterministic, reproducible, and actionable reports.

---

## 📌 Core Philosophy: Zero-Deception Testing

1. **No "Happy-Path Only" Tests:**  
   Every feature must be tested against edge cases, null boundaries, invalid backend payloads, and concurrent operations.
2. **Never Remove or Bypass Failing Tests:**  
   When a test exposes a real bug or crash, it MUST remain in the test suite so it is permanently tracked until the production code is properly refactored.
3. **Dual Verification Requirement:**  
   The suite must contain both:
   - **Crash Reproductions:** Direct calls against production classes that trigger crashes when unhandled.
   - **Guaranteed Invariants:** Strict assertions ensuring that working calculations and flows do not break during refactoring.

---

## 🚀 How to Run the Automated Test Runner

All tests are orchestrated via the custom Dart test runner CLI at `tool/test_runner.dart`.

### 1. Executive Summary
Displays high-level execution counts, pass rates, and durations:
```bash
dart run tool/test_runner.dart --summary
```

### 2. Error & Crash Diagnostic List
Filters out passing tests and displays ONLY failing tests with root-cause messages and exact stack traces:
```bash
dart run tool/test_runner.dart --errors
```

### 3. Verified Passing Invariants
Displays all locked-down, working business logic and model features:
```bash
dart run tool/test_runner.dart --passed
```

### 4. Comprehensive Audit with Markdown Export
Runs the full suite and outputs a formatted Markdown report directly to `/reports`:
```bash
dart run tool/test_runner.dart --all --export reports/production_audit_report.md
```

---

## 📋 Unified Report Structure (Specification)

Every report saved to `/reports/` MUST strictly conform to the following schema:

```markdown
# [Project / Module Name] Audit Report

## 1. Executive Metadata
- **Date & Time (UTC/Local):** `YYYY-MM-DD HH:mm:ss`
- **Suite Target:** `test/<suite_name>.dart`
- **Total Tests Executed:** `N`
- **Passed:** `N (X%)`
- **Failed:** `N (Y%)`
- **Execution Duration:** `Z.ZZ seconds`

## 2. Categorized Root-Cause Breakdown
Group discovered issues by domain:
- `[DATA PARSING BUGS]` Models, JSON deserialization, type mismatches.
- `[BUSINESS LOGIC BUGS]` Pricing formulas, stock limits, coupon capping, distance fees.
- `[AUTH & SECURITY BUGS]` Token lifecycle, logout cascades, null zone dereferences.
- `[UI/UX & RESOURCE LEAKS]` Disposed controller leaks, layout overflows, rating bar crashes.
- `[HELPERS & VALIDATION]` Date converters, phone/email validators, coordinate parsers.

## 3. Bug Catalog Table
| ID | Production File | Method / Line | Crash Mechanism | Severity |
|----|-----------------|---------------|-----------------|----------|
| 1  | `path/to/file`  | `method:line` | `NoSuchMethodError` / etc. | Critical |

## 4. Detailed Bug Reproduction & Trace Analysis
For each failing test:
- **Test Identifier:** Exact name with tag `[TAG]`.
- **Trigger Payload:** Minimal JSON or argument state that induces the failure.
- **Observed Production Behavior:** Exact error message and stack frame.
- **Recommended Production Fix:** Safe parsing pattern or null-guard to apply.

## 5. Regression Safeguards (Working Parts)
List of core features locked down and passing.
```

---

## 🧪 Adding New Tests (Checklist for Developers & AI Agents)

When adding tests to `test/production/`:
1. Use category tags in `group()` and `test()` names:
   - `[DATA PARSING BUG]`
   - `[BUSINESS LOGIC BUG]`
   - `[AUTH & LIFECYCLE BUG]`
   - `[UI/UX CRASH BUG]`
   - `[VALIDATION BUG]`
   - `[INVARIANT VERIFICATION]`
2. Call real production classes (`OrderModel`, `ItemService`, `ValidateCheck`, `CartModel`), never local fake classes.
3. Import the new test file into:
   - `test/production/all_production_tests.dart`
   - `test/full_production_suite.dart`
4. Run `dart run tool/test_runner.dart --all --export reports/production_audit_report.md` to refresh the report.

---

## 📚 Available Engineering & Production Audit Reports

| Report Document | Description & Coverage | Last Updated |
|---|---|---|
| [`data_parsing_and_features_resolution_report.md`](./data_parsing_and_features_resolution_report.md) | **Post-Fix Verification & Resolution Report**: Complete post-fix verification of all 15 resolved data parsing/model defects and 4 major feature implementations with 100% test pass logs. | `2026-09-04` |
| [`vendor_type_logout_phone_payment_manual_report.md`](./vendor_type_logout_phone_payment_manual_report.md) | **Manual Engineering & Production Bug Resolution Report**: Detailed root-cause breakdown, old vs. new code comparisons, and verification logs for Vendor Type Badges, Instant Logout Fix, Phone LTR Alignment, and Multi-Step Payment Onboarding. | `2026-09-04` |
| [`production_audit_report.md`](./production_audit_report.md) | **Initial Production Audit (Baseline)**: Initial automated suite execution results, failure catalog exposing the unhandled crash reproductions, and regression invariant benchmarks. | `2026-09-03` |
| [`comprehensive_system_audit.md`](./comprehensive_system_audit.md) | **System Architecture & Data Flow Audit**: End-to-end audit of state management, payment integrations, and localization. | `2026-09-03` |

