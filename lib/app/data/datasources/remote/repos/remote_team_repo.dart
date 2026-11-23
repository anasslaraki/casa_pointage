import 'package:injectable/injectable.dart';

import '../../../api/api_client.dart';

typedef Json = Map<String, dynamic>;

/// Raw calls of the team, attendance and reference-data endpoints.
abstract class RemoteTeamRepo {
  /// `GET /equipe?date=&filtre=&recherche=&page=&pageSize=`.
  Future<Json> getEquipe(
    String dateKey, {
    String? filter,
    String? search,
    int page = 1,
    int pageSize = 50,
  });

  /// `GET /profil`.
  Future<Json> getProfile();

  /// `GET /motifs`.
  Future<Json> getMotifs();

  /// `GET /types-absence`: the reasons of an absence declaration.
  Future<List<Object?>> getAbsenceTypes();

  /// `GET /circuits`, `/vehicules` and `/chariots`.
  Future<List<Json>> getCircuits();
  Future<List<Json>> getVehicles();
  Future<List<Json>> getCarts({Object? depotId});

  /// `GET /affectation`.
  Future<Json> getAffectation({required int agentId, required String dateKey});

  /// `GET /historique?au=&jours=`: one line per person and day.
  Future<Json> getHistory({
    required String toDateKey,
    required int days,
    int? agentId,
    String? filter,
    int page = 1,
    int pageSize = 50,
  });

  /// `GET /journee?agentId=&date=`: the sheet of one person.
  Future<Json> getDay({required int agentId, required String dateKey});

  /// The writes answer with `{ success, message, data }`.
  Future<ApiResult> postPointage(Json body);
  Future<ApiResult> postAbsence(Json body);
  Future<ApiResult> postDeclaration(Json body);
}

@LazySingleton(as: RemoteTeamRepo)
class RemoteTeamRepoImpl implements RemoteTeamRepo {
  RemoteTeamRepoImpl(this._api);

  final ApiClient _api;

  @override
  Future<Json> getEquipe(
    String dateKey, {
    String? filter,
    String? search,
    int page = 1,
    int pageSize = 50,
  }) async =>
      ((await _api.get(
                '/equipe',
                query: {
                  'date': dateKey,
                  if (filter != null && filter.isNotEmpty) 'filtre': filter,
                  if (search != null && search.trim().isNotEmpty)
                    'recherche': search.trim(),
                  'page': page,
                  'pageSize': pageSize,
                },
              ))
              as Map)
          .cast<String, dynamic>();

  @override
  Future<Json> getProfile() async =>
      ((await _api.get('/profil')) as Map).cast<String, dynamic>();

  @override
  Future<Json> getMotifs() async =>
      ((await _api.get('/motifs')) as Map).cast<String, dynamic>();

  @override
  Future<List<Object?>> getAbsenceTypes() async {
    final json = await _api.get('/types-absence');
    // A list, or an object holding the list.
    if (json is List) return json;
    if (json is Map) {
      return json.values.whereType<List>().firstOrNull ?? const [];
    }
    return const [];
  }

  @override
  Future<List<Json>> getCircuits() => _list('/circuits');

  @override
  Future<List<Json>> getVehicles() => _list('/vehicules');

  @override
  Future<List<Json>> getCarts({Object? depotId}) =>
      _list('/chariots', depotId == null ? null : {'depotId': depotId});

  @override
  Future<Json> getAffectation({
    required int agentId,
    required String dateKey,
  }) async {
    final json = await _api.get(
      '/affectation',
      query: {'agentId': agentId, 'date': dateKey},
    );
    return json is Map ? json.cast<String, dynamic>() : <String, dynamic>{};
  }

  @override
  Future<Json> getHistory({
    required String toDateKey,
    required int days,
    int? agentId,
    String? filter,
    int page = 1,
    int pageSize = 50,
  }) async =>
      ((await _api.get(
                '/historique',
                query: {
                  'au': toDateKey,
                  'jours': days,
                  'agentId': ?agentId,
                  if (filter != null && filter.isNotEmpty) 'filtre': filter,
                  'page': page,
                  'pageSize': pageSize,
                },
              ))
              as Map)
          .cast<String, dynamic>();

  @override
  Future<Json> getDay({required int agentId, required String dateKey}) async =>
      ((await _api.get(
                '/journee',
                query: {'agentId': agentId, 'date': dateKey},
              ))
              as Map)
          .cast<String, dynamic>();

  @override
  Future<ApiResult> postPointage(Json body) =>
      _api.write('POST', '/pointages', body: body);

  @override
  Future<ApiResult> postAbsence(Json body) =>
      _api.write('POST', '/absences', body: body);

  @override
  Future<ApiResult> postDeclaration(Json body) =>
      _api.write('POST', '/declarations', body: body);

  Future<List<Json>> _list(String path, [Map<String, dynamic>? query]) =>
      _api.getAllPages(path, query: query);
}
