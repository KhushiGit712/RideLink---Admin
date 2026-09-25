import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GooglePlacesService {
  static const String apiKey = 'AIzaSyArHLeevUloxh2JjudrB2KaL5SrJEkTM9k';
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  /// Fetch place predictions using Google Places API (New) with fallback
  static Future<List<String>> getPlacePredictions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    try {
      // 1. Try Google Places API (New)
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
          },
        ),
        data: jsonEncode({
          'input': trimmed,
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String
            ? jsonDecode(response.data as String)
            : Map<String, dynamic>.from(response.data as Map);

        final List<dynamic>? suggestions = data['suggestions'] as List<dynamic>?;
        if (suggestions != null && suggestions.isNotEmpty) {
          final List<String> results = [];
          for (final item in suggestions) {
            final prediction = item['placePrediction'];
            if (prediction != null) {
              final textObj = prediction['text'];
              if (textObj != null && textObj['text'] != null) {
                results.add(textObj['text'].toString());
              } else if (prediction['structuredFormat'] != null) {
                final sf = prediction['structuredFormat'];
                final main = sf['mainText']?['text'] ?? '';
                final secondary = sf['secondaryText']?['text'] ?? '';
                if (main.isNotEmpty) {
                  results.add(secondary.isNotEmpty ? '$main, $secondary' : main);
                }
              }
            }
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (e) {
      debugPrint('Places API (New) fetch error: $e');
    }

    // 2. Fallback attempt via Legacy Autocomplete
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': trimmed,
          'key': apiKey,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is String
            ? jsonDecode(response.data as String)
            : Map<String, dynamic>.from(response.data as Map);

        final predictions = data['predictions'] as List<dynamic>?;
        if (predictions != null) {
          return predictions
              .map((p) => p['description']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Legacy Places API fallback error: $e');
    }

    return [];
  }
}

