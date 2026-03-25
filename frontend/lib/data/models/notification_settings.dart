import 'package:equatable/equatable.dart';

/// Notification settings model for storing user preferences
class NotificationSettings extends Equatable {
  final bool enabled;
  final bool sound;
  final bool vibration;

  const NotificationSettings({
    this.enabled = true,
    this.sound = true,
    this.vibration = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'sound': sound,
      'vibration': vibration,
    };
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }

  @override
  List<Object?> get props => [enabled, sound, vibration];
}
