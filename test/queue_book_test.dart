import 'package:feruzbek/features/library/data/models.dart';
import 'package:feruzbek/features/player/data/queue_book.dart';
import 'package:flutter_test/flutter_test.dart';

Track _t(String k) => Track(key: k, title: k, uri: 'file:///$k.mp3', duration: const Duration(minutes: 3));

QueueBook _book(List<String> keys, {int? current}) {
  final b = QueueBook()..replace(keys.map(_t).toList());
  if (current != null) b.setCurrent(current);
  return b;
}

List<String> _keys(QueueBook b) => b.tracks.map((t) => t.key).toList();

void main() {
  group('empty queue', () {
    test('has no current item and safe lookups', () {
      final b = QueueBook();
      expect(b.isEmpty, isTrue);
      expect(b.current, isNull);
      expect(b.at(0), isNull);
      expect(b.at(-1), isNull);
      expect(b.nextInsertIndex, 0);
    });

    test('rejects out-of-range operations', () {
      final b = QueueBook();
      expect(b.setCurrent(0), isFalse);
      expect(b.removeAt(0), isFalse);
      expect(b.move(0, 1), isFalse);
      expect(b.playbackOrder([3, 1]), isEmpty);
    });
  });

  group('single song', () {
    test('play next goes after it', () {
      final b = _book(['a'], current: 0);
      b.insert(b.nextInsertIndex, _t('n'));
      expect(_keys(b), ['a', 'n']);
      expect(b.currentIndex, 0);
    });

    test('removing it leaves no current item', () {
      final b = _book(['a'], current: 0)..removeAt(0);
      expect(b.isEmpty, isTrue);
      expect(b.currentIndex, isNull);
      expect(b.current, isNull);
    });
  });

  group('current index bookkeeping', () {
    test('setCurrent reports changes only', () {
      final b = _book(['a', 'b', 'c']);
      expect(b.setCurrent(1), isTrue);
      expect(b.setCurrent(1), isFalse);
      expect(b.setCurrent(5), isFalse);
      expect(b.current!.key, 'b');
    });

    test('resetCurrent makes the same index report again', () {
      final b = _book(['a', 'b'], current: 1)..resetCurrent();
      expect(b.setCurrent(1), isTrue);
    });

    test('inserting before current shifts it', () {
      final b = _book(['a', 'b', 'c'], current: 1)..insert(0, _t('x'));
      expect(b.current!.key, 'b');
      expect(b.currentIndex, 2);
    });

    test('play next on the last item appends', () {
      final b = _book(['a', 'b', 'c'], current: 2);
      expect(b.nextInsertIndex, 3);
      b.insert(b.nextInsertIndex, _t('n'));
      expect(_keys(b), ['a', 'b', 'c', 'n']);
      expect(b.current!.key, 'c');
    });

    test('removing before current shifts it back', () {
      final b = _book(['a', 'b', 'c'], current: 2)..removeAt(0);
      expect(b.current!.key, 'c');
    });

    test('removing the current last item clamps to the new last item', () {
      final b = _book(['a', 'b', 'c'], current: 2)..removeAt(2);
      expect(b.currentIndex, 1);
      expect(b.current!.key, 'b');
    });

    test('removing after current keeps it', () {
      final b = _book(['a', 'b', 'c'], current: 0)..removeAt(2);
      expect(b.current!.key, 'a');
    });

    test('moving the current item follows it', () {
      final b = _book(['a', 'b', 'c', 'd'], current: 1)..move(1, 3);
      expect(_keys(b), ['a', 'c', 'd', 'b']);
      expect(b.current!.key, 'b');
    });

    test('moving across the current item adjusts it', () {
      final b = _book(['a', 'b', 'c', 'd'], current: 2)..move(0, 3);
      expect(b.current!.key, 'c');
      final b2 = _book(['a', 'b', 'c', 'd'], current: 1)..move(3, 0);
      expect(b2.current!.key, 'b');
    });

    test('replace clears the current item', () {
      final b = _book(['a', 'b'], current: 1)..replace([_t('x')]);
      expect(b.currentIndex, isNull);
    });
  });

  group('removal by key', () {
    test('returns indices highest first so they can be removed in order', () {
      final b = _book(['a', 'x', 'b', 'x']);
      final idx = b.indicesOf({'x'});
      expect(idx, [3, 1]);
      for (final i in idx) {
        b.removeAt(i);
      }
      expect(_keys(b), ['a', 'b']);
    });
  });

  group('playback order', () {
    test('natural order without shuffle', () {
      expect(_book(['a', 'b', 'c']).playbackOrder(null), [0, 1, 2]);
    });

    test('drops stale shuffle indices', () {
      expect(_book(['a', 'b']).playbackOrder([1, 4, 0, -1]), [1, 0]);
    });
  });
}
