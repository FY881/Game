import 'package:flutter_test/flutter_test.dart';
import 'package:mamalik_alnard/core/content/cosmetics.dart';
import 'package:mamalik_alnard/core/content/heroes.dart';
import 'package:mamalik_alnard/core/content/maps.dart';

void main() {
  test('كتالوج الإطلاق يحتوي على ثمانية أبطال بست خرائط أصلية', () {
    expect(Heroes.all, hasLength(8));
    expect(BoardMaps.all, hasLength(6));
    expect(Heroes.all.map((HeroDefinition item) => item.id).toSet(), hasLength(8));
    expect(BoardMaps.all.map((BoardMapTheme item) => item.id).toSet(), hasLength(6));
  });

  test('التخصيصات تجميلية وتوفر بدائل صحيحة عند المعرف غير المعروف', () {
    expect(Cosmetics.pawnStyles, isNotEmpty);
    expect(Cosmetics.diceStyles, isNotEmpty);
    expect(Cosmetics.pawnById('unknown').id, Cosmetics.pawnStyles.first.id);
    expect(Cosmetics.diceById('unknown').id, Cosmetics.diceStyles.first.id);
  });
}
