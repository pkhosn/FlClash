import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'config/remote_config_provider.dart';
import 'config/app_config_model.dart';
import 'config/api_health_service.dart';
import 'config/auth_bootstrap_service.dart';
import 'theme/provider_theme.dart';
import 'theme/provider_tokens.dart';
import 'app_shell/provider_client_page.dart';
import 'widgets/provider_window_frame.dart';
import 'widgets/provider_sidebar.dart';
import 'widgets/auth_background.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/auth/reset_password_page.dart';
import 'pages/dashboard/provider_home_page.dart';
import 'pages/dashboard/customer_service_dialog.dart';
import 'pages/store/store_page.dart';
import 'pages/invite/invite_page.dart';
import 'pages/connections/connection_status_page.dart';
import 'pages/settings/provider_settings_page.dart';
import 'pages/profile/profile_center_page.dart';

class V2ETPreviewApp extends ConsumerWidget {
  const V2ETPreviewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appConfig.brandName,
      theme: V2ETTheme.light(),
      home: const V2ETAuthGate(),
    );
  }
}

class V2ETAuthGate extends ConsumerStatefulWidget {
  const V2ETAuthGate({super.key});

  @override
  ConsumerState<V2ETAuthGate> createState() => _V2ETAuthGateState();
}

class _V2ETAuthGateState extends ConsumerState<V2ETAuthGate> {
  static const _rememberKey = 'v2et_remember_me';
  static const _rememberEmailKey = 'v2et_remember_email';
  static const _rememberPasswordKey = 'v2et_remember_password';

  String page = 'login';
  bool loggedIn = false;
  bool loggingIn = false;
  String? loginError;
  bool rememberMe = false;
  String rememberedEmail = '';
  String rememberedPassword = '';
  bool _restoredOnce = false;
  String _packageVersionText = 'v0.0.0';
  List<String> _emailSuffixes = const ['qq.com'];
  List<String> _languageCodes = const ['zh-CN', 'en-US'];
  String _languageCode = 'zh-CN';
  List<ApiHealthItem> _apiHealthItems = const [];

