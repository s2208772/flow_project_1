// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/models/task.dart';
import 'package:flow_project_1/services/task_store.dart';
import 'project_header.dart';

class GanttChart extends StatefulWidget {
  const GanttChart({super.key});

  @override
  State<GanttChart> createState() => _GanttChartState();
}

class _GanttChartState extends State<GanttChart> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  Project? _project;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _project = ModalRoute.of(context)?.settings.arguments as Project?;
    if (_project != null && _isLoading) {
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await TaskStore.instance.getTasksByProject(_project!.name);
      tasks.sort((a, b) => a.startDate.compareTo(b.startDate));
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: _project != null
          ? ProjectHeader(project: _project!)
          : AppBar(title: const Text('Gantt Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gantt Chart',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF5C5C99),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Each grid box represents a day. The light bar shows planned duration, while the dark bar shows actual progress.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap on a task to view in the schedule.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 12,
                  ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C5C99).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks found for this project',
                              style: TextStyle(
                                color: Color(0xFF5C5C99),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : _buildGanttChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGanttChart() {
    final today = DateTime.now();
    final allStarts = _tasks.expand((t) => [t.startDate, if (t.actualStartDate != null) t.actualStartDate!]).toList();
    final allFinishes = _tasks.expand((t) => [t.finishDate, if (t.actualFinishDate != null) t.actualFinishDate!]).toList();
    final minDate = allStarts.reduce((a, b) => a.isBefore(b) ? a : b).subtract(const Duration(days: 7));
    final maxDateFromTasks = allFinishes.reduce((a, b) => a.isAfter(b) ? a : b);
    final maxDate = (maxDateFromTasks.isAfter(today) ? maxDateFromTasks : today).add(const Duration(days: 7));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GanttChartWidget(
            tasks: _tasks,
            width: constraints.maxWidth,
            height: max(constraints.maxHeight, _tasks.length * 50.0),
            startDate: minDate,
            endDate: maxDate,
            barColor: const Color(0xFF5C5C99),
            lineColor: Colors.grey.shade300,
            fontSize: 12,
            onTaskTap: (task) {
              // Link back to table
              Navigator.pushNamed(
                context,
                '/dependencies',
                arguments: _project,
              );
            },
          );
        },
      ),
    );
  }
}

/// Code adapted from (explodus, 2023)
class GanttChartWidget extends StatelessWidget {
  final List<Task> tasks;
  final double width;
  final double height;
  final DateTime startDate;
  final DateTime endDate;
  final Color barColor;
  final Color lineColor;
  final double fontSize;
  final void Function(Task task)? onTaskTap;

