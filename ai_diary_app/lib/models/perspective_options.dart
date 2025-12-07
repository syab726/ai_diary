import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// 시점 옵션 열거형
enum PerspectiveType {
  firstPerson,
  thirdPerson;
}

// 성별 옵션 열거형
enum GenderType {
  male,
  female,
  unspecified;

  String get icon {
    switch (this) {
      case GenderType.male:
        return '👨';
      case GenderType.female:
        return '👩';
      case GenderType.unspecified:
        return '👤';
    }
  }
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시점 선택
        Row(
          children: [
            Icon(
              Icons.visibility,
              size: 18,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.optionPerspective,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey.withOpacity(0.1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PerspectiveType>(
              value: options.perspective,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              items: PerspectiveType.values.map((perspective) {
                return DropdownMenuItem<PerspectiveType>(
                  value: perspective,
                  child: Row(
                    children: [
                      Icon(
                        perspective == PerspectiveType.firstPerson ? Icons.visibility : Icons.person,
                        size: 20,
                        color: enabled ? const Color(0xFF667EEA) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getPerspectiveDisplayName(l10n, perspective),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              _getPerspectiveDescription(l10n, perspective),
                              style: TextStyle(
                                fontSize: 11,
                                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: enabled ? (perspective) {
                if (perspective != null) {
                  _onPerspectiveChanged(perspective);
                }
              } : null,
            ),
          ),
        ),

        // 3인칭 선택 시 성별 선택 표시
        if (options.perspective == PerspectiveType.thirdPerson) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 18,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.optionCharacterGender,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(8),
              color: enabled ? Colors.white : Colors.grey.withOpacity(0.1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GenderType>(
                value: options.gender,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                items: GenderType.values.map((gender) {
                  return DropdownMenuItem<GenderType>(
                    value: gender,
                    child: Row(
                      children: [
                        Text(
                          gender.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getGenderDisplayName(l10n, gender),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: enabled ? (gender) {
                  if (gender != null) {
                    _onGenderChanged(gender);
                  }
                } : null,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getPerspectiveDisplayName(AppLocalizations l10n, PerspectiveType perspective) {
    switch (perspective) {
      case PerspectiveType.firstPerson:
        return l10n.perspectiveFirstPerson;
      case PerspectiveType.thirdPerson:
        return l10n.perspectiveThirdPerson;
    }
  }

  String _getPerspectiveDescription(AppLocalizations l10n, PerspectiveType perspective) {
    switch (perspective) {
      case PerspectiveType.firstPerson:
        return l10n.perspectiveFirstPersonDesc;
      case PerspectiveType.thirdPerson:
        return l10n.perspectiveThirdPersonDesc;
    }
  }

  String _getGenderDisplayName(AppLocalizations l10n, GenderType gender) {
    switch (gender) {
      case GenderType.male:
        return l10n.genderMale;
      case GenderType.female:
        return l10n.genderFemale;
      case GenderType.unspecified:
        return l10n.genderUnspecified;
    }
  }


  void _onPerspectiveChanged(PerspectiveType perspective) {
    onChanged(options.copyWith(perspective: perspective));
  }

  void _onGenderChanged(GenderType gender) {
    onChanged(options.copyWith(gender: gender));
  }
}