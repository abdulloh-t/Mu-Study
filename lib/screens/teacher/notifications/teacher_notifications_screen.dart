import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mu_study/screens/student/notifications/student_notifications_screen.dart';

class TeacherNotificationsScreen extends ConsumerWidget {
  const TeacherNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const StudentNotificationsScreen();
  }
}
