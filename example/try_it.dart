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

  list.forEach((number) {
    switch (parseInt(number).map((i) => i * 2)) {
      case Ok(val: final n):
        print(n);
      case Err(:String err):
        print(err);
    }
  });
}
