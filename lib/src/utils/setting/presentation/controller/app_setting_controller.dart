import 'package:minimal_todo_app/src/utils/setting/data/app_setting_repository.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_setting_controller.g.dart';

@Riverpod(keepAlive: true)
class AppSettingController extends _$AppSettingController {
  late final AppSettingRepository _appSettingRepo;

  @override
  FutureOr<AppSetting> build() async {
    _appSettingRepo = await ref.watch(appSettingRepositoryProvider.future);
    return await loadSettings();
  }

  Future<AppSetting> loadSettings() async {
    return await _appSettingRepo.loadSettings();
  }

  Future<void> updateDarkMode(
    bool value,
  ) async {
    state = AsyncValue.data(state.value!.copyWith(isDarkMode: value));
    await _appSettingRepo.saveData(AppSettingHelper.isDarkMode, value);
  }
}
