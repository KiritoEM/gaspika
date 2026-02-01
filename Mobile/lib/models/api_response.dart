import 'package:gaspika_mobile/constants/enums/enums.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final NetworkErrorType? errorType;
  final bool? hasError;

  ApiResponse({this.message, this.hasError = false, this.data, this.errorType});

  bool get isSucess => !hasError!;
}
