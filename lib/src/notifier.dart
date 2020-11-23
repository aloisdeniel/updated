import 'dart:async';

import 'package:meta/meta.dart';

import 'future.dart' as future;
import 'update.dart';

/// A notifier is a store for a given [Update<T>].
///
/// The [update] is updated by calling [execute].
///
/// If you're using patterns base on immutable data (like redux, MVU), using `update` function directly
/// may be more appropriate.
class UpdateNotifier<T> {
  /// Create a new notifier.
  ///
  /// If an [initialValue] is given, the [update] is initialized as an [Updated<T>], else
  /// the value is initialized as a [NotUpdated<T>].
  UpdateNotifier({
    T initialValue,
  }) : _update = initialValue == null
            ? Update<T>()
            : Updated<T>.fromUpdating(
                Updating.fromNotLoaded(
                  NotLoaded<T>(),
                  id: 0,
                ),
                initialValue,
              );

  /// Indicates a new change of [update].
  ///
  /// Changes are emmited by calling the [execute] method.
  Stream<Update<T>> get updateChanged => _updateChanged.stream;

  /// Get the current value.
  Update<T> get update => _update;

  final StreamController<Update<T>> _updateChanged =
      StreamController<Update<T>>.broadcast();

  Update<T> _update;

  /// Starts a sequence of updates by running the [updater] and raising a new [Update] after each step of its execution.
  ///
  /// If an update has already been started from the current [update], then the behaviour is controlled
  /// by the [override] parameters. The new update can whether be ignore, or cancel the previous execution.
  ///
  /// An [optimisticValue] can be given to display an anticipated result during the loading phase.
  void execute({
    @required Future<T> Function() updater,
    future.UpdateOverride override = future.UpdateOverride.ignore,
    T optimisticValue,
  }) async {
    await for (var item in future.update(
      getUpdate: () => _update,
      updater: updater,
      override: override,
      optimisticValue: optimisticValue,
    )) {
      _update = item;
      _updateChanged.add(item);
    }
  }

  /// Release all resource (like stream listeners).
  void dispose() {
    _updateChanged.close();
  }
}
