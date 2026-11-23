import 'package:injectable/injectable.dart';

import '../../../api/api_client.dart';
import '../../../face/face_config.dart';

/// Raw calls of the face enrolment endpoints.
abstract class RemoteFaceRepo {
  /// `GET /gabarits?modeleVersion=`: the templates of the team.
  Future<List<Map<String, dynamic>>> getTemplates();

  /// `POST /enrolements`.
  Future<ApiResult> postEnrolment(Map<String, dynamic> body);

  /// `DELETE /enrolements/{agentId}`.
  Future<ApiResult> deleteEnrolment(int agentId);
}

@LazySingleton(as: RemoteFaceRepo)
class RemoteFaceRepoImpl implements RemoteFaceRepo {
  RemoteFaceRepoImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Map<String, dynamic>>> getTemplates() => _api.getAllPages(
        '/gabarits',
        query: {'modeleVersion': FaceConfig.modelVersion},
      );

  @override
  Future<ApiResult> postEnrolment(Map<String, dynamic> body) =>
      _api.write('POST', '/enrolements', body: body);

  @override
  Future<ApiResult> deleteEnrolment(int agentId) =>
      _api.write('DELETE', '/enrolements/$agentId');
}
