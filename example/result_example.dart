import 'package:unwrap_me/unwrap_me.dart';

Result<int, String> parseInt(String number) {
  try {
    return Ok(int.parse(number));
  } catch (e) {
    return Err(e.toString());
  }
}

void main() {
  final List<String> list = ['1', '2x', '3', '4'];

  for (var s in list) {
    switch (parseInt(s).map((i) => i * 2)) {
      case Ok(value: final n):
        print(n);
      case Err(:String error):
        print(error);
    }
  }

  final x = parseInt('4') //
      .inspect((x) => print('original: $x'))
      .map((x) => x * x * x)
      .expect('Failed to parse number');
  print('x = $x');

  final y = parseInt('hello') //
      .inspectErr((e) => print('failed to parse int error: $e'));
}
