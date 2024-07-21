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

void fn(Error e) {
  switch (e) {
    case UserNotFoundError(:String username):
      print(username);
    case ParseIntError(message: final msg):
      print(msg);
  }
  print(e);
}

void main() {
  fn(UserNotFoundError('Pino'));
}
// A function which 