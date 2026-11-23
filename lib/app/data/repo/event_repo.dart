// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:casa_pointage/app/data/datasources/data_source_type.dart';
import 'package:casa_pointage/app/data/datasources/local/repos/local_event_repo.dart';
import 'package:casa_pointage/app/data/datasources/remote/repos/remote_event_repo.dart';
import 'package:casa_pointage/app/data/models/event.dart';

abstract class EventsRepo {
  // Future<Event?> getEvent({DataSourceType type = DataSourceType.remote});
  Future<List<Event>?> getEvents({DataSourceType type = DataSourceType.remote});
}

@LazySingleton(as: EventsRepo)
class EventsRepoImpl implements EventsRepo {
  final RemoteEventRepo remoteEventRepo;
  final LocalEventRepo localeEventRepo;
  EventsRepoImpl(this.remoteEventRepo, this.localeEventRepo);

  @override
  Future<List<Event>?> getEvents(
      {DataSourceType type = DataSourceType.remote}) async {
    if (type == DataSourceType.remote) {
      final events = await remoteEventRepo.getEvents();
      // localeEventRepo.cacheEvents(events);
      return events;
    } else if (type == DataSourceType.locale) {
      return localeEventRepo.getEvents();
    } else {
      return Future.value(null);
    }
  }
}
