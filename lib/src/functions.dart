//
// Copyright (c) 2025-Present Imerio Dall'Olio
// All rights reserved.
//
// Licensed under MIT Licence.
//
import 'package:unwrap_me/unwrap_me.dart';

/// Identity function. Returns the input value unchanged.
T identity<T>(T t) => t;

/// Alias for [identity].
T id<T>(T t) => t;

/// Builds a [Result] that returns an [Ok] containing [t].
Result<T, E> ok<T, E>(T t) => Result<T, E>.Ok(t);

/// Builds a [Result] that returns an [Err] containing [e].
Result<T, E> error<T, E>(E e) => Result<T, E>.Err(e);

/// Builds an [Option] containing [t] as [Some].
Option<T> some<T>(T t) => Option<T>.Some(t);

/// Builds an [Option] with no value ([None]).
Option<T> none<T>() => Option<T>.None();
