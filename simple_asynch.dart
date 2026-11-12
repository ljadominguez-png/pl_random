//sample of a asynchronous code

import 'dart:async';

Future<void> logTask(String name, int steps) async {
  for (int start = 0; start < steps; start++) {
    print('$name : step $start');

    await Future.delayed(const Duration(milliseconds: 100));
  }
}

void main(List<String> args) async {
  // tasks interleave concurrently on a single thread without multiple os threads
  await Future.wait([logTask('step 1', 4), logTask('step 2', 8)]);
  //if done na
  print('all is complete');
}

/**
 * output: 
 * 
step 1 : step 0
step 2 : step 0
step 1 : step 1
step 2 : step 1
step 1 : step 2
step 2 : step 2
step 1 : step 3
step 2 : step 3
step 2 : step 4
step 2 : step 5
step 2 : step 6
step 2 : step 7
all is complete

notice that it is preempted
 */
