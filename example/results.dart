import 'package:unwrap_me/unwrap_me.dart';
import 'package:unwrap_me/unwrap_me.dart' as unwrap_me;
import './errors.dart';

typedef Result<T> = unwrap_me.Result<T, Error>;

Result<int> parseInt(String number) {
  try {
    return Ok(int.parse(number));
  } catch (e) {
    return Err(ParseIntError(e.toString()));
  }
}

Result<int> multiply(String first, String second) {
  return switch (parseInt(first)) {
    Ok(value: final first) => switch (parseInt(second)) {
        Ok(value: final second) => Ok(first * second),
        Err(:Error error) => Err(error),
      },
    Err(:Error error) => Err(error),
  };
}

Result<int> multiply2(String first, String second) {
  return parseInt(first) //
      .andThen((n) => //
          parseInt(second) //
              .andThen((m) => Ok(n * m)));
}

Result<int> multiply3(String first, String second) {
  int firstNumber;
  int secondNumber;
  switch (parseInt(first)) {
    case Ok(:int value):
      firstNumber = value;
    case Err(:Error error):
      return Err(error);
  }
  switch (parseInt(second)) {
    case Ok(:int value):
      secondNumber = value;
    case Err(:Error error):
      return Err(error);
  }

  return Ok(firstNumber * secondNumber);
}

Option<T> getFirst<T>(List<T> list) {
  try {
    return Some(list.first);
  } catch (e) {
    return None();
  }
}

Option<Result<int>> doubleFirst(List<String> list) {
  return getFirst(list) //
      .map((first) => parseInt(first).map((n) => n * 2));
}

Result<Option<int>> doubleFirst2(List<String> list) {
  final opt = getFirst(list) //
      .map((first) => parseInt(first).map((n) => n * 2));

  return opt.mapOr(Ok(None()), (r) => r.map((x) => Some(x)));
}

List<Option<int>> ignoreFailed(List<String> strings) {
  return strings //
      .map((s) => parseInt(s).ok())
      .where((n) => n.isSome())
      .toList();
}

void collectErrors() {
  var strings = ["42", "tofu", "93", "999x", "18"];
  var errors = <Error>[];
  var numbers = strings
      .map((s) => parseInt(s))
      .map((r) => r.inspectErr((e) => errors.add(e)))
      .where((r) => r.isOk())
      .toList();

  print("Numbers: $numbers");
  print("Errors: $errors");
}

void printResult(Result<int> result) {
  switch (result) {
    case Ok(:int value):
      print('Number = $value');
    case Err(:Error error):
      print('$error');
  }
}

void main() {
  print('\n===== parseInt 1 =====');
  final x = parseInt('4') //
      .inspect((x) => print('original: $x'))
      .map((x) => x * x * x)
      .expect('Failed to parse number');
  print('x = $x');

  print('\n===== parseInt 2 =====');
  final y = parseInt('hello') //
      .inspectErr((e) => print('failed to parse int error: $e'));
  print('y = $y');

  print('\n===== parseInt List =====');
  final List<String> list = ['1', '2', '3', '4'];
  for (var s in list) {
    switch (parseInt(s).map((i) => i * 2)) {
      case Ok(value: final n):
        print(n);
      case Err(:Error error):
        print(error);
    }
  }

  print('\n===== multiply 1 =====');
  final twenty = multiply('2', '10');
  printResult(twenty);

  print('\n===== multiply 2 =====');
  final twenty2 = multiply2('2', '10');
  printResult(twenty2);

  print('\n===== multiply 3 =====');
  final twenty3 = multiply3('2', '10');
  printResult(twenty3);

  final numbers = ["42", "93", "18"];
  final List<String> empty = [];
  final strings = ["tofu", "93", "18"];

  print('\n===== doubleFirst numbers =====');
  print('The first doubled is: ${doubleFirst(numbers)}');

  print('\n===== doubleFirst empty =====');
  print('The first doubled is: ${doubleFirst(empty)}');

  print('\n===== doubleFirst string =====');
  print('The first doubled is: ${doubleFirst(strings)}');

  print('\n===== doubleFirst2 numbers =====');
  print('The first doubled is: ${doubleFirst2(numbers)}');

  print('\n===== doubleFirst2 empty =====');
  print('The first doubled is: ${doubleFirst2(empty)}');

  print('\n===== doubleFirst2 string =====');
  print('The first doubled is: ${doubleFirst2(strings)}');

  print('\n===== ignoreFailed numbers =====');
  print('The List is: ${ignoreFailed(numbers)}');

  print('\n===== ignoreFailed string =====');
  print('The List is: ${ignoreFailed(strings)}');

  print('\n===== ignoreFailed empty =====');
  print('The List is: ${ignoreFailed(empty)}');

  print('\n===== collectErrors =====');
  collectErrors();
}
