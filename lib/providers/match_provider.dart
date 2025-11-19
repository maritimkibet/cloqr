import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class MatchProvider with ChangeNotifier {
  List<dynamic> _matchQueue = [];
  List<dynamic> _matches = [];
  List<dynamic> _studyPartners = [];
  bool _isLoading = false;

  List<dynamic> get matchQueue => _matchQueue;
  List<dynamic> get matches => _matches;
  List<dynamic> get studyPartners => _studyPartners;
  bool get isLoading => _isLoading;

  Future<void> fetchMatchQueue({String? mode}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = mode != null 
          ? '${ApiConfig.matchQueue}?mode=$mode'
          : ApiConfig.matchQueue;
      final response = await ApiService.get(url);
      _matchQueue = response['queue'];
    } catch (e) {
      print('Error fetching match queue: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> swipe(String swipedId, String direction) async {
    try {
      final response = await ApiService.post(ApiConfig.swipe, {
        'swipedId': swipedId,
        'direction': direction,
      });
      
      if (response['match'] == true) {
        await fetchMatches();
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMatches() async {
    try {
      final response = await ApiService.get(ApiConfig.matches);
      _matches = response['matches'];
      notifyListeners();
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  Future<void> fetchStudyPartners({
    String? course,
    int? year,
    String? studyStyle,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String url = ApiConfig.studyPartners;
      List<String> params = [];
      
      if (course != null) params.add('course=$course');
      if (year != null) params.add('year=$year');
      if (studyStyle != null) params.add('study_style=$studyStyle');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await ApiService.get(url);
      _studyPartners = response['partners'];
    } catch (e) {
      print('Error fetching study partners: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeFromQueue(int index) {
    if (index < _matchQueue.length) {
      _matchQueue.removeAt(index);
      notifyListeners();
    }
  }
}
