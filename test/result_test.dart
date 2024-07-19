import 'package:test/test.dart';
import 'package:unwrap_me/src/result.dart';

import 'package:unwrap_me/unwrap_me.dart';

void main() {
  group('Creation', () {
    test('Ok<Unit>', () {
      const result = Ok(());
      expect(result.unwrap(), ());
    });

    test('Ok Infer Unit', () {
      Result<(), String> fn() {
        return const Ok(());
      }

      final result = fn();
      expect(result.unwrap(), ());
    });

    test('Err<Unit>', () {
      const result = Err(());
      expect(result.unwrapErr(), ());
    });

    test('Err Infer Unit', () {
      Result<String, ()> fn() {
        return const Err(());
      }

      final result = fn();
      expect(result.unwrapErr(), ());
    });

    test('Result.Ok', () {
      final r = Result.Ok(0);
      const r1 = Ok(0);

      expect(r.unwrap(), 0);
      expect(r, r1);
    });

    test('Result.Err', () {
      final r = Result.Err(0);
      const r1 = Err(0);

      expect(r.unwrapErr(), 0);
      expect(r, r1);
    });

    test('Equality', () {
      expect(Ok(1) == Ok(1), isTrue);
      expect(Ok(1).hashCode == Ok(1).hashCode, isTrue);

      expect(Err(1) == Err(1), isTrue);
      expect(Err(1).hashCode == Err(1).hashCode, isTrue);

      expect(Ok(1) == Result.Ok(1), isTrue);
      expect(Ok(1).hashCode == Result.Ok(1).hashCode, isTrue);

      expect(Err(1) == Result.Err(1), isTrue);
      expect(Err(1).hashCode == Result.Err(1).hashCode, isTrue);

      expect(Ok(1) == ok(1), isTrue);
      expect(Ok(1).hashCode == ok(1).hashCode, isTrue);

      expect(Err(1) == error(1), isTrue);
      expect(Err(1).hashCode == error(1).hashCode, isTrue);
    });
  });

  group('Mapping and Matching', () {
    test('map', () {
      expect(Ok(4).map((n) => n.toString()), Ok('4'));
      expect(Err(4).map((n) => n.toString()), Err(4));
    });

    test('mapErr', () {
      String stringify(int x) {
        return 'Error code: $x.';
      }

      expect(Ok<int, int>(2).mapErr(stringify), Ok(2));
      expect(Err<int, int>(13).mapErr(stringify), Err('Error code: 13.'));
    });

    test('mapOrElse', () {
      final k = 21;

      expect(Ok('foo').mapOrElse((e) => k * 2, (v) => v.length), 3);
      expect(Err('bar').mapOrElse((e) => k * 2, (v) => v.length), 42);
    });

    test('mapOrElse', () {
      expect(Ok('foo').mapOr(42, (v) => v.length), 3);
      expect(Err('bar').mapOr(42, (v) => v.length), 42);
    });

    test('flatMap', () {
      expect(Ok(4).flatMap((n) => Ok(n.toString())), Ok('4'));
      expect(Err(4).flatMap((n) => Ok(n.toString())), Err(4));
    });

    test('flatMapErr', () {
      Result<int, String> stringify(int x) {
        return Err('Error code: $x.');
      }

      expect(Ok<int, int>(2).flatMapErr(stringify), Ok(2));
      expect(Err<int, int>(13).flatMapErr(stringify), Err('Error code: 13.'));
    });

    test('and', () {
      expect(
        Ok<int, String>(2).and(Err<String, String>('late error')),
        Err('late error'),
      );
      expect(
        Err<int, String>('early error').and(Ok<String, String>('foo')),
        Err('early error'),
      );
      expect(
        Err<int, String>('not a 2').and(Err<String, String>('late error')),
        Err('not a 2'),
      );
      expect(
        Ok<int, String>(2).and(Ok<String, String>('different result type')),
        Ok('different result type'),
      );
    });
    test('andThen', () {
      Option<int> checkedDiv((int n, int d) couple) {
        final (n, d) = couple;
        return d == 0 ? None() : Some(n ~/ d);
      }

      Result<String, String> divThenToString((int n, int d) couple) {
        return checkedDiv(couple)
            .map((div) => div.toString())
            .okOr('division by zero');
      }

      expect(
        Ok((4, 2)).andThen(divThenToString),
        Ok(2.toString()),
      );
      expect(
        Ok((4, 0)).andThen(divThenToString),
        Err('division by zero'),
      );
      expect(
        Err<(int, int), String>('not a number').andThen(divThenToString),
        Err('not a number'),
      );
    });
    test('flatten', () {
      expect(Ok(Ok('hello')).flatten(), Ok('hello'));
      expect(Ok(Err(6)).flatten(), Err(6));
      expect(Ok(Ok(Ok('hello'))).flatten(), Ok(Ok('hello')));
      expect(
        Ok(Ok(Ok('hello'))) //
            .flatten()
            .flatten(),
        Ok('hello'),
      );
    });

    test('fold', () {
      final r = Ok<String, String>('OK').fold(
        (o) => 13,
        (e) => 42,
      );
      expect(r, 13);
      final r1 = Err<String, String>('ERR').fold(
        (o) => 13,
        (e) => 42,
      );
      expect(r1, 42);
    });
  });

  group('Unwrappers', () {
    test('unwrap', () {
      expect(Ok(2).unwrap(), 2);
      expect(() => Err('emergency failure').unwrap(),
          throwsA('emergency failure'));
    });
    test('unwrapOr', () {
      expect(Ok<int, String>(9).unwrapOr(2), 9);
      expect(Err<int, String>('error').unwrapOr(2), 2);
    });
    test('unwrapOrElse', () {
      expect(Ok<int, String>(2).unwrapOrElse((e) => e.length), 2);
      expect(Err<int, String>('foo').unwrapOrElse((e) => e.length), 3);
    });
    test('ok', () {
      expect(Ok(2).ok(), Some(2));
      expect(Err('Nothing here').ok(), None());
    });
    test('err', () {
      expect(Ok(2).err(), None());
      expect(Err('Nothing here').err(), Some('Nothing here'));
    });
  });
  group('Filters', () {
    test('isOkAnd', () {
      expect(Ok(2).isOkAnd((x) => x > 1), true);
      expect(Ok(0).isOkAnd((x) => x > 1), false);
      expect(Err(1).isOkAnd((x) => x > 1), false);
    });
    test('isErrAnd', () {
      expect(Err(2).isErrAnd((x) => x > 1), true);
      expect(Err(0).isErrAnd((x) => x > 1), false);
      expect(Ok(1).isOkAnd((x) => x > 1), false);
    });
  });
  group('Iterator', () {
    test('iter', () {
      final x = Ok(1);
      for (int i in x.iter()) {
        expect(i, 1);
      }

      x.iter().forEach((n) {
        expect(n, 1);
      });

      final y = Err(1);
      bool something = false;
      for (int _ in y.iter()) {
        something = true;
      }
      expect(something, false);

      y.iter().forEach((n) {
        something = true;
      });
      expect(something, false);
    });
  });
}
