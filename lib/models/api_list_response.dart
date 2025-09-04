class ApiListResponse<T> {
  final String status; // "success" | "error" | "not_found"
  final String message;
  final int total;
  final List<T> data;

  const ApiListResponse({
    required this.status,
    required this.message,
    required this.total,
    required this.data,
  });

  bool get ok => status == 'success';
}
