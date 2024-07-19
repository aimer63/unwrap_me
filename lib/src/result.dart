//import 'package:option_result/option_result.dart';

import 'package:unwrap_me/unwrap_me.dart';

sealed class Result<T, E> {
  const Result();

  // ignore: non_constant_identifier_names
  const factory Result.Ok(T t) = Ok<T, E>;
  // ignore: non_constant_identifier_names
  const factory Result.Err(E e) = Err<T, E>;

  bool isOk() => //
      switch (this) {
        Ok() => true,
        Err() => false,
      };

  bool isErr() => !isOk();

  /// Returns `true` if the result is `Ok` and the value inside of it matches
  /// a predicate.
  ///
  bool isOkAnd(bool Function(T t) f) => //
      switch (this) {
        Ok(:T value) => f(value),
        Err() => false,
      };

  /// Returns `true` if the result is `Err` and the value inside of it matches
  /// a predicate.
  ///
  bool isErrAnd(bool Function(E e) f) => //
      switch (this) {
        Ok() => false,
        Err(:E error) => f(error),
      };

  /// Returns the contained `Ok` value, if it's `Err` throws the contained `error`
  /// value.
  T unwrap() => //
      switch (this) {
        Ok(:T value) => value,
        Err(:E error) => throw error as Object,
      };

  /// Returns the contained `Ok` value or a provided default if it is `Err`.
  T unwrapOr(T d) => //
      switch (this) {
        Ok(:T value) => value,
        Err() => d,
      };

  /// Returns the contained `Ok` value or computes it from `orElse`.
  T unwrapOrElse(T Function(E e) orElse) => //
      switch (this) {
        Ok(:T value) => value,
        Err(:E error) => orElse(error),
      };

  /// Returns the contained `Err` value, if it's `ok` throws the contained `ok`
  /// value.
  E unwrapErr() => //
      switch (this) {
        Ok(:T value) => throw value as Object,
        Err(:E error) => error,
      };

  /// Returns the contained `Ok` value, if it's `Err` throws `msg`.
  T expect(String msg) => //
      switch (this) {
        Ok(:T value) => value,
        Err() => throw msg,
      };

  /// Returns the contained `Err` value, if it's `Ok` throws `msg`.
  E expectErr(String msg) => //
      switch (this) {
        Ok() => throw msg,
        Err(:E error) => error,
      };

  /// Converts from `Result<T, E>` to [`Option<E>`] discarding the error, if any.
  ///
  Option<T> ok() => //
      switch (this) {
        Ok(:T value) => Some(value),
        Err() => None()
      };

  /// Converts from `Result<T, E>` to `Option<E>`discarding the success value,
  /// if any.
  Option<E> err() => //
      switch (this) {
        Ok() => None(),
        Err(:E error) => Some(error),
      };

  /// Calls a function with a reference to the contained value if `Ok`.
  ///
  /// Returns the original result.
  Result<T, E> inspect(void Function(T t) f) {
    if (this case Ok(:T value)) {
      f(value);
    }
    return this;
  }

  /// Calls a function with a reference to the contained value if `Err`.
  ///
  /// Returns the original result.
  Result<T, E> inspectErr(void Function(E t) f) {
    if (this case Err(:E error)) {
      f(error);
    }
    return this;
  }

  /// Returns the result of onOk for the contained value if it's `Ok`,
  /// otherwise the result of `onErr` if it's an `Err`
  U fold<U>(U Function(T t) onOk, U Function(E e) onErr) => //
      switch (this) {
        Ok(:T value) => onOk(value),
        Err(:E error) => onErr(error),
      };

