import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_subscription.dart';

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, UserSubscription>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<UserSubscription> {
  SubscriptionNotifier() : super(const UserSubscription()) {
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionData = prefs.getString('user_subscription');
      
      if (subscriptionData != null) {
        final map = Map<String, dynamic>.from(
          const {
            'tier': 'free',
            'imageGenerationsUsed': 0,
            'imageGenerationsLimit': 5,
            'imageModificationsUsed': 0,
            'imageModificationsLimit': 0,
          }
        );
        
        // 간단한 파싱 - 실제로는 JSON을 사용해야 함
        final parts = subscriptionData.split(',');
        for (final part in parts) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim();
            final value = keyValue[1].trim();
            
            switch (key) {
              case 'tier':
                map['tier'] = value;
                break;
              case 'imageGenerationsUsed':
                map['imageGenerationsUsed'] = int.tryParse(value) ?? 0;
                break;
              case 'imageGenerationsLimit':
                map['imageGenerationsLimit'] = int.tryParse(value) ?? 5;
                break;
              case 'imageModificationsUsed':
                map['imageModificationsUsed'] = int.tryParse(value) ?? 0;
                break;
              case 'imageModificationsLimit':
                map['imageModificationsLimit'] = int.tryParse(value) ?? 0;
                break;
            }
          }
        }
        
        state = UserSubscription.fromMap(map);
      }
    } catch (e) {
      // 에러 시 기본값 유지
    }
  }

  Future<void> _saveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 간단한 저장 방식 - 실제로는 JSON을 사용해야 함
      final subscriptionData = 'tier:${state.tier.name},'
          'imageGenerationsUsed:${state.imageGenerationsUsed},'
          'imageGenerationsLimit:${state.imageGenerationsLimit},'
          'imageModificationsUsed:${state.imageModificationsUsed},'
          'imageModificationsLimit:${state.imageModificationsLimit}';
      
      await prefs.setString('user_subscription', subscriptionData);
    } catch (e) {
      // 에러 처리
    }
  }

  Future<bool> useImageGeneration() async {
    if (!state.canGenerateImage) return false;
    
    state = state.incrementGenerations();
    await _saveSubscription();
    return true;
  }

  Future<bool> useImageModification() async {
    if (!state.canModifyImage) return false;
    
    state = state.incrementModifications();
    await _saveSubscription();
    return true;
  }

  Future<void> upgradeToPremium() async {
    state = state.startPremiumSubscription();
    await _saveSubscription();
  }

  void resetMonthlyUsage() {
    state = state.copyWith(
      imageGenerationsUsed: 0,
      imageModificationsUsed: 0,
    );
    _saveSubscription();
  }

  // 테스트용 메서드
  void setFreeUser() {
    state = const UserSubscription();
    _saveSubscription();
  }

  void setPremiumUser() {
    state = state.startPremiumSubscription();
    _saveSubscription();
  }
}