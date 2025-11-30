import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// 구매 상태 모델
class PurchaseState {
  final PurchaseStatus? status;
  final String? productId;
  final String? errorMessage;
  final bool isPending;

  const PurchaseState({
    this.status,
    this.productId,
    this.errorMessage,
    this.isPending = false,
  });

  PurchaseState copyWith({
    PurchaseStatus? status,
    String? productId,
    String? errorMessage,
    bool? isPending,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      productId: productId ?? this.productId,
      errorMessage: errorMessage ?? this.errorMessage,
      isPending: isPending ?? this.isPending,
    );
  }

  bool get isSuccess =>
      status == PurchaseStatus.purchased || status == PurchaseStatus.restored;
  bool get isError => status == PurchaseStatus.error;
  bool get isCanceled => status == PurchaseStatus.canceled;
}

/// 구매 상태 Provider
final purchaseStateProvider =
    StateNotifierProvider<PurchaseStateNotifier, PurchaseState>((ref) {
  return PurchaseStateNotifier();
});

class PurchaseStateNotifier extends StateNotifier<PurchaseState> {
  PurchaseStateNotifier() : super(const PurchaseState());

  void setPending(String productId) {
    state = PurchaseState(
      productId: productId,
      isPending: true,
      status: PurchaseStatus.pending,
    );
  }

  void setSuccess(String productId, PurchaseStatus status) {
    state = PurchaseState(
      productId: productId,
      status: status,
      isPending: false,
    );
  }

  void setError(String productId, String errorMessage) {
    state = PurchaseState(
      productId: productId,
      status: PurchaseStatus.error,
      errorMessage: errorMessage,
      isPending: false,
    );
  }

  void reset() {
    state = const PurchaseState();
  }
}
