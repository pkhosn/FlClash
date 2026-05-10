import 'package:flutter/material.dart';
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


class V2ETPreviewApp extends StatelessWidget {
  const V2ETPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: V2ETTokens.brandName,
      theme: V2ETTheme.light(),
      home: const V2ETAuthGate(),
    );
  }
}

class V2ETAuthGate extends StatefulWidget {
  const V2ETAuthGate({super.key});

  @override
  State<V2ETAuthGate> createState() => _V2ETAuthGateState();
}

class _V2ETAuthGateState extends State<V2ETAuthGate> {
  String page = 'login';
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (loggedIn) {
      return ProviderWindowFrame(
        title: V2ETTokens.brandName,
        child: ProviderClientAppShell(onLogout: () => setState(() { loggedIn = false; page = 'login'; })),
      );
    }

    Widget body;
    if (page == 'register') {
      body = V2ETRegisterPage(onLogin: () => setState(() => page = 'login'));
    } else if (page == 'reset') {
      body = V2ETResetPasswordPage(onLogin: () => setState(() => page = 'login'));
    } else {
      body = V2ETLoginPage(
        onLogin: () => setState(() => loggedIn = true),
        onRegister: () => setState(() => page = 'register'),
        onResetPassword: () => setState(() => page = 'reset'),
      );
    }

    return ProviderWindowFrame(title: V2ETTokens.brandName, backgroundColor: V2ETTokens.authBackground, child: body);
  }
}

class ProviderClientAppShell extends StatefulWidget {
  const ProviderClientAppShell({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  State<ProviderClientAppShell> createState() => _ProviderClientAppShellState();
}

class _ProviderClientAppShellState extends State<ProviderClientAppShell> {
  ProviderClientPage current = ProviderClientPage.dashboard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProviderSidebar(
          current: current,
          onChanged: (page) => setState(() => current = page),
          onSupport: () => showV2ETCustomerServiceDialog(context),
          onLogout: widget.onLogout,
        ),
        Expanded(
          child: Container(
            color: V2ETTokens.background,
            child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: KeyedSubtree(key: ValueKey(current), child: _page())),
          ),
        ),
      ],
    );
  }

  Widget _page() {
    switch (current) {
      case ProviderClientPage.dashboard:
        return const V2ETProviderHomePage();
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
