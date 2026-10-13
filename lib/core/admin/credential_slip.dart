class CredentialSlip {
  const CredentialSlip({
    this.profileId,
    required this.username,
    required this.fullName,
    required this.password,
  });

  final String? profileId;
  final String username;
  final String fullName;
  final String password;

  CredentialSlip copyWith({String? password}) {
    return CredentialSlip(
      profileId: profileId,
      username: username,
      fullName: fullName,
      password: password ?? this.password,
    );
  }
}

List<CredentialSlip> uniqueCredentialSlips(Iterable<CredentialSlip> slips) {
  final seen = <String>{};
  final unique = <CredentialSlip>[];
  for (final slip in slips) {
    final key = (slip.profileId ?? slip.username).trim().toLowerCase();
    if (key.isEmpty || !seen.add(key)) continue;
    unique.add(slip);
  }
  return unique;
}
