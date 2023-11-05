import 'package:src_viewer/classes/IRefresh.dart';

class RefreshNotifier {
  static final RefreshNotifier _singleton = RefreshNotifier._internal();
  factory RefreshNotifier() {
    return _singleton;
  }
  RefreshNotifier._internal();

  List<IRefresh> listeners = [];

  void addListener(IRefresh listener) {
    listeners.add(listener);
  }

  void removeListener(IRefresh listener) {
    listeners.remove(listener);
  }

  void notifyListeners() {
    for (IRefresh iR in listeners) {
      iR.refreshPage();
    }
  }
}