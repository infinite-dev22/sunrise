class UserProfile {
  int id;
  String userId;
  String name;
  String email;
  String bio;
  String phoneNumber;
  String profilePicture;

  UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.bio,
    required this.phoneNumber,
    required this.profilePicture,
  });

  factory UserProfile.fromDoc(Map doc) {
    return UserProfile(
      id: doc['id'],
      userId: doc['user_id'],
      name: doc['name'],
      email: doc['email'],
      bio: doc['bio'],
      phoneNumber: doc['phone_number'],
      profilePicture: doc['profile_picture'],
    );
  }
}

class Wallet {
  int? id;
  int userId;
  int balance;

  Wallet({
    this.id,
    required this.userId,
    required this.balance,
  });

  factory Wallet.fromDoc(Map doc) {
    return Wallet(
      id: doc['id'],
      userId: doc['user_id'],
      balance: doc['balance'],
    );
  }

  static toDoc(Wallet wallet) {
    return {
      'id': wallet.id,
      'user_id': wallet.userId,
      'balance': wallet.balance,
    };
  }
}

class Transaction {
  int id;
  int amount;
  String walletId;
  String type;
  String reason;
  String method;

  Transaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.reason,
    required this.method,
  });

  factory Transaction.fromDoc(Map doc) {
    return Transaction(
      id: doc['id'],
      walletId: doc['wallet_id'],
      amount: doc['amount'],
      type: doc['type'],
      reason: doc['reason'],
      method: doc['method'],
    );
  }

  static toDoc(Transaction transaction) {
    return {
      'id': transaction.id,
      'wallet_id': transaction.walletId,
      'amount': transaction.amount,
      'type': transaction.type,
      'reason': transaction.reason,
      'method': transaction.method,
    };
  }
}
