import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              const Icon(Icons.casino_outlined, size: 72, color: Color(0xffd8b16d)),
              const SizedBox(height: 18),
              Text('ممالك النرد', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('لعبة سباق أحجار عربية أصلية. ابدأ مباراة محلية بالقواعد الكلاسيكية، ثم نتوسع تدريجيًا بالأبطال والخرائط والأونلاين.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/offline-match'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('ابدأ مباراة أوفلاين')),
              ),
              const SizedBox(height: 10),
              Text('الإصدار الحالي: نواة القواعد المحلية. لا توجد مشتريات أو إعلانات أو أونلاين بعد.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
