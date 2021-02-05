import 'dart:collection';

abstract class CustomizedList<E> extends ListBase<E> {
  List<E> l = [];
  set length(int newLength) {
    l.length = newLength;
  }

  int get length => l.length;
  E operator [](int index) => l[index];
  void operator []=(int index, E value) {
    l[index] = value;
  }
}