  const GanttChartWidget({
    super.key,
    required this.tasks,
    required this.width,
    required this.height,
    required this.startDate,
    required this.endDate,
    this.barColor = const Color(0xFF5C5C99),
    this.lineColor = const Color(0xFFE0E0E0),
    this.fontSize = 12,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 30;
    const double rowHeight = 40;

    return SingleChildScrollView(
      child: SizedBox(
        width: width,
        height: height,
        child: GestureDetector(
          onTapUp: (details) {
            final tapY = details.localPosition.dy;
            if (tapY > headerHeight) {
              final taskIndex = ((tapY - headerHeight) / rowHeight).floor();
              if (taskIndex >= 0 && taskIndex < tasks.length && onTaskTap != null) {
                onTaskTap!(tasks[taskIndex]);
              }
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: CustomPaint(
              painter: GanttPainter(
                tasks: tasks,
                startDate: startDate,
                endDate: endDate,
                barColor: barColor,
                lineColor: lineColor,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GanttPainter extends CustomPainter {
  final List<Task> tasks;
  final DateTime startDate;
  final DateTime endDate;
  final Color barColor;
  final Color lineColor;
  final double fontSize;
  
  late final Paint taskPaint;
  late final Paint actualPaint;
  late final Paint linePaint;
  late final Paint gridPaint;

  GanttPainter({
    required this.tasks,
    required this.startDate,
    required this.endDate,
    required this.barColor,
    required this.lineColor,
    required this.fontSize,
  }) {
    taskPaint = Paint()
      ..color = barColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    actualPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    
    linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    gridPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
  }

  void _drawTodayLine(Canvas canvas, Size size, double labelWidth, double headerHeight, double dayWidth) {
    final today = DateTime.now();
    if (today.isAfter(startDate.subtract(const Duration(days: 1))) && 
        today.isBefore(endDate.add(const Duration(days: 1)))) {
      final todayOffset = today.difference(startDate).inDays;
      final todayX = labelWidth + (todayOffset * dayWidth);
      
      final todayPaint = Paint()
        ..color = const Color.fromARGB(255, 0, 0, 0)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(todayX, headerHeight),
        Offset(todayX, size.height),
        todayPaint,
      );
      
      final textSpan = TextSpan(
        text: 'Current Day: ${DateTime.now().toLocal().toString().split(' ')[0]}',
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          fontSize: fontSize - 2,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(todayX - textPainter.width / 2, headerHeight - 12));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (tasks.isEmpty) return;

    const double labelWidth = 200;
    const double headerHeight = 30;
    const double rowHeight = 40;
    const double barPadding = 8;
    
    final chartWidth = size.width - labelWidth;
    final totalDays = endDate.difference(startDate).inDays + 1;
    final dayWidth = chartWidth / totalDays;

    _drawHeader(canvas, size, labelWidth, headerHeight, dayWidth, totalDays);
    _drawGrid(canvas, size, labelWidth, headerHeight, dayWidth, totalDays, rowHeight);

    // Draw label
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final y = headerHeight + (i * rowHeight);
      _drawTaskLabel(canvas, '${task.id} - ${task.name}', 0, y, labelWidth, rowHeight);
    }

    //then draw bars
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(labelWidth, 0, size.width - labelWidth, size.height));
    
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final y = headerHeight + (i * rowHeight);
      
      final startOffset = task.startDate.difference(startDate).inDays;
      final duration = task.finishDate.difference(task.startDate).inDays + 1;
      final barX = labelWidth + (startOffset * dayWidth);
      final barY = y + barPadding;
      final barWidth = duration * dayWidth;
      final barHeight = rowHeight - (barPadding * 2);
      
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(barRect, taskPaint);
      
      // Progress Bar
      if (task.actualStartDate != null) {
        final actualEnd = task.actualFinishDate ?? DateTime.now();
        final actualStartOffset = task.actualStartDate!.difference(startDate).inDays;
        final actualDuration = actualEnd.difference(task.actualStartDate!).inDays + 1;
        final actualX = labelWidth + (actualStartOffset * dayWidth);
        final actualWidth = actualDuration * dayWidth;
        
        final actualRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(actualX, barY + barHeight / 4, actualWidth, barHeight / 2),
          const Radius.circular(2),
        );
        canvas.drawRRect(actualRect, actualPaint);

        //ACTUAL duration
        _drawBarText(canvas, '${actualDuration}d', actualX, barY + barHeight / 4, actualWidth, barHeight / 2);
      }
      //Duration
      _drawBarText(canvas, '${duration}d', barX, barY, barWidth, barHeight);
    

    //Start for each task as dd/mm
    final taskStartLabel = '${task.startDate.day.toString().padLeft(1,'0')}/${task.startDate.month.toString().padLeft(2,'0')}';
    _drawText(canvas, taskStartLabel, barX - 30, barY + (barHeight - fontSize) / 2, fontSize - 2, FontWeight.normal, const Color.fromARGB(255, 0, 0, 0));
    
    //Finish date for each task as dd/mm
    final taskFinishLabel = '${task.finishDate.day.toString().padLeft(1,'0')}/${task.finishDate.month.toString().padLeft(2,'0')}';
    _drawText(canvas, taskFinishLabel, barX + barWidth + 4, barY + (barHeight - fontSize) / 2, fontSize - 2, FontWeight.normal, const Color.fromARGB(255, 0, 0, 0));
    }

    // Draw today's date line
    _drawTodayLine(canvas, size, labelWidth, headerHeight, dayWidth);
    canvas.restore();
  }

  void _drawHeader(Canvas canvas, Size size, double labelWidth, double headerHeight, 
      double dayWidth, int totalDays) {

    //Task ID label
    _drawText(canvas, 'ID', 8 , headerHeight / 2 - 6, fontSize, FontWeight.bold, const Color(0xFF5C5C99));

    // Task label
    _drawText(canvas, 'Task', 40, headerHeight / 2 - 6, fontSize, FontWeight.bold, const Color(0xFF5C5C99));
    
    // Date labels in dd/mm/yyyy format
    final startText = '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final endText = '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    
    _drawText(canvas, startText, labelWidth + 4, headerHeight / 2 - 6, fontSize - 2, FontWeight.normal, const Color.fromARGB(255, 0, 0, 0));
    _drawText(canvas, endText, size.width - 70, headerHeight / 2 - 6, fontSize - 2, FontWeight.normal, const Color.fromARGB(255, 0, 0, 0));
    
    //Header line
    canvas.drawLine(
      Offset(0, headerHeight),
      Offset(size.width, headerHeight),
      linePaint,
    );
  }

  void _drawGrid(Canvas canvas, Size size, double labelWidth, double headerHeight, 
      double dayWidth, int totalDays, double rowHeight) {
    // Grid lines
    for (int i = 0; i <= totalDays; i += 1) {
      final x = labelWidth + (i * dayWidth);
      canvas.drawLine(
        Offset(x, headerHeight),
        Offset(x, size.height),
        gridPaint,
      );
    }
    for (int i = 0; i <= tasks.length; i++) {
      final y = headerHeight + (i * rowHeight);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  void _drawTaskLabel(Canvas canvas, String text, double x, double y, double width, double height) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: fontSize,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: width - 16);
    textPainter.paint(canvas, Offset(x + 8, y + (height - textPainter.height) / 2));
  }

  void _drawBarText(Canvas canvas, String text, double x, double y, double width, double height) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize - 2,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    if (textPainter.width < width - 2) {
      textPainter.paint(
        canvas, 
        Offset(x + (width - textPainter.width) / 2, y + (height - textPainter.height) / 2),
      );
    }
  }

  void _drawText(Canvas canvas, String text, double x, double y, double size, 
      FontWeight weight, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
//End of adapted code

// References:
//explodus. (2023, February 3). How to write a simple GanttChartWidget for Flutter. Medium. https://medium.com/@ts.explodus/how-to-write-a-simple-ganttchartwidget-for-flutter-121ab483fae8