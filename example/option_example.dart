import 'package:unwrap_me/unwrap_me.dart';

Option<int> fn() {
  return None();
}

Option<int> stringToInt(String s) {
  try {
    final n = int.parse(s);
    return Some(n);
  } catch (e) {
    return None();
  }
}

Option<double> intToDouble(int i) {
  return Some(i.toDouble());
}

void main() {
  final x = fn();
  print('x = $x');

  final a = Some('10');
  // Orrible to read
  final Option<double> r = a.flatMap(
    (s) => stringToInt(s).flatMap(
      (i) => intToDouble(i),
    ),
  );
  print('r = $r');

  // A lot better, one day I will understand why the formatter puts two tabs!
  final Option<double> r1 = a //
      .flatMap(stringToInt)
      .flatMap(intToDouble);
  print('r1 = $r1');

  //final option = Option<Option<String>>.some(Some('String'));
  final option = Some(Some(Some(1)));
  final o = option //
      .flatMap(identity)
      .flatMap(identity);
  print('option = $option');
  print('o = $o');
  final o1 = option //
      .flatten()
      .flatten();
  print('o1 = $o1');

  final opt = Some(1);
  final opt1 = opt.and(Some('Hello'));
  print('opt1 = $opt1');

  final opt2 = opt //
      .andThen((v) => Some(2.5));
  print('opt2 = $opt2');

  final u = Some("hello").andThen((v) => Some(1));
  print('u = $u');
}
