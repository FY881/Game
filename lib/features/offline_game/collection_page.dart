import 'package:flutter/material.dart';

import '../../core/content/cosmetics.dart';
import '../../core/content/heroes.dart';
import '../../core/content/maps.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key, required this.initialLoadout});

  final GameLoadout initialLoadout;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late GameLoadout _loadout;

  @override
  void initState() {
    super.initState();
    _loadout = widget.initialLoadout;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأبطال والخرائط'),
          bottom: const TabBar(tabs: <Widget>[Tab(text: 'الأبطال'), Tab(text: 'الخرائط'), Tab(text: 'التخصيص')]),
        ),
        body: TabBarView(
          children: <Widget>[
            _HeroTab(loadout: _loadout, onHeroSelected: (String id) => setState(() => _loadout = _loadout.copyWith(heroId: id))),
            _MapTab(loadout: _loadout, onMapSelected: (String id) => setState(() => _loadout = _loadout.copyWith(mapId: id))),
            _CosmeticsTab(
              loadout: _loadout,
              onPawnSelected: (String id) => setState(() => _loadout = _loadout.copyWith(pawnStyleId: id)),
              onDiceSelected: (String id) => setState(() => _loadout = _loadout.copyWith(diceStyleId: id)),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(14),
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(_loadout),
            icon: const Icon(Icons.check),
            label: const Text('اعتماد الاختيارات المحلية'),
          ),
        ),
      ),
    );
  }
}

class _HeroTab extends StatelessWidget {
  const _HeroTab({required this.loadout, required this.onHeroSelected});

  final GameLoadout loadout;
  final ValueChanged<String> onHeroSelected;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: Heroes.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final HeroDefinition hero = Heroes.all[index];
          final bool selected = hero.id == loadout.heroId;
          return Card(
            color: selected ? hero.accent.withValues(alpha: .22) : null,
            child: ListTile(
              onTap: () => onHeroSelected(hero.id),
              leading: CircleAvatar(backgroundColor: hero.accent.withValues(alpha: .28), child: Icon(hero.icon, color: hero.accent)),
              title: Text('${hero.name} — ${hero.title}'),
              subtitle: Text('${hero.ability}\n${hero.note}'),
              isThreeLine: true,
              trailing: selected ? const Icon(Icons.check_circle) : const Icon(Icons.radio_button_unchecked),
            ),
          );
        },
      );
}

class _MapTab extends StatelessWidget {
  const _MapTab({required this.loadout, required this.onMapSelected});

  final GameLoadout loadout;
  final ValueChanged<String> onMapSelected;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: BoardMaps.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final BoardMapTheme map = BoardMaps.all[index];
          final bool selected = map.id == loadout.mapId;
          return Card(
            color: selected ? map.center.withValues(alpha: .22) : null,
            child: ListTile(
              onTap: () => onMapSelected(map.id),
              leading: CircleAvatar(backgroundColor: map.track, child: Icon(map.icon, color: map.paper)),
              title: Text(map.name),
              subtitle: Text(map.description),
              trailing: selected ? const Icon(Icons.check_circle) : const Icon(Icons.radio_button_unchecked),
            ),
          );
        },
      );
}

class _CosmeticsTab extends StatelessWidget {
  const _CosmeticsTab({required this.loadout, required this.onPawnSelected, required this.onDiceSelected});

  final GameLoadout loadout;
  final ValueChanged<String> onPawnSelected;
  final ValueChanged<String> onDiceSelected;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Text('أشكال الأحجار', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...Cosmetics.pawnStyles.map(
            (CosmeticDefinition style) => ListTile(
              onTap: () => onPawnSelected(style.id),
              leading: Icon(style.icon, color: style.accent),
              title: Text(style.name),
              subtitle: Text(style.description),
              trailing: loadout.pawnStyleId == style.id ? const Icon(Icons.check_circle) : const Icon(Icons.radio_button_unchecked),
            ),
          ),
          const Divider(height: 28),
          Text('أشكال النرد', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...Cosmetics.diceStyles.map(
            (CosmeticDefinition style) => ListTile(
              onTap: () => onDiceSelected(style.id),
              leading: Icon(style.icon, color: style.accent),
              title: Text(style.name),
              subtitle: Text(style.description),
              trailing: loadout.diceStyleId == style.id ? const Icon(Icons.check_circle) : const Icon(Icons.radio_button_unchecked),
            ),
          ),
          const SizedBox(height: 12),
          const Text('هذه الاختيارات تجميلية محليًا ولا تعدّل قواعد الحركة أو احتمال النرد أو توازن المباراة.'),
        ],
      );
}
