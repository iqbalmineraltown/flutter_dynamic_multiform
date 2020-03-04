/// Based on https://github.com/frideosapps/frideos_flutter/blob/master/lib/src/core/src/

import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class IDisposable {
  void dispose();
}

class StreamedValue<T> implements IDisposable {
  StreamedValue({
    this.initialData,
    this.onError,
  }) {
    streamController = BehaviorSubject<T>()
      ..stream.listen((e) {
        _lastValue = e;
        if (_onChange != null) {
          _onChange(e);
        }
      }, onError: onError ?? (e) {});

    if (initialData != null) {
      _lastValue = initialData;
      streamController.sink.add(_lastValue);
    }
  }

  /// Stream of type [BehaviorSubject] in order to emit
  /// the last event to every new listener.
  BehaviorSubject<T> streamController;

  /// Callback to handle the errors
  final Function(dynamic e) onError;

  /// Stream getter
  Stream<T> get stream => streamController.stream;

  /// Sink for the stream
  StreamSink<T> get sink => streamController.sink;

  /// Last value emitted by the stream
  T _lastValue;

  /// The initial event of the stream
  T initialData;

  /// This function will be called every time the stream updates.
  Function(T data) _onChange;

  StreamTransformer<T, T> streamTransformer;

  /// Getter for the last value emitted by the stream
  T get value => _lastValue;

  /// To send to stream a new event
  set value(T value) {
    _lastValue = value;
    sink.add(value);
  }

  /// To set a function that will be called every time the stream updates.
  void onChange(Function(T data) onDataChanged) => _onChange = onDataChanged;

  /// Method to refresh the stream (e.g to use when the type it is not
  /// a basic type, and a property of an object has changed).
  void refresh() {
    sink.add(value);
  }

  @override
  void dispose() {
    streamController.close();
  }
}

class StreamedList<T> implements IDisposable {
  StreamedList({List<T> initialData, this.onError}) {
    streamController = StreamedValue<List<T>>()
      ..streamController.listen((data) {
        if (_onChange != null) {
          _onChange(data);
        }
      }, onError: onError ?? (e) {});

    if (initialData != null) {
      streamController.value = initialData;
    }
  }

  StreamedValue<List<T>> streamController;

  /// Callback to handle the errors
  final Function(dynamic e) onError;

  /// Sink for the stream
  StreamSink<List<T>> get sink => streamController.sink;

  /// Stream getter
  Stream<List<T>> get stream => streamController.stream;

  /// The initial event of the stream
  List<T> initialData;

  /// Last value emitted by the stream
  List<T> lastValue;

  List<T> get value => streamController.value;

  int get length => streamController.value.length;

  /// This function will be called every time the stream updates.
  void Function(List<T> data) _onChange;

  /// Set the new value and update the stream
  set value(List<T> list) {
    streamController.value = list;
  }

  /// To set a function that will be called every time the stream updates.
  void onChange(Function(List<T>) onDataChanged) {
    _onChange = onDataChanged;
  }

  /// Used to add an item to the list and update the stream.
  void addElement(T element) {
    streamController.value.add(element);
    refresh();
  }

  /// Used to add a List of item to the list and update the stream.
  ///
  void addAll(Iterable<T> elements) {
    streamController.value.addAll(elements);
    refresh();
  }

  /// Used to remove an item from the list and update the stream.
  bool removeElement(T element) {
    final result = value.remove(element);
    refresh();
    return result;
  }

  /// Used to remove an item from the list and update the stream.
  T removeAt(int index) {
    final removed = value.removeAt(index);
    refresh();
    return removed;
  }

  /// To replace an element at a given index
  void replaceAt(int index, T element) {
    streamController.value[index] = element;
    refresh();
  }

  /// To replace an element
  void replace(T oldElement, T newElement) {
    final index = streamController.value.indexOf(oldElement);
    replaceAt(index, newElement);
  }

  /// Used to clear the list and update the stream.
  void clear() {
    value.clear();
    refresh();
  }

  /// To refresh the stream when the list is modified without using the
  /// methods of this class.
  void refresh() {
    sink.add(value);
  }

  /// Dispose the stream.
  @override
  void dispose() {
    if (T is IDisposable) {
      for (var item in value) {
        (item as IDisposable).dispose();
      }
    }
    streamController.dispose();
  }
}
