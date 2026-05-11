import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';

import '../../theme/provider_tokens.dart';
import '../../widgets/app_notice.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class V2ETProviderSettingsPage extends ConsumerWidget {
  const V2ETProviderSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patch = ref.watch(patchClashConfigProvider);
    final dns = patch.dns;
    final mixedPort = patch.mixedPort;
    final allowLan = patch.allowLan;
    final ipv6 = patch.ipv6;
    final overrideDns = ref.watch(overrideDnsProvider);
    final nameserverCount = dns.nameserver.length;
    final localAddress = '127.0.0.1:$mixedPort';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              _ProxySettingsCard(
                mixedPort: mixedPort,
                allowLan: allowLan,
                localAddress: localAddress,
                onEditPort: () => _editMixedPort(context, ref, mixedPort),
                onAllowLan: (value) {
                  ref
                      .read(patchClashConfigProvider.notifier)
                      .update((state) => state.copyWith(allowLan: value));
                },
              ),
              const SizedBox(height: 16),
              _Ipv6Card(
                ipv6: ipv6,
                onChanged: (value) {
                  ref
                      .read(patchClashConfigProvider.notifier)
                      .update((state) => state.copyWith(ipv6: value));
                },
              ),
              const SizedBox(height: 16),
              _DnsCard(
                overrideDns: overrideDns,
                dnsModeText: dns.enhancedMode.name,
                nameserverCount: nameserverCount,
                onOverrideDns: (value) {
                  ref.read(overrideDnsProvider.notifier).value = value;
                },
                onEditMode: () => _editDnsMode(context, ref, dns.enhancedMode),
                onEditNameserver: () => _editNameserver(
                  context,
                  ref,
                  List<String>.from(dns.nameserver),
                ),
              ),
              const SizedBox(height: 16),
              const _GeoDataCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editMixedPort(
    BuildContext context,
    WidgetRef ref,
    int currentPort,
  ) async {
    final controller = TextEditingController(text: '$currentPort');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return V2ETDialogShell(
          title: '修改混合端口',
          icon: Icons.settings_ethernet_rounded,
          width: 420,
          body: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请输入 1024-49151',
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
          actions: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    final next = int.tryParse(controller.text.trim());
                    if (next == null || next < 1024 || next > 49151) {
                      V2ETNotice.error(context, '端口范围必须在 1024-49151');
                      return;
                    }
                    ref
                        .read(patchClashConfigProvider.notifier)
                        .update((state) => state.copyWith(mixedPort: next));
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editDnsMode(
    BuildContext context,
    WidgetRef ref,
    DnsMode currentMode,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return V2ETDialogShell(
          title: 'DNS模式',
          icon: Icons.dns_rounded,
          width: 380,
          body: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in DnsMode.values)
                  ListTile(
                    title: Text(mode.name),
                    trailing: mode == currentMode
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: V2ETTokens.primary,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(patchClashConfigProvider.notifier)
                          .update((state) => state.copyWith.dns(enhancedMode: mode));
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editNameserver(
    BuildContext context,
    WidgetRef ref,
    List<String> items,
  ) async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => ListInputPage(
          title: '自定义DNS服务器',
          items: items,
          titleBuilder: (item) => Text(item),
        ),
      ),
    );
    if (result == null) return;
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith.dns(nameserver: List.from(result)));
  }
}

