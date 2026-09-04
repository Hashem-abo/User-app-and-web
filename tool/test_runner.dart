// =============================================================================
// AUTOMATED TEST RUNNER & INTELLIGENT REPORTING CLI
// =============================================================================
//
// Usage:
//   dart run tool/test_runner.dart [flags]
//
// Flags:
//   --summary         Display only the executive summary dashboard.
//   --errors          Display only failed tests with exact assertions & stacks.
//   --passed          Display only passed tests with their safety guarantees.
//   --all             Display full report (Summary + Passed Tests + Errors).
//   --suite <path>    Specify test suite path (default: test/production/all_production_tests.dart).
//   --export <path>   Export report as Markdown file (e.g. --export test_report.md).
//   --json            Output the results as raw JSON.
//   --help            Display help information.
//
// Examples:
//   dart run tool/test_runner.dart --summary
//   dart run tool/test_runner.dart --errors
//   dart run tool/test_runner.dart --passed
//   dart run tool/test_runner.dart --export test_report.md
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TestInfo {
  final int id;
  final String name;
  final String category;
  String result = 'unknown'; // success, failure, error, skipped
  int durationMs = 0;
  String? error;
  String? stackTrace;

  TestInfo({required this.id, required this.name, required this.category});
}

void main(List<String> args) async {
  // Parse CLI flags
  bool showSummary = false;
  bool showErrors = false;
  bool showPassed = false;
  bool showAll = false;
  bool outputJson = false;
  String? exportPath;
  String suitePath = 'test/full_production_suite.dart';

  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--summary') showSummary = true;
    else if (arg == '--errors' || arg == '--failures') showErrors = true;
    else if (arg == '--passed' || arg == '--correct') showPassed = true;
    else if (arg == '--all') showAll = true;
    else if (arg == '--json') outputJson = true;
    else if (arg == '--export' && i + 1 < args.length) {
      exportPath = args[++i];
    } else if (arg == '--suite' && i + 1 < args.length) {
      suitePath = args[++i];
    }
  }

  // Default mode if none specified: show all
  if (!showSummary && !showErrors && !showPassed && !showAll) {
    showAll = true;
  }

  stdout.writeln('=============================================================================');
  stdout.writeln('🚀 SIXAM MART AUTOMATED PRODUCTION TEST RUNNER');
  stdout.writeln('=============================================================================');
  stdout.writeln('Suite Target: $suitePath');
  stdout.writeln('Executing tests with real-time JSON streaming...\n');

  final stopwatch = Stopwatch()..start();
  final Map<int, TestInfo> tests = {};
  final List<String> rawErrors = [];

  // Launch flutter test with --reporter json
  final isWindows = Platform.isWindows;
  final executable = isWindows ? 'flutter.bat' : 'flutter';

  Process process;
  try {
    process = await Process.start(
      executable,
      ['test', '--reporter', 'json', suitePath],
      runInShell: true,
    );
  } catch (e) {
    stderr.writeln('Error launching flutter test: $e');
    exit(1);
  }

  final lineStream = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  await for (final line in lineStream) {
    if (line.trim().isEmpty) continue;
    try {
      final event = jsonDecode(line) as Map<String, dynamic>;
      final type = event['type'] as String?;

      if (type == 'testStart') {
        final testObj = event['test'] as Map<String, dynamic>;
        final id = testObj['id'] as int;
        final name = testObj['name'] as String;

        // Skip internal runner / harness tests
        if (!name.startsWith('loading ') && !name.contains('(setUpAll)') && !name.contains('(tearDownAll)')) {
          String category = 'General';
          if (name.contains('[BUSINESS LOGIC]')) category = 'Business Logic & Calculations';
          else if (name.contains('[DATA PARSING]')) category = 'Data Parsing & Null Safety';
          else if (name.contains('[AUTH & LIFECYCLE]')) category = 'Auth & System Lifecycle';
          else if (name.contains('[UI/UX & RESOURCES]')) category = 'UI/UX & Resource Guards';
          else if (name.contains('[FIXED]')) category = 'Regression Verification';

          tests[id] = TestInfo(id: id, name: name, category: category);
        }
      } else if (type == 'error') {
        final testId = event['testID'] as int?;
        final errorMsg = event['error'] as String? ?? '';
        final stack = event['stackTrace'] as String? ?? '';

        if (testId != null && tests.containsKey(testId)) {
          tests[testId]!.error = errorMsg;
          tests[testId]!.stackTrace = stack;
        } else {
          rawErrors.add('$errorMsg\n$stack');
        }
      } else if (type == 'testDone') {
        final testId = event['testID'] as int?;
        final result = event['result'] as String? ?? 'unknown';
        final hidden = event['hidden'] as bool? ?? false;
        final time = event['time'] as int? ?? 0;

        if (testId != null && tests.containsKey(testId) && !hidden) {
          tests[testId]!.result = result;
          tests[testId]!.durationMs = time;
        }
      }
    } catch (_) {
      // Non-JSON output (e.g. flutter tool notifications)
    }
  }

  final exitCode = await process.exitCode;
  stopwatch.stop();

  // Aggregate results
  final totalTests = tests.values.length;
  final passedTests = tests.values.where((t) => t.result == 'success').toList();
  final failedTests = tests.values.where((t) => t.result == 'failure' || t.result == 'error').toList();
  final skippedTests = tests.values.where((t) => t.result == 'unknown' || t.result == 'skipped').toList();
  final passRate = totalTests > 0 ? ((passedTests.length / totalTests) * 100).toStringAsFixed(1) : '0.0';

  // Category breakdown
  final Map<String, int> categoryPassed = {};
  final Map<String, int> categoryTotal = {};
  for (final t in tests.values) {
    categoryTotal[t.category] = (categoryTotal[t.category] ?? 0) + 1;
    if (t.result == 'success') {
      categoryPassed[t.category] = (categoryPassed[t.category] ?? 0) + 1;
    }
  }

  // Format outputs
  final buffer = StringBuffer();

  void log(String line) {
    stdout.writeln(line);
    buffer.writeln(line);
  }

  // 1. SUMMARY SECTION
  if (showSummary || showAll) {
    log('-----------------------------------------------------------------------------');
    log('📊 TEST EXECUTION SUMMARY DASHBOARD');
    log('-----------------------------------------------------------------------------');
    log('  Total Tests Executed : $totalTests');
    log('  Passed               : ${passedTests.length} [✓]');
    log('  Failed               : ${failedTests.length} [✗]');
    log('  Skipped              : ${skippedTests.length}');
    log('  Pass Rate            : $passRate%');
    log('  Total Execution Time : ${stopwatch.elapsedMilliseconds} ms (${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s)');
    log('');
    log('📂 CATEGORY BREAKDOWN:');
    for (final entry in categoryTotal.entries) {
      final cat = entry.key;
      final total = entry.value;
      final passed = categoryPassed[cat] ?? 0;
      final percent = ((passed / total) * 100).toStringAsFixed(1);
      log('  • $cat : $passed / $total passed ($percent%)');
    }
    log('-----------------------------------------------------------------------------\n');
  }

  // 2. PASSED / CORRECT SECTION
  if (showPassed || showAll) {
    log('-----------------------------------------------------------------------------');
    log('✅ VERIFIED PRODUCTION TESTS (${passedTests.length} Tests)');
    log('-----------------------------------------------------------------------------');
    for (final t in passedTests) {
      log('  [✓] ${t.name} (${t.durationMs}ms)');
    }
    log('-----------------------------------------------------------------------------\n');
  }

  // 3. ERRORS / FAILURES SECTION
  if (showErrors || showAll) {
    if (failedTests.isNotEmpty || rawErrors.isNotEmpty) {
      log('-----------------------------------------------------------------------------');
      log('❌ PRODUCTION CRASH / FAILURE INVESTIGATION (${failedTests.length} Failures)');
      log('-----------------------------------------------------------------------------');
      int count = 1;
      for (final t in failedTests) {
        log('[$count] Test Name : ${t.name}');
        log('    Category  : ${t.category}');
        log('    Result    : ${t.result.toUpperCase()}');
        if (t.error != null) {
          log('    Assertion / Error:\n      ${t.error!.trim().replaceAll('\n', '\n      ')}');
        }
        if (t.stackTrace != null && t.stackTrace!.isNotEmpty) {
          log('    Stack Trace:\n      ${t.stackTrace!.trim().replaceAll('\n', '\n      ')}');
        }
        log('-----------------------------------------------------------------------------');
        count++;
      }
      for (final err in rawErrors) {
        log('[RAW ERROR]\n  $err');
      }
    } else {
      if (showErrors) {
        log('🎉 No errors or crashes detected! 100% of tested production cases passed.');
      }
    }
  }

  // JSON OUTPUT MODE
  if (outputJson) {
    final jsonReport = {
      'timestamp': DateTime.now().toIso8601String(),
      'suite': suitePath,
      'durationMs': stopwatch.elapsedMilliseconds,
      'total': totalTests,
      'passed': passedTests.length,
      'failed': failedTests.length,
      'passRate': double.tryParse(passRate) ?? 0.0,
      'categories': categoryTotal.map((k, v) => MapEntry(k, {
        'total': v,
        'passed': categoryPassed[k] ?? 0,
      })),
      'failures': failedTests.map((f) => {
        'name': f.name,
        'category': f.category,
        'error': f.error,
        'stack': f.stackTrace,
      }).toList(),
    };
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(jsonReport));
  }

  // EXPORT MARKDOWN REPORT
  if (exportPath != null) {
    final file = File(exportPath);
    final md = StringBuffer();
    md.writeln('# Automated Test Execution Report');
    md.writeln('**Generated at:** ${DateTime.now().toIso8601String()}  ');
    md.writeln('**Suite:** `$suitePath`  ');
    md.writeln('**Status:** ${failedTests.isEmpty ? '✅ ALL PASSED' : '❌ FAILURES DETECTED'}\n');
    md.writeln('## Executive Summary');
    md.writeln('| Metric | Value |');
    md.writeln('|---|---|');
    md.writeln('| **Total Tests** | $totalTests |');
    md.writeln('| **Passed** | ${passedTests.length} |');
    md.writeln('| **Failed** | ${failedTests.length} |');
    md.writeln('| **Pass Rate** | $passRate% |');
    md.writeln('| **Duration** | ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s |\n');
    md.writeln('## Category Breakdown');
    md.writeln('| Category | Passed / Total | Pass Rate |');
    md.writeln('|---|---|---|');
    for (final entry in categoryTotal.entries) {
      final cat = entry.key;
      final total = entry.value;
      final passed = categoryPassed[cat] ?? 0;
      final percent = ((passed / total) * 100).toStringAsFixed(1);
      md.writeln('| $cat | $passed / $total | $percent% |');
    }
    if (failedTests.isNotEmpty) {
      md.writeln('\n## Failed Tests');
      for (final t in failedTests) {
        md.writeln('### ❌ ${t.name}');
        md.writeln('- **Category:** ${t.category}');
        md.writeln('```');
        md.writeln(t.error ?? 'No error message provided');
        md.writeln('```\n');
      }
    }
    md.writeln('\n## Verified Passing Assertions');
    for (final t in passedTests) {
      md.writeln('- [x] `${t.name}` (${t.durationMs}ms)');
    }

    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    await file.writeAsString(md.toString());
    stdout.writeln('\n📄 Report exported successfully to: $exportPath');
  }

  exit(exitCode);
}

void _printHelp() {
  stdout.writeln('''
Automated Test Runner & Intelligent Reporting CLI

Options:
  --summary          Show only high-level summary metrics.
  --errors           Show only failing tests and root cause details.
  --passed           Show only verified passing tests.
  --all              Show full report (Default).
  --suite <path>     Specify test suite path (Default: test/production/all_production_tests.dart).
  --export <path>    Export full markdown report to specified file.
  --json             Print report as raw JSON.
  --help, -h         Show this message.
''');
}
