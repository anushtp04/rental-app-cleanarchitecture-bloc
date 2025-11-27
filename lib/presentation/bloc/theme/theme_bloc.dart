import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/utils/hive_helper.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(_getTheme()) {
    on<ToggleTheme>(_onToggleTheme);
  }


  static ThemeState _getTheme() {
    final box = HiveHelper.themeBox;
    final isDark = box.get('isDark', defaultValue: false) as bool;
    return ThemeLoaded(isDark: isDark);
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final box = HiveHelper.themeBox;
    final currentIsDark = state is ThemeLoaded ? (state as ThemeLoaded).isDark : false;
    final newIsDark = !currentIsDark;
    box.put('isDark', newIsDark);
    emit(ThemeLoaded(isDark: newIsDark));
  }
}

