sealed class Error {}

class UserNotFoundError extends Error {
  final String _username;
  UserNotFoundError(this._username);

  String get username => _username;
  @override
  String toString() {
    return 'UserNotFoundError($_username)';
  }
}

class ParseIntError extends Error {
  final String _message;
  ParseIntError(this._message);
  String get message => _message;

  @override
  String toString() {
    return 'ParsintError($_message)';
  }
}

void printError(Error e) {
  switch (e) {
    case UserNotFoundError(:String username):
      print('User not found: $username');
    case ParseIntError(message: final msg):
      print('Parse error: $msg');
  }
  print('Error object: $e');
}

void main() {
  final error1 = UserNotFoundError('Pino');
  final error2 = ParseIntError('Invalid integer format');
  printError(error1);
  printError(error2);
}
