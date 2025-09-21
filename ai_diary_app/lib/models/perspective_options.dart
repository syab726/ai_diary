import 'package:flutter/material.dart';

// 시점 옵션 열거형
enum PerspectiveType {
  firstPerson('1인칭 시점', '내가 직접 경험하는 관점'),
  thirdPerson('3인칭 시점', '나를 객관적으로 보는 관점');

  const PerspectiveType(this.displayName, this.description);
  final String displayName;
  final String description;
}

// 성별 옵션 열거형
enum GenderType {
  male('남성', '👨'),
  female('여성', '👩'),
  unspecified('지정하지 않음', '👤');

  const GenderType(this.displayName, this.icon);
  final String displayName;
  final String icon;
}

// 시점 및 성별 옵션 클래스
class PerspectiveOptions {
  final PerspectiveType perspective;
  final GenderType gender;

  const PerspectiveOptions({
    this.perspective = PerspectiveType.thirdPerson,
    this.gender = GenderType.unspecified,
  });

  // AI 프롬프트용 텍스트 생성
  String getPromptSuffix() {
    if (perspective == PerspectiveType.firstPerson) {
      return "from first person perspective, I am experiencing this";
    } else {
      switch (gender) {
        case GenderType.male:
          return "third person view showing a young man";
        case GenderType.female:
          return "third person view showing a young woman";
        case GenderType.unspecified:
          return "third person view showing a person";
      }
    }
  }

  // 복사 메서드
  PerspectiveOptions copyWith({
    PerspectiveType? perspective,
    GenderType? gender,
  }) {
    return PerspectiveOptions(
      perspective: perspective ?? this.perspective,
      gender: gender ?? this.gender,
    );
  }

  // 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'perspective': perspective.name,
      'gender': gender.name,
    };
  }

  // 맵에서 생성
  factory PerspectiveOptions.fromMap(Map<String, dynamic> map) {
    return PerspectiveOptions(
      perspective: PerspectiveType.values.firstWhere(
        (e) => e.name == map['perspective'],
        orElse: () => PerspectiveType.thirdPerson,
      ),
      gender: GenderType.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => GenderType.unspecified,
      ),
    );
  }
}

// 시점 옵션 선택기 위젯
class PerspectiveOptionsSelector extends StatelessWidget {
  final PerspectiveOptions options;
  final ValueChanged<PerspectiveOptions> onChanged;
  final bool enabled;

  const PerspectiveOptionsSelector({
    super.key,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시점 선택
        ...PerspectiveType.values.map((perspective) => Column(
          children: [
            _buildPerspectiveCard(perspective),
            if (perspective == PerspectiveType.thirdPerson &&
                options.perspective == PerspectiveType.thirdPerson) ...[
              const SizedBox(height: 8),
              _buildGenderSelector(),
            ],
            const SizedBox(height: 12),
          ],
        )),
      ],
    );
  }

  Widget _buildPerspectiveCard(PerspectiveType perspective) {
    final isSelected = options.perspective == perspective;

    return GestureDetector(
      onTap: enabled ? () => _onPerspectiveChanged(perspective) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                : (enabled ? Colors.grey.shade300 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? (enabled ? const Color(0xFF667EEA).withOpacity(0.1) : Colors.grey.withOpacity(0.1))
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              perspective == PerspectiveType.firstPerson ? Icons.visibility : Icons.person,
              color: isSelected
                  ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                  : (enabled ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perspective.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                          : (enabled ? Colors.grey.shade700 : Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    perspective.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '캐릭터 성별',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: GenderType.values.map((gender) {
              final isSelected = options.gender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: enabled ? () => _onGenderChanged(gender) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isSelected
                          ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                          : (enabled ? Colors.white : Colors.grey.shade200),
                      border: Border.all(
                        color: isSelected
                            ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          gender.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gender.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? (enabled ? Colors.white : Colors.grey.shade400)
                                : (enabled ? Colors.grey.shade700 : Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _onPerspectiveChanged(PerspectiveType perspective) {
    onChanged(options.copyWith(perspective: perspective));
  }

  void _onGenderChanged(GenderType gender) {
    onChanged(options.copyWith(gender: gender));
  }
}