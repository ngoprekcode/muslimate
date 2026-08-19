import 'package:flutter/foundation.dart';
import 'package:muslimate/features/quran/data/quran_last_read_store.dart';
import 'package:muslimate/features/quran/models/quran_last_read.dart';

class QuranLastReadProvider extends ChangeNotifier {
  QuranLastReadProvider(this._store);

  final QuranLastReadStore _store;
  bool _disposed = false;
  bool isLoading = true;
  QuranLastRead? position;

  Future<void> load() async {
    final stored = await _store.load();
    if (_disposed) return;
    position = stored;
    isLoading = false;
    notifyListeners();
  }

  Future<void> update(QuranLastRead nextPosition) async {
    position = nextPosition;
    if (!_disposed) notifyListeners();
    await _store.save(nextPosition);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
