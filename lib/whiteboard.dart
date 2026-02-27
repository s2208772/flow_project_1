import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flow_project_1/models/project.dart';
import 'project_header.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_saver/file_saver.dart';

class Whiteboard extends StatefulWidget {
  const Whiteboard({super.key});

  @override
  State<Whiteboard> createState() => _WhiteboardState();
}

class _WhiteboardState extends State<Whiteboard> {
  final DrawingController _drawingController = DrawingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Important Notice',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                ),
              ),
                const SizedBox(height: 12),
              Text(
                'Please note, this whiteboard is a temporary space for quick sketches and brainstorming. It does not save your work, so be sure to capture or save anything important before leaving this page.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 83, 83, 83),
                      fontSize: 16,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK',
                  style: TextStyle(color: Color(0xFF5C5C99), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  Future<bool> onLeavingPage() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('This whiteboard is temporary and does not save your work, so be sure to save anything important locally before leaving this page. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C5C99),
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }
  void _addText() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your text...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Add text as a simple line annotation at center
                // (flutter_drawing_board doesn't have native text,
                //  so we overlay it via a stack)
                setState(() {
                  _textOverlays.add(_TextOverlay(
                    text: controller.text,
                    offset: const Offset(100, 100),
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: const Color(0xFF5C5C99),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  //Text overlays addition
  final List<_TextOverlay> _textOverlays = [];

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)?.settings.arguments as Project?;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await onLeavingPage();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: project != null
          ? ProjectHeader(project: project, onNavigateAway: onLeavingPage)
          : AppBar(title: const Text('Whiteboard')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Full-screen drawing board + text overlays
              Screenshot(
                controller: _screenshotController,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    children: [
                      DrawingBoard(
                        controller: _drawingController,
                        background: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        boardPanEnabled: false,
                        boardScaleEnabled: false,
                        showDefaultActions: true,
                        showDefaultTools: true,
                      ),

                      // Draggable text overlays
                      for (int i = 0; i < _textOverlays.length; i++)
                        Positioned(
                          left: _textOverlays[i].offset.dx,
                          top: _textOverlays[i].offset.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _textOverlays[i] = _TextOverlay(
                                  text: _textOverlays[i].text,
                                  offset: _textOverlays[i].offset + details.delta,
                                );
                              });
                            },
                            onDoubleTap: () {
                              // Remove text on double-tap
                              setState(() => _textOverlays.removeAt(i));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF5C5C99),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _textOverlays[i].text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Floating toolbar (top-right)
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    _buildFloatingButton(
                      icon: Icons.text_fields,
                      tooltip: 'Add Text',
                      onPressed: _addText,
                    ),
                    const SizedBox(height: 6),
                    _buildFloatingButton(
                      tooltip: 'Clear All',
                      icon: Icons.delete_outline,
                      onPressed: () {
                        _drawingController.clear();
                        setState(() => _textOverlays.clear());
                      },
                    ),
                    const SizedBox(height: 6),  
                    _buildFloatingButton(
                      tooltip: 'Save as Image',
                      icon: Icons.save_alt,
                      onPressed: () async {
                        try {
                          final Uint8List? image = await _screenshotController.capture();
                          if (image != null) {
                            await FileSaver.instance.saveFile(
                              name: 'whiteboard_${DateTime.now().millisecondsSinceEpoch}',
                              bytes: image,
                              fileExtension: 'png',
                              mimeType: MimeType.png,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Whiteboard saved as image!')),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(
        side: BorderSide(color: Color(0xFF5C5C99), width: 1.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: const Color(0xFF5C5C99), size: 22),
        ),
      ),
    );
  }
}

/// Simple data class for a draggable text overlay.
class _TextOverlay {
  final String text;
  final Offset offset;
  const _TextOverlay({required this.text, required this.offset});
}
