import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

/// 이미지 압축 및 최적화를 제공하는 헬퍼 클래스
class ImageHelper {
  /// AI 생성 이미지 압축 (1-2MB → 200-300KB)
  ///
  /// [imageFile]: 압축할 이미지 파일
  /// [quality]: 압축 품질 (0-100, 기본값: 85)
  /// [maxWidth]: 최대 너비 (기본값: 1080)
  /// [maxHeight]: 최대 높이 (기본값: 1080)
  ///
  /// Returns: 압축된 이미지 파일
  static Future<File> compressAIImage({
    required File imageFile,
    int quality = 85,
    int maxWidth = 1080,
    int maxHeight = 1080,
  }) async {
    try {
      if (kDebugMode) {
        final originalSize = await imageFile.length();
        print('[ImageHelper] 원본 이미지 크기: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');
      }

      // 파일 확장자 확인
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final targetPath = imageFile.path.replaceFirst(
        RegExp(r'\.\w+$'),
        '_compressed.$fileExtension',
      );

      // flutter_image_compress를 사용한 압축
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg, // JPEG 형식으로 변환 (더 나은 압축률)
      );

      if (compressedBytes == null) {
        if (kDebugMode) print('[ImageHelper] 이미지 압축 실패, 원본 반환');
        return imageFile;
      }

      // 압축된 이미지를 파일로 저장
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      if (kDebugMode) {
        final compressedSize = compressedBytes.length;
        print('[ImageHelper] 압축된 이미지 크기: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        final originalSize = await imageFile.length();
        final compressionRatio = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
        print('[ImageHelper] 압축률: $compressionRatio%');
      }

      // 원본 파일 삭제
      try {
        await imageFile.delete();
      } catch (e) {
        if (kDebugMode) print('[ImageHelper] 원본 파일 삭제 실패: $e');
      }

      return compressedFile;
    } catch (e) {
      if (kDebugMode) print('[ImageHelper] 이미지 압축 중 오류 발생: $e');
      return imageFile; // 오류 발생 시 원본 반환
    }
  }

  /// 썸네일 생성 (리스트뷰용)
  ///
  /// [imageFile]: 썸네일을 생성할 이미지 파일
  /// [size]: 썸네일 크기 (기본값: 256)
  ///
  /// Returns: 썸네일 이미지 파일
  static Future<File> generateThumbnail({
    required File imageFile,
    int size = 256,
  }) async {
    try {
      final thumbnailPath = imageFile.path.replaceFirst(
        RegExp(r'\.\w+$'),
        '_thumb.jpg',
      );

      // 썸네일이 이미 존재하면 반환
      final thumbnailFile = File(thumbnailPath);
      if (await thumbnailFile.exists()) {
        return thumbnailFile;
      }

      if (kDebugMode) print('[ImageHelper] 썸네일 생성 중: $size x $size');

      // 이미지 압축하여 썸네일 생성
      final thumbnailBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: size,
        minHeight: size,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      if (thumbnailBytes == null) {
        if (kDebugMode) print('[ImageHelper] 썸네일 생성 실패');
        return imageFile;
      }

      await thumbnailFile.writeAsBytes(thumbnailBytes);

      if (kDebugMode) {
        final thumbSize = thumbnailBytes.length;
        print('[ImageHelper] 썸네일 크기: ${(thumbSize / 1024).toStringAsFixed(2)} KB');
      }

      return thumbnailFile;
    } catch (e) {
      if (kDebugMode) print('[ImageHelper] 썸네일 생성 중 오류 발생: $e');
      return imageFile;
    }
  }

  /// 이미지 리사이징
  ///
  /// [imageFile]: 리사이징할 이미지 파일
  /// [maxWidth]: 최대 너비
  /// [maxHeight]: 최대 높이
  ///
  /// Returns: 리사이징된 이미지 파일
  static Future<File> resizeImage({
    required File imageFile,
    required int maxWidth,
    required int maxHeight,
  }) async {
    try {
      if (kDebugMode) print('[ImageHelper] 이미지 리사이징: $maxWidth x $maxHeight');

      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        if (kDebugMode) print('[ImageHelper] 이미지 디코딩 실패');
        return imageFile;
      }

      // 원본 비율 유지하면서 리사이징
      final resized = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : null,
        height: image.height > maxHeight ? maxHeight : null,
      );

      final resizedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 85));

      // 리사이징된 이미지 저장
      final resizedPath = imageFile.path.replaceFirst(
        RegExp(r'\.\w+$'),
        '_resized.jpg',
      );
      final resizedFile = File(resizedPath);
      await resizedFile.writeAsBytes(resizedBytes);

      if (kDebugMode) {
        print('[ImageHelper] 리사이징 완료: ${resized.width} x ${resized.height}');
      }

      return resizedFile;
    } catch (e) {
      if (kDebugMode) print('[ImageHelper] 이미지 리사이징 중 오류 발생: $e');
      return imageFile;
    }
  }

  /// WebP 형식으로 변환
  ///
  /// [imageFile]: 변환할 이미지 파일
  /// [quality]: 품질 (0-100, 기본값: 85)
  ///
  /// Returns: WebP 형식의 이미지 파일
  static Future<File> convertToWebP({
    required File imageFile,
    int quality = 85,
  }) async {
    try {
      if (kDebugMode) print('[ImageHelper] WebP로 변환 중...');

      final webpPath = imageFile.path.replaceFirst(
        RegExp(r'\.\w+$'),
        '.webp',
      );

      final webpBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        format: CompressFormat.webp,
      );

      if (webpBytes == null) {
        if (kDebugMode) print('[ImageHelper] WebP 변환 실패');
        return imageFile;
      }

      final webpFile = File(webpPath);
      await webpFile.writeAsBytes(webpBytes);

      if (kDebugMode) {
        final webpSize = webpBytes.length;
        print('[ImageHelper] WebP 크기: ${(webpSize / 1024).toStringAsFixed(2)} KB');
      }

      return webpFile;
    } catch (e) {
      if (kDebugMode) print('[ImageHelper] WebP 변환 중 오류 발생: $e');
      return imageFile;
    }
  }

  /// 이미지 메타데이터 제거 및 최적화
  ///
  /// [imageFile]: 최적화할 이미지 파일
  ///
  /// Returns: 최적화된 이미지 파일
  static Future<File> optimizeImage({
    required File imageFile,
  }) async {
    try {
      if (kDebugMode) print('[ImageHelper] 이미지 최적화 중...');

      // 1. 리사이징 (1080x1080 이하로)
      var optimizedFile = await resizeImage(
        imageFile: imageFile,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      // 2. 압축
      optimizedFile = await compressAIImage(
        imageFile: optimizedFile,
        quality: 85,
      );

      if (kDebugMode) print('[ImageHelper] 이미지 최적화 완료');

      return optimizedFile;
    } catch (e) {
      if (kDebugMode) print('[ImageHelper] 이미지 최적화 중 오류 발생: $e');
      return imageFile;
    }
  }
}
