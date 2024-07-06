import 'package:flutter/material.dart';

class Node{
  String value;

  Node? left;
  Node? right;

  Node({required this.value});
}

class Deque{
  int _capacity = 0;
  Node? _left;
  Node? _right;

  Deque();

  void addLeft(String element){
    Node newNode = Node(value: element);
    newNode.right = _left;
    _left?.left = newNode;
    _left = newNode;
    _right ??= newNode;
    _capacity += 1;
  }

  void addRight(String element){
    Node newNode = Node(value: element);
    newNode.left = _right;
    _right?.right = newNode;
    _right = newNode;
    _left ??= newNode;
    _capacity += 1;
  }

  void popLeft(){
    if(isEmpty()) { return; }
    _left = _left!.right;
    _left?.left = null;
    _right = _left == null ? null : _right;
    _capacity -= 1;
  }

  void popRight(){
    if(isEmpty()) { return; }
    _right = _right!.left;
    _right?.right = null;
    _left = _right == null ? null : _left;
    _capacity -= 1;
  }

  String? getLeft() => _left?.value;
  String? getRight() => _right?.value;

  int getCapacity() => _capacity;
  bool isEmpty() => _capacity < 1;

  void popAll(){
    while(isEmpty() != true){
      popRight();
    }
  }

  @override
  String toString() {
    List<String> arr = [];

    Node? cur = _left;
    while(cur != null){
      arr.add(cur.value);
      cur = cur.right;
    }

    String str = arr.map<String>((String e) => e).join("");
    return str;
  }
}