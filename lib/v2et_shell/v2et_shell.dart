import 'package:fl_clash/provider_client/app_shell/provider_app_shell.dart';
import 'package:fl_clash/provider_client/config/remote_config_provider.dart';
import 'package:fl_clash/provider_client/pages/auth/login_page.dart';
import 'package:fl_clash/provider_client/pages/auth/register_page.dart';
import 'package:fl_clash/provider_client/pages/auth/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _AuthTab { login, register, forgot }

class V2etShellPage extends ConsumerStatefulWidget {
  const V2etShellPage({super.key});

  @override
  ConsumerState<V2etShellPage> createState() => _V2etShellPageState();
}

class _V2etShellPageState extends ConsumerState<V2etShellPage> {
  bool _loggedIn = false;
  _AuthTab _tab = _AuthTab.login;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigSyncProvider);
    if (_loggedIn) {
      return ProviderAppShell(
        onLogout: () => setState(() => _loggedIn = false),
      );
    }
    if (_tab == _AuthTab.register) {
      return RegisterPage(
        onBackToLogin: () => setState(() => _tab = _AuthTab.login),
      );
    }
    if (_tab == _AuthTab.forgot) {
      return ResetPasswordPage(
        onBackToLogin: () => setState(() => _tab = _AuthTab.login),
      );
    }
    return LoginPage(
      brandName: config.app.brandName,
      versionText: config.app.versionText,
      onLogin: () => setState(() => _loggedIn = true),
      onRegister: () => setState(() => _tab = _AuthTab.register),
      onForgot: () => setState(() => _tab = _AuthTab.forgot),
      onSupport: () {},
    );
  }
}
