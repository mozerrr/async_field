import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class AsyncField<T, E> extends Equatable {
  const AsyncField._({
    this.data,
    this.error,
    this.isLoading = false,
  });

  const AsyncField.data(T this.data)
      : error = null,
        isLoading = false;

  const AsyncField.error(
    E this.error, {
    this.data,
  }) : isLoading = false;

  const AsyncField.loading({this.data})
      : isLoading = true,
        error = null;

  final T? data;
  final E? error;
  final bool isLoading;

  bool get hasData => data != null;

  bool get hasError => error != null;

  Widget when({
    required Widget Function() onLoading,
    required Widget Function(T data) onData,
    required Widget Function(E error) onError,
  }) {
    if (hasError) {
      return onError(
        error as E,
      );
    }
    if (hasData) {
      return onData(data as T);
    }
    return onLoading();
  }

  /// [maybeWhen] помимо трех вышеупомянутых состояний имеет 4-ое обязательное:
  ///
  /// [orElse] вызывается, когда три других состояния не инициализированы
  Widget maybeWhen({
    Widget Function()? onLoading,
    Widget Function(T data)? onData,
    Widget Function(E error)? onError,
    required Widget Function() orElse,
  }) {
    if (hasError && onError != null) {
      return onError(
        error as E,
      );
    }
    if (hasData && onData != null) {
      return onData(data as T);
    }
    if (isLoading && onLoading != null) {
      return onLoading();
    }
    return orElse();
  }

  AsyncField<T, E> copyWith({
    T? data,
    E? error,
    bool? isLoading,
  }) {
    return AsyncField<T, E>._(
      data: data ?? this.data,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [data, error, isLoading];
}
