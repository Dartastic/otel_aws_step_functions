# otel_aws_step_functions

Dartastic OpenTelemetry bridge for AWS Step Functions (state machine orchestration).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_step_functions/otel_aws_step_functions.dart';

await tracedAwsStepFunctions<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsStepFunctionsCallResult(value: r, result: AwsStepFunctionsResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsStepFunctionsInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
