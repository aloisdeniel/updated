import 'package:meta/meta.dart';

/// An update represents the lifecycle of a [T] value that can be loaded asynchronously.
///
/// Its initial state is `NotLoaded`. During its first update, it goes through the `Updating` state
/// then `Updated` or `FailedUpdate` states, whether it is a success or not. During the following updates,
/// it goes through the `Refreshing` state then `Updated` or `FailedRefresh` states, whether it is a success or not.
///
/// See also :
///
/// * [update] method to update a value from a [Future] and manage transitions and cancellation.
abstract class Update<T> {
  /// Create a [NotLoaded] instance.
  const factory Update() = NotLoaded<T>;

  /// Internal constructor.
  const Update._();

  /// Combine [update1] and [update2] as a new [Update].
  ///
  /// If two values are available, they are merged into a new one
  /// with [combineValue].
  static Update<T3> combine<T1, T2, T3>({
    @required Update<T1> update1,
    @required Update<T2> update2,
    @required T3 Function(T1 value1, T2 value2) combineValues,
  }) {
    assert(update1 != null);
    assert(update2 != null);
    assert(combineValues != null);

    return update1.map(
      notLoaded: (state1) => update2.maybeMap(
        failedUpdate: (state2) => FailedUpdate<T3>(
          id: state2.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        refreshing: (state2) => NotLoaded<T3>(),
        failedRefresh: (state2) => FailedUpdate<T3>(
          id: state2.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        orElse: () => NotLoaded<T3>(),
      ),
      updating: (state1) => update2.map(
        failedUpdate: (state2) => FailedUpdate<T3>(
          id: state1.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        refreshing: (state2) => Updating<T3>(
          id: state2.id ^ state2.id,
        ),
        failedRefresh: (state2) => FailedUpdate<T3>(
          id: state1.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        notLoaded: (state2) => NotLoaded<T3>(),
        updated: (state2) => Updating<T3>(
          id: state1.id ^ state2.id,
        ),
        updating: (state2) => Updating<T3>(
          id: state1.id ^ state2.id,
        ),
      ),
      failedUpdate: (state1) => FailedUpdate<T3>(
        id: state1.id,
        error: state1.error,
        stackTrace: state1.error,
      ),
      refreshing: (state1) => update2.map(
        failedUpdate: (state2) => FailedUpdate<T3>(
          id: state1.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        refreshing: (state2) => Refreshing<T3>.fromUpdated(
          Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.previousUpdate.updatedAt,
            value: combineValues(
              state1.previousUpdate.value,
              state2.previousUpdate.value,
            ),
          ),
          id: state2.id ^ state2.id,
        ),
        failedRefresh: (state2) => FailedRefresh<T3>(
          previousUpdate: Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.previousUpdate.updatedAt,
            value: combineValues(
              state1.previousUpdate.value,
              state2.previousUpdate.value,
            ),
          ),
          error: state2.error,
          stackTrace: state2.error,
        ),
        notLoaded: (state2) => NotLoaded<T3>(),
        updated: (state2) => Refreshing<T3>.fromUpdated(
          Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.previousUpdate.updatedAt,
            value: combineValues(
              state1.previousUpdate.value,
              state2.value,
            ),
          ),
          id: state2.id ^ state2.id,
        ),
        updating: (state2) => Updating<T3>(
          id: state1.id ^ state2.id,
        ),
      ),
      failedRefresh: (state1) => update2.map(
        failedUpdate: (state2) => FailedUpdate<T3>(
          id: state1.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        refreshing: (state2) => FailedRefresh<T3>(
          previousUpdate: Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.previousUpdate.updatedAt,
            value: combineValues(
              state1.previousUpdate.value,
              state2.previousUpdate.value,
            ),
          ),
          error: state1.error,
          stackTrace: state1.error,
        ),
        failedRefresh: (state2) => FailedRefresh<T3>(
          previousUpdate: Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.previousUpdate.updatedAt,
            value: combineValues(
              state1.previousUpdate.value,
              state2.previousUpdate.value,
            ),
          ),
          error: state2.error,
          stackTrace: state2.error,
        ),
        notLoaded: (state2) => FailedUpdate<T3>(
          id: state1.id,
          error: state1.error,
          stackTrace: state1.stackTrace,
        ),
        updated: (state2) => FailedRefresh<T3>(
          previousUpdate: Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.previousUpdate.updatedAt,
            value: combineValues(
              state1.previousUpdate.value,
              state2.value,
            ),
          ),
          error: state1.error,
          stackTrace: state1.error,
        ),
        updating: (state2) => Updating<T3>(
          id: state1.id ^ state2.id,
        ),
      ),
      updated: (state1) => update2.map(
        failedUpdate: (state2) => FailedUpdate<T3>(
          id: state1.id ^ state2.id,
          error: state2.error,
          stackTrace: state2.error,
        ),
        refreshing: (state2) => Refreshing<T3>.fromUpdated(
          Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.updatedAt,
            value: combineValues(
              state1.value,
              state2.previousUpdate.value,
            ),
          ),
          id: state2.id ^ state2.id,
        ),
        failedRefresh: (state2) => FailedRefresh<T3>(
          previousUpdate: Updated<T3>(
            id: state1.id ^ state2.id,
            updatedAt: state1.updatedAt,
            value: combineValues(
              state1.value,
              state2.previousUpdate.value,
            ),
          ),
          error: state2.error,
          stackTrace: state2.error,
        ),
        notLoaded: (state2) => NotLoaded<T3>(),
        updated: (state2) => Updated<T3>(
          id: state1.id ^ state2.id,
          updatedAt: state1.updatedAt,
          value: combineValues(
            state1.value,
            state2.value,
          ),
        ),
        updating: (state2) => Updating<T3>(
          id: state1.id ^ state2.id,
        ),
      ),
    );
  }

  /// Gets the value if available (regardless of it is an optimistic one or not), else returns the
  /// result of [defaultValue].
  T getValue({
    @required T Function() defaultValue,
  }) {
    assert(defaultValue != null);
    return mapValue(
      value: (value, _) => value,
      orElse: () => defaultValue(),
    );
  }

  /// Indicates whether a value is currently available (regardless of it is an optimistic one or not).
  bool get hasValue {
    return mapValue(
      value: (value, _) => true,
      orElse: () => false,
    );
  }

  /// Indicates whether the update is currently [Updating] or [Refreshing].
  bool get isLoading {
    return map(
      updated: (state) => false,
      failedRefresh: (state) => false,
      refreshing: (state) => true,
      failedUpdate: (state) => false,
      notLoaded: (state) => false,
      updating: (state) => true,
    );
  }

  /// Indicates whether the update is currently [FailedUpdate] or [FailedRefresh].
  bool get hasFailed {
    return map(
      updated: (state) => false,
      failedRefresh: (state) => true,
      refreshing: (state) => false,
      failedUpdate: (state) => true,
      notLoaded: (state) => false,
      updating: (state) => false,
    );
  }

  /// Indicates whether the update is currently [Updated].
  bool get hasSucceeded {
    return map(
      updated: (state) => true,
      failedRefresh: (state) => false,
      refreshing: (state) => false,
      failedUpdate: (state) => false,
      notLoaded: (state) => false,
      updating: (state) => false,
    );
  }

  /// Map the current value to a [K] value , if available. If so, the [value] method is called, else
  /// the [orElse] method is called.
  K mapValue<K>({
    @required K Function(T value, bool isOptimistic) value,
    @required K Function() orElse,
  }) {
    assert(value != null);
    assert(orElse != null);
    return map(
      updated: (state) => value(state.value, false),
      failedRefresh: (state) => value(state.previousUpdate.value, false),
      refreshing: (state) => state.optimisticValue != null
          ? value(state.optimisticValue, true)
          : value(state.previousUpdate.value, false),
      failedUpdate: (state) => orElse(),
      notLoaded: (state) => orElse(),
      updating: (state) => state.optimisticValue != null
          ? value(state.optimisticValue, true)
          : orElse(),
    );
  }

  /// Map the current loading state to a [K] value. If [Updating] or [refreshing], the [loading] method is
  /// called, else the [orElse] method is called.
  K mapLoading<K>({
    @required K Function() loading,
    @required K Function() notLoading,
  }) {
    return map(
      updating: (state) => loading(),
      refreshing: (state) => loading(),
      updated: (state) => notLoading(),
      failedRefresh: (state) => notLoading(),
      failedUpdate: (state) => notLoading(),
      notLoaded: (state) => notLoading(),
    );
  }

  /// Map the current error to a [K] value , if in a failure state. If so, the [error] method is called, else
  /// the [orElse] method is called.
  K mapError<K>({
    @required K Function(dynamic error, StackTrace stackTrace) error,
    @required K Function() orElse,
  }) {
    assert(error != null);
    assert(orElse != null);
    return map(
      failedRefresh: (state) => error(state.error, state.stackTrace),
      failedUpdate: (state) => error(state.error, state.stackTrace),
      updated: (state) => orElse(),
      refreshing: (state) => orElse(),
      notLoaded: (state) => orElse(),
      updating: (state) => orElse(),
    );
  }

  /// Map the current state to a [K] value.
  K map<K>({
    @required K Function(NotLoaded<T> state) notLoaded,
    @required K Function(Updating<T> state) updating,
    @required K Function(FailedUpdate<T> state) failedUpdate,
    @required K Function(Refreshing<T> state) refreshing,
    @required K Function(FailedRefresh<T> state) failedRefresh,
    @required K Function(Updated<T> state) updated,
  }) {
    final state = this;
    if (state is Updated<T>) {
      return updated(state);
    }
    if (state is NotLoaded<T>) {
      return notLoaded(state);
    }
    if (state is FailedUpdate<T>) {
      return failedUpdate(state);
    }
    if (state is Updating<T>) {
      return updating(state);
    }
    if (state is Refreshing<T>) {
      return refreshing(state);
    }
    if (state is FailedRefresh<T>) {
      return failedRefresh(state);
    }

    throw Exception();
  }

  /// Map the current state to a [K] value.
  ///
  /// The [orElse] callback is used for any missing case.
  K maybeMap<K>({
    @required K Function() orElse,
    K Function(NotLoaded<T> state) notLoaded,
    K Function(Updating<T> state) updating,
    K Function(FailedUpdate<T> state) failedUpdate,
    K Function(Refreshing<T> state) refreshing,
    K Function(FailedRefresh<T> state) failedRefresh,
    K Function(Updated<T> state) updated,
  }) {
    assert(orElse != null);
    final state = this;
    if (state is Updated<T>) {
      return updated != null ? updated(state) : orElse();
    }
    if (state is NotLoaded<T>) {
      return notLoaded != null ? notLoaded(state) : orElse();
    }
    if (state is FailedUpdate<T>) {
      return failedUpdate != null ? failedUpdate(state) : orElse();
    }
    if (state is Updating<T>) {
      return updating != null ? updating(state) : orElse();
    }
    if (state is Refreshing<T>) {
      return refreshing != null ? refreshing(state) : orElse();
    }
    if (state is FailedRefresh<T>) {
      return failedRefresh != null ? failedRefresh(state) : orElse();
    }

    return orElse();
  }
}

