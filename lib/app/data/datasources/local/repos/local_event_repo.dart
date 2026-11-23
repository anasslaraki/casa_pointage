// Package imports:
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:casa_pointage/app/data/datasources/local/local_keys.dart';
import 'package:casa_pointage/app/data/datasources/local/repos/local_repo.dart';
import 'package:casa_pointage/app/data/datasources/remote/errors/exceptions.dart';
import 'package:casa_pointage/app/data/models/event.dart';

abstract class LocalEventRepo {
  Future<List<Event>?> getEvents();
  // Future<Event> getEvent({required String id});
  Future<List<Event>> cacheEvents(List<Event> events);
}

@Injectable(as: LocalEventRepo)
class LocalEventRepoImpl extends LocalEventRepo {
  /// Events Box
  Box? box;
  final boxVersion = "20230329-1";
  final boxName = "events";

  final LocalRepo localRepo;
  LocalEventRepoImpl(this.localRepo) {
    _initBox();
  }

  _initBox() async {
    if (box != null) return;
    box = await localRepo.initBox(boxName: boxName, version: boxVersion);
  }

  @override
  // Future<Event> getEvent({required String id}) async {}

  @override
  Future<List<Event>?> getEvents() async {
    try {
      await _initBox();
      return _getEvents();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Event>> cacheEvents(List<Event> events) async {
    try {
      await _initBox();
      const key = LocalKeys.events;
      final oldEvents = _getEvents();
      if (oldEvents != null) {
        final maps = oldEvents.map((el) => el.toJson()).toList();
        await box!.put(key, maps);
        return oldEvents;
      } else {
        await box!.put(key, events.map((el) => el.toJson()).toList());
        return events;
      }
    } catch (e) {
      throw CacheException();
    }
  }

  List<Event>? _getEvents() {
    const key = LocalKeys.events;
    if (!box!.containsKey(key)) return null;
    final list = box!.get(key) as List;
    return list.map((el) => Event.fromJson(el)).toList();
  }
}
