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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Google 로그인
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        // 무료 사용자로 설정 (나중에 프리미엄 구독 가능)
        ref.read(subscriptionProvider.notifier).setFreeUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('환영합니다, ${user.displayName ?? '사용자'}님!'),
            backgroundColor: const Color(0xFF667EEA),
          ),
        );

        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인 실패: $e'),
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

  Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 익명 로그인 (Guest 모드)
      final user = await AuthService.signInAnonymously();
      if (user != null && mounted) {
        // 무료 사용자로 설정
        ref.read(subscriptionProvider.notifier).setFreeUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guest로 시작합니다 (데이터는 이 기기에만 저장됩니다)'),
            backgroundColor: Color(0xFFF59E0B),
            duration: Duration(seconds: 4),
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
                    'AI가 그려주는 감동적인 그림일기',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: const Color(0xFF718096),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const SizedBox(height: 48),

              // Google 로그인 버튼
              _buildLoginButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: Icons.login,
                text: 'Google로 시작하기',
                backgroundColor: const Color(0xFF667EEA),
                textColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // Guest 로그인 버튼
              _buildLoginButton(
                onPressed: _isLoading ? null : _signInAsGuest,
                icon: Icons.person_outline,
                text: 'Guest로 계속하기',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF2D3748),
                borderColor: const Color(0xFFE2E8F0),
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
              Text(
                '매일의 소중한 순간을\nAI가 아름다운 그림으로 만들어드려요',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
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