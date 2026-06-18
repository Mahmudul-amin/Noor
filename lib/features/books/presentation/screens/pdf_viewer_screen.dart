import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;
  final String? coverImage;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.coverImage,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  bool _isLoading = true;
  String _errorMessage = "";
  int _retryCount = 0;
  int _currentPage = 1;
  int _totalPage = 0;

  String? _localFilePath;
  double _downloadProgress = 0.0;
  bool _didRetryDocumentLoad = false;
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel();
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    final url = widget.pdfUrl;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _downloadProgress = 0.0;
      });
    }
    if (url.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No PDF URL provided.';
      });
      return;
    }

    try {
      if (url.startsWith('http')) {
        final dir = await getTemporaryDirectory();
        final filename = Uri.parse(url).pathSegments.isNotEmpty
            ? Uri.parse(url).pathSegments.last
            : 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${dir.path}/$filename';
        final tempPath = '$filePath.download';

        final file = File(filePath);
        if (await file.exists()) {
          final contentLength = await _getRemoteContentLength(url);
          if (contentLength != null && await file.length() == contentLength) {
            _localFilePath = filePath;
            setState(() => _isLoading = false);
            return;
          }
          await file.delete();
        }

        final dio = Dio();
        await dio.download(
          url,
          tempPath,
          onReceiveProgress: (received, total) {
            final progress =
                (total != -1 && total > 0) ? (received / total) : 0.0;
            if (mounted) {
              setState(() {
                _downloadProgress = progress;
              });
            }
          },
          cancelToken: _cancelToken,
          options:
              Options(receiveTimeout: Duration.zero, followRedirects: true),
        );

        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.rename(filePath);
          _localFilePath = filePath;
        }

        if (mounted) setState(() => _isLoading = false);
      } else {
        _localFilePath = url;
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to download/open PDF: $e';
        });
      }
    }
  }

  Future<int?> _getRemoteContentLength(String url) async {
    try {
      final dio = Dio();
      final response = await dio.head(
        url,
        options: Options(followRedirects: true, receiveTimeout: Duration.zero),
      );
      final lengthHeader = response.headers.value('content-length');
      return lengthHeader != null ? int.tryParse(lengthHeader) : null;
    } catch (_) {
      return null;
    }
  }

  void _zoomIn() {
    _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
  }

  void _zoomOut() {
    if (_pdfViewerController.zoomLevel > 1.0) {
      _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
    }
  }

  void _showJumpToPageDialog(BuildContext context, bool isDark) {
    final TextEditingController textController =
        TextEditingController(text: _currentPage.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Go to Page",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter page number (1 - $_totalPage):",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? AppColors.bgDark
                      : Colors.grey.withValues(alpha: 0.1),
                  hintText: "Page",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final input = textController.text.trim();
                final page = int.tryParse(input);
                if (page != null && page >= 1 && page <= _totalPage) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Please enter a valid page number between 1 and $_totalPage"),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Go"),
            ),
          ],
        );
      },
    );
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _currentPage = 1;
      _totalPage = 0;
      _downloadProgress = 0.0;
      _retryCount++;
      _localFilePath = null;
    });
    _preparePdf();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.primary),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: _errorMessage.isNotEmpty
          ? _buildErrorView(isDark)
          : _buildBody(isDark),
      bottomNavigationBar: !_isLoading &&
              _errorMessage.isEmpty &&
              _totalPage > 0
          ? SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: AppColors.primary, size: 28),
                      onPressed: _currentPage > 1
                          ? () => _pdfViewerController.previousPage()
                          : null,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _showJumpToPageDialog(context, isDark),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Page $_currentPage of $_totalPage',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.primary, size: 28),
                      onPressed: _currentPage < _totalPage
                          ? () => _pdfViewerController.nextPage()
                          : null,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.grey.withValues(alpha: 0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_rounded,
                          color: AppColors.primary),
                      onPressed: _zoomOut,
                      tooltip: 'Zoom Out',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded,
                          color: AppColors.primary),
                      onPressed: _zoomIn,
                      tooltip: 'Zoom In',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Container(
      color: isDark ? AppColors.bgDark : Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry Load"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      final theme = Theme.of(context);
      const startColor = Color(0xFF7A1F2B);
      const endColor = Color(0xFF0D5C46);
      final progressColor =
          Color.lerp(startColor, endColor, _downloadProgress.clamp(0.0, 1.0))!;
      final progressPercent =
          (_downloadProgress * 100).clamp(0, 100).toStringAsFixed(0);

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                        colors: [
                        progressColor.withOpacity(0.18),
                        progressColor.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                    backgroundColor: progressColor.withOpacity(0.16),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        Icons.auto_stories_rounded,
                        color: progressColor,
                        size: 30,
                      ),
                    const SizedBox(height: 6),
                    Text(
                      '$progressPercent%',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Preparing your book',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 220,
              child: LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                valueColor: AlwaysStoppedAnimation(progressColor),
                backgroundColor: progressColor.withOpacity(0.12),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    }

    if (_localFilePath == null || _localFilePath!.isEmpty) {
      return _buildErrorView(isDark);
    }

    final file = File(_localFilePath!);
    if (!file.existsSync()) return _buildErrorView(isDark);

    return SfPdfViewer.file(
      file,
      key: ValueKey('file_${_localFilePath}_$_retryCount'),
      controller: _pdfViewerController,
      canShowScrollHead: false,
      canShowScrollStatus: true,
      enableTextSelection: false,
      pageLayoutMode: PdfPageLayoutMode.single,
      scrollDirection: PdfScrollDirection.horizontal,
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _totalPage = _pdfViewerController.pageCount;
          });
        }
      },
      onPageChanged: (PdfPageChangedDetails details) {
        if (mounted) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
        }
      },
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) async {
        if (!_didRetryDocumentLoad && _localFilePath != null) {
          _didRetryDocumentLoad = true;
          final file = File(_localFilePath!);
          if (await file.exists()) {
            await file.delete();
          }
          if (mounted) {
            setState(() {
              _isLoading = true;
              _errorMessage = '';
              _downloadProgress = 0.0;
            });
          }
          await _preparePdf();
          return;
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Failed to load book: ${details.description}";
          });
        }
      },
    );
  }
}
