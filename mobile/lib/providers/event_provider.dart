import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getEvents({String? campus, String? type, bool upcoming = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (campus != null) queryParams['campus'] = campus;
      if (type != null) queryParams['type'] = type;
      if (upcoming) queryParams['upcoming'] = 'true';

      final uri = Uri.parse(ApiConfig.events).replace(queryParameters: queryParams);
      final response = await ApiService.get(uri.toString());

      _events = (response as List).map((e) => Event.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Event> createEvent({
    required String title,
    String? description,
    String? eventType,
    String? location,
    String? campus,
    required DateTime startTime,
    DateTime? endTime,
    int? maxAttendees,
    bool isPublic = true,
    List<String>? tags,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.createEvent, {
        'title': title,
        'description': description,
        'event_type': eventType,
        'location': location,
        'campus': campus,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'max_attendees': maxAttendees,
        'is_public': isPublic,
        'tags': tags ?? [],
      });

      final event = Event.fromJson(response);
      _events.insert(0, event);
      notifyListeners();
      return event;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rsvpEvent(String eventId, String status) async {
    try {
      await ApiService.post(ApiConfig.eventRsvp(eventId), {'status': status});

      // Update local event
      final index = _events.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        final event = _events[index];
        _events[index] = Event(
          eventId: event.eventId,
          creatorId: event.creatorId,
          title: event.title,
          description: event.description,
          eventType: event.eventType,
          location: event.location,
          campus: event.campus,
          startTime: event.startTime,
          endTime: event.endTime,
          maxAttendees: event.maxAttendees,
          isPublic: event.isPublic,
          tags: event.tags,
          creatorName: event.creatorName,
          attendeeCount: status == 'going' ? event.attendeeCount + 1 : event.attendeeCount,
          userStatus: status,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await ApiService.delete(ApiConfig.deleteEvent(eventId));
      _events.removeWhere((e) => e.eventId == eventId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
