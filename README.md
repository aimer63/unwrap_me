# unwrap_me

**unwrap_me** Rust's `Option` and `Result` types directly into Dart.

> "I decided to write this because I was forced to learn Rust and Dart together."

While juggling the learning curves of both languages, I missed the Rust's enums while
writing Dart. Instead of struggling whith "Null Safety" I tryied to port one the best parts
of Rust's standard library to Dart.

## Features

* **`Option<T>`:** Explicit handling of value presence/absence, replacing implicit nulls.
* **`Result<T, E>`:** Typed error handling that treats errors as values, not exceptions.
* **Functional Combinators:** Chainable methods like `map`, `flatMap`, `zip`, `filter`, and `fold`.
* **Dart 3 Pattern Matching:** Built using `sealed` classes, enabling exhaustive `switch` expressions.
* **Transformations:** Includes `transpose` (flip `Option<Result>` to `Result<Option>`) and `flatten`.
* **Helpers:** Shorthand functions like `some()`, `none()`, `ok()`, and `error()` for cleaner syntax.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  unwrap_me: ^0.1.0
```

## Usage

### Error Handling with Pattern Matching

```dart
sealed class Error {}

class UserNotFoundError extends Error {
  final String username;
  UserNotFoundError(this.username);
}

class ParseIntError extends Error {
  final String message;
  ParseIntError(this.message);
}

void printError(Error e) {
  switch (e) {
    case UserNotFoundError(:String username):
      print('User not found: $username');
    case ParseIntError(message: final msg):
      print('Parse error: $msg');
  }
  print('Error object: $e');
}

void main() {
  final error1 = UserNotFoundError('Pino');
  final error2 = ParseIntError('Invalid integer format');
  printError(error1);
  printError(error2);
}
```

### Chaining Option Operations

```dart
final Option<double> result = Some('42')
    .flatMap((s) => int.tryParse(s) != null ? Some(int.parse(s)) : None())
    .flatMap((i) => Some(i.toDouble()));
print(result); // Some(42.0)
```

### Collecting Results and Errors

```dart
final strings = ["42", "tofu", "93", "999x", "18"];
final errors = <Error>[];
final numbers = strings
    .map((s) => int.tryParse(s) != null
        ? Ok(int.parse(s))
        : Err(ParseIntError('Invalid: $s')))
    .map((r) => r.inspectErr((e) => errors.add(e)))
    .where((r) => r.isOk())
    .toList();

print("Numbers: $numbers");
print("Errors: $errors");
```

> **See more complete examples in the [`example/`](example/) directory.**

## License

MIT
