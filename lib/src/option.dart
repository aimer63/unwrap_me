import 'package:unwrap_me/unwrap_me.dart';

sealed class Option<T> {
  const Option();

  const factory Option.some(T t) = Some<T>;
  const factory Option.none() = None<T>;

  bool isSome() => switch (this) {
        Some() => true,
        None() => false,
      };

  bool isNone() => !isSome();

  /// Returns the value if any, throws if `None`
  T unwrap() => switch (this) {
        Some(:T val) => val,
        None() => throw 'None',
      };

  /// Returns the contained `Some` value or the provided one if `None`
  T unwrapOr(T d) => switch (this) {
        Some(:T val) => val,
        None() => d,
      };

  /// Returns the contained `Some` value or computes it from `orElse` in `None`.
  T unwrapOrElse(T Function() orElse) => switch (this) {
        Some(:T val) => val,
        None() => orElse(),
      };

  /// Returns the value if any, throws the `String` if `None`
  T expect(String msg) => switch (this) {
        Some(:T val) => val,
        None() => throw msg,
      };

  /// Maps an `Option<T>` to `Option<U>` by applying a function to a contained
  /// value (if `Some`) or returns `None` (if `None`).
  Option<U> map<U>(U Function(T t) f) => switch (this) {
        Some(:T val) => Some(f(val)),
        None() => None(),
      };

  /// Returns the provided default (if `None`), or applies a function
  /// to the contained value (if any) and returns `U=f(t)`.
  U mapOr<U>(U d, U Function(T t) f) => switch (this) {
        Some(:T val) => f(val),
        None() => d,
      };

  /// Returns a value computed by the default function (if `None`), or applies
  /// a different function to the contained value (if any).
  U mapOrElse<U>(U Function() orElse, U Function(T t) f) => switch (this) {
        Some(:T val) => f(val),
        None() => orElse(),
      };

  /// Returns a `onNone` (if `None`), or applies `onSome` to the contained value
  /// (if any).
  U fold<U>(U Function(T t) onSome, U Function() onNone) => switch (this) {
        Some(:T val) => onSome(val),
        None() => onNone(),
      };

  /// Computes a new `Option<U>` applying f if `Some`, `None` otherwise.
  /// Useful to chain fallible operations, if something goes wrong
  /// you end up with a `None`
  ///
  /// ```dart
  /// final a = Some('10'); // final a = Some('10=')
  /// final Option<double> r = a.flatMap(
  ///   (s) => stringToInt(s).flatMap(
  ///     (i) => intToDouble(i),
  ///   ),
  /// );
  /// print(r);
  /// final Option<double> r1 = a.flatMap(stringToInt).flatMap(intToDouble);
  /// print(r1);
  /// ```
  Option<U> flatMap<U>(covariant Option<U> Function(T t) f) => switch (this) {
        Some(:T val) => f(val),
        None() => None(),
      };

  /// It looks it works... but I had to replace `Never` with `T` in the generics
  /// of `None` and, from the None implementation, return `None()` instead of
  /// `this`.
  Option<T> or(covariant Option<T> b) => switch (this) {
        Some() => this,
        None() => b,
      };

  /// Same as for 'or'.
  Option<T> orElse(covariant Option<T> Function() orElse) => switch (this) {
        Some() => this,
        None() => orElse(),
      };

  /// Returns None if the option is None, otherwise returns u.
  Option<U> and<U>(covariant Option<U> u) => switch (this) {
        Some() => u,
        None() => None(),
      };

  /// Returns None if the option is `None`, otherwise calls `then` with the
  /// wrapped value and returns the result. Same as `flatMap`.
  Option<U> andThen<U>(covariant Option<U> Function(T t) then) =>
      switch (this) {
        Some(:T val) => then(val),
        None() => None(),
      };

  /// Transforms the `Option<T>` into a `Result<T, E>`, mapping `Some(v)` to
  /// `Ok(v)` and `None` to `Err(err)`.
  Result<T, E> okOr<E>(E err) => switch (this) {
        Some(:T val) => Ok(val),
        None() => Err(err),
      };

  /// Transforms the `Option<T>` into a `Result<T, E>`, mapping `Some(v)` to
  /// `Ok(v)` and `None` to `Err(err())`.
  Result<T, E> okOrElse<E>(E Function() err) => switch (this) {
        Some(:T val) => Ok(val),
        None() => Err(err()),
      };

  /// Zips `this` with another `Option`.
  /// If `this` is `Some(s)` and `other` is `Some(o)`, this method returns `Some((s, o))`.
  /// Otherwise, `None` is returned.
  Option<(T, U)> zip<U>(covariant Option<U> other) => switch ((this, other)) {
        (Some(val: T a), Some(val: U b)) => Some((a, b)),
        _ => None(),
      };

  /// Zips `this` and another `Option` with function `f`.
  /// If self is `Some(s)` and other is `Some(o)`, this method returns `Some(f(s, o))`.
  /// Otherwise, None is returned.
  Option<R> zipWith<U, R>(Option<U> other, R Function(T t, U u) f) =>
      switch ((this, other)) {
        (Some(val: T a), Some(val: U b)) => Some(f(a, b)),
        _ => None(),
      };

  /// Converts from `Option<Option<T>>` to `Option<T>`. Only one level is flatten.
  /// Chain or compose to flatten more levels.
  ///
  /// ```dart
  /// final option = Some(Some(Some(1)));
  /// final o = option.flatMap(identity).flatMap(identity);
  /// print(option);
  /// print(o);
  /// final o1 = Option.flatten(Option.flatten(option));
  /// print(o1);
  /// ```
  ///
  factory Option.flatten(Option<Option<T>> x) => x.flatMap(identity);
}

final class Some<T> extends Option<T> {
  final T _val;
  const Some(this._val);

  T get val => _val;

  @override
  bool operator ==(Object other) =>
      (other is Some<T>) && (other._val == _val || identical(other.val, _val));

  @override
  int get hashCode => Object.hash(runtimeType, _val);

  @override
  String toString() => 'Some($_val)';
}

final class None<T> extends Option<T> {
  const None();

  @override
  bool operator ==(Object other) => other is None;

  @override
  int get hashCode => Object.hash(runtimeType, 'None');

  @override
  String toString() => 'None';
}

extension FlatIt<T> on Option<Option<T>> {
  /// Converts from `Option<Option<T>>` to `Option<T>`. Only one level is flatten.
  /// Chain or compose to flatten more levels.
  ///
  /// ```dart
  /// final option = Some(Some(Some(1)));
  /// final o = option.flatMap(identity).flatMap(identity);
  /// print(option);
  /// print(o);
  /// final o1 = option.flatten().flatten();
  /// print(o1);
  /// ```
  ///
  Option<T> flatten() => flatMap(identity);
}
