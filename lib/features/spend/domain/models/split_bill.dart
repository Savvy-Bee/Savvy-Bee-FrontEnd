class SplitPerson {
  final String name;
  final String username;
  bool isIncluded;
  SplitStatus status;

  SplitPerson({
    required this.name,
    required this.username,
    this.isIncluded = false,
    this.status = SplitStatus.pending,
  });
}

enum SplitStatus { approved, pending }

class SavedAccount {
  final String type;
  final String name;
  final String bank;
  final String accountNumber;
  bool isSelected;

  SavedAccount({
    required this.type,
    required this.name,
    required this.bank,
    required this.accountNumber,
    this.isSelected = false,
  });
}
