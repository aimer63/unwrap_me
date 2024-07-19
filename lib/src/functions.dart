import 'package:unwrap_me/unwrap_me.dart';

// Identity
T identity<T>(T t) => t;
T id<T>(T t) => t;

// Build a Result that returns an Ok.
Result<T, E> ok<T, E>(T t) => Result<T, E>.Ok(t);

// Build a Result that returns an Err.
Result<T, E> error<T, E>(E e) => Result<T, E>.Err(e);

Option<T> some<T>(T t) => Option<T>.Some(t);
Option<T> none<T>() => Option<T>.None();
