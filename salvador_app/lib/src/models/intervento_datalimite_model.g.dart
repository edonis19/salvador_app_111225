// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervento_datalimite_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetInterventoSyncLogCollection on Isar {
  IsarCollection<String, InterventoSyncLog> get interventoSyncLogs =>
      this.collection();
}

const InterventoSyncLogSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'InterventoSyncLog',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'datalimite',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'user',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, InterventoSyncLog>(
    serialize: serializeInterventoSyncLog,
    deserialize: deserializeInterventoSyncLog,
    deserializeProperty: deserializeInterventoSyncLogProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeInterventoSyncLog(IsarWriter writer, InterventoSyncLog object) {
  IsarCore.writeLong(
      writer, 1, object.datalimite.toUtc().microsecondsSinceEpoch);
  IsarCore.writeString(writer, 2, object.user);
  IsarCore.writeString(writer, 3, object.id);
  return Isar.fastHash(object.id);
}

@isarProtected
InterventoSyncLog deserializeInterventoSyncLog(IsarReader reader) {
  final DateTime _datalimite;
  {
    final value = IsarCore.readLong(reader, 1);
    if (value == -9223372036854775808) {
      _datalimite =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _datalimite =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final String _user;
  _user = IsarCore.readString(reader, 2) ?? '';
  final object = InterventoSyncLog(
    datalimite: _datalimite,
    user: _user,
  );
  return object;
}

@isarProtected
dynamic deserializeInterventoSyncLogProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      {
        final value = IsarCore.readLong(reader, 1);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _InterventoSyncLogUpdate {
  bool call({
    required String id,
    DateTime? datalimite,
    String? user,
  });
}

class _InterventoSyncLogUpdateImpl implements _InterventoSyncLogUpdate {
  const _InterventoSyncLogUpdateImpl(this.collection);

  final IsarCollection<String, InterventoSyncLog> collection;

  @override
  bool call({
    required String id,
    Object? datalimite = ignore,
    Object? user = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (datalimite != ignore) 1: datalimite as DateTime?,
          if (user != ignore) 2: user as String?,
        }) >
        0;
  }
}

sealed class _InterventoSyncLogUpdateAll {
  int call({
    required List<String> id,
    DateTime? datalimite,
    String? user,
  });
}

class _InterventoSyncLogUpdateAllImpl implements _InterventoSyncLogUpdateAll {
  const _InterventoSyncLogUpdateAllImpl(this.collection);

  final IsarCollection<String, InterventoSyncLog> collection;

  @override
  int call({
    required List<String> id,
    Object? datalimite = ignore,
    Object? user = ignore,
  }) {
    return collection.updateProperties(id, {
      if (datalimite != ignore) 1: datalimite as DateTime?,
      if (user != ignore) 2: user as String?,
    });
  }
}

extension InterventoSyncLogUpdate on IsarCollection<String, InterventoSyncLog> {
  _InterventoSyncLogUpdate get update => _InterventoSyncLogUpdateImpl(this);

  _InterventoSyncLogUpdateAll get updateAll =>
      _InterventoSyncLogUpdateAllImpl(this);
}

sealed class _InterventoSyncLogQueryUpdate {
  int call({
    DateTime? datalimite,
    String? user,
  });
}

class _InterventoSyncLogQueryUpdateImpl
    implements _InterventoSyncLogQueryUpdate {
  const _InterventoSyncLogQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<InterventoSyncLog> query;
  final int? limit;

  @override
  int call({
    Object? datalimite = ignore,
    Object? user = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (datalimite != ignore) 1: datalimite as DateTime?,
      if (user != ignore) 2: user as String?,
    });
  }
}

extension InterventoSyncLogQueryUpdate on IsarQuery<InterventoSyncLog> {
  _InterventoSyncLogQueryUpdate get updateFirst =>
      _InterventoSyncLogQueryUpdateImpl(this, limit: 1);

  _InterventoSyncLogQueryUpdate get updateAll =>
      _InterventoSyncLogQueryUpdateImpl(this);
}

class _InterventoSyncLogQueryBuilderUpdateImpl
    implements _InterventoSyncLogQueryUpdate {
  const _InterventoSyncLogQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<InterventoSyncLog, InterventoSyncLog, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? datalimite = ignore,
    Object? user = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (datalimite != ignore) 1: datalimite as DateTime?,
        if (user != ignore) 2: user as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension InterventoSyncLogQueryBuilderUpdate
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QOperations> {
  _InterventoSyncLogQueryUpdate get updateFirst =>
      _InterventoSyncLogQueryBuilderUpdateImpl(this, limit: 1);

  _InterventoSyncLogQueryUpdate get updateAll =>
      _InterventoSyncLogQueryBuilderUpdateImpl(this);
}

extension InterventoSyncLogQueryFilter
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QFilterCondition> {
  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      datalimiteEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      datalimiteGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      datalimiteGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      datalimiteLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      datalimiteLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      datalimiteBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      userIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }
}

extension InterventoSyncLogQueryObject
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QFilterCondition> {}

extension InterventoSyncLogQuerySortBy
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QSortBy> {
  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy>
      sortByDatalimite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy>
      sortByDatalimiteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy> sortByUser(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy>
      sortByUserDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension InterventoSyncLogQuerySortThenBy
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QSortThenBy> {
  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy>
      thenByDatalimite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy>
      thenByDatalimiteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy> thenByUser(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy>
      thenByUserDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension InterventoSyncLogQueryWhereDistinct
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QDistinct> {
  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterDistinct>
      distinctByDatalimite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<InterventoSyncLog, InterventoSyncLog, QAfterDistinct>
      distinctByUser({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }
}

extension InterventoSyncLogQueryProperty1
    on QueryBuilder<InterventoSyncLog, InterventoSyncLog, QProperty> {
  QueryBuilder<InterventoSyncLog, DateTime, QAfterProperty>
      datalimiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<InterventoSyncLog, String, QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<InterventoSyncLog, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension InterventoSyncLogQueryProperty2<R>
    on QueryBuilder<InterventoSyncLog, R, QAfterProperty> {
  QueryBuilder<InterventoSyncLog, (R, DateTime), QAfterProperty>
      datalimiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<InterventoSyncLog, (R, String), QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<InterventoSyncLog, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension InterventoSyncLogQueryProperty3<R1, R2>
    on QueryBuilder<InterventoSyncLog, (R1, R2), QAfterProperty> {
  QueryBuilder<InterventoSyncLog, (R1, R2, DateTime), QOperations>
      datalimiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<InterventoSyncLog, (R1, R2, String), QOperations>
      userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<InterventoSyncLog, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}
