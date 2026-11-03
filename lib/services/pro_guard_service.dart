class ProGuardService {
  static final ProGuardService _instance = ProGuardService._internal();
  factory ProGuardService() => _instance;
  ProGuardService._internal();

  bool _isProUser = false;

  bool get isProUser => _isProUser;

  void unlockPro() {
    _isProUser = true;
  }

  void resetPro() {
    _isProUser = false;
  }
}
