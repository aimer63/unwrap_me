//import 'package:option_result/option_result.dart';

sealed class Result<T, E> {
  const Result();

  const factory Result.ok(T t) = Ok<T, E>;
  const factory Result.err(E e) = Err<T, E>;

  bool isOk() => switch (this) {
        Ok() => true,
        Err() => false,
      };

  bool isErr() => !isOk();

  /// Returns the contained `Ok` value, if it's `Err` throws the contained `err`
  /// value.
  T unwrap() => switch (this) {
        Ok(:T val) => val,
        Err(:E err) => throw err as Object,
      };

  /// Returns the contained `Ok` value or a provided default if it is `Err`.
  T unwrapOr(T d) => switch (this) {
        Ok(:T val) => val,
        Err() => d,
      };

  /// Returns the contained `Ok` value or computes it from `orElse`.
  T unwrapOrElse(T Function(E e) orElse) => switch (this) {
        Ok(:T val) => val,
        Err(:E err) => orElse(err),
      };

  /// Returns the contained `Err` value, if it's `ok` throws the contained `ok`
  /// value.
  E unwrapErr() => switch (this) {
        Ok(:T val) => throw val as Object,
        Err(:E err) => err,
      };

  /// Returns the contained `Ok` value, if it's `Err` throws `msg`.
  T expect(String msg) => switch (this) {
        Ok(:T val) => val,
        Err() => throw msg,
      };

  /// Returns the contained `Err` value, if it's `Ok` throws `msg`.
  E expectErr(String msg) => switch (this) {
        Ok() => throw msg,
        Err(:E err) => err,
      };

  /// Returns the result of onOk for the contained value if it's `Ok`,
  /// otherwise the result of `onErr` if it's an `Err`
  U match<U>(U Function(T t) onOk, U Function(E e) onErr) => switch (this) {
        Ok(:T val) => onOk(val),
        Err(:E err) => onErr(err),
      };

  /// Same as `match`.
  U fold<U>(U Function(T t) onOk, U Function(E e) onErr) => switch (this) {
        Ok(:T val) => onOk(val),
        Err(:E err) => onErr(err),
      };

  /// Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a
  /// contained `Ok` value, leaving an `Err` value untouched.
  /// This function can be used to compose the results of two functions.
  /// ```dart
  /// final List<String> list = ['1', '2x', '3', '4'];
  ///
  /// list.forEach((number) {
  ///   switch (parseInt(number).map((i) => i * 2)) {
  ///     case Ok(val: final n):
  ///       print(n);
  ///     case Err(:String err):
  ///       print(err);
  ///   }
  /// });
  /// ```
  ///
  Result<U, E> map<U>(U Function(T t) fn) => switch (this) {
        Ok(:T val) => Ok(fn(val)),
        Err(:E err) => Err(err),
      };

  /// Maps a `Result<T, E>` to `Result<T, F>` by applying a function to a
  /// contained `Err` value, leaving an `Ok` value untouched.
  /// This function can be used to pass through a successful result
  /// while handling an error.
  Result<T, F> mapErr<F>(F Function(E e) fn) => switch (this) {
        Ok(:T val) => Ok(val),
        Err(:E err) => Err(fn(err)),
      };

  // Returns a new Result mapping any Ok value using the given transformation,
  // the transformation itself produces the new Result
  Result<U, E> flatMap<U>(covariant Result<U, E> Function(T t) fn) =>
      switch (this) {
        Ok(:T val) => fn(val),
        Err(:E err) => Err(err),
      };

  // Returns a new Result mapping any Err value using the given transformation,
  // the transformation itself produces the new Result
  Result<T, U> flatMapErr<U>(covariant Result<T, U> Function(E e) fn) =>
      switch (this) {
        Ok(:T val) => Ok(val),
        Err(:E err) => fn(err),
      };
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this._val);
  final T _val;

  T get val => _val;

  @override
  bool operator ==(Object other) {
    return other is Ok && other._val == _val;
  }

  @override
  int get hashCode => _val.hashCode;

  @override
  String toString() => 'Ok($_val)';
}

final class Err<T, E> extends Result<T, E> {
  const Err(this._err);
  final E _err;

  E get err => _err;

  @override
  bool operator ==(Object other) {
    return other is Err && other._err == _err;
  }

  @override
  int get hashCode => _err.hashCode;
  @override
  String toString() => 'Err($_err)';
}