  /// Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a
  /// contained `Ok` value, leaving an `Err` value untouched.
  /// This function can be used to compose the results of two functions.
  /// ```dart
  /// final List<String> list = ['1', '2x', '3', '4'];
  ///
  /// list.forEach((number) {
  ///   switch (parseInt(number).map((i) => i * 2)) {
  ///     case Ok(value: final n):
  ///       print(n);
  ///     case Err(:String error):
  ///       print(error);
  ///   }
  /// });
  /// ```
  ///
  Result<U, E> map<U>(U Function(T t) fn) => //
      switch (this) {
        Ok(:T value) => Ok(fn(value)),
        Err(:E error) => Err(error),
      };

  /// Maps a `Result<T, E>` to `Result<T, F>` by applying a function to a
  /// contained `Err` value, leaving an `Ok` value untouched.
  /// This function can be used to pass through a successful result
  /// while handling an error.
  Result<T, F> mapErr<F>(F Function(E e) fn) => //
      switch (this) {
        Ok(:T value) => Ok(value),
        Err(:E error) => Err(fn(error)),
      };

  /// Returns the provided default (if `Err`), or
  /// applies a function to the contained value (if `Ok`).
  ///
  U mapOr<U>(U d, U Function(T t) f) => //
      switch (this) {
        Ok(:T value) => f(value),
        Err() => d,
      };

  /// Maps a `Result<T, E>` to `U` by applying fallback function `orElse` to
  /// a contained `Err` value, or function `f` to a contained `Ok` value.
  ///
  /// This function can be used to unpack a successful result
  /// while handling an error.
  ///
  U mapOrElse<U>(U Function(E e) orElse, U Function(T t) f) => //
      switch (this) {
        Ok(:T value) => f(value),
        Err(:E error) => orElse(error),
      };

  /// Calls `op` if the result is `Ok`, otherwise returns the `Err` value of `this`.
  /// Same as andThen
  Result<U, E> flatMap<U>(covariant Result<U, E> Function(T t) op) =>
      switch (this) {
        Ok(:T value) => op(value),
        Err(:E error) => Err(error),
      };

  // Returns a new Result mapping any Err value using the given transformation,
  // the transformation itself produces the new Result
  Result<T, U> flatMapErr<U>(covariant Result<T, U> Function(E e) fn) =>
      switch (this) {
        Ok(:T value) => Ok(value),
        Err(:E error) => fn(error),
      };

  /// Returns `res` if the result is `Ok`, otherwise returns the `Err` value of `this`.
  ///
  Result<U, E> and<U>(covariant Result<U, E> res) => //
      switch (this) {
        Ok() => res,
        Err(:E error) => Err(error),
      };

  /// Calls `op` if the result is `Ok`, otherwise returns the `Err` value of `this4`.
  /// Same as flatMap
  Result<U, E> andThen<U>(covariant Result<U, E> Function(T t) op) => //
      flatMap(op);

  /// Returns a mutable iterator over the possibly contained value.
  ///
  /// The iterator yields one value if the result is `Result::Ok`,
  /// otherwise none.
  Iterable<T> iter() sync* {
    switch (this) {
      case Ok(:T value):
        yield value;
      case Err():
        return;
    }
  }
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this._value);
  final T _value;

  T get value => _value;

  @override
  bool operator ==(Object other) =>
      (other is Ok<T, E>) &&
      (other.value == _value || identical(other.value, _value));

  @override
  int get hashCode => Object.hash(runtimeType, _value);

  @override
  String toString() => 'Ok($_value)';
}

final class Err<T, E> extends Result<T, E> {
  const Err(this._error);
  final E _error;

  E get error => _error;

  @override
  bool operator ==(Object other) =>
      (other is Err<T, E>) &&
      (other.error == _error || identical(other.error, _error));

  @override
  int get hashCode => Object.hash(runtimeType, _error);

  @override
  String toString() => 'Err($_error)';
}

extension FlattenRes<T, E> on Result<Result<T, E>, E> {
  /// Converts from `Result<Result<T, E>, E>` to `Result<T, E>`
  /// Only one level is flatten.
  /// Chain or compose to flatten more levels.
  ///
  Result<T, E> flatten() => //
      flatMap(identity);
}
