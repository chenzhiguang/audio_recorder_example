import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _record = AudioRecorder();

  @override
  void dispose() {
    _record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('你讲话'),
      ),
      body: Center(
        child: StreamBuilder<RecordState>(
            stream: _record.onStateChanged(),
            builder: (context, state) {
              final isRecording = state.data == RecordState.record;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, size: 50),
                    onPressed: _startRecord,
                    color: isRecording ? Colors.red : null,
                  ),
                  const SizedBox(width: 50),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 50),
                    onPressed: isRecording ? _record.stop : null,
                  ),
                ],
              );
            }),
      ),
    );
  }

  Future<void> _startRecord() async {
    if (!await _record.hasPermission()) {
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = DateTime.now().toIso8601String();
    final filePath = '${tempDir.path}/$fileName.pcm';
    final file = File(filePath);
    final fileSink = file.openWrite();

    final stream = await _record.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
      ),
    );

    stream.listen(
      (event) {
        fileSink.add(event);
      },
      onDone: () {
        fileSink.close();
        print('Recording saved to: $filePath');
      },
    );
  }
}
