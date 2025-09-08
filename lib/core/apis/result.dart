/// Result of an operation: either Success or Failure.
abstract class Result<S, F> {
  /// Pattern matching for [Result]. Calls [ifSuccess] or [ifFailure].
  T when<T>(T Function(S value) ifSuccess, T Function(F error) ifFailure);

  /// Returns the value if Success, otherwise null.
  S? valueOrNull() => when((S value) => value, (_) => null);

  /// Returns the error if Failure, otherwise null.
  F? errorOrNull() => when((_) => null, (F error) => error);

  /// True if this is a Success.
  bool get isSuccess => when((_) => true, (_) => false);

  /// True if this is a Failure.
  bool get isFailure => when((_) => false, (_) => true);
}

/// Represents a successful result with a value of type [S].
class Success<S, F> extends Result<S, F> {
  /// The success value
  final S _value;

  /// Creates a new [Success] with the given value
  Success(this._value);

  /// Getter for the success value
  S get value => _value;

  @override
  T when<T>(T Function(S s) ifSuccess, T Function(F f) ifFailure) => ifSuccess(_value);

  @override
  bool operator ==(Object other) => identical(this, other) || other is Success<S, F> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Success($_value)';
}

/// Represents a failed result with an error of type [F].
class Failure<S, F> extends Result<S, F> {
  /// The failure value (error)
  final F _value;

  /// Creates a new [Failure] with the given error
  Failure(this._value);

  /// Getter for the failure value
  F get value => _value;

  @override
  T when<T>(T Function(S s) ifSuccess, T Function(F f) ifFailure) => ifFailure(_value);

  @override
  bool operator ==(Object other) => identical(this, other) || other is Failure<S, F> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Failure($_value)';
}
