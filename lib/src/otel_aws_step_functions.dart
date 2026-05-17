// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_step_functions_suppression.dart';

class AwsStepFunctionsResult {
  const AwsStepFunctionsResult({
    this.stateMachineArn,
    this.executionArn,
    this.executionName,
    this.state,
    this.stateType,
    this.taskToken,
    this.status,
    this.cause,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? stateMachineArn;
  final String? executionArn;
  final String? executionName;
  final String? state;
  final String? stateType;
  final String? taskToken;
  final String? status;
  final String? cause;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsStepFunctionsCallResult<T> {
  const AwsStepFunctionsCallResult({required this.value, this.result});
  final T value;
  final AwsStepFunctionsResult? result;
}

Future<T> tracedAwsStepFunctions<T>({
  required String operation,
  required Future<AwsStepFunctionsCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsStepFunctionsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTel.tracerProvider().getTracer('otel_aws_step_functions');
  final span = t.startSpan('stepfunctions $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'aws-api');
    span.setStringAttribute('rpc.service', 'SFN');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.stateMachineArn != null) {
        span.setStringAttribute(
          'aws.sfn.state_machine.arn',
          res.stateMachineArn!,
        );
      }
      if (res.executionArn != null) {
        span.setStringAttribute('aws.sfn.execution.arn', res.executionArn!);
      }
      if (res.executionName != null) {
        span.setStringAttribute('aws.sfn.execution.name', res.executionName!);
      }
      if (res.state != null) {
        span.setStringAttribute('aws.sfn.state', res.state!);
      }
      if (res.stateType != null) {
        span.setStringAttribute('aws.sfn.state.type', res.stateType!);
      }
      if (res.taskToken != null) {
        span.setStringAttribute('aws.sfn.task_token', res.taskToken!);
      }
      if (res.status != null) {
        span.setStringAttribute('aws.sfn.status', res.status!);
      }
      if (res.cause != null) {
        span.setStringAttribute('aws.sfn.cause', res.cause!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('stepfunctions.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'step_functions.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