class NotLoaded<T> extends Update<T> {
  const NotLoaded() : super._();

  @override
  String toString() {
    return 'NotLoaded<$T>()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || other is NotLoaded<T>;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class Updating<T> extends Update<T> {
  Updating({
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        super._();

  Updating.fromNotLoaded(
    NotLoaded<T> previous, {
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        super._();

  Updating.fromFailed(
    FailedUpdate<T> previous, {
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        super._();

  Updating.cancelling(
    Updating<T> previous, {
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        super._();

  final int id;
  final T optimisticValue;
  final DateTime startedAt;

  @override
  String toString() {
    return 'Updating<$T>(id: $id, startedAt: $startedAt, optimisticValue: ${optimisticValue ?? 'none'})';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Updating<T> &&
            id == other.id &&
            optimisticValue == other.optimisticValue);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ id.hashCode ^ (optimisticValue?.hashCode ?? 0);
}

class Updated<T> extends Update<T> {
  Updated.fromUpdating(Updating<T> previous, this.value)
      : id = previous.id,
        updatedAt = DateTime.now(),
        super._();

  Updated.fromRefreshing(Refreshing<T> previous, this.value)
      : id = previous.id,
        updatedAt = DateTime.now(),
        super._();

  const Updated({
    @required this.id,
    @required this.updatedAt,
    @required this.value,
  }) : super._();

  final int id;
  final DateTime updatedAt;
  final T value;

  @override
  String toString() {
    return 'Updated<$T>(id: $id, updatedAt: $updatedAt, previousUpdate: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Updated<T> && id == other.id && value == other.value);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ id.hashCode ^ (value?.hashCode ?? 0);
}

class FailedUpdate<T> extends Update<T> {
  FailedUpdate.fromUpdating(
    Updating<T> previous, {
    @required this.error,
    @required this.stackTrace,
  })  : failedAt = DateTime.now(),
        id = previous.id,
        super._();

  FailedUpdate({
    @required this.id,
    @required this.error,
    @required this.stackTrace,
  })  : failedAt = DateTime.now(),
        super._();

  final int id;
  final DateTime failedAt;
  final dynamic error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'FailedUpdate<$T>(id: $id, error: $error, stackTrace: $stackTrace, failedAt: $failedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is FailedUpdate<T> && id == other.id);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ id.hashCode;
}

class Refreshing<T> extends Update<T> {
  Refreshing.fromUpdated(
    Updated<T> previous, {
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        previousUpdate = previous,
        super._();

  Refreshing.fromFailed(
    FailedRefresh<T> previous, {
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        previousUpdate = previous.previousUpdate,
        super._();

  Refreshing.cancelling(
    Refreshing<T> previous, {
    @required this.id,
    this.optimisticValue,
  })  : startedAt = DateTime.now(),
        previousUpdate = previous.previousUpdate,
        super._();

  final int id;
  final DateTime startedAt;
  final T optimisticValue;
  final Updated<T> previousUpdate;

  @override
  String toString() {
    return 'Refreshing<$T>(id: $id, startedAt: $startedAt, previousUpdate: $previousUpdate, optimisticValue: ${optimisticValue ?? 'none'})';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Refreshing<T> &&
            id == other.id &&
            optimisticValue == other.optimisticValue &&
            previousUpdate == other.previousUpdate);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      id.hashCode ^
      (optimisticValue?.hashCode ?? 0) ^
      previousUpdate.hashCode;
}

class FailedRefresh<T> extends Update<T> {
  FailedRefresh.fromRefreshing(
    Refreshing<T> previous, {
    @required this.error,
    @required this.stackTrace,
  })  : failedAt = DateTime.now(),
        id = previous.id,
        previousUpdate = previous.previousUpdate,
        super._();

  FailedRefresh({
    @required this.previousUpdate,
    @required this.error,
    @required this.stackTrace,
  })  : failedAt = DateTime.now(),
        id = previousUpdate.id,
        super._();

  final int id;
  final Updated<T> previousUpdate;
  final DateTime failedAt;
  final dynamic error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'FailedRefresh<$T>(id: $id, error: $error, stackTrace: $stackTrace, failedAt: $failedAt, previousUpdate: $previousUpdate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is FailedRefresh<T> &&
            id == other.id &&
            previousUpdate == other.previousUpdate);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ id.hashCode ^ previousUpdate.hashCode;
}
