import 'package:test/test.dart';
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
    });

    test('Infer Some<Unit> type', () {
      Option<()> fn() {
        return const Some(());
      }

      final o = fn();
      expect(o.unwrap(), ());
    });

    test('Option.some', () {
      final o = Option.some(0);
      const o1 = Some(0);

      expect(o.expect('zero'), 0);
      expect(o, o1);
    });

    test('Option.none', () {
      const o = Option.none();
      const o1 = None();
      expect(() => o.expect('Something'), throwsA('Something'));

      // This fails if `const o1 = None;
      // FIXME: Understand why.
      expect(o, o1);
    });
    test('Equatable', () {
      expect(const Some(1) == const Some(1), isTrue);
      expect(const Some(1).hashCode == const Some(1).hashCode, isTrue);

      expect(const Some(1) == const Option.some(1), isTrue);
      expect(const Some(1).hashCode == const Option.some(1).hashCode, isTrue);

      expect(const Some(1) == some(1), isTrue);
      expect(const Some(1).hashCode == some(1).hashCode, isTrue);

      expect(const None() == const None(), isTrue);
      expect(const None().hashCode == const None().hashCode, isTrue);

      expect(const None() == const Option.none(), isTrue);
      expect(const None().hashCode == const Option.none().hashCode, isTrue);

      expect(const None() == none(), isTrue);
      expect(const None().hashCode == none().hashCode, isTrue);
    });
  });

  group('Mapping and Matching', () {
    group('Maps', () {
      test('Map Some', () {
        const o = Some(0);
        final o1 = o.map((v) => v.toString());
        expect(o1.unwrap(), '0');
      });
      test('Map None', () {
        const o = None();
        final o1 = o.map((v) => v.toString());
        expect(() => o1.expect('Something'), throwsA('Something'));
      });
      test('MapOr Some', () {
        const o = Some(0);
        final s = o.mapOr('defaultValue', (v) => v.toString());
        expect(s, '0');
      });
      test('MapOr None', () {
        const o = None();
        final s = o.mapOr('defaultValue', (v) => v.toString());
        expect(s, 'defaultValue');
      });
      test('MapElse Some', () {
        const o = Some(0);
        final s = o.mapOrElse(() => 'default', (v) => v.toString());
        expect(s, '0');
      });
      test('MapOrElse None', () {
        const o = None();
        final s = o.mapOrElse(() => 'default', (v) => v.toString());
        expect(s, 'default');
      });
      test('FlatMap Some', () {
        const o = Some(0);
        final s = o.flatMap((v) => Some(v.toString()));
        expect(s, Some('0'));
      });
      test('FlatMap None', () {
        const o = Option<int>.none();
        final s = o.flatMap((v) => Some(v.toString()));
        expect(s, None());
      });
      test('Flatten Some', () {
        expect(Some(Some(0)).flatten(), Some(0));
      });
      test('Flatten None', () {
        expect(Some(None()).flatten(), None());
      });
      test('Flatten Long', () {
        expect(
          Some(Some(Some(Some(Some(Some(1)))))) //
              .flatten()
              .flatten()
              .flatten(),
          Some(Some(Some(1))),
        );
      });
      test('Or', () {
        expect(Some(0).or(Some(3)), Some(0));
        expect(None<int>().or(Some(3)), Some(3));
        expect(Some(0).or(None()), Some(0));
        expect(None<int>().or(None()), None());
      });
      test('OrElse', () {
        expect(Some(0).orElse(() => Some(3)), Some(0));
        expect(None<int>().orElse(() => Some(3)), Some(3));
        expect(Some(0).orElse(() => None()), Some(0));
        expect(None<int>().orElse(() => None()), None());
      });
      test('And Some', () {
        const o = Option<int>.some(0);
        final o1 = o.and(Some("Hello"));
        expect(o1, Some("Hello"));

        const o2 = Option<int>.some(0);
        final o3 = o2.and(None());
        expect(o3, None());
      });
      test('And None', () {
        const o = None();
        final o1 = o.and(Some("Hello"));
        expect(o1, None());

        const o2 = None();
        final o3 = o2.and(None());
        expect(o3, None());
      });
      test('AndThen Some', () {
        const o = Option<int>.some(0);
        final o1 = o.andThen((v) => Some("Hello"));
        expect(o1, Some("Hello"));
      });
      test('AndThen None', () {
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
      });
    });
    group('Matches', () {
      test('Match Some', () {
        const o = Option<int>.some(2);
        final m = o.fold(
          (n) => n * n,
          () => 0,
        );
        expect(m, 4);

        final ms = switch (o) {
          Some(val: final n) => n * n,
          None() => 0,
        };
        expect(ms, 4);
      });
      test('Match None', () {
        const o = Option<int>.none();
        final m = o.fold(
          (n) => n * n,
          () => 0,
        );
        expect(m, 0);

        final ms = switch (o) {
          Some(val: final n) => n * n,
          None() => 0,
        };
        expect(ms, 0);
      });
    });
  });
}
