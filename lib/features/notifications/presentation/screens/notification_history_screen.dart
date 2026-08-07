import 'package:flutter/material.dart';
import '../../data/fcm_repository.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  static const Color darkNavy = Color(0xFF072D62);

  final _fcmRepository = FcmRepository();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<NotificationItem> _notifications = [];
  int _currentPage = 1;
  bool _hasNextPage = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications(reset: true);
  }

  Future<void> _loadNotifications({bool reset = false}) async {
    setState(() {
      if (reset) {
        _isLoading = true;
        _currentPage = 1;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    final result = await _fcmRepository.getMyNotifications(page: _currentPage);

    if (!mounted) return;

    if (result.success) {
      setState(() {
        if (reset) {
          _notifications = result.results;
        } else {
          _notifications.addAll(result.results);
        }
        _hasNextPage = result.next != null;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNextPage) return;
    _currentPage += 1;
    await _loadNotifications();
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final local = dt.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SENT':
        return const Color(0xFF14AE5C);
      case 'FAILED':
        return const Color(0xFFC62828);
      default:
        return Colors.black45;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3159, 1.0],
                colors: [Color(0xFF072D62), Color(0xFF114995)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () => _loadNotifications(reset: true),
                        child: const Text('Retry')),
                  ],
                ),
              ),
            )
                : _notifications.isEmpty
                ? const Center(
              child: Text('No notifications yet',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
            )
                : RefreshIndicator(
              onRefresh: () => _loadNotifications(reset: true),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!_isLoadingMore &&
                      _hasNextPage &&
                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
                    _loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length + (_hasNextPage ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= _notifications.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final n = _notifications[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(n.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: darkNavy)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _statusColor(n.status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(n.status,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusColor(n.status))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(n.body, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text(n.hotelName,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_fmtDate(n.createdAt),
                              style: const TextStyle(fontSize: 10, color: Colors.black45)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}