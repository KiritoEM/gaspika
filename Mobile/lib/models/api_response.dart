class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool? hasError;

  ApiResponse({this.message, this.hasError = false, this.data});

  bool get isSucess => !hasError!;
}
