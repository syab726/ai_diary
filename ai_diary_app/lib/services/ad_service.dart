import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AdMob 광고 서비스
///
/// 무료 사용자를 위한 보상형 광고 및 배너 광고를 관리합니다.
/// 프리미엄 사용자는 광고를 표시하지 않습니다.
class AdService {
  // 싱글톤 패턴
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 보상형 광고
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;
  
  // 전면 광고 (추후 사용 가능)
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  /// AdMob SDK 초기화
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    print('[AdService] AdMob SDK 초기화 완료');
  }

  /// 보상형 광고 Unit ID 가져오기
  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_IOS'] ?? '';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 배너 광고 Unit ID 가져오기
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_AD_UNIT_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_AD_UNIT_ID_IOS'] ?? '';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 전면 광고 Unit ID 가져오기
  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS'] ?? '';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 보상형 광고 로드
  Future<void> loadRewardedAd() async {
    if (_isRewardedAdLoading || _rewardedAd != null) {
      print('[AdService] 보상형 광고 이미 로드 중이거나 로드됨');
      return;
    }

    _isRewardedAdLoading = true;
    print('[AdService] 보상형 광고 로드 시작...');

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('[AdService] 보상형 광고 로드 성공');
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          // fullScreenContentCallback은 show() 시 설정됨
        },
        onAdFailedToLoad: (error) {
          print('[AdService] 보상형 광고 로드 실패: $error');
          _isRewardedAdLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  /// 보상형 광고 표시 (이미지 생성 전)
  ///
  /// Returns:
  /// - true: 사용자가 광고를 끝까지 시청함
  /// - false: 광고를 시청하지 않음 (로드 실패 또는 사용자 취소)
  Future<bool> showRewardedAd() async {
    // 광고가 로드되지 않았으면 로드 시도
    if (_rewardedAd == null && !_isRewardedAdLoading) {
      await loadRewardedAd();

      // 로드 완료까지 최대 5초 대기
      int waitTime = 0;
      while (_isRewardedAdLoading && waitTime < 5000) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitTime += 100;
      }
    }

    // 광고 로드 실패시 기능 차단하지 않고 진행 허용
    if (_rewardedAd == null) {
      print('[AdService] 보상형 광고 로드 실패 - 기능 허용');
      return true; // 광고 없이도 기능 사용 허용
    }

    // Completer를 사용하여 광고가 닫힐 때까지 기다림
    final Completer<bool> completer = Completer<bool>();
    bool rewardEarned = false;

    // 광고 이벤트 리스너 설정 (show 전에 설정)
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('[AdService] 보상형 광고 표시 시작');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('[AdService] 보상형 광고 닫힘 - 보상 수령 여부: $rewardEarned');
        ad.dispose();
        _rewardedAd = null;

        // 광고가 닫힐 때 결과 반환
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }

        // 다음 사용을 위해 광고 미리 로드
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('[AdService] 보상형 광고 표시 실패: $error');
        ad.dispose();
        _rewardedAd = null;

        // 실패 시 결과 반환
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    // 광고 표시
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('[AdService] 사용자가 보상 획득: ${reward.amount} ${reward.type}');
        rewardEarned = true;
      },
    );

    // 광고가 닫힐 때까지 기다림
    return await completer.future;
  }

  /// 전면 광고 로드 (추후 사용)
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoading || _interstitialAd != null) {
      print('[AdService] 전면 광고 이미 로드 중이거나 로드됨');
      return;
    }

    _isInterstitialAdLoading = true;
    print('[AdService] 전면 광고 로드 시작...');

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('[AdService] 전면 광고 로드 성공');
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('[AdService] 전면 광고 표시 시작');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('[AdService] 전면 광고 닫힘');
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('[AdService] 전면 광고 표시 실패: $error');
              ad.dispose();
              _interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('[AdService] 전면 광고 로드 실패: $error');
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// 전면 광고 표시
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('[AdService] 전면 광고가 로드되지 않음');
    }
  }

  /// 광고 리소스 해제
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