  bool get _isDarkMode {
    final mode = ref.read(themeSettingProvider).themeMode;
    return switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => WidgetsBinding
              .instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
    };
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(appConfigProvider.notifier).loadConfig();
      await _loadPackageVersion();
      await _loadAuthBootstrap();
      await _refreshApiHealth();
      await _restoreRememberedLogin();
      if (mounted) setState(() {});
      if (rememberMe &&
          rememberedEmail.isNotEmpty &&
          rememberedPassword.isNotEmpty) {
        await _handleLogin(
          rememberedEmail,
          rememberedPassword,
          true,
          silent: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);
    if (loggedIn) {
      return ProviderWindowFrame(
        title: appConfig.brandName,
        child: ProviderClientAppShell(
          onLogout: () => setState(() {
            loggedIn = false;
            page = 'login';
          }),
        ),
      );
    }

    Widget body;
    if (page == 'register') {
      body = V2ETRegisterPage(
        onLogin: () => setState(() => page = 'login'),
        brandName: appConfig.brandName,
        logoUrl: appConfig.logoUrl,
        authBackgroundUrl: appConfig.authBackgroundUrl,
        emailSuffixes: _emailSuffixes,
        languageCode: _languageCode,
        onLanguageTap: _cycleLanguage,
        onThemeToggle: _toggleThemeMode,
        isDarkMode: _isDarkMode,
        serviceOk: _serviceOk,
        onServiceTap: _showServiceDialog,
      );
    } else if (page == 'reset') {
      body = V2ETResetPasswordPage(
        onLogin: () => setState(() => page = 'login'),
        authBackgroundUrl: appConfig.authBackgroundUrl,
        crispWebsiteId: appConfig.crispWebsiteId,
        languageCode: _languageCode,
        onLanguageTap: _cycleLanguage,
        onThemeToggle: _toggleThemeMode,
        isDarkMode: _isDarkMode,
        serviceOk: _serviceOk,
        onServiceTap: _showServiceDialog,
      );
    } else {
      body = V2ETLoginPage(
        onLogin: (email, password, remember) =>
            _handleLogin(email, password, remember),
        onRegister: () => setState(() => page = 'register'),
        onResetPassword: () => setState(() => page = 'reset'),
        brandName: appConfig.brandName,
        logoUrl: appConfig.logoUrl,
        authBackgroundUrl: appConfig.authBackgroundUrl,
        crispWebsiteId: appConfig.crispWebsiteId,
        versionText: _resolveVersionText(appConfig),
        languageCode: _languageCode,
        onLanguageTap: _cycleLanguage,
        onThemeToggle: _toggleThemeMode,
        isDarkMode: _isDarkMode,
        serviceOk: _serviceOk,
        onServiceTap: _showServiceDialog,
        initialEmail: rememberedEmail,
        initialPassword: rememberedPassword,
        initialRemember: rememberMe,
      );
    }

    return ProviderWindowFrame(
      title: appConfig.brandName,
      backgroundColor: V2ETTokens.authBackground,
      child: Stack(
        children: [
          Positioned.fill(child: body),
          if (loggingIn)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if ((loginError ?? '').isNotEmpty)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Material(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    loginError!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(
    String email,
    String password,
    bool remember, {
    bool silent = false,
  }) async {
    final appConfig = ref.read(appConfigProvider);
    final candidates = _candidateBaseUrls(appConfig);
    if (candidates.isEmpty) {
      setState(() {
        loginError = '配置错误：API 地址无效';
      });
      return;
    }

    if (!silent) {
      setState(() {
        loggingIn = true;
        loginError = null;
      });
    }
    try {
      final bridge = ref.read(v2etBridgeProvider);
      Object? lastError;
      Uri? activeBaseUrl;
      for (final baseUrl in candidates) {
        try {
          await bridge.login(
            baseUrl: baseUrl,
            email: email,
            password: password,
          );
          activeBaseUrl = baseUrl;
          break;
        } catch (e) {
          lastError = e;
        }
      }
      if (activeBaseUrl == null) {
        throw StateError('所有 API 地址登录失败: $lastError');
      }
      final subscription = await bridge.fetchSubscription();

      final profile = await Profile.normal(
        label: 'v2et',
        url: subscription.subscriptionUrl.toString(),
      ).update();
      appController.putProfile(profile);
      await appController.updateStatus(true);
      await _saveRememberedLogin(
        remember: remember,
        email: email,
        password: password,
      );

      if (!mounted) return;
      setState(() {
        loggedIn = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loginError = '登录失败: $e';
      });
    } finally {
      if (mounted && !silent) {
        setState(() {
          loggingIn = false;
        });
      }
    }
  }

  Future<void> _restoreRememberedLogin() async {
    if (_restoredOnce) return;
    _restoredOnce = true;
    final sp = await preferences.sharedPreferencesCompleter.future;
    if (sp == null) return;
    rememberMe = sp.getBool(_rememberKey) ?? false;
    rememberedEmail = sp.getString(_rememberEmailKey) ?? '';
    rememberedPassword = sp.getString(_rememberPasswordKey) ?? '';
    if (!rememberMe) {
      rememberedEmail = '';
      rememberedPassword = '';
    }
  }

  Future<void> _saveRememberedLogin({
    required bool remember,
    required String email,
    required String password,
  }) async {
    final sp = await preferences.sharedPreferencesCompleter.future;
    if (sp == null) return;
    rememberMe = remember;
    if (remember) {
      rememberedEmail = email.trim();
      rememberedPassword = password;
      await sp.setBool(_rememberKey, true);
      await sp.setString(_rememberEmailKey, rememberedEmail);
      await sp.setString(_rememberPasswordKey, rememberedPassword);
    } else {
      rememberedEmail = '';
      rememberedPassword = '';
      await sp.setBool(_rememberKey, false);
      await sp.remove(_rememberEmailKey);
      await sp.remove(_rememberPasswordKey);
    }
  }

  Future<void> _loadPackageVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final name = info.version.trim();
      final build = info.buildNumber.trim();
      final composed = build.isEmpty ? name : '$name+$build';
      _packageVersionText = composed.isEmpty ? 'v0.0.0' : 'v$composed';
    } catch (_) {
      _packageVersionText = 'v0.0.0';
    }
  }

  Future<void> _loadAuthBootstrap() async {
    final appConfig = ref.read(appConfigProvider);
    final candidates = _candidateBaseUrls(appConfig);
    for (final baseUrl in candidates) {
      try {
        final data = await AuthBootstrapService().fetch(baseUrl);
        _emailSuffixes = data.emailSuffixes;
        _languageCodes = data.languages;
        if (_languageCodes.isNotEmpty &&
            !_languageCodes.contains(_languageCode)) {
          _languageCode = _languageCodes.first;
        }
        break;
      } catch (_) {}
    }
  }

  void _cycleLanguage() {
    if (_languageCodes.isEmpty) return;
    final index = _languageCodes.indexOf(_languageCode);
    final next = (index + 1) % _languageCodes.length;
    final nextCode = _languageCodes[next];
    setState(() => _languageCode = nextCode);
    ref.read(appSettingProvider.notifier).update(
      (state) => state.copyWith(locale: nextCode),
    );
  }

  void _toggleThemeMode() {
    ref.read(themeSettingProvider.notifier).update((state) {
      final current = state.themeMode;
      final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      return state.copyWith(themeMode: next);
    });
    if (mounted) setState(() {});
  }

  Future<void> _refreshApiHealth() async {
    final appConfig = ref.read(appConfigProvider);
    final urls = appConfig.apiUrls;
    if (urls.isEmpty) return;
    _apiHealthItems = await ApiHealthService().probeAll(urls);
  }

  bool get _serviceOk {
    if (_apiHealthItems.isEmpty) return true;
    return _apiHealthItems.any((e) => e.ok);
  }

  Future<void> _showServiceDialog() async {
    await _refreshApiHealth();
    if (!mounted) return;
    await showServiceProbeDialog(context, items: _apiHealthItems);
    if (mounted) {
      setState(() {});
    }
  }

  List<Uri> _candidateBaseUrls(AppConfig appConfig) {
    final list = <Uri>[];
    for (final raw in appConfig.apiUrls) {
      final uri = Uri.tryParse(raw.trim());
      if (uri != null && uri.hasScheme) {
        list.add(uri);
      }
    }
    if (list.isEmpty) {
      final primary = Uri.tryParse(appConfig.apiUrl.trim());
      if (primary != null && primary.hasScheme) list.add(primary);
    }
    return list;
  }

  String _resolveVersionText(AppConfig appConfig) {
    final configVersion = appConfig.versionText.trim();
    if (configVersion.isNotEmpty) return configVersion;
    return _packageVersionText;
  }
}

class ProviderClientAppShell extends ConsumerStatefulWidget {
  const ProviderClientAppShell({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  ConsumerState<ProviderClientAppShell> createState() =>
      _ProviderClientAppShellState();
}

class _ProviderClientAppShellState
    extends ConsumerState<ProviderClientAppShell> {
  ProviderClientPage current = ProviderClientPage.dashboard;

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);
    return Row(
      children: [
        ProviderSidebar(
          current: current,
          onChanged: (page) => setState(() => current = page),
          onSupport: () => showV2ETCustomerServiceDialog(
            context,
            crispWebsiteId: appConfig.crispWebsiteId,
          ),
          onLogout: widget.onLogout,
        ),
        Expanded(
          child: Container(
            color: V2ETTokens.background,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(key: ValueKey(current), child: _page()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _page() {
    final appConfig = ref.watch(appConfigProvider);
    switch (current) {
      case ProviderClientPage.dashboard:
        return V2ETProviderHomePage(showNoticePopup: appConfig.showNoticePopup);
      case ProviderClientPage.store:
        return const V2ETStorePage();
      case ProviderClientPage.invite:
        return const V2ETInvitePage();
      case ProviderClientPage.connections:
        return const V2ETConnectionStatusPage();
      case ProviderClientPage.profile:
        return const V2ETProfileCenterPage();
      case ProviderClientPage.settings:
        return const V2ETProviderSettingsPage();
    }
  }
}
