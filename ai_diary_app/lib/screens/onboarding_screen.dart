import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/first_launch_provider.dart';
import '../services/database_service.dart';
import '../models/diary_entry.dart';
import '../l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCreatingSample = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    if (_isCreatingSample) return;

    setState(() {
      _isCreatingSample = true;
    });

    try {
      // 샘플 일기 생성
      await _createSampleDiary();

      // 온보딩 완료 표시
      await ref.read(firstLaunchProvider.notifier).completeOnboarding();

      if (!mounted) return;

      // 로그인 화면으로 이동
      context.go('/login');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingSample = false;
        });
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleDiary() async {
    final loc = AppLocalizations.of(context);
    final sampleEntry = DiaryEntry(
      id: const Uuid().v4(),
      title: loc.sampleDiaryTitle,
      content: loc.sampleDiaryContent,
      createdAt: DateTime.now(),
      emotion: 'happy',
      keywords: [loc.emotionHappy, loc.emotionPeaceful, loc.emotionGrateful],
      generatedImageUrl: 'https://via.placeholder.com/800x600/87CEEB/FFFFFF/?text=Sample+Diary+Image',
    );

    await DatabaseService.insertDiary(sampleEntry);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 건너뛰기 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      loc.onboardingSkip,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 페이지뷰
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPage(
                    icon: Icons.auto_stories,
                    iconColor: const Color(0xFF667EEA),
                    title: loc.onboardingPage1Title,
                    description: loc.onboardingPage1Desc,
                  ),
                  _buildPage(
                    icon: Icons.edit_note,
                    iconColor: const Color(0xFFF59E0B),
                    title: loc.onboardingPage2Title,
                    description: loc.onboardingPage2Desc,
                  ),
                  _buildPage(
                    icon: Icons.palette,
                    iconColor: const Color(0xFFEC4899),
                    title: loc.onboardingPage3Title,
                    description: loc.onboardingPage3Desc,
                  ),
                  _buildPage(
                    icon: Icons.photo_library,
                    iconColor: const Color(0xFF10B981),
                    title: loc.onboardingPage4Title,
                    description: loc.onboardingPage4Desc,
                  ),
                ],
              ),
            ),

            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF667EEA)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage == 3
                  ? SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isCreatingSample ? null : _completeOnboarding,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isCreatingSample
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                loc.onboardingStart,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          loc.onboardingNext,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
