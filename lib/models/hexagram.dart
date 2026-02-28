/// Hexagram model matching assets/data/hexagrams.json.
/// Binary convention: bottom→top; "1" = yang (solid), "0" = yin (broken).
class Hexagram {
  const Hexagram({
    required this.id,
    required this.nameCn,
    required this.nameEn,
    required this.binary,
    required this.classical,
    required this.modern,
  });

  factory Hexagram.fromJson(Map<String, dynamic> json) {
    final classicalJson = json['classical'] as Map<String, dynamic>? ?? {};
    final modernJson = json['modern'] as Map<String, dynamic>? ?? {};
    return Hexagram(
      id: json['id'] as int,
      nameCn: json['name_cn'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      binary: json['binary'] as String? ?? '000000',
      classical: HexagramClassical.fromJson(
        classicalJson.cast<String, dynamic>(),
      ),
      modern: HexagramModern.fromJson(modernJson.cast<String, dynamic>()),
    );
  }

  final int id;
  final String nameCn;
  final String nameEn;
  final String binary;
  final HexagramClassical classical;
  final HexagramModern modern;

  /// Lines bottom→top: true = solid (yang), false = broken (yin).
  List<bool> get lines {
    final b = binary.padRight(6, '0').substring(0, 6);
    return b.split('').map((c) => c == '1').toList();
  }
}

class HexagramClassical {
  const HexagramClassical({
    required this.judgmentCn,
    required this.linesCn,
  });

  factory HexagramClassical.fromJson(Map<String, dynamic> json) {
    final linesCn = json['lines_cn'];
    return HexagramClassical(
      judgmentCn: json['judgment_cn'] as String? ?? '',
      linesCn: linesCn is Map
          ? (linesCn as Map).map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : <String, String>{},
    );
  }

  final String judgmentCn;
  final Map<String, String> linesCn;
}

class HexagramModern {
  const HexagramModern({
    required this.summaryCn,
    required this.summaryEn,
    required this.linesExplainedCn,
    required this.linesExplainedEn,
  });

  factory HexagramModern.fromJson(Map<String, dynamic> json) {
    final lc = json['lines_explained_cn'];
    final le = json['lines_explained_en'];
    return HexagramModern(
      summaryCn: json['summary_cn'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? '',
      linesExplainedCn: lc is Map
          ? (lc as Map).map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : <String, String>{},
      linesExplainedEn: le is Map
          ? (le as Map).map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          : <String, String>{},
    );
  }

  final String summaryCn;
  final String summaryEn;
  final Map<String, String> linesExplainedCn;
  final Map<String, String> linesExplainedEn;
}
