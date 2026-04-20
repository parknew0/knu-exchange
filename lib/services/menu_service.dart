import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해 추가
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/menu_item.dart';

class MenuService {
  final String _sheetUrl = dotenv.env['MENU_SHEET_URL'] ?? '';

  Future<List<MenuItem>> fetchRemoteMenu() async {
    try {
      final response = await http.get(Uri.parse(_sheetUrl));

      if (response.statusCode == 200) {
        // [디버깅] 실제 데이터가 어떻게 오는지 로그 확인
        debugPrint('--- Menu CSV Fetch Success ---');

        List<List<dynamic>> rows = const CsvToListConverter().convert(response.body);

        if (rows.length <= 1) {
          debugPrint('Warning: No data rows found in CSV.');
          return [];
        }

        // 데이터 변환 및 로그 출력
        final items = rows.skip(1).map((row) {
          final item = MenuItem.fromCsv(row);
          // dinner가 포함되어 있는지 확인용 로그
          if (item.meal.contains('dinner')) {
            debugPrint('Found dinner item: ${item.date} - ${item.facility}');
          }
          return item;
        }).toList();

        return items;
      } else {
        throw Exception('Failed to load menu: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching menu: $e');
      rethrow;
    }
  }
}