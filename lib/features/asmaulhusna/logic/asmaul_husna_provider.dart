import 'package:flutter/material.dart';
import '../data/asmaul_husna_model.dart';
import '../data/asmaul_husna_repository.dart';

class AsmaulHusnaProvider with ChangeNotifier {
  final AsmaulHusnaRepository _repository = AsmaulHusnaRepository();

  List<AsmaulHusna> _allNames = [];
  List<AsmaulHusna> _filteredNames = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<AsmaulHusna> get names => _filteredNames;
  bool get isLoading => _isLoading;

  AsmaulHusnaProvider() {
    loadNames();
  }

  Future<void> loadNames() async {
    _isLoading = true;
    notifyListeners();

    _allNames = await _repository.getAsmaulHusna();
    _applyFilter();

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredNames = List.from(_allNames);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredNames = _allNames.where((item) {
        return item.latin.toLowerCase().contains(query) ||
            item.index.toString().contains(query) ||
            item.translationEn.toLowerCase().contains(query) ||
            item.translationId.toLowerCase().contains(query);
      }).toList();
    }
  }
}
