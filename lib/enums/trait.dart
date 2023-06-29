enum Trait { suspended }

extension TraitEx on Trait {
  String get name => toString().split('.').last;
}
