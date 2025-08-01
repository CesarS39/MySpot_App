// Crear un archivo: lib/services/place_notifier.dart
import 'dart:async';

class PlaceNotifier {
  static final PlaceNotifier _instance = PlaceNotifier._internal();
  factory PlaceNotifier() => _instance;
  PlaceNotifier._internal();

  final StreamController<PlaceLikeUpdate> _controller = StreamController<PlaceLikeUpdate>.broadcast();

  Stream<PlaceLikeUpdate> get stream => _controller.stream;

  void notifyLikeChanged(String placeId, bool isLiked) {
    _controller.add(PlaceLikeUpdate(placeId: placeId, isLiked: isLiked));
  }

  void dispose() {
    _controller.close();
  }
}

class PlaceLikeUpdate {
  final String placeId;
  final bool isLiked;

  PlaceLikeUpdate({required this.placeId, required this.isLiked});
}