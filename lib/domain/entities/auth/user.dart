class UserEntity {
  final String token;

  UserEntity({required this.token});

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
      };

  UserEntity copyWith({
    String? token,
  }) {
    return UserEntity(
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'UserEntity { token: $token }';
  }

  List<Object?> get props {
    return [
      token,
    ];
  }

}
