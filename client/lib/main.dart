import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:web_socket_channel/io.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

final providerOfMessages = StreamProvider.autoDispose<String>((ref) async* {
  // Open the connection
  final channel = IOWebSocketChannel.connect('ws://10.0.2.2:8080');

  // Close the connection when the stream is destroyed
  ref.onDispose(() => channel.sink.close());

  channel.sink.add('send_something');

  // Parse the value received and emit a Message instance
  await for (final value in channel.stream) {
    yield value.toString();
  }
});

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(providerOfMessages);

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: messages.when(
              data: (data) {
                print(data);

                return Text(
                  data,
                  style: const TextStyle(fontSize: 30),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text(
                  'Probably server not running, run "yarn start" under the server folder!'),
            ),
          ),
        ),
      ),
    );
  }
}
