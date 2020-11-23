import 'package:updated/updated.dart';

Future<int> requestValue() async {
  await Future.delayed(const Duration(seconds: 1));
  return 42;
}

Future<void> main() async {
  var value = Update<int>();

  // ---
  // Value : 32
  // Is Loading...
  // Details : Updating<int>(id: 28313824297, startedAt: 2020-11-23 16:57:04.298751, optimisticValue: 32)
  // ---
  // Value : 42
  // Is not loading : Updated<int>(id: 28313824297, updatedAt: 2020-11-23 16:57:05.315, previousUpdate: 42)
  // Details : Updated<int>(id: 28313824297, updatedAt: 2020-11-23 16:57:05.315, previousUpdate: 42)
  await for (var item in update(
    updater: requestValue,
    getUpdate: () => value,
    optimisticValue: 32,
  )) {
    print('---');
    value = item;
    item.mapValue(
      value: (value, isOptimistic) => print('Value : $value'),
      orElse: () => print('No value'),
    );
    item.mapLoading(
      loading: () => print('Is Loading...'),
      notLoading: () => print('Is not loading : $value'),
    );
    print('Details : $item');
  }

  // ---
  // Value : 32
  // Is Loading...
  // Details : Refreshing<int>(id: 28313797308, startedAt: 2020-11-23 16:56:38.327266, previousUpdate: Updated<int>(id: 28313797307, updatedAt: 2020-11-23 16:56:38.322668, previousUpdate: 42), optimisticValue: 32)
  // ---
  // Value : 42
  // Is not loading : Updated<int>(id: 28313797308, updatedAt: 2020-11-23 16:56:39.334887, previousUpdate: 42)
  // Details : Updated<int>(id: 28313797308, updatedAt: 2020-11-23 16:56:39.334887, previousUpdate: 42)
  await for (var item in update(
    updater: requestValue,
    getUpdate: () => value,
    optimisticValue: 32,
  )) {
    print('---');
    value = item;
    item.mapValue(
      value: (value, isOptimistic) => print('Value : $value'),
      orElse: () => print('No value'),
    );
    item.mapLoading(
      loading: () => print('Is Loading...'),
      notLoading: () => print('Is not loading : $value'),
    );
    print('Details : $item');
  }
}
