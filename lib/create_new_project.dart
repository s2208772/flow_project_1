import 'package:flutter/material.dart';
import 'header.dart';
import 'package:flow_project_1/models/project.dart';
import 'package:flow_project_1/services/project_store.dart';

class CreateNewProject extends StatefulWidget {
  @override
  State<CreateNewProject> createState() => _CreateNewProjectState();
}

class _CreateNewProjectState extends State<CreateNewProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  String? _projectType;
  String? _status;
  DateTime? _targetDate;

  final List<String> _projectTypes = [
    'Industry (Construction, Manufacturing)',
    'Purpose/Objective (Strategic, Operational, Compliance, Marketing)',
    'Funding (Public, Private, Mixed)',
    'Methodology (Agile, Waterfall, Software Projects)',
  ];

  final List<String> _statuses = [
    'New',
    'In progress',
    'On hold',
    'Complete',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final project = Project(
      name: _nameController.text.trim(),
      owner: _ownerController.text.trim(),
      type: _projectType,
      targetDate: _targetDate,
      status: _status ?? 'New',
    );
    await ProjectStore.instance.addProject(project);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project saved: ${project.name}')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Create New Project',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5C5C99), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Project Name'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter project name';
                            final valid = RegExp(r'^[a-zA-Z0-9 _-]+$').hasMatch(v);
                            if (!valid) return 'Only letters, numbers, spaces, - and _ allowed';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ownerController,
                          decoration: const InputDecoration(labelText: 'Owner (Email Address)'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter owner email';
                            final valid = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+").hasMatch(v);
                            if (!valid) return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _projectType,
                          items: _projectTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _projectType = v),
                          decoration: const InputDecoration(labelText: 'Project Type'),
                          validator: (v) => v == null ? 'Select a project type' : null,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Target Completion Date',
                                hintText: _targetDate == null ? 'Select date' : '${_targetDate!.toLocal()}'.split(' ')[0],
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              validator: (v) => _targetDate == null ? 'Choose a date' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _status = v),
                          decoration: const InputDecoration(labelText: 'Project Status'),
                          validator: (v) => v == null ? 'Select status' : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C5C99)),
                              child: const Text('Save', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}