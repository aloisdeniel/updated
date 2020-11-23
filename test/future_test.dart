import 'package:meta/meta.dart';
import 'package:updated/updated.dart';
import 'package:updated/updated.dart' as u;
import 'package:test/test.dart';

class TestStore<T> {
  Update<T> value;
  TestStore.notUpdated() : value = Update<T>();

  TestStore.updating({
    @required int id,
  }) : value = Updating.fromNotLoaded(Update<T>(), id: id);

  TestStore.refreshing({
    @required int id,
    @required T value,
  }) : value = Refreshing.fromUpdated(
            Updated<T>.fromUpdating(
              Updating.fromNotLoaded(Update<T>(), id: id),
              value,
            ),
            id: id);

  TestStore.updated({
    @required int id,
    @required T value,
  }) : value = Updated<T>.fromUpdating(
          Updating.fromNotLoaded(Update<T>(), id: id),
          value,
        );

  Future<List<Update<T>>> update({
    @required Future<T> Function() updater,
    UpdateOverride override = UpdateOverride.ignore,
    T optimisticValue,
  }) async {
    final result = <Update<T>>[];
    await for (var item in u.update(
      updater: updater,
      getUpdate: () => value,
      override: override,
      optimisticValue: optimisticValue,
    )) {
      value = item;
      result.add(item);
    }
    return result;
  }
}

