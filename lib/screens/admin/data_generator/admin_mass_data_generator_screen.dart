import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/components/cards/premium_card.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/core/theme/app_colors.dart';
import 'package:mu_study/models/enums.dart';
import 'package:mu_study/core/admin/credential_slips_source.dart';
import 'package:mu_study/providers/admin/admin_providers.dart';
import 'package:mu_study/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMassDataGeneratorScreen extends ConsumerStatefulWidget {
  const AdminMassDataGeneratorScreen({super.key});

  @override
  ConsumerState<AdminMassDataGeneratorScreen> createState() =>
      _AdminMassDataGeneratorScreenState();
}

class _AdminMassDataGeneratorScreenState
    extends ConsumerState<AdminMassDataGeneratorScreen> {
  final _teachersCtrl = TextEditingController();
  final _studentsCtrl = TextEditingController();
  final _groupsCtrl = TextEditingController();
  final _assignmentsCtrl = TextEditingController();

  bool _running = false;

  @override
  void dispose() {
    _teachersCtrl.dispose();
    _studentsCtrl.dispose();
    _groupsCtrl.dispose();
    _assignmentsCtrl.dispose();
    super.dispose();
  }

  static List<String> _splitLines(String raw) => raw
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  /// Format: `username|password|full_name|sphere` (sphere: math|english)
  List<Map<String, dynamic>> _parseTeachers() {
    final out = <Map<String, dynamic>>[];
    for (final line in _splitLines(_teachersCtrl.text)) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length != 4) {
        throw ArgumentError(
          'Teacher line must be: username|password|full_name|sphere. Bad: "$line"',
        );
      }

      final sphereRaw = parts[3].toLowerCase();
      final sphere = Sphere.values.firstWhere(
        (s) => s.name == sphereRaw,
        orElse: () => Sphere.math,
      );

      out.add({
        'username': parts[0],
        'password': parts[1],
        'full_name': parts[2],
        'sphere': sphere.name,
      });
    }
    return out;
  }

  /// Format: `username|password|full_name`
  List<Map<String, dynamic>> _parseStudents() {
    final out = <Map<String, dynamic>>[];
    for (final line in _splitLines(_studentsCtrl.text)) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length != 3) {
        throw ArgumentError(
          'Student line must be: username|password|full_name. Bad: "$line"',
        );
      }

      out.add({
        'username': parts[0],
        'password': parts[1],
        'full_name': parts[2],
      });
    }
    return out;
  }

  /// Format: `teacher_username|group_title`
  List<Map<String, dynamic>> _parseGroups() {
    final out = <Map<String, dynamic>>[];
    for (final line in _splitLines(_groupsCtrl.text)) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length != 2) {
        throw ArgumentError(
          'Group line must be: teacher_username|group_title. Bad: "$line"',
        );
      }
      out.add({
        'teacher_username': parts[0],
        'title': parts[1],
      });
    }
    return out;
  }

  /// Format: `teacher_username|group_title|student_username`
  List<Map<String, dynamic>> _parseAssignments() {
    final out = <Map<String, dynamic>>[];
    for (final line in _splitLines(_assignmentsCtrl.text)) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.length != 3) {
        throw ArgumentError(
          'Assignment line must be: teacher_username|group_title|student_username. Bad: "$line"',
        );
      }
      out.add({
        'teacher_username': parts[0],
        'group_title': parts[1],
        'student_username': parts[2],
      });
    }
    return out;
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      final teachers = _parseTeachers();
      final students = _parseStudents();
      final groups = _parseGroups();
      final assignments = _parseAssignments();

      await supabase.rpc(
        'admin_mass_generate_school_data',
        params: {
          'p_teachers': teachers,
          'p_students': students,
          'p_groups': groups,
          'p_assignments': assignments,
        },
      );
      await saveLoginPasswordsByUsername([...teachers, ...students]);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Generated successfully.',
          ),
        ),
      );

      ref.invalidate(adminPlatformStatsProvider);
      ref.invalidate(adminGroupsProvider);
      ref.invalidate(allProfilesProvider);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mass Data Generator'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          shellContentBottomPadding(context, extra: 24),
        ),
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paste data (use "|" delimiter).',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  '1) Teachers: username|password|full_name|sphere',
                  style: TextStyle(color: AppColors.inkAlpha(context, 0.55)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _teachersCtrl,
                  minLines: 6,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '@teacher1|password123|Teacher One|math',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2) Students: username|password|full_name',
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _studentsCtrl,
                  minLines: 6,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '@student1|password123|Student One',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '3) Groups: teacher_username|group_title',
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _groupsCtrl,
                  minLines: 4,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '@teacher1|English 7A',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '4) Assignments: teacher_username|group_title|student_username',
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _assignmentsCtrl,
                  minLines: 4,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '@teacher1|English 7A|@student1',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _running ? null : _run,
                    icon: _running
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high_rounded),
                    label: Text(_running ? 'Generating...' : 'Generate'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: usernames should match exactly the ones used in Teachers/Students.',
                  style: TextStyle(color: AppColors.inkAlpha(context, 0.55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

