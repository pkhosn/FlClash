import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import 'config/remote_config_provider.dart';
import 'theme/provider_theme.dart';
import 'theme/provider_tokens.dart';
import 'app_shell/provider_client_page.dart';
import 'widgets/provider_window_frame.dart';
import 'widgets/provider_sidebar.dart';
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
  String page = 'login';
  bool loggedIn = false;
  bool loggingIn = false;
  String? loginError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appConfigProvider.notifier).loadConfig());
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
      );
    } else if (page == 'reset') {
      body = V2ETResetPasswordPage(
        onLogin: () => setState(() => page = 'login'),
        authBackgroundUrl: appConfig.authBackgroundUrl,
        crispWebsiteId: appConfig.crispWebsiteId,
      );
    } else {
      body = V2ETLoginPage(
        onLogin: (email, password) => _handleLogin(email, password),
        onRegister: () => setState(() => page = 'register'),
        onResetPassword: () => setState(() => page = 'reset'),
        brandName: appConfig.brandName,
        logoUrl: appConfig.logoUrl,
        authBackgroundUrl: appConfig.authBackgroundUrl,
        crispWebsiteId: appConfig.crispWebsiteId,
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

  Future<void> _handleLogin(String email, String password) async {
    final appConfig = ref.read(appConfigProvider);
    final baseUrl = Uri.tryParse(appConfig.apiUrl.trim());
    if (baseUrl == null || !baseUrl.hasScheme) {
      setState(() {
        loginError = '配置错误：API 地址无效';
      });
      return;
    }

    setState(() {
      loggingIn = true;
      loginError = null;
    });
    try {
      final bridge = ref.read(v2etBridgeProvider);
      await bridge.login(baseUrl: baseUrl, email: email, password: password);
      final subscription = await bridge.fetchSubscription();

      final profile = await Profile.normal(
        label: 'v2et',
        url: subscription.subscriptionUrl.toString(),
      ).update();
      appController.putProfile(profile);
      await appController.updateStatus(true);

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
      if (mounted) {
        setState(() {
          loggingIn = false;
        });
      }
    }
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
