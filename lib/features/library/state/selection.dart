import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';

/// Multi-select state: the selected songs and the list they came from (for
/// "select all").
@immutable
class SelectionState {
  const SelectionState({this.selected = const {}, this.scope = const []});

  static const empty = SelectionState();

  final Set<String> selected;
  final List<Track> scope;

  bool get active => selected.isNotEmpty;
  bool contains(String key) => selected.contains(key);

  /// Selected songs in list order.
  List<Track> get tracks => [
    for (final t in scope)
      if (selected.contains(t.key)) t,
  ];
}

class SelectionNotifier extends Notifier<SelectionState> {
  @override
  SelectionState build() => SelectionState.empty;

  void start(Track t, List<Track> scope) => state = SelectionState(selected: {t.key}, scope: scope);

  void toggle(Track t) {
    final next = {...state.selected};
    if (!next.remove(t.key)) next.add(t.key);
    state = SelectionState(selected: next, scope: state.scope);
  }

  void selectAll() => state = SelectionState(selected: {for (final t in state.scope) t.key}, scope: state.scope);

  void clear() => state = SelectionState.empty;
}

final selectionProvider = NotifierProvider<SelectionNotifier, SelectionState>(SelectionNotifier.new);

final isSelectedProvider = Provider.family<bool, String>((ref, key) => ref.watch(selectionProvider).contains(key));
