import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/models/task.dart';
import 'package:flow_project_1/services/task_store.dart';
import 'package:flow_project_1/services/project_store.dart';
import 'project_header.dart';

class Dependencies extends StatefulWidget {
  final Project? project;
  const Dependencies({super.key, this.project});

  @override
  State<Dependencies> createState() => _DependenciesState();
}

class _DependenciesState extends State<Dependencies> {
  List<Task> tasks = [];
  Project? _project;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final project = widget.project ?? ModalRoute.of(context)?.settings.arguments as Project?;
    if (project != null) {
      // Fetch fresh project data from Firestore to get updated members list
      final freshProject = await ProjectStore.instance.getProject(project.name);
      final loadedTasks = await TaskStore.instance.getTasksByProject(project.name);
      setState(() {
        _project = freshProject;
        tasks = loadedTasks;
      });
    }
  }

  void _addTask() {
    final taskNameController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedOwner = _project?.owner;
    DateTime? startDate;
    DateTime? finishDate;
    DateTime? actualStartDate;
    DateTime? actualFinishDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      startDate = date;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Estimated Start Date',
                        hintText: startDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(startDate!),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      finishDate = date;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Estimated Finish Date',
                        hintText: finishDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(finishDate!),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: StatefulBuilder(
                  builder: (context, setDialogState) => DropdownButtonFormField<String>(
                    value: selectedOwner,
                    items: _project?.allTeamMembers.map((member) => DropdownMenuItem(
                      value: member,
                      child: Text(member == _project?.owner ? '$member (Project Manager)' : member),
                    )).toList() ?? [],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedOwner = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Task Owner',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Actual Dates (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C5C99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      actualStartDate = date;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Actual Start Date',
                        hintText: actualStartDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(actualStartDate!),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      actualFinishDate = date;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Actual Finish Date',
                        hintText: actualFinishDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(actualFinishDate!),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskNameController.text.isNotEmpty &&
                  startDate != null &&
                  finishDate != null) {
                final newTask = Task(
                  id: (tasks.length + 1).toString(),
                  name: taskNameController.text,
                  startDate: startDate!,
                  finishDate: finishDate!,
                  notes: notesController.text,
                  taskOwner: selectedOwner ?? '',
                  projectId: _project?.name ?? '',
                  actualStartDate: actualStartDate,
                  actualFinishDate: actualFinishDate,
                );
                setState(() {
                  tasks.add(newTask);
                });
                // Save to Firestore
                TaskStore.instance.addTask(newTask);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C5C99),
            ),
            child: const Text(
              'Add Task',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _editTask(Task task) {
    final taskNameController = TextEditingController(text: task.name);
    final notesController = TextEditingController(text: task.notes);
    String? selectedOwner = task.taskOwner;
    DateTime? startDate = task.startDate;
    DateTime? finishDate = task.finishDate;
    DateTime? actualStartDate = task.actualStartDate;
    DateTime? actualFinishDate = task.actualFinishDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: taskNameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() {
                          startDate = date;
                        });
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Estimated Start Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  startDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(startDate!),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, color: Color(0xFF5C5C99)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: finishDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() {
                          finishDate = date;
                        });
                      }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 50),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Estimated Finish Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  finishDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(finishDate!),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, color: Color(0xFF5C5C99)),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  minLines: 2,
                  expands: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedOwner,
                  items: _project?.allTeamMembers.map((member) => DropdownMenuItem(
                    value: member,
                    child: Text(member == _project?.owner ? '$member (Project Manager)' : member),
                  )).toList() ?? [],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedOwner = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Task Owner',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Actual Dates (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C5C99))),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: actualStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() {
                        actualStartDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Actual Start Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                actualStartDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(actualStartDate!),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, color: Color(0xFF5C5C99)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: actualFinishDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() {
                        actualFinishDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Actual Finish Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                actualFinishDate == null ? 'Select date' : DateFormat('dd MMM yyyy').format(actualFinishDate!),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, color: Color(0xFF5C5C99)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  id: task.id,
                  name: taskNameController.text,
                  startDate: startDate!,
                  finishDate: finishDate!,
                  notes: notesController.text,
                  taskOwner: selectedOwner ?? '',
                  projectId: task.projectId,
                  actualStartDate: actualStartDate,
                  actualFinishDate: actualFinishDate,
                );
                setState(() {
                  final index = tasks.indexWhere((t) => t.id == task.id);
                  if (index != -1) {
                    tasks[index] = updatedTask;
                  }
                });
                TaskStore.instance.updateTask(updatedTask);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C5C99)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      );
  }

  void _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete task "${task.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        tasks.removeWhere((t) => t.id == task.id);
      });
      TaskStore.instance.deleteTask(task.id, task.projectId, taskName: task.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = _project ?? widget.project ?? ModalRoute.of(context)?.settings.arguments as Project?;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0EA),
      appBar: project != null
          ? ProjectHeader(project: project)
          : AppBar(title: const Text('Dependencies')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dependencies',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF5C5C99),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                //Code adapted from (GeeksforGeeks, 2022)
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for task by name or ID',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF5C5C99)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                        ),
                        //End of adapted code
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _addTask(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add new task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C5C99),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
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
                child: tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks for this project. Add one using the + button.',
                          style: TextStyle(
                            color: Color(0xFF5C5C99),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        thickness: 10,
                        child: Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: true,
                          thickness: 10,
                          notificationPredicate: (notification) => notification.depth == 1,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 1600,
                                child: DataTable(
                            showCheckboxColumn: false,
                            columns: const [
                              DataColumn(label: Text('Task ID')),
                              DataColumn(label: Text('Task Name')),
                              DataColumn(label: Text('Estimated Start')),
                              DataColumn(label: Text('Estimated Finish')),
                              DataColumn(label: Text('Actual Start')),
                              DataColumn(label: Text('Actual Finish')),
                              DataColumn(label: Text('Notes')),
                              DataColumn(label: Text('Task Owner')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: tasks
                                .where((task) => _searchQuery.isEmpty ||
                                    task.name.toLowerCase().contains(_searchQuery) ||
                                    task.id.toLowerCase().contains(_searchQuery))
                                .map((task) => DataRow(
                                      onSelectChanged: (_) => _editTask(task),
                                      cells: [
                                        DataCell(SizedBox(width: 50, child: Text(task.id))),
                                        DataCell(GestureDetector(
                                          onTap: () => _editTask(task),
                                          child: Tooltip(
                                            message: task.name,
                                            child: SizedBox(
                                              width: 120,
                                              child: Text(task.name, style: const TextStyle(decoration: TextDecoration.underline, color: Color(0xFF5C5C99)), overflow: TextOverflow.ellipsis),
                                            ),
                                          ),
                                        )),
                                        DataCell(GestureDetector(
                                          onTap: () => _editTask(task),
                                          child: SizedBox(width: 115, child: Text(DateFormat('dd MMM yyyy').format(task.startDate))),
                                        )),
                                        DataCell(GestureDetector(
                                          onTap: () => _editTask(task),
                                          child: SizedBox(width: 115, child: Text(DateFormat('dd MMM yyyy').format(task.finishDate))),
                                        )),
                                        DataCell(GestureDetector(
                                          onTap: () => _editTask(task),
                                          child: SizedBox(width: 115, child: Text(task.actualStartDate != null ? DateFormat('dd MMM yyyy').format(task.actualStartDate!) : '-')),
                                        )),
                                        DataCell(GestureDetector(
                                          onTap: () => _editTask(task),
                                          child: SizedBox(width: 115, child: Text(task.actualFinishDate != null ? DateFormat('dd MMM yyyy').format(task.actualFinishDate!) : '-')),
                                        )),
                                        DataCell(GestureDetector(
                                          onTap: () => _editTask(task),
                                          child: Tooltip(
                                            message: task.notes,
                                            child: SizedBox(
                                              width: 150,
                                              child: Text(
                                                task.notes,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        )),
                                        DataCell(Tooltip(
                                          message: task.taskOwner,
                                          child: SizedBox(width: 150, child: Text(task.taskOwner, overflow: TextOverflow.ellipsis)),
                                        )),
                                        DataCell(
                                          SizedBox(
                                            width: 80,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Color(0xFF5C5C99), size: 18),
                                                  onPressed: () => _editTask(task),
                                                  tooltip: 'Edit',
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                                  onPressed: () => _deleteTask(task),
                                                  tooltip: 'Delete',
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                            ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//References
//GeeksforGeeks. (2022, April 24). Flutter Search Bar. GeeksforGeeks. https://www.geeksforgeeks.org/flutter/flutter-search-bar/