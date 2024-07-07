import 'package:equatable/equatable.dart';

enum SortingOption { manual, alphaAsc, alphaDesc, duedateAsc, duedateDesc }

class AppSetting extends Equatable {
  final bool isDarkMode;
  final SortingOption sortingOption;

  const AppSetting({
    bool? isDarkMode,
    SortingOption? sortingOption,
  })  : isDarkMode = isDarkMode ?? false,
        sortingOption = sortingOption ?? SortingOption.manual;

  AppSetting copyWith({
    bool? isDarkMode,
    SortingOption? sortingOption,
  }) {
    return AppSetting(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      sortingOption: sortingOption ?? this.sortingOption,
    );
  }

  @override
  String toString() =>
      'AppSetting(isDarkMode: $isDarkMode, sortingOption: $sortingOption)';

  @override
  List<Object?> get props => [isDarkMode, sortingOption];
}
