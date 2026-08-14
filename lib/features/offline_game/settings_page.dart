import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/game_settings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(gameSettingsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final GameSettings settings = ref.watch(gameSettingsProvider);
    final GameSettingsController controller = ref.read(gameSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات اللعب')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Text('إتاحة وراحة اللعب', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('تُحفظ هذه الخيارات على الجهاز وتُطبّق في كل مباراة محلية.'),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('حجم النص', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  SegmentedButton<double>(
                    segments: const <ButtonSegment<double>>[
                      ButtonSegment<double>(value: 0.9, label: Text('صغير')),
                      ButtonSegment<double>(value: 1, label: Text('عادي')),
                      ButtonSegment<double>(value: 1.15, label: Text('كبير')),
                      ButtonSegment<double>(value: 1.3, label: Text('كبير جدًا')),
                    ],
                    selected: <double>{settings.textScale},
                    onSelectionChanged: (Set<double> selection) => controller.update(settings.copyWith(textScale: selection.first)),
                  ),
                  const SizedBox(height: 18),
                  Text('تمييز ألوان اللاعبين', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ColorVisionMode>(
                    initialValue: settings.colorVisionMode,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: ColorVisionMode.values
                        .map((ColorVisionMode item) => DropdownMenuItem<ColorVisionMode>(value: item, child: Text(item.label)))
                        .toList(),
                    onChanged: (ColorVisionMode? value) => value == null ? null : controller.update(settings.copyWith(colorVisionMode: value)),
                  ),
                  const SizedBox(height: 8),
                  const Text('تطبّق لوحة اللعبة ألوانًا بديلة وواضحة للحفاظ على تمييز الأحجار والمسارات.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile.adaptive(
                  value: settings.reduceMotion,
                  onChanged: (bool value) => controller.update(settings.copyWith(reduceMotion: value)),
                  title: const Text('خفض الحركة'),
                  subtitle: const Text('ينفّذ أدوار الخصوم فورًا ويقلل الانتقالات غير الضرورية.'),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: settings.vibrationEnabled,
                  onChanged: (bool value) => controller.update(settings.copyWith(vibrationEnabled: value)),
                  title: const Text('الاهتزاز اللمسي'),
                  subtitle: const Text('نبضة خفيفة عند رمي النرد وتحريك الحجر.'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('وتيرة المباراة', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      SegmentedButton<GamePace>(
                        segments: GamePace.values
                            .map((GamePace pace) => ButtonSegment<GamePace>(value: pace, label: Text(pace.label)))
                            .toList(),
                        selected: <GamePace>{settings.pace},
                        onSelectionChanged: (Set<GamePace> selection) => controller.update(settings.copyWith(pace: selection.first)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('الأداء والطاقة', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<PerformanceMode>(
                        initialValue: settings.performanceMode,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: PerformanceMode.values
                            .map((PerformanceMode item) => DropdownMenuItem<PerformanceMode>(value: item, child: Text(item.label)))
                            .toList(),
                        onChanged: (PerformanceMode? value) => value == null ? null : controller.update(settings.copyWith(performanceMode: value)),
                      ),
                      const SizedBox(height: 8),
                      const Text('وضع توفير البطارية يحدّث محرك اللوحة على وتيرة أقل مستهدفة لتقليل الاستهلاك على الهواتف الضعيفة.'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: settings.soundEnabled,
                  onChanged: (bool value) => controller.update(settings.copyWith(soundEnabled: value)),
                  title: const Text('تفعيل مؤثرات الصوت'),
                  subtitle: const Text('خيار محفوظ وجاهز عند إضافة مؤثرات صوتية أصلية في مرحلة لاحقة.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
