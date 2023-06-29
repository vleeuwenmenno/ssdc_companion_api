import 'package:darq/darq.dart';
import 'package:isar/isar.dart';
import 'package:ssdc_companion_api/enums/trait.dart';
import 'package:ssdc_companion_api/exceptions/missing_trait_exception.dart';
import 'package:ssdc_companion_api/exceptions/unexpected_trait_exception.dart';
import 'package:ssdc_companion_api/models/login/session.dart';
import 'package:ssdc_companion_api/models/user/user.dart';
import 'package:ssdc_companion_api/models/user/user_trait.dart';
import 'package:ssdc_companion_api/services/api_service.dart';

extension UserTraitEx on User {
  Future addTrait(Trait trait) async {
    final isar = serviceCollection.get<Isar>();
    final userTrait = UserTrait()
      ..user.value = this
      ..trait = trait.name;

    traits.add(userTrait);

    await isar.writeTxn(() async {
      await isar.userTraits.put(userTrait);
      await traits.save();
    });
  }

  Future removeTrait(Trait trait) async {
    final isar = serviceCollection.get<Isar>();
    final userTrait = await isar.userTraits
        .filter()
        .user((q) => q.idEqualTo(id))
        .traitEqualTo(trait.name)
        .findFirst();
    if (userTrait != null) {
      await isar.writeTxn(() async {
        await isar.userTraits.delete(userTrait.id);
        await traits.save();
      });
    }
  }

  hasTrait(Trait trait) {
    return traits.any((element) => element.trait == trait.name);
  }

  Future assertHasTraits(List<Trait> traits) async {
    final isar = serviceCollection.get<Isar>();
    final userTraits =
        await isar.userTraits.filter().user((q) => q.idEqualTo(id)).findAll();
    final userTraitValues = userTraits.map((e) => e.trait).toList();
    for (final trait in traits) {
      if (!userTraitValues.contains(trait.name)) {
        throw MissingTraitException(trait);
      }
    }
  }

  Future assertMissingTraits(List<Trait> traits) async {
    final isar = serviceCollection.get<Isar>();
    final userTraits =
        await isar.userTraits.filter().user((q) => q.idEqualTo(id)).findAll();
    final userTraitValues = userTraits.map((e) => e.trait).toList();
    for (final trait in traits) {
      if (userTraitValues.contains(trait.name)) {
        throw UnexpectedTraitException(
            Trait.values.firstWhere((e) => e.name.toString() == trait.name));
      }
    }
  }

  Future suspendUser() async {
    final isar = serviceCollection.get<Isar>();
    final loginSessions = (await isar.loginSessions
            .filter()
            .user((q) => q.idEqualTo(id))
            .findAll())
        .select((e, index) => e.id)
        .toList();

    // Clear users session tokens
    isar.writeTxn(() async {
      await isar.loginSessions.deleteAll(loginSessions);
    });

    addTrait(Trait.suspended);
  }
}
