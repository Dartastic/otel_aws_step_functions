// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_step_functions/otel_aws_step_functions.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_step_functions', () {
    test('suppression toggles in zone', () async {
      expect(awsStepFunctionsInstrumentationSuppressed(), isFalse);
      await runWithoutAwsStepFunctionsInstrumentationAsync(() async {
        expect(awsStepFunctionsInstrumentationSuppressed(), isTrue);
      });
      expect(awsStepFunctionsInstrumentationSuppressed(), isFalse);
    });

    test('AwsStepFunctionsResult fields default null', () {
      const r = AwsStepFunctionsResult();
      expect(r.statusCode, isNull);
    });
  });
}
