import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../providers/subscription_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInAsFreeUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 익명 로그인 후 무료 사용자로 설정
      final user = await AuthService.signInAnonymously();
      if (user != null && mounted) {
        // 무료 사용자로 설정
        ref.read(subscriptionProvider.notifier).setFreeUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('무료 사용자로 로그인했습니다'),
            backgroundColor: Colors.orange,
          ),
        );
        
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAsPremiumUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 익명 로그인 후 프리미엄 사용자로 설정
      final user = await AuthService.signInAnonymously();
      if (user != null && mounted) {
        // 프리미엄 사용자로 설정
        ref.read(subscriptionProvider.notifier).setPremiumUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프리미엄 사용자로 로그인했습니다'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고 및 타이틀
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6B73FF), Color(0xFF764BA2)],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI 그림일기',
                    style: GoogleFonts.notoSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '테스트 모드',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: const Color(0xFF718096),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // 테스트 로그인 버튼들
              Column(
                children: [
                  // 무료 사용자 로그인
                  _buildLoginButton(
                    onPressed: _isLoading ? null : _signInAsFreeUser,
                    icon: Icons.person,
                    text: '무료 사용자로 시작하기',
                    backgroundColor: Colors.orange,
                    textColor: Colors.white,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 프리미엄 사용자 로그인
                  _buildLoginButton(
                    onPressed: _isLoading ? null : _signInAsPremiumUser,
                    icon: Icons.star,
                    text: '프리미엄 사용자로 시작하기',
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 로딩 인디케이터
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6B73FF),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // 설명 텍스트
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '테스트 모드 안내',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 무료: 월 5개 이미지 + 광고 보상\n• 프리미엄: 무제한 이미지 + 전용 스타일\n• 설정에서 언제든지 전환 가능',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null 
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
          shadowColor: Colors.transparent,
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}