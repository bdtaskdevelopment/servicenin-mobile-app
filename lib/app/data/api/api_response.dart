class ApiResponse<T> {
  final bool success;
  final T? data;
  final T? errorMessage;

  ApiResponse.success(this.data) : success = true, errorMessage = null;

  ApiResponse.error(this.errorMessage) : success = false, data = null;
}

/*

// Example API call with custom response handling
  Future<ApiResponse<List<PostModel>>> getPosts() async {
    final response = await _apiCall('/posts', null);
    if (response.status.hasError) {
      return ApiResponse.error('Failed to fetch posts.');
    } else {
      final data = response.body;
      final posts = data.map<PostModel>((json) => PostModel.fromJson(json)).toList();
      return ApiResponse.success(posts);
    }
  }
*/