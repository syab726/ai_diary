import 'dart:typed_data';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'image_style.dart';
import 'font_family.dart';
import 'image_time.dart';
import 'image_weather.dart';
import 'image_season.dart';

class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? generatedImageUrl;
  final Uint8List? imageData;  // 실제 이미지 바이너리 데이터
  final String? emotion;
  final List<String> keywords;
  final String? aiPrompt;
  final ImageStyle imageStyle;
  final bool hasBeenRegenerated;
  final FontFamily fontFamily;
  final ImageTime imageTime;
  final ImageWeather imageWeather;
  final ImageSeason imageSeason;
  final List<String> userPhotos;  // 사용자가 업로드한 사진들의 경로

  DiaryEntry({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.updatedAt,
    this.generatedImageUrl,
    this.imageData,
    this.emotion,
    List<String>? keywords,
    this.aiPrompt,
    this.imageStyle = ImageStyle.illustration,
    this.hasBeenRegenerated = false,
    this.fontFamily = FontFamily.notoSans,
    this.imageTime = ImageTime.morning,
    this.imageWeather = ImageWeather.sunny,
    this.imageSeason = ImageSeason.spring,
    List<String>? userPhotos,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toLocal(),
       keywords = keywords ?? [],
       userPhotos = userPhotos ?? [];

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? generatedImageUrl,
    Uint8List? imageData,
    String? emotion,
    List<String>? keywords,
    String? aiPrompt,
    ImageStyle? imageStyle,
    bool? hasBeenRegenerated,
    FontFamily? fontFamily,
    ImageTime? imageTime,
    ImageWeather? imageWeather,
    ImageSeason? imageSeason,
    List<String>? userPhotos,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toLocal(),
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      imageData: imageData ?? this.imageData,
      emotion: emotion ?? this.emotion,
      keywords: keywords ?? this.keywords,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      imageStyle: imageStyle ?? this.imageStyle,
      hasBeenRegenerated: hasBeenRegenerated ?? this.hasBeenRegenerated,
      fontFamily: fontFamily ?? this.fontFamily,
      imageTime: imageTime ?? this.imageTime,
      imageWeather: imageWeather ?? this.imageWeather,
      imageSeason: imageSeason ?? this.imageSeason,
      userPhotos: userPhotos ?? this.userPhotos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'generatedImageUrl': generatedImageUrl,
      'imageData': imageData != null ? base64Encode(imageData!) : null,
      'emotion': emotion,
      'keywords': keywords.join(','),
      'aiPrompt': aiPrompt,
      'imageStyle': imageStyle.name,
      'hasBeenRegenerated': hasBeenRegenerated ? 1 : 0,
      'fontFamily': fontFamily.name,
      'imageTime': imageTime.name,
      'imageWeather': imageWeather.name,
      'imageSeason': imageSeason.name,
      'userPhotos': userPhotos.join('|||'),  // 구분자로 연결
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']).toLocal(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']).toLocal() : null,
      generatedImageUrl: map['generatedImageUrl'],
      imageData: map['imageData'] != null ? base64Decode(map['imageData']) : null,
      emotion: map['emotion'],
      keywords: map['keywords'] != null ? (map['keywords'] as String).split(',').where((k) => k.isNotEmpty).toList() : [],
      aiPrompt: map['aiPrompt'],
      imageStyle: map['imageStyle'] != null 
          ? ImageStyle.values.firstWhere(
              (style) => style.name == map['imageStyle'],
              orElse: () => ImageStyle.illustration,
            )
          : ImageStyle.illustration,
      hasBeenRegenerated: (map['hasBeenRegenerated'] ?? 0) == 1,
      fontFamily: map['fontFamily'] != null
          ? FontFamily.values.firstWhere(
              (font) => font.name == map['fontFamily'],
              orElse: () => FontFamily.notoSans,
            )
          : FontFamily.notoSans,
      imageTime: map['imageTime'] != null
          ? ImageTime.values.firstWhere(
              (time) => time.name == map['imageTime'],
              orElse: () => ImageTime.morning,
            )
          : ImageTime.morning,
      imageWeather: map['imageWeather'] != null
          ? ImageWeather.values.firstWhere(
              (weather) => weather.name == map['imageWeather'],
              orElse: () => ImageWeather.sunny,
            )
          : ImageWeather.sunny,
      imageSeason: map['imageSeason'] != null
          ? ImageSeason.values.firstWhere(
              (season) => season.name == map['imageSeason'],
              orElse: () => ImageSeason.spring,
            )
          : ImageSeason.spring,
      userPhotos: map['userPhotos'] != null && (map['userPhotos'] as String).isNotEmpty
          ? (map['userPhotos'] as String).split('|||')
          : [],
    );
  }
}
