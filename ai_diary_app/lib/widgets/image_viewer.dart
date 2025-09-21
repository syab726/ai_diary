import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const ImageViewer({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.title != null
          ? Text(
              widget.title!,
              style: const TextStyle(color: Colors.white),
            )
          : null,
        actions: [
          IconButton(
            icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.download, color: Colors.white),
            onPressed: _isLoading ? null : _saveImage,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: _buildImageWidget(),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    // file:// 경로인 경우 로컬 파일로 처리
    if (widget.imageUrl.startsWith('file://')) {
      final filePath = widget.imageUrl.replaceFirst('file://', '');
      final file = File(filePath);

      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      } else {
        return _buildErrorWidget();
      }
    }
    // data: URL인 경우 (base64)
    else if (widget.imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = widget.imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        );
      } catch (e) {
        return _buildErrorWidget();
      }
    }
    // HTTP URL인 경우 네트워크 이미지로 처리
    else if (widget.imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        errorWidget: (context, url, error) {
          return _buildErrorWidget();
        },
      );
    }
    // 알 수 없는 형식
    else {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.white54,
        ),
        SizedBox(height: 16),
        Text(
          '이미지를 불러올 수 없습니다',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _saveImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Uint8List? imageBytes;

      // file:// 경로인 경우
      if (widget.imageUrl.startsWith('file://')) {
        final filePath = widget.imageUrl.replaceFirst('file://', '');
        final file = File(filePath);
        if (file.existsSync()) {
          imageBytes = await file.readAsBytes();
        }
      }
      // data: URL인 경우
      else if (widget.imageUrl.startsWith('data:image/')) {
        final base64Data = widget.imageUrl.split(',')[1];
        imageBytes = base64Decode(base64Data);
      }
      // HTTP URL인 경우
      else if (widget.imageUrl.startsWith('http')) {
        final response = await HttpClient().getUrl(Uri.parse(widget.imageUrl));
        final httpResponse = await response.close();
        final bytes = <int>[];
        await for (var chunk in httpResponse) {
          bytes.addAll(chunk);
        }
        imageBytes = Uint8List.fromList(bytes);
      }

      if (imageBytes != null) {
        // 갤러리에 저장
        await Gal.putImageBytes(imageBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지가 갤러리에 저장되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('이미지 데이터를 가져올 수 없습니다');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}