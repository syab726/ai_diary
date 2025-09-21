import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

// 일기 목록 상태 관리
final diaryEntriesProvider = StateNotifierProvider<DiaryEntriesNotifier, AsyncValue<List<DiaryEntry>>>((ref) {
  return DiaryEntriesNotifier();
});

class DiaryEntriesNotifier extends StateNotifier<AsyncValue<List<DiaryEntry>>> {
  DiaryEntriesNotifier() : super(const AsyncValue.loading()) {
    loadDiaries();
  }

  Future<void> loadDiaries() async {
    try {
      print('DiaryProvider: loadDiaries 시작');
      state = const AsyncValue.loading();
      final diaries = await DatabaseService.getAllDiaries();
      print('DiaryProvider: 데이터베이스에서 가져온 일기 개수: ${diaries.length}');
      for (int i = 0; i < diaries.length && i < 3; i++) {
        print('DiaryProvider: 일기 $i - 제목: ${diaries[i].title}, 내용 길이: ${diaries[i].content.length}');
      }
      state = AsyncValue.data(diaries);
      print('DiaryProvider: 상태 업데이트 완료');
    } catch (error, stackTrace) {
      print('DiaryProvider: 에러 발생: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> addDiary(DiaryEntry entry) async {
    try {
      await DatabaseService.insertDiary(entry);
      await loadDiaries(); // 목록 새로고침
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDiary(DiaryEntry entry) async {
    try {
      await DatabaseService.updateDiary(entry);
      await loadDiaries(); // 목록 새로고침
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDiary(String id) async {
    try {
      await DatabaseService.deleteDiary(id);
      await loadDiaries(); // 목록 새로고침
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> searchDiaries(String query) async {
    try {
      state = const AsyncValue.loading();
      final diaries = query.isEmpty 
          ? await DatabaseService.getAllDiaries()
          : await DatabaseService.searchDiaries(query);
      state = AsyncValue.data(diaries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// AI 처리 상태 관리
final aiProcessingProvider = StateNotifierProvider<AIProcessingNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return AIProcessingNotifier();
});

class AIProcessingNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  AIProcessingNotifier() : super(const AsyncValue.data(null));

  Future<void> processEntry(String content, String style) async {
    try {
      state = const AsyncValue.loading();
      final result = await AIService.processEntry(content, style);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// 선택된 일기 상태 관리 
final selectedDiaryProvider = StateProvider<DiaryEntry?>((ref) => null);

// 검색 쿼리 상태 관리
final searchQueryProvider = StateProvider<String>((ref) => '');

// 현재 편집 중인 일기 상태 관리
final editingDiaryProvider = StateProvider<DiaryEntry?>((ref) => null);
