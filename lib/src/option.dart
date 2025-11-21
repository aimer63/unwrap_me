//
// Copyright (c) 2025-Present Imerio Dall'Olio
// All rights reserved.
//
// Licensed under MIT Licence.
//
import 'package:unwrap_me/unwrap_me.dart';

sealed class Option<T> {
  const Option();

  // ignore: non_constant_identifier_names
  const factory Option.Some(T t) = Some<T>;
  // ignore: non_constant_identifier_names
  const factory Option.None() = None<T>;

  /// Converts a nullable [value] into an [Option].
  /// Returns [None] if [value] is null, otherwise [Some(value)].
  factory Option.fromNullable(T? value) => //
      switch (value) {
        null => None(),
        _ => Some(value),
      };

  /// Converts this [Option] to a nullable value.
  /// Returns the contained value if [Some], otherwise null.
  T? toNullable() => switch (this) {
        Some(:T value) => value,
        None() => null,
      };

  /// Returns `true` if this [Option] is [Some], otherwise `false`.
  bool isSome() => switch (this) {
        Some() => true,
        None() => false,
      };

  /// Returns `true` if this [Option] is [None], otherwise `false`.
  bool isNone() => !isSome();

  /// Returns `true` if the option is a `Some` and the value inside of it
  /// matches the predicate `f`.
  bool isSomeAnd(bool Function(T t) f) => //
      switch (this) {
        Some(:T value) => f(value),
        None() => false,
      };

  /// Returns the contained value if [Some], otherwise throws `'None'`.
  /// The stack trace will show the caller location.
  T unwrap() => //
      switch (this) {
        Some(:T value) => value,
        None() => throw 'None',
      };

  /// Returns the contained value if [Some], otherwise returns [d].
  T unwrapOr(T d) => //
      switch (this) {
        Some(:T value) => value,
        None() => d,
      };

  /// Returns the contained value if [Some], otherwise computes it from [orElse].
  T unwrapOrElse(T Function() orElse) => //
      switch (this) {
        Some(:T value) => value,
        None() => orElse(),
      };

  /// Returns the contained value if [Some], otherwise throws [msg].
  T expect(String msg) => //
      switch (this) {
        Some(:T value) => value,
        None() => throw msg,
      };

  /// Maps an [Option<T>] to [Option<U>] by applying [f] to the contained value
  /// if [Some], otherwise returns [None].
  Option<U> map<U>(U Function(T t) f) => //
      switch (this) {
        Some(:T value) => Some(f(value)),
        None() => None(),
      };

  /// Returns [d] if [None], otherwise applies [f] to the contained value and
  /// returns the result of `f(value)` if [Some].
  U mapOr<U>(U d, U Function(T t) f) => //
      switch (this) {
        Some(:T value) => f(value),
        None() => d,
      };

  /// Returns a value computed by [orElse] if [None], otherwise applies [f]
  /// to the contained value and returns the result of `f(value)` if [Some].
  U mapOrElse<U>(U Function() orElse, U Function(T t) f) => //
      switch (this) {
        Some(:T value) => f(value),
        None() => orElse(),
      };

  /// Returns the result `onNone` (if `None`), returns the result `onSome`
  /// applied to the contained value (if `Some`).
  U fold<U>(U Function(T t) onSome, U Function() onNone) => //
      switch (this) {
        Some(:T value) => onSome(value),
        None() => onNone(),
      };

  /// Returns a new [Option] by applying [f] to the contained value if [Some],
  /// otherwise returns [None]. Useful for chaining fallible operations.
  ///
  /// If this is [Some], returns the result of `f(value)`.
  /// If this is [None], returns [None].
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
  Option<U> flatMap<U>(covariant Option<U> Function(T t) f) => //
      switch (this) {
        Some(:T value) => f(value),
        None() => None(),
      };

  /// Returns this [Option] if it contains a value, otherwise returns [b].
  ///
  /// If this is [Some], returns itself.
  /// If this is [None], returns [b].
  Option<T> or(covariant Option<T> b) => //
      switch (this) {
        Some() => this,
        None() => b,
      };

  /// Returns [Some] if exactly one of this and [b] is [Some], otherwise [None].
  ///
  /// If only one is [Some], returns that [Some].
  /// If both are [Some] or both are [None], returns [None].
  Option<T> xor(covariant Option<T> b) => //
      switch ((this, b)) {
        (Some(), None()) => this,
        (None(), Some()) => b,
        _ => None(),
      };

  /// Returns this [Option] if it contains a value, otherwise calls [orElse]
  /// and returns its result.
  ///
  /// If this is [Some], returns itself.
  /// If this is [None], returns the result of [orElse].
  Option<T> orElse(covariant Option<T> Function() orElse) => //
      switch (this) {
        Some() => this,
        None() => orElse(),
      };

