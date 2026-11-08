import 'dart:async';
import 'dart:isolate';

// -------------------------------------------------------------
// 1. SIMPLE PERSISTENT DATA STRUCTURE (HELLO WORLD LEVEL)
// -------------------------------------------------------------
// A persistent list keeps old versions intact by creating a new
// head node that points back to the previous list (structural sharing).

class SimpleNode {
  final int value;
  final SimpleNode? next;

  SimpleNode(this.value, [this.next]);
}

void demoPersistentDataStructure() {
  print('--- 1. Persistent Data Structure ---');

  // Version 1 contains only the number 1.
  final v1 = SimpleNode(1);

  // Version 2 prepends 2, pointing to Version 1.
  // v1 is unchanged.
  final v2 = SimpleNode(2, v1);

  // Version 3 branches from v1 with 3.
  // Both v2 and v3 share node 1 in memory.
  final v3 = SimpleNode(3, v1);

  print('v1 head: ${v1.value}'); // 1
  print('v2 head: ${v2.value}, next: ${v2.next?.value}'); // 2 -> 1
  print('v3 head: ${v3.value}, next: ${v3.next?.value}'); // 3 -> 1
}

// -------------------------------------------------------------
// 2. SIMPLE MONADIC SAFETY (HELLO WORLD LEVEL)
// -------------------------------------------------------------
// A Result type safely wraps either a value or an error, avoiding
// uncaught exceptions and null crashes.

class SafeVal {
  final int? value;
  final String? error;

  SafeVal.ok(this.value) : error = null;
  SafeVal.err(this.error) : value = null;

  bool get isOk => error == null;

  // Transforms the internal value only if there is no error.
  SafeVal map(int Function(int v) transform) {
    if (!isOk) return this;
    return SafeVal.ok(transform(value!));
  }
}

// Safe function returning a SafeVal instead of throwing an exception.
SafeVal safeDivide(int a, int b) {
  if (b == 0) return SafeVal.err('Division by zero');
  return SafeVal.ok(a ~/ b);
}

void demoMonadicSafety() {
  print('\n--- 2. Monadic Safety ---');

  // Successful calculation: 10 / 2 = 5, then + 3 = 8
  final success = safeDivide(10, 2).map((v) => v + 3);
  print('Success result: ${success.value}'); // 8

  // Failing calculation: 10 / 0 short-circuits, map is skipped safely
  final failure = safeDivide(10, 0).map((v) => v + 3);
  print('Failure result: ${failure.error}'); // Division by zero
}

// -------------------------------------------------------------
// ASYNCHRONOUS SESSION: 7. CONCURRENCY & PARALLELISM MODELS
// -------------------------------------------------------------

// -------------------------------------------------------------
// 7.1 SHARED-STATE: THREADS, MUTEXES, & DATA RACES
// -------------------------------------------------------------
// Shared-state concurrency allows multiple execution flows to read
// and write the same memory address. Without synchronization (like
// a Mutex/Lock), operations can interleave and create data races.
//
// Note: Dart isolates do not share memory by default. This class
// models how a Mutex prevents race conditions in shared-memory environments.

class SimpleMutex {
  Completer<void>? _lock;

  // Wait until the current lock is released, then acquire it.
  Future<void> acquire() async {
    while (_lock != null) {
      await _lock!.future;
    }
    _lock = Completer<void>();
  }

  // Release the lock to let the next operation proceed.
  void release() {
    final current = _lock;
    _lock = null;
    current?.complete();
  }
}

class SharedCounter {
  int count = 0;
  final SimpleMutex mutex = SimpleMutex();

  // Without the mutex, interleaved asynchronous reads/writes can cause data loss.
  Future<void> incrementSafely() async {
    await mutex.acquire();
    try {
      final current = count;
      // Simulating a delay where a race condition would normally happen.
      await Future.delayed(Duration(milliseconds: 10));
      count = current + 1;
    } finally {
      mutex.release();
    }
  }
}

Future<void> demoSharedState() async {
  print('\n--- 7.1 Shared-State & Mutex ---');
  final counter = SharedCounter();

  // Run two concurrent increments safely protected by the mutex.
  await Future.wait([
    counter.incrementSafely(),
    counter.incrementSafely(),
  ]);

  print('Counter after 2 safe increments: ${counter.count}'); // 2
}

// -------------------------------------------------------------
// 7.2 CHANNEL-BASED CONCURRENCY (CSP / GO STYLE)
// -------------------------------------------------------------
// "Do not communicate by sharing memory; instead, share memory by communicating."
// Communicating Sequential Processes (CSP) uses channels/streams to pass messages.

void demoChannelBased() async {
  print('\n--- 7.2 Channel-Based Concurrency ---');

  // StreamController acts as a basic channel for sending and receiving data.
  final channel = StreamController<String>();

  // Consumer: Listens on the channel asynchronously.
  channel.stream.listen((message) {
    print('Channel received: $message');
  });

  // Producer: Sends messages over the channel.
  channel.sink.add('Hello from Channel!');
  channel.sink.add('Second CSP message');

  // Allow events to flush before closing.
  await Future.delayed(Duration(milliseconds: 20));
  await channel.close();
}

// -------------------------------------------------------------
// 7.3 ACTOR MODEL & SHARED-NOTHING ARCHITECTURE
// -------------------------------------------------------------
// Each actor owns its private state and memory completely (shared-nothing).
// Actors communicate strictly by sending immutable messages.
// Dart's `Isolate` is a real-world implementation of the Actor model.

// Background worker function running in an isolated memory space.
void actorWorker(SendPort mainSendPort) {
  final workerReceivePort = ReceivePort();

  // Send the worker's own port back to main so main can message it.
  mainSendPort.send(workerReceivePort.sendPort);

  // Process incoming messages sequentially from its inbox.
  workerReceivePort.listen((message) {
    if (message is String) {
      final reply = 'Actor processed: $message';
      mainSendPort.send(reply);
    }
  });
}

Future<void> demoActorModel() async {
  print('\n--- 7.3 Actor Model (Dart Isolate) ---');

  final mainReceivePort = ReceivePort();

  // Spawn an actor in a completely separate thread with no shared memory.
  final isolate = await Isolate.spawn(actorWorker, mainReceivePort.sendPort);

  // Convert the stream to a broadcast stream to allow multiple readers.
  final stream = mainReceivePort.asBroadcastStream();

  // Wait to receive the worker's private SendPort.
  final workerSendPort = await stream.first as SendPort;

  // Send an isolated message to the actor.
  workerSendPort.send('Ping from Main');

  // Await the actor's response.
  final response = await stream.first;
  print('$response');

  // Clean up resources.
  mainReceivePort.close();
  isolate.kill();
}

// -------------------------------------------------------------
// MAIN ENTRY POINT
// -------------------------------------------------------------
void main() async {
  demoPersistentDataStructure();
  demoMonadicSafety();
  await demoSharedState();
  demoChannelBased();
  await demoActorModel();
}