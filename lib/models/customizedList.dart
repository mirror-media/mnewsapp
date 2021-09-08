import 'dart:collection';

class CustomizedList<E> extends ListBase<E> {
  List innerList = List.empty(growable: true);

  int get length => innerList.length;

  set length(int length) {
    innerList.length = length;
  }

  void operator []=(int index, E value) {
    innerList[index] = value;
  }

  E operator [](int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(E value) => innerList.add(value);

  void addAll(Iterable<E> all) => innerList.addAll(all);
}
