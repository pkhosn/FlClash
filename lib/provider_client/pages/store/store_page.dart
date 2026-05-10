import 'package:flutter/material.dart';
import '../../mock/mock_provider_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/plan_card.dart';

class V2ETStorePage extends StatefulWidget {
  const V2ETStorePage({super.key});

  @override
  State<V2ETStorePage> createState() => _V2ETStorePageState();
}

class _V2ETStorePageState extends State<V2ETStorePage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final visible = mockPlans.where((p) {
      if (tab == 1) return p.type == '常规套餐';
      if (tab == 2) return p.type == '一次性套餐';
      return true;
    }).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 730),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  V2ETSegmentButton(
                    label: '全部',
                    selected: tab == 0,
                    onTap: () => setState(() => tab = 0),
                  ),
                  const SizedBox(width: 10),
                  V2ETSegmentButton(
                    label: '常规套餐',
                    selected: tab == 1,
                    onTap: () => setState(() => tab = 1),
                  ),
                  const SizedBox(width: 10),
                  V2ETSegmentButton(
                    label: '一次性套餐',
                    selected: tab == 2,
                    onTap: () => setState(() => tab = 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  for (final plan in visible)
                    V2ETPlanCard(plan: plan, onSubscribe: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
