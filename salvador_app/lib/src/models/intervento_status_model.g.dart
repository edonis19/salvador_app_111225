// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervento_status_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetInterventoStatusCollection on Isar {
  IsarCollection<int, InterventoStatus> get interventoStatus =>
      this.collection();
}

const InterventoStatusSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'InterventoStatus',
    idName: 'idTestata',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'status',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, InterventoStatus>(
    serialize: serializeInterventoStatus,
    deserialize: deserializeInterventoStatus,
    deserializeProperty: deserializeInterventoStatusProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeInterventoStatus(IsarWriter writer, InterventoStatus object) {
  {
    final value = object.status;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  return object.idTestata;
}

@isarProtected
InterventoStatus deserializeInterventoStatus(IsarReader reader) {
  final int _idTestata;
  _idTestata = IsarCore.readId(reader);
  final String? _status;
  _status = IsarCore.readString(reader, 1);
  final object = InterventoStatus(
    idTestata: _idTestata,
    status: _status,
  );
  return object;
}

@isarProtected
dynamic deserializeInterventoStatusProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _InterventoStatusUpdate {
  bool call({
    required int idTestata,
    String? status,
  });
}

class _InterventoStatusUpdateImpl implements _InterventoStatusUpdate {
  const _InterventoStatusUpdateImpl(this.collection);

  final IsarCollection<int, InterventoStatus> collection;

  @override
  bool call({
    required int idTestata,
    Object? status = ignore,
  }) {
    return collection.updateProperties([
          idTestata
        ], {
          if (status != ignore) 1: status as String?,
        }) >
        0;
  }
}

sealed class _InterventoStatusUpdateAll {
  int call({
    required List<int> idTestata,
    String? status,
  });
}

class _InterventoStatusUpdateAllImpl implements _InterventoStatusUpdateAll {
  const _InterventoStatusUpdateAllImpl(this.collection);

  final IsarCollection<int, InterventoStatus> collection;

  @override
  int call({
    required List<int> idTestata,
    Object? status = ignore,
  }) {
    return collection.updateProperties(idTestata, {
      if (status != ignore) 1: status as String?,
    });
  }
}

extension InterventoStatusUpdate on IsarCollection<int, InterventoStatus> {
  _InterventoStatusUpdate get update => _InterventoStatusUpdateImpl(this);

  _InterventoStatusUpdateAll get updateAll =>
      _InterventoStatusUpdateAllImpl(this);
}

sealed class _InterventoStatusQueryUpdate {
  int call({
    String? status,
  });
}

class _InterventoStatusQueryUpdateImpl implements _InterventoStatusQueryUpdate {
  const _InterventoStatusQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<InterventoStatus> query;
  final int? limit;

  @override
  int call({
    Object? status = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (status != ignore) 1: status as String?,
    });
  }
}

extension InterventoStatusQueryUpdate on IsarQuery<InterventoStatus> {
  _InterventoStatusQueryUpdate get updateFirst =>
      _InterventoStatusQueryUpdateImpl(this, limit: 1);

  _InterventoStatusQueryUpdate get updateAll =>
      _InterventoStatusQueryUpdateImpl(this);
}

class _InterventoStatusQueryBuilderUpdateImpl
    implements _InterventoStatusQueryUpdate {
  const _InterventoStatusQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<InterventoStatus, InterventoStatus, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? status = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (status != ignore) 1: status as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension InterventoStatusQueryBuilderUpdate
    on QueryBuilder<InterventoStatus, InterventoStatus, QOperations> {
  _InterventoStatusQueryUpdate get updateFirst =>
      _InterventoStatusQueryBuilderUpdateImpl(this, limit: 1);

  _InterventoStatusQueryUpdate get updateAll =>
      _InterventoStatusQueryBuilderUpdateImpl(this);
}

extension InterventoStatusQueryFilter
    on QueryBuilder<InterventoStatus, InterventoStatus, QFilterCondition> {
  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      idTestataEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      idTestataGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      idTestataGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      idTestataLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      idTestataLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      idTestataBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }
}

extension InterventoStatusQueryObject
    on QueryBuilder<InterventoStatus, InterventoStatus, QFilterCondition> {}

extension InterventoStatusQuerySortBy
    on QueryBuilder<InterventoStatus, InterventoStatus, QSortBy> {
  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy>
      sortByIdTestata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy>
      sortByIdTestataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy> sortByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy>
      sortByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension InterventoStatusQuerySortThenBy
    on QueryBuilder<InterventoStatus, InterventoStatus, QSortThenBy> {
  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy>
      thenByIdTestata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy>
      thenByIdTestataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy> thenByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InterventoStatus, InterventoStatus, QAfterSortBy>
      thenByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension InterventoStatusQueryWhereDistinct
    on QueryBuilder<InterventoStatus, InterventoStatus, QDistinct> {
  QueryBuilder<InterventoStatus, InterventoStatus, QAfterDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }
}

extension InterventoStatusQueryProperty1
    on QueryBuilder<InterventoStatus, InterventoStatus, QProperty> {
  QueryBuilder<InterventoStatus, int, QAfterProperty> idTestataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<InterventoStatus, String?, QAfterProperty> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }
}

extension InterventoStatusQueryProperty2<R>
    on QueryBuilder<InterventoStatus, R, QAfterProperty> {
  QueryBuilder<InterventoStatus, (R, int), QAfterProperty> idTestataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<InterventoStatus, (R, String?), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }
}

extension InterventoStatusQueryProperty3<R1, R2>
    on QueryBuilder<InterventoStatus, (R1, R2), QAfterProperty> {
  QueryBuilder<InterventoStatus, (R1, R2, int), QOperations>
      idTestataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<InterventoStatus, (R1, R2, String?), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InterventoStatusImpl _$$InterventoStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$InterventoStatusImpl(
      idTestata: (json['idTestata'] as num).toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$InterventoStatusImplToJson(
        _$InterventoStatusImpl instance) =>
    <String, dynamic>{
      'idTestata': instance.idTestata,
      'status': instance.status,
    };
