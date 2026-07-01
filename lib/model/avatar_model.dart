class AvatarData {
  static const List<String> maleAvatars = [
    'assets/images/male1.jpg',
    'assets/images/male2.jpg',
    'assets/images/male3.jpg',
    'assets/images/male4.jpg',
    'assets/images/male5.jpg',
    'assets/images/male6.jpg',
  ];

  static const List<String> femaleAvatars = [
    'assets/images/female1.jpg',
    'assets/images/female2.jpg',
    'assets/images/female3.jpg',
    'assets/images/female4.jpg',
    'assets/images/female5.jpg',
    'assets/images/female6.jpg',
  ];

  static List<String> avatarsForGender(String? gender) {
    return gender?.toLowerCase() == 'female' ? femaleAvatars : maleAvatars;
  }

  static const String defaultMale = 'assets/images/male1.jpg';
  static const String defaultFemale = 'assets/images/female1.jpg';
}