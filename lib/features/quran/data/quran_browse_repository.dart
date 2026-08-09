import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:muslimate/features/quran/models/quran_browse_item.dart';

abstract interface class QuranBrowseRepository {
  Future<List<QuranBrowseItem>> getSurahs();
  Future<List<QuranBrowseItem>> getJuz();
}

class AssetQuranBrowseRepository implements QuranBrowseRepository {
  AssetQuranBrowseRepository({
    required String languageCode,
    AssetBundle? bundle,
  }) : _languageCode = languageCode == 'id' ? 'id' : 'en',
       _bundle = bundle ?? rootBundle;

  static const _coreAsset = 'assets/quran/core/quran_index.json';

  final String _languageCode;
  final AssetBundle _bundle;
  Future<_QuranBrowseData>? _cachedData;

  @override
  Future<List<QuranBrowseItem>> getSurahs() async => (await _load()).surahs;

  @override
  Future<List<QuranBrowseItem>> getJuz() async => (await _load()).juz;

  Future<_QuranBrowseData> _load() {
    return _cachedData ??= _readAssets();
  }

  Future<_QuranBrowseData> _readAssets() async {
    final languageAsset =
        'assets/quran/languages/$_languageCode/chapter_names.json';
    final values = await Future.wait([
      _bundle.loadString(_coreAsset),
      _bundle.loadString(languageAsset),
    ]);
    final core = _decodeObject(values[0], _coreAsset);
    final localization = _decodeObject(values[1], languageAsset);
    _validateSchema(core, _coreAsset);
    _validateSchema(localization, languageAsset);

    if (localization['language'] != _languageCode) {
      throw const FormatException('Quran language asset does not match locale');
    }

    final chapterValues = core['chapters'];
    final localizedValues = localization['chapters'];
    final juzValues = core['juz'];
    if (chapterValues is! List ||
        localizedValues is! Map<String, dynamic> ||
        juzValues is! List) {
      throw const FormatException('Invalid Quran browse asset structure');
    }
    if (chapterValues.length != 114 || juzValues.length != 30) {
      throw const FormatException('Incomplete Quran browse assets');
    }

    final surahs = <QuranBrowseItem>[];
    for (var index = 0; index < chapterValues.length; index++) {
      final chapter = _asObject(chapterValues[index], 'chapter');
      final id = _asInt(chapter['id'], 'chapter id');
      if (id != index + 1) {
        throw const FormatException('Quran chapters are not correctly ordered');
      }
      final meaning = localizedValues['$id'];
      if (meaning is! String || meaning.isEmpty) {
        throw FormatException('Missing localized name for Surah $id');
      }
      final revelationPlace = _asString(
        chapter['revelationPlace'],
        'revelation place',
      );
      if (revelationPlace != 'makkah' && revelationPlace != 'madinah') {
        throw FormatException('Invalid revelation place for Surah $id');
      }
      surahs.add(
        QuranBrowseItem(
          type: QuranBrowseType.surah,
          number: id,
          title: _asString(chapter['nameSimple'], 'Surah name'),
          surahNumber: id,
          ayahNumber: 1,
          arabicTitle: _asString(chapter['nameArabic'], 'Arabic Surah name'),
          meaning: meaning,
          ayahCount: _asInt(chapter['versesCount'], 'verse count'),
          revelationType: _revelationLabel(revelationPlace),
        ),
      );
    }

    final juz = <QuranBrowseItem>[];
    for (var index = 0; index < juzValues.length; index++) {
      final value = _asObject(juzValues[index], 'juz');
      final number = _asInt(value['number'], 'juz number');
      if (number != index + 1) {
        throw const FormatException('Quran Juz are not correctly ordered');
      }
      final verseKey = _asString(value['startVerseKey'], 'Juz start');
      final parts = verseKey.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid start position for Juz $number');
      }
      final surahNumber = int.tryParse(parts[0]);
      final ayahNumber = int.tryParse(parts[1]);
      if (surahNumber == null ||
          surahNumber < 1 ||
          surahNumber > 114 ||
          ayahNumber == null ||
          ayahNumber < 1) {
        throw FormatException('Invalid start position for Juz $number');
      }
      juz.add(
        QuranBrowseItem(
          type: QuranBrowseType.juz,
          number: number,
          title: 'Juz $number',
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
        ),
      );
    }

    return _QuranBrowseData(List.unmodifiable(surahs), List.unmodifiable(juz));
  }

  String _revelationLabel(String value) {
    if (_languageCode == 'id') {
      return value == 'makkah' ? 'Makkiyah' : 'Madaniyah';
    }
    return value == 'makkah' ? 'Meccan' : 'Medinan';
  }
}

class _QuranBrowseData {
  const _QuranBrowseData(this.surahs, this.juz);

  final List<QuranBrowseItem> surahs;
  final List<QuranBrowseItem> juz;
}

Map<String, dynamic> _decodeObject(String source, String assetName) {
  final value = jsonDecode(source);
  if (value is! Map<String, dynamic>) {
    throw FormatException('$assetName must contain a JSON object');
  }
  return value;
}

Map<String, dynamic> _asObject(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('Invalid $field');
  }
  return value;
}

String _asString(Object? value, String field) {
  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid $field');
  }
  return value;
}

int _asInt(Object? value, String field) {
  if (value is! int) throw FormatException('Invalid $field');
  return value;
}

void _validateSchema(Map<String, dynamic> value, String assetName) {
  if (value['schemaVersion'] != 1) {
    throw FormatException('Unsupported schema in $assetName');
  }
}
