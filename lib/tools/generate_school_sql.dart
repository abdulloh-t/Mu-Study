import 'dart:io';
import 'dart:math';

final teachers = <Map<String, String>>[
  {
    'first_name': 'James',
    'last_name': 'English',
    'username': '@james',
    'sphere': 'english',
  },
  {
    'first_name': 'Malika',
    'last_name': 'Math',
    'username': '@malika',
    'sphere': 'math',
  },
];

final students = <Map<String, String>>[
  {'first_name': 'John', 'last_name': 'Jones', 'username': '@john_jones'},
  {'first_name': 'Someone', 'last_name': 'Someone', 'username': '@someone'},
  {'first_name': 'Amina', 'last_name': 'Karimova', 'username': '@amina01'},
];

final groups = <Map<String, String>>[
  {'teacher_username': '@james', 'title': 'English Group C'},
  {'teacher_username': '@malika', 'title': 'Math Group A'},
];

final assignments = <Map<String, String>>[
  {
    'teacher_username': '@james',
    'group_title': 'English Group C',
    'student_username': '@john_jones',
  },
  {
    'teacher_username': '@james',
    'group_title': 'English Group C',
    'student_username': '@someone',
  },
  {
    'teacher_username': '@malika',
    'group_title': 'Math Group A',
    'student_username': '@amina01',
  },
];

final usedPasswords = <String>{};
final rng = Random.secure();

String sqlEscape(String value) => value.replaceAll("'", "''");

String sqlString(String value) => "'${sqlEscape(value)}'";

String generatePassword() {
  const alphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_';
  String next() =>
      List.generate(20, (_) => alphabet[rng.nextInt(alphabet.length)]).join();

  var password = next();
  while (usedPasswords.contains(password)) {
    password = next();
  }
  usedPasswords.add(password);
  return password;
}

String normalizeUsername(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('username is required');
  }
  return trimmed.startsWith('@') ? trimmed : '@$trimmed';
}

String authEmail(String username) {
  final local = username.replaceAll('@', '').toLowerCase().trim();
  return '$local@mustudy.internal';
}

String fullName(Map<String, String> user) {
  final first = (user['first_name'] ?? '').trim();
  final last = (user['last_name'] ?? '').trim();
  return '$first $last'.trim();
}

final printedCredentials = <String>[];

void printCreateUser({
  required Map<String, String> user,
  required String role,
  String? sphere,
}) {
  final username = normalizeUsername(user['username'] ?? '');
  final name = fullName(user);
  final password = generatePassword();
  final email = authEmail(username);
  final sphereSql = sphere == null ? 'NULL' : sqlString(sphere);
  printedCredentials.add(
    '$username|$password|$name|$role',
  );

  stdout.writeln(
    '-- $username / $password  ($role${sphere == null ? '' : ', $sphere'})',
  );
  stdout.writeln('''
DO \$\$
DECLARE
  v_user_id UUID := gen_random_uuid();
  v_email TEXT := ${sqlString(email)};
  v_username TEXT := ${sqlString(username)};
  v_full_name TEXT := ${sqlString(name)};
  v_password TEXT := ${sqlString(password)};
  v_role public.user_role := ${sqlString(role)}::public.user_role;
  v_sphere public.sphere_type := ${sphere == null ? 'NULL' : "$sphereSql::public.sphere_type"};
  v_teacher_id UUID;
BEGIN
  IF EXISTS (SELECT 1 FROM public.profiles WHERE username = v_username) THEN
    RAISE NOTICE 'skip existing user %', v_username;
    RETURN;
  END IF;

  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change,
    is_sso_user, is_anonymous
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    NOW(),
    jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
    jsonb_build_object('username', v_username, 'full_name', v_full_name, 'role', v_role::text),
    NOW(), NOW(), '', '', '', '', false, false
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(),
    v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
    'email',
    v_email,
    NOW(), NOW(), NOW()
  );

  INSERT INTO public.profiles (id, username, full_name, role, auth_email)
  VALUES (v_user_id, v_username, v_full_name, v_role, v_email);

  INSERT INTO public.login_credentials (profile_id, password, updated_at)
  VALUES (v_user_id, v_password, NOW())
  ON CONFLICT (profile_id) DO UPDATE
    SET password = excluded.password,
        updated_at = NOW();

  IF v_role = 'teacher' THEN
    INSERT INTO public.teachers (profile_id, sphere)
    VALUES (v_user_id, v_sphere)
    RETURNING id INTO v_teacher_id;
  ELSIF v_role = 'student' THEN
    INSERT INTO public.students (profile_id) VALUES (v_user_id);
  END IF;
END
\$\$;
''');
}

void main() {
  stdout.writeln('-- Generated by lib/tools/generate_school_sql.dart');
  stdout.writeln('-- Copy everything below into Supabase SQL Editor and run.');
  stdout.writeln(
    '-- Login passwords are in the comments above each user block.',
  );
  stdout.writeln();
  stdout.writeln('BEGIN;');
  stdout.writeln();
  stdout.writeln('''
CREATE TABLE IF NOT EXISTS public.login_credentials (
  profile_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  password text NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);
''');

  stdout.writeln('-- =========================');
  stdout.writeln('-- Teachers');
  stdout.writeln('-- =========================');
  for (final teacher in teachers) {
    printCreateUser(
      user: teacher,
      role: 'teacher',
      sphere: (teacher['sphere'] ?? 'math').toLowerCase(),
    );
  }

  stdout.writeln('-- =========================');
  stdout.writeln('-- Students');
  stdout.writeln('-- =========================');
  for (final student in students) {
    printCreateUser(user: student, role: 'student');
  }

  stdout.writeln('-- =========================');
  stdout.writeln('-- Groups');
  stdout.writeln('-- =========================');
  for (final group in groups) {
    final teacherUsername = normalizeUsername(group['teacher_username'] ?? '');
    final title = (group['title'] ?? '').trim();
    stdout.writeln('''
INSERT INTO public.groups (teacher_id, title)
SELECT t.id, ${sqlString(title)}
FROM public.teachers t
JOIN public.profiles p ON p.id = t.profile_id
WHERE p.username = ${sqlString(teacherUsername)}
  AND NOT EXISTS (
    SELECT 1 FROM public.groups g
    WHERE g.teacher_id = t.id AND g.title = ${sqlString(title)}
  );
''');
  }

  stdout.writeln('-- =========================');
  stdout.writeln('-- Assign students to groups');
  stdout.writeln('-- =========================');
  for (final assignment in assignments) {
    final teacherUsername = normalizeUsername(
      assignment['teacher_username'] ?? '',
    );
    final groupTitle = (assignment['group_title'] ?? '').trim();
    final studentUsername = normalizeUsername(
      assignment['student_username'] ?? '',
    );
    stdout.writeln('''
INSERT INTO public.group_students (group_id, student_id)
SELECT g.id, s.id
FROM public.groups g
JOIN public.teachers t ON t.id = g.teacher_id
JOIN public.profiles tp ON tp.id = t.profile_id
JOIN public.students s ON TRUE
JOIN public.profiles sp ON sp.id = s.profile_id
WHERE tp.username = ${sqlString(teacherUsername)}
  AND g.title = ${sqlString(groupTitle)}
  AND sp.username = ${sqlString(studentUsername)}
ON CONFLICT (group_id, student_id) DO NOTHING;
''');
  }

  stdout.writeln('COMMIT;');
  stdout.writeln();
  stdout.writeln('-- =========================');
  stdout.writeln('-- =========================');
  for (final line in printedCredentials) {
    stdout.writeln('$line');
  }
}
