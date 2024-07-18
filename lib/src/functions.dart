import 'package:unwrap_me/unwrap_me.dart';

// Identity
T identity<T>(T a) => a;
T id<T>(T a) => a;

// Build a Result that returns an Ok.
Result<T, E> ok<T, E>(T t) => Result<T, E>.ok(t);

// Build a Result that returns an Err.
Result<T, E> err<T, E>(E e) => Result<T, E>.err(e);

Option<T> some<T>(T t) => Option<T>.some(t);
Option<T> none<T>() => Option<T>.none();
