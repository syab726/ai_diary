import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import '../models/diary_entry.dart';
import 'image_viewer.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry diary;
  final VoidCallback onTap;

  const DiaryCard({
    super.key,
    required this.diary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 생성된 이미지 또는 플레이스홀더
            AspectRatio(
              aspectRatio: 16 / 9,
              child: diary.generatedImageUrl != null
                  ? _buildImageWidget(diary.generatedImageUrl!, context)
                  : _buildPlaceholder(context),
            ),
            
            // 일기 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 날짜
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          diary.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MM/dd').format(diary.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 일기 내용 미리보기
                  Text(
                    diary.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 감정과 키워드
                  Row(
                    children: [
                      // 감정
                      if (diary.emotion != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEmotionColor(diary.emotion!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getEmotionIcon(diary.emotion!),
                                size: 14,
                                color: _getEmotionColor(diary.emotion!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getEmotionText(diary.emotion!),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getEmotionColor(diary.emotion!),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      // 키워드 개수
                      if (diary.keywords.isNotEmpty) ...[
                        Icon(
                          Icons.tag,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${diary.keywords.length}개 키워드',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl, BuildContext context) {
    Widget imageWidget;

    // file:// 경로인 경우 로컬 파일로 처리
    if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '');
      final file = File(filePath);

      // 파일이 존재하는지 확인
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) print('로컬 이미지 로드 오류: $error');
            return _buildPlaceholder(context);
          },
        );
      } else {
        if (kDebugMode) print('로컬 이미지 파일이 존재하지 않음: $filePath');
        return _buildPlaceholder(context);
      }
    }
    // data: URL인 경우 (base64)
    else if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) print('base64 이미지 로드 오류: $error');
            return _buildPlaceholder(context);
          },
        );
      } catch (e) {
        if (kDebugMode) print('base64 디코딩 오류: $e');
        return _buildPlaceholder(context);
      }
    }
    // HTTP URL인 경우 네트워크 이미지로 처리
    else if (imageUrl.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          if (kDebugMode) print('네트워크 이미지 로드 오류: $error');
          return _buildPlaceholder(context);
        },
      );
    }
    // 알 수 없는 형식
    else {
      if (kDebugMode) print('알 수 없는 이미지 URL 형식: $imageUrl');
      return _buildPlaceholder(context);
    }

    // 이미지를 GestureDetector로 감싸서 클릭 시 ImageViewer로 이동
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewer(
              imageUrl: imageUrl,
              title: diary.title,
            ),
          ),
        );
      },
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'AI가 그림을 그리는 중...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.yellow[700]!;
      case 'sad':
        return Colors.blue[700]!;
      case 'angry':
        return Colors.red[700]!;
      case 'excited':
        return Colors.orange[700]!;
      case 'peaceful':
        return Colors.green[700]!;
      case 'anxious':
        return Colors.purple[700]!;
      case 'grateful':
        return Colors.pink[700]!;
      case 'nostalgic':
        return Colors.brown[700]!;
      case 'romantic':
        return Colors.pink[400]!;
      case 'frustrated':
        return Colors.red[900]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'excited':
        return Icons.celebration;
      case 'peaceful':
        return Icons.self_improvement;
      case 'anxious':
        return Icons.psychology_alt;
      case 'grateful':
        return Icons.favorite;
      case 'nostalgic':
        return Icons.history;
      case 'romantic':
        return Icons.favorite_border;
      case 'frustrated':
        return Icons.mood_bad;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getEmotionText(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '행복';
      case 'sad':
        return '슬픔';
      case 'angry':
        return '화남';
      case 'excited':
        return '흥분';
      case 'peaceful':
        return '평온';
      case 'anxious':
        return '불안';
      case 'grateful':
        return '감사';
      case 'nostalgic':
        return '그리움';
      case 'romantic':
        return '로맨틱';
      case 'frustrated':
        return '짜증';
      default:
        return '보통';
    }
  }
}
