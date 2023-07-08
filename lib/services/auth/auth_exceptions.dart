//Login exception handling
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

//Register exception handling
class EmailAlreadyInUseAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//Generic exception handling
class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}
