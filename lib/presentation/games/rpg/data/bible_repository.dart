import '../models/verse_fragment.dart';

class BibleRepository {
  Future<List<VerseFragment>> getRpgVerses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      VerseFragment(
        id: 'gen1_1',
        reference: 'Génesis 1:1',
        text: 'En el principio creó Dios los cielos y la tierra.',
      ),
      VerseFragment(
        id: 'jn3_16',
        reference: 'Juan 3:16',
        text: 'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito.',
      ),
      VerseFragment(
        id: 'sal23_1',
        reference: 'Salmos 23:1',
        text: 'Jehová es mi pastor; nada me faltará.',
      ),
      VerseFragment(
        id: 'rom8_28',
        reference: 'Romanos 8:28',
        text: 'A los que aman a Dios, todas las cosas les ayudan a bien.',
      ),
    ];
  }
}
