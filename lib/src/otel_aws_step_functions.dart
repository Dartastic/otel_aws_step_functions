// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_step_functions_suppression.dart';

class AwsStepFunctionsResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsStepFunctionsCallResult<T> {
  /// Creates a call result.
  const AwsStepFunctionsCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsStepFunctionsResult? result;
}

Future<T> tracedAwsStepFunctions<T>({
  required String operation,
  required Future<AwsStepFunctionsCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsStepFunctionsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_step_functions');
  final span = t.startSpan('stepfunctions $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.service', 'SFN')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.stateMachineArn != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'aws.sfn.state_machine.arn',
            res.stateMachineArn!,
          )
        ]));
      }
      if (res.executionArn != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('aws.sfn.execution.arn', res.executionArn!)
        ]));
      }
      if (res.executionName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('aws.sfn.execution.name', res.executionName!)
        ]));
      }
      if (res.state != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sfn.state', res.state!)]));
      }
      if (res.stateType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sfn.state.type', res.stateType!)]));
      }
      if (res.taskToken != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sfn.task_token', res.taskToken!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sfn.status', res.status!)]));
      }
      if (res.cause != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.sfn.cause', res.cause!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('stepfunctions.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'step_functions.error',
          )
        ]));
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
