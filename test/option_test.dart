import 'package:test/test.dart';
import 'package:unwrap_me/src/option.dart';
import 'package:unwrap_me/unwrap_me.dart';

class Point {
  final double x;
  final double y;
  const Point(this.x, this.y);

  factory Point.make(double x, double y) {
    return Point(x, y);
  }
  @override
  operator ==(Object other) => switch (other) {
        Point(x: double otherX, y: double otherY) => x == otherX && y == otherY,
        _ => false
      };

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() {
    return '($x, $y)';
  }
}

Point makePoint(double x, double y) {
  return Point(x, y);
}

void main() {
  group('Creational', () {
    test('Some<Unit>', () {
      const opt = Some(());
      expect(opt.unwrap(), ());
      expect(opt.isSome(), true);
      expect(opt.toString(), 'Some(())');
    });

    test('Infer Unit', () {
      Option<()> fn() {
        return const Some(());
      }

      final o = fn();
      expect(o.unwrap(), ());
    });

    test('Option.Some', () {
      final o = Option.Some(0);
      const o1 = Some(0);

      expect(o.expect('zero'), 0);
      expect(o, o1);
    });

    test('Option.None', () {
      const o = Option.None();
      const o1 = None();
      expect(() => o.expect('Something'), throwsA('Something'));

      // This fails if `const o1 = None;
      // FIXME: Understand why.
      expect(o, o1);
      expect(o1.isNone(), true);
      expect(o1.toString(), 'None');
    });
    test('Equality', () {
      expect(Some(1) == Some(1), isTrue);
      expect(Some(1).hashCode == Some(1).hashCode, isTrue);

      expect(Some(1) == Option.Some(1), isTrue);
      expect(Some(1).hashCode == Option.Some(1).hashCode, isTrue);

      expect(Some(1) == some(1), isTrue);
      expect(Some(1).hashCode == some(1).hashCode, isTrue);

      expect(None() == None(), isTrue);
      expect(None().hashCode == None().hashCode, isTrue);

      expect(None() == Option.None(), isTrue);
      expect(None().hashCode == Option.None().hashCode, isTrue);

      expect(None() == none(), isTrue);
      expect(None().hashCode == none().hashCode, isTrue);

      expect(None() == None<String>(), isTrue);
      expect(None<int>() == None<String>(), isTrue);
    });
  });

  group('Unwrappers', () {
    test('unwrap', () {
      expect(Some('air').unwrap(), 'air');
      expect(() => None().unwrap(), throwsA('None'));
    });
    test('unwrapOr', () {
      expect(Some('car').unwrapOr('bike'), 'car');
      expect(None().unwrapOr('bike'), 'bike');
    });
    test('unwrapOrElse', () {
      final k = 10;
      expect(Some(4).unwrapOrElse(() => 2 * k), 4);
      expect(None().unwrapOrElse(() => 2 * k), 20);
    });
  });

  group('Mapping and Matching', () {
    group('Maps', () {
      test('map Some', () {
        const o = Some(0);
        final o1 = o.map((v) => v.toString());
        expect(o1.unwrap(), '0');
      });
      test('map None', () {
        const o = None();
        final o1 = o.map((v) => v.toString());
        expect(() => o1.expect('Something'), throwsA('Something'));
      });
      test('mapOr Some', () {
        const o = Some(0);
        final s = o.mapOr('defaultValue', (v) => v.toString());
        expect(s, '0');
      });
      test('mapOr None', () {
        const o = None();
        final s = o.mapOr('defaultValue', (v) => v.toString());
        expect(s, 'defaultValue');
      });
      test('mapOrElse Some', () {
        const o = Some(0);
        final s = o.mapOrElse(() => 'default', (v) => v.toString());
        expect(s, '0');
      });
      test('mapOrElse None', () {
        const o = None();
        final s = o.mapOrElse(() => 'default', (v) => v.toString());
        expect(s, 'default');
      });
      test('flatMap Some', () {
        const o = Some(0);
        final s = o.flatMap((v) => Some(v.toString()));
        expect(s, Some('0'));
      });
      test('flatMap None', () {
        const o = Option<int>.None();
        final s = o.flatMap((v) => Some(v.toString()));
        expect(s, None());
      });
      test('flatten Some', () {
        expect(Some(Some(0)).flatten(), Some(0));
      });
      test('flatten None', () {
        expect(Some(None()).flatten(), None());
      });
      test('flatten Long', () {
        expect(
          Some(Some(Some(Some(Some(Some(1)))))) //
              .flatten()
              .flatten()
              .flatten(),
          Some(Some(Some(1))),
        );
        expect(
          Option.flatten(
            Option.flatten(
              Option.flatten(
                Some(Some(Some(Some(Some(Some(1)))))),
              ),
            ),
          ),
          Some(Some(Some(1))),
        );
      });
      test('or', () {
        expect(Some(0).or(Some(3)), Some(0));
        expect(None<int>().or(Some(3)), Some(3));
        expect(Some(0).or(None()), Some(0));
        expect(None<int>().or(None()), None());
      });
      test('orElse', () {
        expect(Some(0).orElse(() => Some(3)), Some(0));
        expect(None<int>().orElse(() => Some(3)), Some(3));
        expect(Some(0).orElse(() => None()), Some(0));
        expect(None<int>().orElse(() => None()), None());
      });
      test('xor', () {
        expect(Some(1).xor(None()), Some(1));
        expect(None<int>().xor(Some(2)), Some(2));
        expect(Some(1).xor(Some(2)), None());
      });
      test('and Some', () {
        const o = Option<int>.Some(0);
        final o1 = o.and(Some("Hello"));
        expect(o1, Some("Hello"));

        const o2 = Option<int>.Some(0);
        final o3 = o2.and(None());
        expect(o3, None());
      });
      test('and None', () {
        const o = None();
        final o1 = o.and(Some("Hello"));
        expect(o1, None());

        const o2 = None();
        final o3 = o2.and(None());
        expect(o3, None());
      });
      test('andThen Some', () {
        const o = Option<int>.Some(0);
        final o1 = o.andThen((v) => Some("Hello"));
        expect(o1, Some("Hello"));
      });
      test('andThen None', () {
        const o = None();
        final o1 = o.andThen((v) => Some("Hello"));
        expect(o1, None());
      });
      test('okOr', () {
        expect(Some('foo').okOr(0), Ok('foo'));
        expect(None().okOr(0), Err(0));
      });
      test('okOrElse', () {
        expect(Some('foo').okOrElse(() => 0), Ok('foo'));
        expect(None().okOrElse(() => 0), Err(0));
      });
      test('zip', () {
        expect(Some(1).zip(Some('hi')), Some((1, 'hi')));
        expect(Some(1).zip(None<int>()), None());
      });
      test('zipWith', () {
        final x = Some(3.0);
        final y = Some(2.0);
        expect(x.zipWith(y, Point.new), Some(Point(3.0, 2.0)));
        expect(x.zipWith(y, Point.make), Some(Point(3.0, 2.0)));
        expect(x.zipWith(y, makePoint), Some(Point(3.0, 2.0)));
        expect(None<double>().zipWith(y, makePoint), None());
      });
      test('unzip', () {
        expect(Some((1, 'hi')).unzip(), (Some(1), Some('hi')));
        expect(None<(int, String)>().unzip(), (None(), None()));
      });
      test('transpose', () {
        final Result<Option<int>, String> x = Ok(Some(5));
        final Option<Result<int, String>> y = Some(Ok(5));

        final Result<Option<int>, String> x1 = Err('error');
        final Option<Result<int, String>> y1 = Some(Err('error'));

        expect(x, y.transpose());
        expect(x.transpose(), y);
        expect(x1, y1.transpose());
        expect(x1.transpose(), y1);
        expect(None<Result<int, String>>().transpose(),
            Ok<Option<int>, String>(None()));
      });
      test('inspect', () {
        bool inspect = false;
        final x = Some(0).inspect((n) {
          inspect = true;
        });

        expect(inspect, true);
        expect(x, Some(0));

        inspect = false;
        final y = None().inspect((n) {
          inspect = true;
        });
        expect(inspect, false);
        expect(y, None());
      });
    });
    group('Matches', () {
      test('fold Some', () {
        const o = Option<int>.Some(2);
        final m = o.fold(
          (n) => n * n,
          () => 0,
        );
        expect(m, 4);

        final ms = switch (o) {
          Some(value: final n) => n * n,
          None() => 0,
        };
        expect(ms, 4);
      });
      test('fold None', () {
        const o = Option<int>.None();
        final m = o.fold(
          (n) => n * n,
          () => 0,
        );
        expect(m, 0);

        final ms = switch (o) {
          Some(value: final n) => n * n,
          None() => 0,
        };
        expect(ms, 0);
      });
    });
  });
  group('Iterator', () {
    test('iter', () {
      final x = Some(1);
      for (int i in x.iter()) {
        expect(i, 1);
      }

      x.iter().forEach((n) {
        expect(n, 1);
      });

      final y = None<int>();
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
  group('Filters', () {
    test('isSomeAnd', () {
      expect(Some(2).isSomeAnd((x) => x > 1), true);
      expect(Some(0).isSomeAnd((x) => x > 1), false);
      expect(None().isSomeAnd((x) => x > 1), false);
    });
    test('filter', () {
      bool isEven(int n) {
        return n % 2 == 0;
      }

      expect(None<int>().filter(isEven), None());
      expect(Some(3).filter(isEven), None());
      expect(Some(4).filter(isEven), Some(4));
    });
  });
}
