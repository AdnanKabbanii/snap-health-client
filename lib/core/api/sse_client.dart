import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_client.dart';

class SseEvent {
  final String event;
  final Map<String, dynamic> data;

  SseEvent({required this.event, required this.data});
}

Stream<SseEvent> streamScan(Uint8List imageBytes, String filename, {String? barcode}) async* {
  try {
    final map = <String, dynamic>{
      'image': MultipartFile.fromBytes(imageBytes, filename: filename),
    };
    if (barcode != null) map['barcode'] = barcode;
    final formData = FormData.fromMap(map);

    final response = await apiClient.post<ResponseBody>(
      '/scan',
      data: formData,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final stream = response.data!.stream;
    String buffer = '';
    String currentEvent = '';
    String currentData = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      final lines = buffer.split('\n');
      buffer = lines.last;

      for (int i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();

        if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          currentData = line.substring(5).trim();
        } else if (line.isEmpty && currentEvent.isNotEmpty) {
          try {
            final data = jsonDecode(currentData) as Map<String, dynamic>;
            yield SseEvent(event: currentEvent, data: data);
          } catch (e) {
            yield SseEvent(event: 'error', data: {'message': 'Stream parse error'});
          }
          currentEvent = '';
          currentData = '';
        }
      }
    }
  } catch (e) {
    yield SseEvent(event: 'error', data: {'message': 'Connection error'});
  }
}
