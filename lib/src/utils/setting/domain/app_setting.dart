import 'package:equatable/equatable.dart';

class AppSetting extends Equatable {
  final bool isDarkMode;
  const AppSetting({
    bool? isDarkMode,
  }) : isDarkMode = isDarkMode ?? false;

  AppSetting copyWith({
    bool? isDarkMode,
  }) {
    return AppSetting(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  String toString() => 'AppSetting(isDarkMode: $isDarkMode)';

  @override
  List<Object> get props => [isDarkMode];
}
