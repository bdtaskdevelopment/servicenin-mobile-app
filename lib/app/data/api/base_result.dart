sealed class Result<S> {
  const Result();
}

final class Success<S> extends Result<S> {
  const Success(this.value);
  final S value;
}

final class Failure<S> extends Result<S> {
  const Failure(this.errorMessage);
  final String errorMessage;
}

class Loading extends Result {}

/* 

// Sealed class for representing different API result states
sealed class Result<T> {
  const Result._();

  factory Result.success(T value) = Success<T>;
  factory Result.error(ApiError error) = Error<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value) : super._();
}

class Error<T> extends Result<T> {
  final ApiError error;
  const Error(this.error) : super._();
}

class ApiError {
  final String message;
  ApiError(this.message);
}

 */