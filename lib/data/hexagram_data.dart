import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/hexagram.dart';

const _assetPath = 'assets/data/hexagrams.json';

/// Loads hexagrams from assets. Returns empty list on failure.
Future<List<Hexagram>> loadHexagrams() async {
  try {
    final str = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(str) as Map<String, dynamic>;
    final list = json['hexagrams'] as List<dynamic>? ?? [];
    return list
        .map((e) => Hexagram.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

final _random = Random();

/// Picks a random hexagram from the list. Returns [placeholderHexagram] if list is empty.
Hexagram getRandomHexagram(List<Hexagram> hexagrams) {
  if (hexagrams.isEmpty) return placeholderHexagram;
  return hexagrams[_random.nextInt(hexagrams.length)];
}

/// Fallback when asset load fails or list is empty (需 / Waiting).
Hexagram get placeholderHexagram => Hexagram(
      id: 5,
      nameCn: '需',
      nameEn: 'Waiting',
      binary: '010111',
      classical: HexagramClassical(
        judgmentCn: '有孚，光亨，贞吉。利涉大川。',
        linesCn: const {},
      ),
      modern: HexagramModern(
        summaryCn: '此卦强调等待与准备。',
        summaryEn: 'Patience and nourishment. Wait for the right moment.',
        linesExplainedCn: const {},
        linesExplainedEn: const {},
      ),
    );
