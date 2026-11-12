import 'dart:async';

Future<void> fetchUserdata() async {
  print('Fetching User Data');
  await Future.delayed(const Duration(milliseconds: 100));
  print('User Data Loaded');
}

Future<void> fetchConfig() async {
  print('Fetching config');
  await Future.delayed(const Duration(milliseconds: 10));
  print('config loaded');
}

void main(List<String> args) async {
  // tasks will be preempted
  await Future.wait([fetchConfig(), fetchUserdata()]);
}
