// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trait.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserTraitCollection on Isar {
  IsarCollection<UserTrait> get userTraits => this.collection();
}

const UserTraitSchema = CollectionSchema(
  name: r'UserTrait',
  id: -11741434728869595,
  properties: {
    r'trait': PropertySchema(
      id: 0,
      name: r'trait',
      type: IsarType.string,
    )
  },
  estimateSize: _userTraitEstimateSize,
  serialize: _userTraitSerialize,
  deserialize: _userTraitDeserialize,
  deserializeProp: _userTraitDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'user': LinkSchema(
      id: -6945456017156273080,
      name: r'user',
      target: r'User',
      single: true,
      linkName: r'traits',
    )
  },
  embeddedSchemas: {},
  getId: _userTraitGetId,
  getLinks: _userTraitGetLinks,
  attach: _userTraitAttach,
  version: '3.1.0+1',
);

int _userTraitEstimateSize(
  UserTrait object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.trait;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userTraitSerialize(
  UserTrait object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.trait);
}

UserTrait _userTraitDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserTrait();
  object.id = id;
  object.trait = reader.readStringOrNull(offsets[0]);
  return object;
}

P _userTraitDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userTraitGetId(UserTrait object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userTraitGetLinks(UserTrait object) {
  return [object.user];
}

void _userTraitAttach(IsarCollection<dynamic> col, Id id, UserTrait object) {
  object.id = id;
  object.user.attach(col, col.isar.collection<User>(), r'user', id);
}

extension UserTraitQueryWhereSort
    on QueryBuilder<UserTrait, UserTrait, QWhere> {
  QueryBuilder<UserTrait, UserTrait, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserTraitQueryWhere
    on QueryBuilder<UserTrait, UserTrait, QWhereClause> {
  QueryBuilder<UserTrait, UserTrait, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserTraitQueryFilter
    on QueryBuilder<UserTrait, UserTrait, QFilterCondition> {
  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trait',
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trait',
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trait',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trait',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trait',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trait',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trait',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trait',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trait',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trait',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trait',
        value: '',
      ));
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> traitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trait',
        value: '',
      ));
    });
  }
}

extension UserTraitQueryObject
    on QueryBuilder<UserTrait, UserTrait, QFilterCondition> {}

extension UserTraitQueryLinks
    on QueryBuilder<UserTrait, UserTrait, QFilterCondition> {
  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> user(
      FilterQuery<User> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'user');
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterFilterCondition> userIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'user', 0, true, 0, true);
    });
  }
}

extension UserTraitQuerySortBy on QueryBuilder<UserTrait, UserTrait, QSortBy> {
  QueryBuilder<UserTrait, UserTrait, QAfterSortBy> sortByTrait() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trait', Sort.asc);
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterSortBy> sortByTraitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trait', Sort.desc);
    });
  }
}

extension UserTraitQuerySortThenBy
    on QueryBuilder<UserTrait, UserTrait, QSortThenBy> {
  QueryBuilder<UserTrait, UserTrait, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterSortBy> thenByTrait() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trait', Sort.asc);
    });
  }

  QueryBuilder<UserTrait, UserTrait, QAfterSortBy> thenByTraitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trait', Sort.desc);
    });
  }
}

extension UserTraitQueryWhereDistinct
    on QueryBuilder<UserTrait, UserTrait, QDistinct> {
  QueryBuilder<UserTrait, UserTrait, QDistinct> distinctByTrait(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trait', caseSensitive: caseSensitive);
    });
  }
}

extension UserTraitQueryProperty
    on QueryBuilder<UserTrait, UserTrait, QQueryProperty> {
  QueryBuilder<UserTrait, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserTrait, String?, QQueryOperations> traitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trait');
    });
  }
}
