abstract class ShowEvents {}

class FetchShowIntro extends ShowEvents {
  final String showCategoryId;
  FetchShowIntro(this.showCategoryId);
  @override
  String toString() => 'FetchShowIntro { ShowCategoryId: $showCategoryId }';
}
