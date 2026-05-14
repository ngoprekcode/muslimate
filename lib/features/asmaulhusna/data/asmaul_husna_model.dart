class AsmaulHusna {
  final int index;
  final String latin;
  final String arabic;
  final String translationEn;
  final String translationId;

  const AsmaulHusna({
    required this.index,
    required this.latin,
    required this.arabic,
    required this.translationEn,
    required this.translationId,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      index: json['index'] as int,
      latin: json['latin'] as String,
      arabic: json['arabic'] as String,
      translationEn: json['translation_en'] as String,
      translationId: json['translation_id'] as String,
    );
  }
}
