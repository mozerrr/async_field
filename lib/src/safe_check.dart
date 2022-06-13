import 'async_field.dart';

Future<AsyncField<T>> safeCheck<T>(Future<T> Function() check) async {
  try {
    final data = await check();
    return AsyncField.data(data);
  } on Exception catch (e, s) {
    return AsyncField.error(e, originalError: e, stackTrace: s);
  }
}
