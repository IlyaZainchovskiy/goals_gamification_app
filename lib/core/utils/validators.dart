class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть електронну адресу';
    }
    
    bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
    
    if (!emailValid) {
      return 'Введіть коректну електронну адресу';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }
    
    if (value.length < 6) {
      return 'Пароль має бути не менше 6 символів';
    }
    
    return null;
  }
}