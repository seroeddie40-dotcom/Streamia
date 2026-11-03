class RecordingTask {
  final String title;
  final String url;
  final DateTime startedAt;
  bool isCompleted;

  RecordingTask({
    required this.title,
    required this.url,
    required this.startedAt,
    this.isCompleted = false,
  });
}

class RecordingDownloadService {
  static final RecordingDownloadService _instance = RecordingDownloadService._internal();
  factory RecordingDownloadService() => _instance;
  RecordingDownloadService._internal();

  final List<RecordingTask> _tasks = [];
  List<RecordingTask> get tasks => _tasks;

  Future<void> startRecording(String title, String url) async {
    final task = RecordingTask(
      title: title,
      url: url,
      startedAt: DateTime.now(),
    );
    _tasks.add(task);
    await Future.delayed(const Duration(seconds: 2));
    task.isCompleted = true;
  }
}