  /// Returns [None] if this is [None], otherwise returns [u].
  ///
  /// If this is [Some], returns [u].
  /// If this is [None], returns [None].
  Option<U> and<U>(covariant Option<U> u) => //
      switch (this) {
        Some() => u,
        None() => None(),
      };

  /// Returns [None] if this is [None], otherwise calls [then] with the
  /// contained value and returns its result.
  /// Same as [flatMap].
  Option<U> andThen<U>(covariant Option<U> Function(T t) then) => //
      flatMap(then);

  /// Transforms the [Option] into a [Result], mapping [Some(v)] to [Ok(v)]
  /// and [None] to [Err(error)].
  Result<T, E> okOr<E>(E error) => //
      switch (this) {
        Some(:T value) => Ok(value),
        None() => Err(error),
      };

  /// Transforms the [Option] into a [Result], mapping [Some(v)] to [Ok(v)]
  /// and [None] to [Err(error())].
  Result<T, E> okOrElse<E>(E Function() error) => //
      switch (this) {
        Some(:T value) => Ok(value),
        None() => Err(error()),
      };

  /// Zips this [Option] with another [Option].
  ///
  /// If both are [Some], returns [Some] containing a tuple of both values.
  /// Otherwise, returns [None].
  Option<(T, U)> zip<U>(covariant Option<U> other) => //
      switch ((this, other)) {
        (Some(value: T a), Some(value: U b)) => Some((a, b)),
        _ => None(),
      };

  /// Zips this [Option] and another [Option] with function [f].
  ///
  /// If both are [Some], returns [Some] containing the result of [f].
  /// Otherwise, returns [None].
  Option<R> zipWith<U, R>(
          covariant Option<U> other, R Function(T t, U u) f) => //
      switch ((this, other)) {
        (Some(value: T a), Some(value: U b)) => Some(f(a, b)),
        _ => None(),
      };

  /// Returns an iterator over the possibly contained value.
  ///
  /// The iterator yields one value if this is [Some], otherwise none.
  Iterable<T> iter() sync* {
    switch (this) {
      case Some(:T value):
        yield value;
      case None():
        return;
    }
  }

  /// Returns [None] if this is [None], otherwise calls [predicate]
  /// with the contained value and returns:
  ///
  /// - [Some(t)] if [predicate] returns `true`
  /// - [None] if [predicate] returns `false`
  Option<T> filter(bool Function(T t) predicate) => //
      switch (this) {
        Some(:T value) => predicate(value) ? this : None(),
        None() => this
      };

  /// Calls [f] with the contained value if [Some].
  /// Returns the original [Option].
  Option<T> inspect(void Function(T t) f) {
    if (this case Some(:T value)) {
      f(value);
    }
    return this;
  }

  /// Converts from [Option<Option<T>>] to [Option<T>]. Only one level is
  /// flattened. Chain or compose to flatten more levels.
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
  factory Option.flatten(Option<Option<T>> x) => //
      x.flatMap(identity);
}

final class Some<T> extends Option<T> {
  final T _value;
  const Some(this._value);

  T get value => _value;

  @override
  bool operator ==(Object other) => //
      (other is Some<T>) &&
      (other.value == _value || identical(other.value, _value));

  @override
  int get hashCode => //
      Object.hash(runtimeType, _value);

  @override
  String toString() => //
      'Some($_value)';
}

final class None<T> extends Option<T> {
  const None();

  @override
  bool operator ==(Object other) => //
      other is None;

  @override
  int get hashCode => //
      Object.hash(runtimeType, 'None');

  @override
  String toString() => //
      'None';
}

extension FlattenOpt<T> on Option<Option<T>> {
  /// Converts from [Option<Option<T>>] to [Option<T>]. Only one level is
  /// flattened. Chain or compose to flatten more levels.
  ///
  /// If this is [Some(Some(value))], returns [Some(value)].
  /// If this is [Some(None())] or [None()], returns [None].
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
  Option<T> flatten() => //
      flatMap(identity);
}

extension UnzipIt<A, B> on Option<(A, B)> {
  /// Unzips an option containing a tuple of two options.
  ///
  /// If `this` is `Some((a, b))` this method returns `(Some(a), Some(b))`.
  /// Otherwise, `(None, None)` is returned.
  (Option<A>, Option<B>) unzip() => //
      switch (this) {
        Some(value: (A a, B b)) => (Some(a), Some(b)),
        None() => (None(), None()),
      };
}

extension TransposeIt<T, E> on Option<Result<T, E>> {
  /// Transposes an [Option] of a [Result] into a [Result] of an [Option].
  ///
  /// [None] will be mapped to [Ok(None)]. [Some(Ok(_))] and [Some(Err(_))]
  /// will be mapped to [Ok(Some(_))] and [Err(_)].
  Result<Option<T>, E> transpose() => //
      switch (this) {
        Some(value: Ok(:T value)) => Ok(Some(value)),
        Some(value: Err(:E error)) => Err(error),
        None() => Ok(None()),
      };
}
