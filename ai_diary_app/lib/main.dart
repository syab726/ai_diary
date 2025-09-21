import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/ai_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/diary_list_screen.dart';
import 'screens/diary_create_screen.dart';
import 'screens/diary_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_provider.dart';
import 'models/font_family.dart';

// 라틴어와 같이 Flutter에서 지원하지 않는 로케일을 위한 폴백 델리게이트
class _FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // 라틴어나 기타 지원되지 않는 로케일에 대해 영어 폴백 제공
    return locale.languageCode == 'la' || !GlobalMaterialLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // 영어로 폴백
    return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

// Cupertino 위젯을 위한 폴백 델리게이트
class _FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // 라틴어나 기타 지원되지 않는 로케일에 대해 영어 폴백 제공
    return locale.languageCode == 'la' || !GlobalCupertinoLocalizations.delegate.isSupported(locale);
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    // 영어로 폴백
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화 (개발용으로 주석 처리)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // 날짜 포맷 로케일 초기화 (웹 플랫폼 호환성)
  await initializeDateFormatting('ko_KR', null);
  
  // AI 서비스 초기화
  AIService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final appTheme = ref.watch(themeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final selectedFont = ref.watch(fontProvider);
    
    return MaterialApp.router(
      title: 'AI Diary App',
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        const _FallbackMaterialLocalizationsDelegate(),
        const _FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('ko'), // 한국어
        Locale('ja'), // 일본어
        Locale('en'), // 영어
        Locale('zh'), // 중국어
      ],
      theme: _buildLightTheme(fontSize, selectedFont),
      themeMode: ThemeMode.light,
      routerConfig: _createRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildLightTheme(double fontSize, FontFamily selectedFont) {
    // 앱 전체에는 기본 글꼴만 적용하고, 일기 내용에만 선택된 글꼴 적용
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B73FF),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

}

class RouterNotifier extends ChangeNotifier {
  final WidgetRef _ref;
  RouterNotifier(this._ref) {
    // 인증 상태 변경만 감지하고 locale 변경은 감지하지 않음
    _ref.listen(authStateProvider, (previous, next) {
      // 실제 인증 상태가 변경된 경우만 리다이렉트
      final prevLoggedIn = previous?.whenOrNull(data: (user) => user != null) ?? false;
      final nextLoggedIn = next.whenOrNull(data: (user) => user != null) ?? false;
      
      if (prevLoggedIn != nextLoggedIn) {
        notifyListeners();
      }
    });
  }
}

GoRouter _createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.whenOrNull(data: (user) => user != null) ?? false;
      final currentLocation = state.fullPath;
      
      // 언어 변경 후 저장된 라우트가 있으면 해당 라우트로 이동
      final savedRoute = ref.read(currentRouteProvider);
      if (savedRoute != null) {
        // Future를 사용하여 빌드 후에 상태 초기화
        Future.microtask(() => ref.read(currentRouteProvider.notifier).state = null);
        return savedRoute;
      }
      
      // 로그인이 필요한 페이지들
      final protectedRoutes = ['/', '/list', '/calendar', '/create', '/edit', '/detail', '/settings'];
      final isProtectedRoute = protectedRoutes.any((route) => 
        currentLocation?.startsWith(route) == true && currentLocation != '/login');
      
      // 로그인되지 않았고 보호된 라우트에 접근하려는 경우만 로그인으로 리다이렉트
      if (!isLoggedIn && isProtectedRoute) {
        return '/login';
      }
      
      // 이미 로그인되어 있고 로그인 페이지에 있는 경우 홈으로 리다이렉트
      if (isLoggedIn && currentLocation == '/login') {
        return '/list';
      }
      
      // 기타 경우는 리다이렉트하지 않음
      return null;
    },
    routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const DiaryListScreen(),
    ),
    GoRoute(
      path: '/list',
      name: 'list',
      builder: (context, state) => const DiaryListScreen(),
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/create',
      name: 'create',
      builder: (context, state) => const DiaryCreateScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      name: 'edit',
      builder: (context, state) => DiaryCreateScreen(
        existingDiaryId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/detail/:id',
      name: 'detail',
      builder: (context, state) => DiaryDetailScreen(
        entryId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    ],
  );
}
