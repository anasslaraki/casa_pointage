// Package imports:
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:casa_pointage/app/data/datasources/remote/errors/exceptions.dart';
import 'package:casa_pointage/app/data/models/event.dart';

abstract class RemoteEventRepo {
  Future<List<Event>> getEvents();
  // Future<Event> getEvent({required String id});
}

@Injectable(as: RemoteEventRepo)
class RemoteEventRepoImpl extends RemoteEventRepo {
  final Dio dio;
  final RemoteException remoteException;
  RemoteEventRepoImpl(this.dio, this.remoteException);

  @override
  Future<List<Event>> getEvents() async {
    final apiCall = dio.get('/events');
    final List<dynamic> data =
        await remoteException.handleRemoteResponse(apiCall);
    return data.map((el) => Event.fromJson(el)).toList();
  }
}
