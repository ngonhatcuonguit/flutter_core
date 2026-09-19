class FestivalSession {
  final String accessToken;
  final String? username;
  final String? displayName;

  const FestivalSession({
    required this.accessToken,
    this.username,
    this.displayName,
  });

  factory FestivalSession.fromJson(
    Map<String, dynamic> json, {
    String? fallbackUsername,
  }) {
    final data = _asStringMap(_read(json, 'Data'));
    final user = _asStringMap(_read(json, 'User')) ??
        (data == null ? null : _asStringMap(_read(data, 'User')));
    final source = data ?? json;
    final token = _stringFrom(
      source,
      const [
        'AccessToken',
        'access_token',
        'Token',
        'ApiToken',
        'ApiKey',
      ],
    );

    if (token == null || token.isEmpty) {
      throw const FormatException(
        'Festival login response does not contain an access token.',
      );
    }

    return FestivalSession(
      accessToken: token,
      username: (user == null
              ? null
              : _stringFrom(user, const ['Username', 'UserName'])) ??
          _stringFrom(source, const ['Username', 'UserName']) ??
          fallbackUsername,
      displayName: (user == null
              ? null
              : _stringFrom(
                  user,
                  const ['FullName', 'DisplayName', 'Name'],
                )) ??
          _stringFrom(
            source,
            const ['FullName', 'DisplayName', 'Name'],
          ),
    );
  }
}

class FestivalGate {
  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  const FestivalGate({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.isActive = true,
  });

  factory FestivalGate.fromJson(Map<String, dynamic> json) {
    return FestivalGate(
      id: _intValue(_read(json, 'Id')) ?? 0,
      name: _stringValue(_read(json, 'GateName')) ?? '',
      code: _stringValue(_read(json, 'GateCode')) ?? '',
      description: _stringValue(_read(json, 'Description')),
      isActive: (_intValue(_read(json, 'Status')) ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'GateName': name,
        'GateCode': code,
        'Description': description,
        'Status': isActive ? 1 : 0,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestivalGate &&
          other.id == id &&
          other.name == name &&
          other.code == code;

  @override
  int get hashCode => Object.hash(id, name, code);
}

class FestivalCheckInResult {
  final bool success;
  final bool alreadyCheckedIn;
  final String? fullName;
  final String? company;
  final int? vipLevel;
  final String? guestCode;
  final String message;
  final String? previousCheckInTime;
  final String? previousGate;
  final String? position;
  final String? vipName;
  final String? checkInTime;
  final String? gateName;

  const FestivalCheckInResult({
    required this.success,
    required this.alreadyCheckedIn,
    required this.message,
    this.fullName,
    this.company,
    this.vipLevel,
    this.guestCode,
    this.previousCheckInTime,
    this.previousGate,
    this.position,
    this.vipName,
    this.checkInTime,
    this.gateName,
  });

  factory FestivalCheckInResult.fromJson(Map<String, dynamic> json) {
    final guest = _asStringMap(_read(json, 'Guest'));
    final source = guest ?? json;
    return FestivalCheckInResult(
      success: _boolFrom(_read(json, 'Success')),
      alreadyCheckedIn: _boolFrom(_read(json, 'AlreadyCheckedIn')),
      fullName: _stringValue(_read(source, 'FullName')),
      company: _stringValue(_read(source, 'Company')),
      position: _stringValue(_read(source, 'Position')),
      vipLevel: _intValue(_read(source, 'VIP')),
      vipName: _stringValue(_read(source, 'VIPName')),
      guestCode: _stringValue(_read(source, 'GuestCode')),
      message: _stringValue(_read(json, 'Message')) ?? '',
      previousCheckInTime: _stringValue(_read(json, 'PreviousCheckInTime')),
      previousGate: _stringValue(_read(json, 'PreviousGate')),
      checkInTime: _stringValue(_read(json, 'CheckInTime')),
      gateName: _stringValue(_read(json, 'GateName')),
    );
  }
}

class FestivalGiftCheckInResult {
  final bool success;
  final bool alreadyReceived;
  final String? fullName;
  final String? company;
  final int? vipLevel;
  final String? guestCode;
  final String message;
  final String? position;
  final String? vipName;
  final String? giftReceivedDate;
  final String? giftGateName;

  const FestivalGiftCheckInResult({
    required this.success,
    required this.alreadyReceived,
    required this.message,
    this.fullName,
    this.company,
    this.vipLevel,
    this.guestCode,
    this.position,
    this.vipName,
    this.giftReceivedDate,
    this.giftGateName,
  });

  factory FestivalGiftCheckInResult.fromJson(Map<String, dynamic> json) {
    final guest = _asStringMap(_read(json, 'Guest'));
    final source = guest ?? json;
    return FestivalGiftCheckInResult(
      success: _boolFrom(_read(json, 'Success')),
      alreadyReceived: _boolFrom(_read(json, 'AlreadyReceived')),
      fullName: _stringValue(_read(source, 'FullName')),
      company: _stringValue(_read(source, 'Company')),
      position: _stringValue(_read(source, 'Position')),
      vipLevel: _intValue(_read(source, 'VIP')),
      vipName: _stringValue(_read(source, 'VIPName')),
      guestCode: _stringValue(_read(source, 'GuestCode')),
      message: _stringValue(_read(json, 'Message')) ?? '',
      giftReceivedDate: _stringValue(_read(source, 'GiftReceivedDate')) ??
          _stringValue(_read(json, 'GiftReceivedDate')) ??
          _stringValue(_read(json, 'PreviousGiftReceivedDate')),
      giftGateName: _stringValue(_read(source, 'GiftGateName')) ??
          _stringValue(_read(json, 'GiftGateName')) ??
          _stringValue(_read(json, 'PreviousGiftGateName')),
    );
  }
}

Object? readFestivalJsonValue(Map<String, dynamic> json, String key) =>
    _read(json, key);

Object? _read(Map<String, dynamic> json, String key) {
  if (json.containsKey(key)) return json[key];
  final normalizedKey = key.toLowerCase();
  for (final entry in json.entries) {
    if (entry.key.toLowerCase() == normalizedKey) return entry.value;
  }
  return null;
}

Map<String, dynamic>? _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _stringFrom(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _stringValue(_read(json, key));
    if (value != null) return value;
  }
  return null;
}

String? _stringValue(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool _boolFrom(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'success';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
