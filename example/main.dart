// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_step_functions/otel_aws_step_functions.dart';

/// Traces Aws Step Functions calls with OpenTelemetry.
///
/// `otel_aws_step_functions` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Step Functions call in
/// [tracedAwsStepFunctions]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-step-functions-example');

  // Traces a Aws Step Functions call.
  final awsStepFunctionsId = await tracedAwsStepFunctions<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Step Functions call here, then report what it returned.
      const id = 'aws_step_functions_8f3a2c';
      return const AwsStepFunctionsCallResult(
          value: id,
          result: AwsStepFunctionsResult(
              stateMachineArn: 'active',
              executionArn: 'example',
              executionName: 'example',
              state: 'active',
              stateType: 'active',
              taskToken: 'example',
              status: 'succeeded',
              cause: 'example',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsStepFunctions create returned $awsStepFunctionsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsStepFunctionsInstrumentationAsync.
  await runWithoutAwsStepFunctionsInstrumentationAsync(
    () => tracedAwsStepFunctions<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_step_functions_8f3a2c';
        return const AwsStepFunctionsCallResult(
            value: id,
            result: AwsStepFunctionsResult(
                stateMachineArn: 'active',
                executionArn: 'example',
                executionName: 'example',
                state: 'active',
                stateType: 'active',
                taskToken: 'example',
                status: 'succeeded',
                cause: 'example',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
