// 2.1 Thread-per-request

import 'dart:isolate';

// hadle and indiv inc task on its own dedicated worker
void handleRequest(String req) {
  print('Processing $req on a separate thread');
}

void main(List<String> args) {
  final requests = ['task 1', 'task 2', 'task 3'];
  for (final req in requests) {
    Isolate.spawn(handleRequest, req);
  }
}
