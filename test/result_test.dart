import 'package:test/test.dart';

import 'package:unwrap_me/unwrap_me.dart';

void main() {
  group('Creation', () {
    test('Ok<Unit>', () {
      const result = Ok(());
      expect(result.unwrap(), ());
    });

    test('Infer Ok<Unit> type', () {
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

    test('Infer Err<Unit> type', () {
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

    test('Equatable', () {
      expect(const Ok(1) == const Ok(1), isTrue);
      expect(const Ok(1).hashCode == const Ok(1).hashCode, isTrue);

      expect(const Err(1) == const Err(1), isTrue);
      expect(const Err(1).hashCode == const Err(1).hashCode, isTrue);

      expect(const Ok(1) == Result.ok(1), isTrue);
      expect(const Ok(1).hashCode == Result.ok(1).hashCode, isTrue);

      expect(const Err(1) == Result.err(1), isTrue);
      expect(const Err(1).hashCode == Result.err(1).hashCode, isTrue);

      expect(const Ok(1) == ok(1), isTrue);
      expect(const Ok(1).hashCode == ok(1).hashCode, isTrue);

      expect(const Err(1) == err(1), isTrue);
      expect(const Err(1).hashCode == err(1).hashCode, isTrue);
    });
  });

  group('Mapping and Matching', () {
    group('Map', () {
      test('Ok', () {
        const r = Ok(4);
        final r1 = r.map((v) => '=' * v);

        expect(r1.unwrap(), '====');
      });

      test('Err', () {
        final r = err<String, int>(4);
        final r1 = r.map((v) => 'change_it');

        expect(() => r1.unwrap(), throwsA(4));
        expect(r1.unwrapErr(), 4);
      });
    });

    group('MapErr', () {
      test('Ok', () {
        const r = Ok<int, int>(4);
        final r1 = r.mapErr((e) => '=' * e);

        expect(r1.unwrap(), 4);
        expect(() => r1.unwrapErr(), throwsA(4));
      });

      test('Err', () {
        const r = Err<String, int>(4);
        final r1 = r.mapErr((e) => '=' * e);

        expect(() => r1.unwrap(), throwsA('===='));
        expect(r1.unwrapErr(), "====");
      });
    });

    group('FlatMap', () {
      test('Ok', () {
        const r = Ok<int, int>(4);
        final r1 = r.flatMap((v) => Ok('=' * v));

        expect(r1.unwrap(), '====');
      });

      test('Err', () {
        final r = err<String, int>(4);
        final r1 = r.flatMap((_) => const Ok('===='));

        expect(() => r1.unwrap(), throwsA(4));
        expect(r1.unwrapErr(), 4);
      });
    });

    group('FlatMapError', () {
      test('Ok', () {
        const r = Ok<int, String>(4);
        final r1 = r.flatMapErr((v) => const Err('===='));

        expect(r1.unwrap(), 4);
        expect(() => r1.unwrapErr(), throwsA(4));
      });

      test('Err', () {
        const r = Err<int, int>(4);
        final r1 = r.flatMapErr((e) => Err('=' * e));

        expect(() => r1.unwrap(), throwsA("===="));
        expect(r1.unwrapErr(), "====");
      });
    });

    group('Match', () {
      test('Ok', () {
        const r = Ok<String, String>('====');
        final r1 = r.match(
          (o) => 13,
          (e) => 42,
        );

        expect(r1, 13);
      });
      test('Err', () {
        const r = Err<String, String>('====');
        final r1 = r.match(
          (o) => 13,
          (e) => 42,
        );

        expect(r1, 42);
      });
    });
  });

  group('Unwrappers', () {
    group('unwrap', () {
      test('Ok', () {
        const Result<int, String> r = Ok(0);
        expect(r.unwrap(), 0);
      });
      test('Err', () {
        const Result<int, String> r = Err('Failure');
        expect(r.unwrap, throwsA('Failure'));
      });
    });
    group('unwrapOrElse', () {
      test('Ok', () {
        const r = Ok<int, String>(0);
        final val = r.unwrapOrElse((e) => -1);
        expect(val, 0);
      });

      test('Err', () {
        const r = Err<String, int>(0);
        final val = r.unwrapOrElse((e) => 'zero');
        expect(val, 'zero');
      });
    });
    group('unwrapOr', () {
      test('Ok', () {
        const r = Ok<int, String>(0);
        final val = r.unwrapOr(-1);
        expect(val, 0);
      });

      test('Err', () {
        const r = Err<String, int>(0);
        final val = r.unwrapOr('zero');
        expect(val, 'zero');
      });
    });
  });
}
