import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../api/api_exception.dart';
import '../datasources/remote/repos/remote_face_repo.dart';
import '../face/face_config.dart';
import '../face/face_math.dart';

/// The face template of one enrolled person.
class FaceTemplate {
  const FaceTemplate({
    required this.agentId,
    required this.matricule,
    required this.template,
    this.date,
  });

  final int agentId;
  final String matricule;

  /// Normalised, from the model of [FaceConfig.modelVersion].
  final Float32List template;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
        'agentId': agentId,
        'matricule': matricule,
        'gabarit': FaceMath.toBase64(template),
        'dateEnrolement': date?.toIso8601String(),
      };

  static FaceTemplate? fromJson(Map<String, dynamic> json) {
    final raw = json['gabarit'];
    final id = json['agentId'];
    if (raw is! String || id is! num) return null;
    return FaceTemplate(
      agentId: id.toInt(),
      matricule: '${json['matricule'] ?? ''}',
      template: FaceMath.fromBase64(raw),
      date: DateTime.tryParse('${json['dateEnrolement'] ?? ''}'),
    );
  }
}

/// The templates of the team, kept encrypted on the phone so the face can be
/// recognised without network.
abstract class FaceTemplateRepo {
  /// Downloads the templates of the team and keeps them. Without network the
  /// copy stored on the phone is used.
  Future<List<FaceTemplate>> sync();

  /// What is stored on the phone.
  Future<List<FaceTemplate>> stored();

  /// Sends the template of [agentId] (replacing a previous one) and keeps it.
  Future<void> enrol({
    required int agentId,
    required String matricule,
    required Float32List template,
    required double quality,
  });

  /// Forgets everything (logout).
  Future<void> clear();
}

@LazySingleton(as: FaceTemplateRepo)
class FaceTemplateRepoImpl implements FaceTemplateRepo {
  FaceTemplateRepoImpl(this._remote, this._storage);

  static const _key = 'face_templates';

  final RemoteFaceRepo _remote;
  final FlutterSecureStorage _storage;

  List<FaceTemplate>? _memory;

  @override
  Future<List<FaceTemplate>> stored() async {
    final cached = _memory;
    if (cached != null) return cached;
    final text = await _storage.read(key: _key);
    if (text == null || text.isEmpty) return _memory = const [];
    try {
      final list = (jsonDecode(text) as List)
          .whereType<Map>()
          .map((e) => FaceTemplate.fromJson(e.cast<String, dynamic>()))
          .whereType<FaceTemplate>()
          .toList();
      return _memory = list;
    } catch (_) {
      return _memory = const [];
    }
  }

  Future<void> _save(List<FaceTemplate> list) async {
    _memory = list;
    await _storage.write(
      key: _key,
      value: jsonEncode([for (final t in list) t.toJson()]),
    );
  }

  @override
  Future<List<FaceTemplate>> sync() async {
    try {
      final rows = await _remote.getTemplates();
      final list = [
        for (final row in rows)
          if (FaceTemplate.fromJson(row) case final t?) t,
      ];
      await _save(list);
      return list;
    } on NetworkUnavailable {
      return stored();
    }
  }

  @override
  Future<void> enrol({
    required int agentId,
    required String matricule,
    required Float32List template,
    required double quality,
  }) async {
    final current = await stored();
    final already = current.any((t) => t.agentId == agentId);
    if (already) await _remote.deleteEnrolment(agentId);

    await _remote.postEnrolment({
      'agentId': agentId,
      'gabarit': FaceMath.toBase64(template),
      'modeleVersion': FaceConfig.modelVersion,
      'qualite': double.parse(quality.toStringAsFixed(3)),
      'consentement': true,
    });

    await _save([
      for (final t in current)
        if (t.agentId != agentId) t,
      FaceTemplate(
        agentId: agentId,
        matricule: matricule,
        template: template,
        date: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<void> clear() async {
    _memory = const [];
    await _storage.delete(key: _key);
  }
}
