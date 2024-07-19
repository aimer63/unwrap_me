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

    test('Result.ok', () {
      final r = Result.ok(0);
      const r1 = Ok(0);

      expect(r.unwrap(), 0);
      expect(r, r1);
    });

    test('Result.err', () {
      final r = Result.err(0);
      const r1 = Err(0);

      expect(r.unwrapErr(), 0);
      expect(r, r1);
    });

    test('Equality', () {
      expect(Ok(1) == Ok(1), isTrue);
      expect(Ok(1).hashCode == Ok(1).hashCode, isTrue);

      expect(Err(1) == Err(1), isTrue);
      expect(Err(1).hashCode == Err(1).hashCode, isTrue);

      expect(Ok(1) == Result.ok(1), isTrue);
      expect(Ok(1).hashCode == Result.ok(1).hashCode, isTrue);

      expect(Err(1) == Result.err(1), isTrue);
      expect(Err(1).hashCode == Result.err(1).hashCode, isTrue);

      expect(Ok(1) == ok(1), isTrue);
      expect(Ok(1).hashCode == ok(1).hashCode, isTrue);

      expect(Err(1) == err(1), isTrue);
      expect(Err(1).hashCode == err(1).hashCode, isTrue);
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
      // TODO:
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
  });
}
