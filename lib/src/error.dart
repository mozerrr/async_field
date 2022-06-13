class CustomException implements Exception {
  const CustomException([this.message = '']);

  final String message;

  // ignore: unnecessary_this
  String get type => (this.runtimeType).toString();

  bool get hasMessage => message.isNotEmpty;

  @override
  String toString() {
    var report = type;
    if (message.isNotEmpty) {
      report = "$report: $message";
    }
    return report;
  }
}

class DataIsNullException extends CustomException {
  const DataIsNullException([String message = '']) : super(message);
}

class CheckNotPassed extends CustomException {
  const CheckNotPassed([String message = 'Проверка не пройдена'])
      : super(message);
}
