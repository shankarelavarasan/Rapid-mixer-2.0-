import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

void main() {
  runApp(const RapidMixerApp());
}

class RapidMixerApp extends StatelessWidget {
  const RapidMixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapid Mixer 2.0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isProcessing = false;
  List<Map<String, dynamic>> _separatedFiles = [];
  String _statusMessage = '';
  
  // API Configuration
  static const String _flaskApiUrl = 'https://rapid-mixer-backend.onrender.com';
  static const String _nodeApiUrl = 'https://rapid-mixer-node-api.onrender.com';
  
  // Fallback URLs for development
  static const String _localFlaskUrl = 'http://localhost:5000';
  static const String _localNodeUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    try {
      final response = await http.get(Uri.parse('$_nodeApiUrl/health'));
      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = 'API Connected Successfully';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'API Connection Failed: Using Local Mode';
      });
    }
  }

  Future<void> _pickAndProcessFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _isProcessing = true;
          _statusMessage = 'Processing audio file...';
        });

        await _processAudioFile(file);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _processAudioFile(PlatformFile file) async {
    try {
      // Try primary API first, then fallback
      String apiUrl = _flaskApiUrl;
      bool success = false;
      
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('$apiUrl/split-audio'),
          );

          // Add CORS headers
          request.headers.addAll({
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
          });

          request.files.add(
            http.MultipartFile.fromBytes(
              'audio',
              file.bytes!,
              filename: file.name,
            ),
          );

          setState(() {
            _statusMessage = attempt == 0 ? 'Connecting to primary server...' : 'Trying backup server...';
          });

          final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
              _separatedFiles = List<Map<String, dynamic>>.from(data['files'] ?? []);
              _statusMessage = 'Audio separation completed successfully!';
              _isProcessing = false;
            });
            success = true;
            break;
          } else {
            throw Exception('Server error: ${response.statusCode}');
          }
        } catch (e) {
          if (attempt == 0) {
            // Try local development server as fallback
            apiUrl = _localFlaskUrl;
            setState(() {
              _statusMessage = 'Primary server unavailable, trying local server...';
            });
            continue;
          }
          rethrow;
        }
      }
      
      if (!success) {
        throw Exception('All servers unavailable');
      }
      
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please check your internet connection and try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Processing failed: $e';
      }
      
      setState(() {
        _isProcessing = false;
        _statusMessage = errorMessage;
      });
    }
  }

  void _downloadFile(String url, String filename) {
    (web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..click());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapid Mixer 2.0'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.audiotrack,
                        size: 64,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AI-Powered Audio Separation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload an audio file to separate vocals, drums, bass, and other instruments',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Status Message
              if (_statusMessage.isNotEmpty)
                Card(
                  color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                      ? Colors.red[50]
                      : Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                            ? Colors.red[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Upload Button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickAndProcessFile,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isProcessing ? 'Processing...' : 'Select Audio File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Results
              if (_separatedFiles.isNotEmpty)
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Separated Audio Files',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _separatedFiles.length,
                              itemBuilder: (context, index) {
                                final file = _separatedFiles[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.music_note,
                                      color: Colors.blue[800],
                                    ),
                                    title: Text(file['name'] ?? 'Unknown'),
                                    subtitle: Text(
                                      'Size: ${(file['size'] / 1024 / 1024).toStringAsFixed(2)} MB',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () => _downloadFile(
                                        '$_flaskApiUrl${file['url']}',
                                        '${file['name']}.wav',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}