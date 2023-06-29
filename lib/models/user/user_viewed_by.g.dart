// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_viewed_by.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserViewsCollection on Isar {
  IsarCollection<UserViews> get userViews => this.collection();
}

const UserViewsSchema = CollectionSchema(
  name: r'UserViews',
  id: 5613001026266530098,
  properties: {
    r'dateTime': PropertySchema(
      id: 0,
      name: r'dateTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _userViewsEstimateSize,
  serialize: _userViewsSerialize,
  deserialize: _userViewsDeserialize,
  deserializeProp: _userViewsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'subject': LinkSchema(
      id: 1355040852433934563,
      name: r'subject',
      target: r'User',
      single: true,
    ),
    r'viewedBy': LinkSchema(
      id: 6933203237598835768,
      name: r'viewedBy',
      target: r'User',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _userViewsGetId,
  getLinks: _userViewsGetLinks,
  attach: _userViewsAttach,
  version: '3.1.0+1',
);

int _userViewsEstimateSize(
  UserViews object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userViewsSerialize(
  UserViews object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTime);
}

UserViews _userViewsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserViews();
  object.dateTime = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  return object;
}

P _userViewsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userViewsGetId(UserViews object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userViewsGetLinks(UserViews object) {
  return [object.subject, object.viewedBy];
}

void _userViewsAttach(IsarCollection<dynamic> col, Id id, UserViews object) {
  object.id = id;
  object.subject.attach(col, col.isar.collection<User>(), r'subject', id);
  object.viewedBy.attach(col, col.isar.collection<User>(), r'viewedBy', id);
}

extension UserViewsQueryWhereSort
    on QueryBuilder<UserViews, UserViews, QWhere> {
  QueryBuilder<UserViews, UserViews, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserViewsQueryWhere
    on QueryBuilder<UserViews, UserViews, QWhereClause> {
  QueryBuilder<UserViews, UserViews, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserViews, UserViews, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterWhereClause> idBetween(
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

extension UserViewsQueryFilter
    on QueryBuilder<UserViews, UserViews, QFilterCondition> {
  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> dateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateTime',
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition>
      dateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateTime',
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> dateTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> dateTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> dateTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> dateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> idBetween(
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
}

extension UserViewsQueryObject
    on QueryBuilder<UserViews, UserViews, QFilterCondition> {}

extension UserViewsQueryLinks
    on QueryBuilder<UserViews, UserViews, QFilterCondition> {
  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> subject(
      FilterQuery<User> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'subject');
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> subjectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subject', 0, true, 0, true);
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> viewedBy(
      FilterQuery<User> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'viewedBy');
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterFilterCondition> viewedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'viewedBy', 0, true, 0, true);
    });
  }
}

extension UserViewsQuerySortBy on QueryBuilder<UserViews, UserViews, QSortBy> {
  QueryBuilder<UserViews, UserViews, QAfterSortBy> sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterSortBy> sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }
}

extension UserViewsQuerySortThenBy
    on QueryBuilder<UserViews, UserViews, QSortThenBy> {
  QueryBuilder<UserViews, UserViews, QAfterSortBy> thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterSortBy> thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserViews, UserViews, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension UserViewsQueryWhereDistinct
    on QueryBuilder<UserViews, UserViews, QDistinct> {
  QueryBuilder<UserViews, UserViews, QDistinct> distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }
}

extension UserViewsQueryProperty
    on QueryBuilder<UserViews, UserViews, QQueryProperty> {
  QueryBuilder<UserViews, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserViews, DateTime?, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }
}
