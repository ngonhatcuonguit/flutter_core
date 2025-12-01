import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class LocaleCubit extends HydratedCubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  void changeLocale(String languageCode) {
    emit(Locale(languageCode));
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      emit(const Locale('vi'));
    } else {
      emit(const Locale('en'));
    }
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final String? languageCode = json['languageCode'] as String?;
    return languageCode != null ? Locale(languageCode) : const Locale('en');
  }

  @override
  Map<String, dynamic>? toJson(Locale state) {
    return {'languageCode': state.languageCode};
  }
}