void main() {
  group('An update call', () {
    test('transitions from `NotLoaded` to `Updating` then `Updated`', () async {
      final store = TestStore.notUpdated();

      final updates = await store.update(
        updater: () async {
          await Future.delayed(const Duration(seconds: 1));
          return 42;
        },
      );

      expect(updates.length, 2);

      // Updating
      final updating = updates.first;
      expect(updating.isLoading, isTrue);
      expect(updating.hasValue, isFalse);
      expect(
          updating.map(
            updating: (_) => true,
            notLoaded: (_) => false,
            failedUpdate: (_) => false,
            refreshing: (_) => false,
            failedRefresh: (_) => false,
            updated: (_) => false,
          ),
          isTrue);

      // Updated
      final updated = updates[1];
      expect(updated.isLoading, isFalse);
      expect(updated.hasValue, isTrue);
      expect(
          updated.map(
            updating: (_) => false,
            notLoaded: (_) => false,
            failedUpdate: (_) => false,
            refreshing: (_) => false,
            failedRefresh: (_) => false,
            updated: (_) => true,
          ),
          isTrue);
      expect(updated.getValue(defaultValue: () => throw Exception), equals(42));
    });

    test('transitions from `NotLoaded` to `Updating` with an optimistic value',
        () async {
      final store = TestStore.notUpdated();

      final updates = await store.update(
        optimisticValue: 71,
        updater: () async {
          await Future.delayed(const Duration(seconds: 1));
          return 42;
        },
      );

      expect(updates.length, 2);

      // Updating
      final updating = updates.first;
      expect(updating.isLoading, isTrue);
      expect(updating.hasValue, isTrue);
      expect(
          updating.map(
            updating: (_) => true,
            notLoaded: (_) => false,
            failedUpdate: (_) => false,
            refreshing: (_) => false,
            failedRefresh: (_) => false,
            updated: (_) => false,
          ),
          isTrue);
      expect(
          updating.getValue(defaultValue: () => throw Exception), equals(71));

      // Updated
      final updated = updates[1];
      expect(updated.isLoading, isFalse);
      expect(updated.hasValue, isTrue);
      expect(
          updated.map(
            updating: (_) => false,
            notLoaded: (_) => false,
            failedUpdate: (_) => false,
            refreshing: (_) => false,
            failedRefresh: (_) => false,
            updated: (_) => true,
          ),
          isTrue);
      expect(updated.getValue(defaultValue: () => throw Exception), equals(42));
    });

    test('transitions from `NotLoaded` to `Updating` then `FailedUpdate`',
        () async {
      final store = TestStore.notUpdated();

      final updates = await store.update(
        updater: () async {
          await Future.delayed(const Duration(seconds: 1));
          throw Exception('TEST');
        },
      );

      expect(updates.length, 2);

      // Updating
      final updating = updates.first;
      expect(updating.isLoading, isTrue);
      expect(updating.hasValue, isFalse);
      expect(
          updating.map(
            updating: (_) => true,
            notLoaded: (_) => false,
            failedUpdate: (_) => false,
            refreshing: (_) => false,
            failedRefresh: (_) => false,
            updated: (_) => false,
          ),
          isTrue);

      // FailedUpdate
      final failed = updates[1];
      expect(failed.hasFailed, isTrue);
      expect(failed.isLoading, isFalse);
      expect(failed.hasValue, isFalse);
      expect(
          failed.map(
            updating: (_) => false,
            notLoaded: (_) => false,
            failedUpdate: (_) => true,
            refreshing: (_) => false,
            failedRefresh: (_) => false,
            updated: (_) => false,
          ),
          isTrue);
      expect(
          failed.mapError(
            error: (error, stackTrace) => error.message,
            orElse: () => throw Exception,
          ),
          equals('TEST'));
    });
  });

  test('transitions from `Updated` to `Refreshing` then `Updated`', () async {
    final store = TestStore.updated(id: 1, value: 42);

    // Starting a refresh
    final updates = await store.update(
      updater: () async {
        await Future.delayed(const Duration(seconds: 1));
        return 24;
      },
    );

    expect(updates.length, 2);

    // Refreshing
    final refreshing = updates.first;
    expect(refreshing.isLoading, isTrue);
    expect(refreshing.hasValue, isTrue);
    expect(
        refreshing.map(
          updating: (_) => false,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => true,
          failedRefresh: (_) => false,
          updated: (_) => false,
        ),
        isTrue);
    expect(
        refreshing.getValue(defaultValue: () => throw Exception), equals(42));

    // Updated
    final refreshed = updates[1];
    expect(refreshed.isLoading, isFalse);
    expect(refreshed.hasValue, isTrue);
    expect(
        refreshed.map(
          updating: (_) => false,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => false,
          failedRefresh: (_) => false,
          updated: (_) => true,
        ),
        isTrue);
    expect(refreshed.getValue(defaultValue: () => throw Exception), equals(24));
  });

  test('does nothing from `Updating` with ignore override', () async {
    final store = TestStore.updating(id: 1);

    // Starting a refresh
    final updates = await store.update(
      override: UpdateOverride.ignore,
      updater: () async {
        await Future.delayed(const Duration(seconds: 1));
        return 24;
      },
    );

    expect(updates.length, 0);

    // Updating
    final updating = store.value;
    expect(updating.isLoading, isTrue);
    expect(updating.hasValue, isFalse);
    expect(
        updating.map(
          updating: (_) => true,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => false,
          failedRefresh: (_) => false,
          updated: (_) => false,
        ),
        isTrue);
  });

  test('does nothing from `Refreshing` with ignore override', () async {
    final store = TestStore.refreshing(id: 1, value: 42);

    // Starting a refresh
    final updates = await store.update(
      override: UpdateOverride.ignore,
      updater: () async {
        await Future.delayed(const Duration(seconds: 1));
        return 24;
      },
    );

    expect(updates.length, 0);

    // Refreshing
    final refreshing = store.value;
    expect(refreshing.isLoading, isTrue);
    expect(refreshing.hasValue, isTrue);
    expect(
        refreshing.map(
          updating: (_) => false,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => true,
          failedRefresh: (_) => false,
          updated: (_) => false,
        ),
        isTrue);
    expect(
        refreshing.getValue(defaultValue: () => throw Exception), equals(42));
  });

  test('cancels `Updating` when cancelPrevious override', () async {
    final store = TestStore.notUpdated();

    final cancelledUpdatesFuture = store.update(
      updater: () async {
        await Future.delayed(const Duration(seconds: 3));
        return 24;
      },
    );

    await Future.delayed(const Duration(seconds: 1));

    final overridingUpdatesFuture = store.update(
      override: UpdateOverride.cancelPrevious,
      updater: () async {
        await Future.delayed(const Duration(seconds: 1));
        return 42;
      },
    );

    final cancelledUpdates = await cancelledUpdatesFuture;
    final overridingUpdates = await overridingUpdatesFuture;

    expect(cancelledUpdates.length, 1);

    // Cancelled : Updating
    final cancelUpdating = cancelledUpdates.first;
    expect(cancelUpdating.isLoading, isTrue);
    expect(cancelUpdating.hasValue, isFalse);
    expect(
        cancelUpdating.map(
          updating: (_) => true,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => false,
          failedRefresh: (_) => false,
          updated: (_) => false,
        ),
        isTrue);

    expect(overridingUpdates.length, 2);

    // Updating
    final updating = overridingUpdates.first;
    expect(updating.isLoading, isTrue);
    expect(updating.hasValue, isFalse);
    expect(
        updating.map(
          updating: (_) => true,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => false,
          failedRefresh: (_) => false,
          updated: (_) => false,
        ),
        isTrue);

    // Updated
    final updated = overridingUpdates[1];
    expect(updated.isLoading, isFalse);
    expect(updated.hasValue, isTrue);
    expect(
        updated.map(
          updating: (_) => false,
          notLoaded: (_) => false,
          failedUpdate: (_) => false,
          refreshing: (_) => false,
          failedRefresh: (_) => false,
          updated: (_) => true,
        ),
        isTrue);
    expect(updated.getValue(defaultValue: () => throw Exception), equals(42));
  });
}
