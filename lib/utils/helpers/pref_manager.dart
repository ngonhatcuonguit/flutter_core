import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ActiveTheme {
  light(ThemeMode.light),
  dark(ThemeMode.dark),
  system(ThemeMode.system);

  final ThemeMode mode;

  const ActiveTheme(this.mode);
}

class PrefManager {
  String kIsLogin = "isLogin";
  String kCanReciveJob = "canReciveJob";
  String kToken = "api_key";
  String kUserId = "userId";
  String kProvinceId = "province_id";
  String kVersionAPI = "versionAPI";

  String kText = "text";
  String kColor = "color";
  String kIcon = "icon";
  String kUser = "user";
  String kFCM = "fcm";
  String kLanguage = "language";
  String kLocale = "locale";
  String kTheme = "theme";
  String kDeviceId = "device_id";
  String kOsName = "os";
  String kOsVersion = "os_version";
  String kApp = "app";
  String kAppVersion = "app_version";
  String kModel = "model";
  String kBrand = "brand";
  String kIsDark = "isDark";
  String kStatusFontSize = "statusFontSize";
  String kOnline = "statusOnline";
  String kViewMoney = "viewMoney";

  /// Light, Dark ,System

  SharedPreferences preferences;

  PrefManager(this.preferences);

  //for Bloc.Bloc.login
  set isLogin(bool value) => preferences.setBool(kIsLogin, value);

  bool get isLogin => preferences.getBool(kIsLogin) ?? false;

  set isOnline(bool value) => preferences.setBool(kOnline, value);

  bool get isOnline => preferences.getBool(kOnline) ?? false;

  set canReciveJob(bool value) => preferences.setBool(kCanReciveJob, value);

  bool get canReciveJob => preferences.getBool(kCanReciveJob) ?? true;

  set viewMoney(bool value) => preferences.setBool(kViewMoney, value);

  bool get viewMoney => preferences.getBool(kViewMoney) ?? true;

  set statusFontSize(bool value) => preferences.setBool(kStatusFontSize, value);

  bool get statusFontSize => preferences.getBool(kStatusFontSize) ?? false;

  set isDark(bool value) => preferences.setBool(kIsDark, value);

  bool get isDark => preferences.getBool(kIsDark) ?? false;

  //for Bloc.Bloc.login
  set provinceId(String value) => preferences.setString(kProvinceId, value);

  String get provinceId => preferences.getString(kProvinceId) ?? "1";

  set versionAPI(String value) => preferences.setString(kVersionAPI, value);

  String get versionAPI => preferences.getString(kVersionAPI) ?? "1";

  set token(String? value) => preferences.setString(kToken, value ?? "");

  String? get token => preferences.getString(kToken);
  // String? get token => "";

  set fcmToken(String? value) => preferences.setString(kFCM, value ?? "");

  String? get fcmToken => preferences.getString(kFCM);

  set user(String? value) => preferences.setString(kUser, value ?? "");

  String? get user => preferences.getString(kUser);

  set userId(String? value) => preferences.setString(kUserId, value ?? "");

  String? get userId => preferences.getString(kUserId);

  set text(String? value) => preferences.setString(kText, value ?? "");

  String get text => preferences.getString(kText) ?? "";

  set color(String? value) => preferences.setString(kColor, value ?? "");

  String? get color => preferences.getString(kColor);

  set icon(String? value) => preferences.setString(kIcon, value ?? "");

  String? get icon => preferences.getString(kIcon);
  //////////set DeviceInfo /////
  ///
  set deviceId(String? value) => preferences.setString(kDeviceId, value ?? "");

  String get deviceId => preferences.getString(kDeviceId) ?? "";

  set osName(String? value) => preferences.setString(kOsName, value ?? "");

  String get osName => preferences.getString(kOsName) ?? "";

  set osVersion(String? value) =>
      preferences.setString(kOsVersion, value ?? "");

  String get osVersion => preferences.getString(kOsVersion) ?? "";

  set app(String? value) => preferences.setString(kApp, value ?? "");

  String get app => preferences.getString(kApp) ?? "";

  set appVersion(String? value) =>
      preferences.setString(kAppVersion, value ?? "");

  String get appVersion => preferences.getString(kAppVersion) ?? "";

  set model(String? value) => preferences.setString(kModel, value ?? "");

  String get model => preferences.getString(kModel) ?? "";

  set brand(String? value) => preferences.setString(kBrand, value ?? "");

  String get brand => preferences.getString(kBrand) ?? "";

  /// Default locale set to English
  set locale(String? value) => preferences.setString(kLocale, value ?? "en");

  String get locale => preferences.getString(kLocale) ?? "en";

  /// Default locale set to English
  set theme(String? value) =>
      preferences.setString(kTheme, value ?? ActiveTheme.system.name);

  String get theme => preferences.getString(kTheme) ?? ActiveTheme.system.name;

  void logout() => preferences.clear();
}
