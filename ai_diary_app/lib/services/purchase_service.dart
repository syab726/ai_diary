import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_logger.dart';

/// 인앱 결제 서비스
/// Google Play와 App Store의 구독 결제를 처리합니다.
class PurchaseService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  // 구독 상품 ID
  static const String premiumMonthlyProductId = 'premium_monthly';

  // 모든 구독 상품 ID 목록
  static const Set<String> _productIds = {
    premiumMonthlyProductId,
  };

  // 구매 상태 변경 콜백
  static Function(String productId)? _onPendingCallback;
  static Function(String productId, PurchaseStatus status)? _onSuccessCallback;
  static Function(String productId, String errorMessage)? _onErrorCallback;

  /// 구매 상태 콜백 등록
  static void setCallbacks({
    Function(String productId)? onPending,
    Function(String productId, PurchaseStatus status)? onSuccess,
    Function(String productId, String errorMessage)? onError,
  }) {
    _onPendingCallback = onPending;
    _onSuccessCallback = onSuccess;
    _onErrorCallback = onError;
  }

  /// 서비스 초기화
  static Future<void> initialize() async {
    try {
      AppLogger.log('=== PurchaseService 초기화 시작 ===');

      // 스토어 연결 가능 여부 확인
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        AppLogger.log('인앱 결제를 사용할 수 없습니다 (에뮬레이터 또는 스토어 미지원)');
        return;
      }

      // Android 플랫폼 설정
      // (enablePendingPurchases는 최신 버전에서 자동으로 활성화되어 더 이상 호출 불필요)
      if (Platform.isAndroid) {
        AppLogger.log('Android 인앱 결제 설정 완료');
      }

      // iOS 플랫폼 설정
      if (Platform.isIOS) {
        AppLogger.log('iOS 인앱 결제 설정 완료');
      }

      // 구매 업데이트 스트림 구독
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          AppLogger.log('구매 스트림 종료');
        },
        onError: (error) {
          AppLogger.log('구매 스트림 오류: $error');
        },
      );

      AppLogger.log('=== PurchaseService 초기화 완료 ===');
    } catch (e) {
      AppLogger.log('PurchaseService 초기화 오류: $e');
    }
  }

  /// 서비스 종료
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    AppLogger.log('PurchaseService 종료됨');
  }

  /// 구매 가능한 상품 조회
  static Future<List<ProductDetails>> getProducts() async {
    try {
      AppLogger.log('=== 구매 가능한 상품 조회 시작 ===');

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        AppLogger.log('인앱 결제를 사용할 수 없습니다');
        return [];
      }

      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        AppLogger.log('상품 조회 오류: ${response.error}');
        return [];
      }

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.log('찾을 수 없는 상품 ID: ${response.notFoundIDs}');
      }

      AppLogger.log('조회된 상품 개수: ${response.productDetails.length}');
      for (var product in response.productDetails) {
        AppLogger.log('상품: ${product.id} - ${product.title} - ${product.price}');
      }

      return response.productDetails;
    } catch (e) {
      AppLogger.log('상품 조회 오류: $e');
      return [];
    }
  }

  /// 구독 구매 시작
  static Future<bool> purchaseSubscription(ProductDetails productDetails) async {
    try {
      AppLogger.log('=== 구독 구매 시작: ${productDetails.id} ===');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      AppLogger.log('구매 요청 전송 완료: $success');
      return success;
    } catch (e) {
      AppLogger.log('구매 시작 오류: $e');
      return false;
    }
  }

  /// 구독 복원
  static Future<void> restorePurchases() async {
    try {
      AppLogger.log('=== 구독 복원 시작 ===');
      await _inAppPurchase.restorePurchases();
      AppLogger.log('구독 복원 완료');
    } catch (e) {
      AppLogger.log('구독 복원 오류: $e');
    }
  }

  /// 구매 업데이트 콜백
  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      AppLogger.log('=== 구매 업데이트: ${purchaseDetails.productID} ===');
      AppLogger.log('상태: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        AppLogger.log('구매 대기 중...');
        _showPendingUI(purchaseDetails.productID);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        AppLogger.log('구매 오류: ${purchaseDetails.error}');
        _handleError(purchaseDetails.productID, purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        AppLogger.log('구매 성공!');
        _deliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        AppLogger.log('구매 취소됨');
        _onErrorCallback?.call(purchaseDetails.productID, '구매가 취소되었습니다.');
      }

      // 구매 완료 처리 (중요!)
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
        AppLogger.log('구매 완료 처리됨');
      }
    }
  }

  /// 구매 대기 UI 표시
  static void _showPendingUI(String productId) {
    AppLogger.log('구매 대기 중 UI 표시: $productId');
    _onPendingCallback?.call(productId);
  }

  /// 오류 처리
  static void _handleError(String productId, IAPError error) {
    AppLogger.log('구매 오류 처리: ${error.message}');
    _onErrorCallback?.call(productId, error.message);
  }

  /// 상품 제공 (구독 활성화)
  static void _deliverProduct(PurchaseDetails purchaseDetails) {
    AppLogger.log('=== 상품 제공: ${purchaseDetails.productID} ===');

    // 영수증 검증
    verifyPurchase(purchaseDetails).then((verified) {
      if (verified) {
        AppLogger.log('영수증 검증 성공');

        if (purchaseDetails.productID == premiumMonthlyProductId) {
          AppLogger.log('프리미엄 월간 구독 활성화');

          // 구독 성공 콜백 호출
          _onSuccessCallback?.call(
            purchaseDetails.productID,
            purchaseDetails.status,
          );
        }
      } else {
        AppLogger.log('영수증 검증 실패');
        _onErrorCallback?.call(
          purchaseDetails.productID,
          '영수증 검증에 실패했습니다.',
        );
      }
    });
  }

  /// 현재 활성 구독 확인
  static Future<bool> hasActiveSubscription() async {
    try {
      // 미완료 구매 내역 조회
      await _inAppPurchase.restorePurchases();

      // TODO: 실제로는 서버에서 구독 상태를 확인해야 함
      // 여기서는 간단하게 로컬 체크만 수행

      return false; // 기본값
    } catch (e) {
      AppLogger.log('구독 상태 확인 오류: $e');
      return false;
    }
  }

  /// 구독 취소 (사용자가 스토어에서 직접 취소해야 함)
  static Future<void> cancelSubscription() async {
    AppLogger.log('구독 취소는 Google Play 또는 App Store에서 직접 진행해야 합니다');
    // 안내 메시지만 표시
    // 실제 취소는 각 스토어에서 사용자가 직접 수행
  }

  /// 구독 관리 페이지로 이동
  static Future<bool> manageSubscription() async {
    try {
      Uri? url;

      if (Platform.isAndroid) {
        AppLogger.log('Google Play 구독 관리 페이지 열기');
        url = Uri.parse('https://play.google.com/store/account/subscriptions');
      } else if (Platform.isIOS) {
        AppLogger.log('App Store 구독 관리 페이지 열기');
        url = Uri.parse('https://apps.apple.com/account/subscriptions');
      }

      if (url != null && await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.log('URL을 열 수 없습니다: $url');
        return false;
      }
    } catch (e) {
      AppLogger.log('구독 관리 페이지 열기 오류: $e');
      return false;
    }
  }

  /// 영수증 검증 (간단한 버전)
  /// 실제 프로덕션에서는 서버에서 검증해야 함
  static Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      AppLogger.log('=== 영수증 검증 시작 ===');

      // Android
      if (Platform.isAndroid) {
        // Google Play Billing Library의 영수증 데이터
        final String verificationData = purchaseDetails.verificationData.serverVerificationData;
        AppLogger.log('Android 영수증 데이터 길이: ${verificationData.length}');

        // TODO: 실제로는 서버에 전송하여 Google Play Developer API로 검증
        return true;
      }

      // iOS
      if (Platform.isIOS) {
        // App Store의 영수증 데이터
        final String verificationData = purchaseDetails.verificationData.serverVerificationData;
        AppLogger.log('iOS 영수증 데이터 길이: ${verificationData.length}');

        // TODO: 실제로는 서버에 전송하여 App Store Server API로 검증
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.log('영수증 검증 오류: $e');
      return false;
    }
  }
}
