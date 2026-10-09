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
  final String? tableName;
  final String? tableSeat;
  final int? guestId;
  final int? tableId;
  final int? numberInvited;

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
    this.tableName,
    this.tableSeat,
    this.guestId,
    this.tableId,
    this.numberInvited,
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
      tableName: _stringValue(_read(source, 'TableName')) ??
          _stringValue(_read(json, 'TableName')),
      tableSeat: _stringValue(_read(source, 'TableSeat')) ??
          _stringValue(_read(json, 'TableSeat')),
      guestId: _intValue(_read(source, 'Id')),
      tableId: _intValue(_read(source, 'TableId')) ??
          _intValue(_read(json, 'TableId')),
      numberInvited: _intValue(_read(source, 'NumberInvited')),
    );
  }
}

class FestivalPrefixColor {
  final String prefixCode;
  final String? bgColor;
  final String? textColor;
  final String? note;

  const FestivalPrefixColor({
    required this.prefixCode,
    this.bgColor,
    this.textColor,
    this.note,
  });

  factory FestivalPrefixColor.fromJson(Map<String, dynamic> json) =>
      FestivalPrefixColor(
        prefixCode: _stringValue(_read(json, 'PrefixCode')) ?? '',
        bgColor: _stringValue(_read(json, 'BgColor')),
        textColor: _stringValue(_read(json, 'TextColor')),
        note: _stringValue(_read(json, 'Note')),
      );
}

class FestivalAssignedTable {
  final int tableId;
  final String tableName;
  final String? zone;
  final int seatCount;
  final String? seatsDescription;

  const FestivalAssignedTable({
    required this.tableId,
    required this.tableName,
    this.zone,
    required this.seatCount,
    this.seatsDescription,
  });

  factory FestivalAssignedTable.fromJson(Map<String, dynamic> json) =>
      FestivalAssignedTable(
        tableId: _intValue(_read(json, 'TableId')) ?? 0,
        tableName: _stringValue(_read(json, 'TableName')) ?? '',
        zone: _stringValue(_read(json, 'Zone')),
        seatCount: _intValue(_read(json, 'SeatCount')) ?? 0,
        seatsDescription: _stringValue(_read(json, 'SeatsDescription')),
      );
}

class FestivalHotlineGuest {
  final int id;
  final String guestCode;
  final String fullName;
  final int numberInvited;
  final int totalAssignedSeats;
  final int remainingNeededSeats;
  final FestivalPrefixColor? prefixColor;
  final List<FestivalAssignedTable> assignedTables;

  const FestivalHotlineGuest({
    required this.id,
    required this.guestCode,
    required this.fullName,
    required this.numberInvited,
    required this.totalAssignedSeats,
    required this.remainingNeededSeats,
    this.prefixColor,
    this.assignedTables = const [],
  });

  factory FestivalHotlineGuest.fromJson(Map<String, dynamic> json) {
    final guest = _asStringMap(_read(json, 'Guest')) ?? json;
    final prefix = _asStringMap(_read(json, 'PrefixColor')) ??
        _asStringMap(_read(guest, 'PrefixColor'));
    final tables =
        _read(json, 'AssignedTables') ?? _read(guest, 'AssignedTables');
    final invited = _intValue(_read(guest, 'NumberInvited')) ??
        _intValue(_read(json, 'NeededSeats')) ??
        1;
    final assigned = _intValue(_read(json, 'TotalAssignedSeats')) ??
        _intValue(_read(guest, 'TotalAssignedSeats')) ??
        0;
    return FestivalHotlineGuest(
      id: _intValue(_read(guest, 'Id')) ?? 0,
      guestCode: _stringValue(_read(guest, 'GuestCode')) ?? '',
      fullName: _stringValue(_read(guest, 'FullName')) ?? '',
      numberInvited: invited,
      totalAssignedSeats: assigned,
      remainingNeededSeats: _intValue(_read(json, 'RemainingNeededSeats')) ??
          _intValue(_read(guest, 'RemainingNeededSeats')) ??
          (invited - assigned).clamp(0, invited),
      prefixColor: prefix != null
          ? FestivalPrefixColor.fromJson(prefix)
          : _read(guest, 'BgColor') != null
              ? FestivalPrefixColor.fromJson(guest)
              : null,
      assignedTables: tables is List
          ? tables
              .whereType<Map>()
              .map((item) => FestivalAssignedTable.fromJson(
                  Map<String, dynamic>.from(item)))
              .where((table) => table.tableId > 0)
              .toList(growable: false)
          : const [],
    );
  }
}

class FestivalSeatingTable {
  final int id;
  final String name;
  final String zone;
  final int capacity;
  final int occupiedSeats;
  final int availableSeats;
  final bool isFull;

  const FestivalSeatingTable({
    required this.id,
    required this.name,
    required this.zone,
    required this.capacity,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.isFull,
  });

  factory FestivalSeatingTable.fromJson(Map<String, dynamic> json) {
    final capacity = _intValue(_read(json, 'Capacity')) ?? 0;
    final occupied = _intValue(_read(json, 'OccupiedSeats')) ?? 0;
    final available = _intValue(_read(json, 'AvailableSeats')) ??
        (capacity - occupied).clamp(0, capacity);
    return FestivalSeatingTable(
      id: _intValue(_read(json, 'TableId')) ??
          _intValue(_read(json, 'Id')) ??
          0,
      name: _stringValue(_read(json, 'TableName')) ?? '',
      zone: _stringValue(_read(json, 'Zone')) ?? '',
      capacity: capacity,
      occupiedSeats: occupied,
      availableSeats: available,
      isFull: _boolFrom(_read(json, 'IsFull')) || available <= 0,
    );
  }
}

class FestivalSeatingZone {
  final String name;
  final String? color;
  final List<FestivalSeatingTable> tables;

  const FestivalSeatingZone({
    required this.name,
    this.color,
    required this.tables,
  });

  int get availableSeats =>
      tables.fold(0, (sum, table) => sum + table.availableSeats);

  factory FestivalSeatingZone.fromJson(Map<String, dynamic> json) {
    final rawTables = _read(json, 'Tables');
    return FestivalSeatingZone(
      name: _stringValue(_read(json, 'ZoneName')) ??
          _stringValue(_read(json, 'Name')) ??
          '',
      color: _stringValue(_read(json, 'Color')),
      tables: rawTables is List
          ? rawTables
              .whereType<Map>()
              .map((item) => FestivalSeatingTable.fromJson(
                  Map<String, dynamic>.from(item)))
              .where((table) => table.id > 0)
              .toList(growable: false)
          : const [],
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
  final String? tableName;
  final String? tableSeat;
  final int? giftStatus;
  final String? giftNote;

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
    this.tableName,
    this.tableSeat,
    this.giftStatus,
    this.giftNote,
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
      tableName: _stringValue(_read(source, 'TableName')) ??
          _stringValue(_read(json, 'TableName')),
      tableSeat: _stringValue(_read(source, 'TableSeat')) ??
          _stringValue(_read(json, 'TableSeat')),
      giftStatus: _intValue(_read(source, 'GiftStatus')) ??
          _intValue(_read(json, 'GiftStatus')),
      giftNote: _optionalDisplayString(_read(source, 'GiftNote')) ??
          _optionalDisplayString(_read(json, 'GiftNote')),
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

String? _optionalDisplayString(Object? value) {
  final text = _stringValue(value);
  if (text == null) return null;
  switch (text.toLowerCase()) {
    case 'null':
    case 'undefined':
    case 'n/a':
    case 'na':
    case '-':
      return null;
  }
  return text;
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