class _ProxySettingsCard extends StatelessWidget {
  const _ProxySettingsCard({
    required this.mixedPort,
    required this.allowLan,
    required this.localAddress,
    required this.onEditPort,
    required this.onAllowLan,
  });
  final int mixedPort;
  final bool allowLan;
  final String localAddress;
  final VoidCallback onEditPort;
  final ValueChanged<bool> onAllowLan;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.code_rounded,
            title: '代理设置',
            subtitle: '管理本地代理服务',
          ),
          const SizedBox(height: 14),
          _SettingRow(
            icon: Icons.settings_ethernet_rounded,
            title: '混合端口',
            subtitle: '$mixedPort',
            trailing: V2ETButton(
              label: '修改',
              tone: V2ETButtonTone.soft,
              height: 30,
              onPressed: onEditPort,
            ),
          ),
          _SettingRow(
            icon: Icons.devices_other_rounded,
            title: '允许局域网',
            subtitle: '允许其他设备连接',
            trailing: Switch(value: allowLan, onChanged: onAllowLan),
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: V2ETTokens.cardSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: V2ETTokens.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  color: V2ETTokens.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  localAddress,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                V2ETButton(
                  label: '复制',
                  icon: Icons.copy_rounded,
                  tone: V2ETButtonTone.soft,
                  height: 32,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: localAddress));
                    if (context.mounted) {
                      V2ETNotice.success(context, '代理地址已复制');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ipv6Card extends StatelessWidget {
  const _Ipv6Card({required this.ipv6, required this.onChanged});
  final bool ipv6;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      radius: 16,
      child: Column(
        children: [
          const _SectionHeader(
            icon: Icons.water_drop_rounded,
            title: 'IPv6 设置',
            subtitle: '用一个开关统一管理 IPv6 相关能力',
          ),
          const SizedBox(height: 14),
          _SettingRow(
            icon: Icons.toggle_on_rounded,
            title: 'IPv6 总开关',
            subtitle: '统一控制核心和 DNS IPv6 功能',
            trailing: Switch(value: ipv6, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _DnsCard extends StatelessWidget {
  const _DnsCard({
    required this.overrideDns,
    required this.dnsModeText,
    required this.nameserverCount,
    required this.onOverrideDns,
    required this.onEditMode,
    required this.onEditNameserver,
  });
  final bool overrideDns;
  final String dnsModeText;
  final int nameserverCount;
  final ValueChanged<bool> onOverrideDns;
  final VoidCallback onEditMode;
  final VoidCallback onEditNameserver;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      radius: 16,
      child: Column(
        children: [
          const _SectionHeader(
            icon: Icons.dns_rounded,
            title: 'DNS 设置',
            subtitle: '管理 DNS 解析配置',
          ),
          const SizedBox(height: 14),
          _SettingRow(
            icon: Icons.dns_rounded,
            title: 'DNS覆写',
            subtitle: '开启后将覆盖配置中的 DNS 选项',
            trailing: Switch(value: overrideDns, onChanged: onOverrideDns),
          ),
          _SettingRow(
            icon: Icons.tune_rounded,
            title: 'DNS模式',
            subtitle: dnsModeText,
            trailing: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onEditMode,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: V2ETTokens.textMuted,
                ),
              ),
            ),
          ),
          _SettingRow(
            icon: Icons.edit_rounded,
            title: '自定义DNS服务器',
            subtitle: '已配置 $nameserverCount 个DNS服务器',
            trailing: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onEditNameserver,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: V2ETTokens.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoDataCard extends ConsumerStatefulWidget {
  const _GeoDataCard();

  @override
  ConsumerState<_GeoDataCard> createState() => _GeoDataCardState();
}

class _GeoDataCardState extends ConsumerState<_GeoDataCard> {
  final _updating = <String, bool>{
    'GeoIp': false,
    'GeoSite': false,
    'MMDB': false,
    'ASN': false,
  };

  @override
  Widget build(BuildContext context) {
    final allUpdating = _updating.values.any((e) => e);
    return V2ETCard(
      radius: 16,
      child: Column(
        children: [
          Row(
            children: [
              const _SectionHeader(
                icon: Icons.public_rounded,
                title: '地理数据',
                subtitle: '更新 GeoIP / GeoSite 数据库',
              ),
              const Spacer(),
              V2ETButton(
                label: '全部更新',
                icon: Icons.sync_rounded,
                tone: V2ETButtonTone.soft,
                onPressed: allUpdating ? null : _updateAll,
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in const ['GeoIp', 'GeoSite', 'MMDB', 'ASN'])
            _SettingRow(
              icon: Icons.circle,
              title: item,
              subtitle: '',
              trailing: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _updating[item] == true ? null : () => _updateOne(item),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _updating[item] == true
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: V2ETTokens.textSecondary,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateAll() async {
    for (final key in const ['GeoIp', 'GeoSite', 'MMDB', 'ASN']) {
      await _updateOne(key);
    }
  }

  Future<void> _updateOne(String key) async {
    setState(() => _updating[key] = true);
    try {
      final geoName = switch (key) {
        'GeoIp' => GEOIP,
        'GeoSite' => GEOSITE,
        'MMDB' => MMDB,
        'ASN' => ASN,
        _ => '',
      };
      if (geoName.isEmpty) return;
      final message = await coreController.updateGeoData(
        UpdateGeoDataParams(geoType: key, geoName: geoName),
      );
      if (message.isNotEmpty) throw message;
      if (!mounted) return;
      V2ETNotice.success(context, '$key 更新成功');
    } catch (e) {
      if (!mounted) return;
      V2ETNotice.error(context, '$key 更新失败: $e');
    } finally {
      if (mounted) {
        setState(() => _updating[key] = false);
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon: icon, color: V2ETTokens.teal),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: V2ETTokens.h3),
            const SizedBox(height: 4),
            Text(subtitle, style: V2ETTokens.small),
          ],
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _IconBox(icon: icon, color: const Color(0xFFA8D4FF), size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) Text(subtitle, style: V2ETTokens.small),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
