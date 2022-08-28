import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'error.dart';
import 'safe_check.dart';

class AsyncField<T> extends Equatable {
  const AsyncField._({
    this.data,
    this.error,
    this.originalError,
    this.stackTrace,
    this.isLoading = false,
  });
  
  const AsyncField.empty() 
      : data = null,
        error = null,
        stackTrace = null,
        originalError = null,
        isLoading = false;

  const AsyncField.data(T this.data)
      : error = null,
        stackTrace = null,
        originalError = null,
        isLoading = false;

  const AsyncField.error(
    Exception this.error, {
    this.originalError,
    this.stackTrace,
    this.data,
  }) : isLoading = false;

  const AsyncField.loading({this.data})
      : isLoading = true,
        error = null,
        stackTrace = null,
        originalError = null;

  final T? data;
  final Exception? error;
  final Exception? originalError;
  final StackTrace? stackTrace;
  final bool isLoading;

  bool get hasData => data != null;

  bool get hasError => error != null;

  static Future<AsyncField<T>> action<T>({
    required Future<T?> Function() action,
    Future<bool> Function()? check,
  }) async {
    final needToCheck = check != null;
    var passed = needToCheck ? false : true;
    Exception? originalError;
    StackTrace? stackTrace;

    if (needToCheck) {
      final checkResult = await safeCheck(check!);
      if (checkResult.hasData) {
        passed = checkResult.data!;
      } else {
        originalError = checkResult.originalError;
        stackTrace = checkResult.stackTrace;
      }
    }

    if (passed) {
      T? data;
      Exception? error;
      try {
        data = await action();
      } on Exception catch (e, s) {
        error = e;
        originalError = error;
        stackTrace = s;
      } finally {
        if (data == null && error == null) {
          error = const DataIsNullException();
        }
      }
      if (error != null) {
        return AsyncField.error(
          error,
          originalError: originalError,
          stackTrace: stackTrace,
        );
      } else {
        return AsyncField.data(data!);
      }
    } else {
      return AsyncField.error(
        const CheckNotPassed(),
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }
  }

  Widget when({
    required Widget Function() onLoading,
    required Widget Function(T data) onData,
    required Widget Function(Exception error,
            {Exception? originalError, StackTrace? stackTrace})
        onError,
  }) {
    if (hasError) {
      return onError(
        error!,
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }
    if (hasData) {
      return onData(data!);
    }
    return onLoading();
  }

  /// [maybeWhen] помимо трех вышеупомянутых состояний имеет 4-ое обязательное:
  ///
  /// [orElse] вызывается, когда три других состояния не инициализированы
  Widget maybeWhen({
    Widget Function()? onLoading,
    Widget Function(T data)? onData,
    Widget Function(Exception error,
            {Exception? originalError, StackTrace? stackTrace})?
        onError,
    required Widget Function() orElse,
  }) {
    if (hasError && onError != null) {
      return onError(
        error!,
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }
    if (hasData && onData != null) {
      return onData(data!);
    }
    if (isLoading && onLoading != null) {
      return onLoading();
    }
    return orElse();
  }

  AsyncField<T> copyWith({
    T? data,
    Exception? error,
    Exception? originalError,
    StackTrace? stackTrace,
    bool? isLoading,
  }) {
    return AsyncField<T>._(
      data: data ?? this.data,
      error: error ?? this.error,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props =>
      [data, error, stackTrace, originalError, isLoading];
}
