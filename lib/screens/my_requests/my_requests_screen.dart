import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/request_card.dart';
import '../detail/detail_request_screen.dart';

// StatefulWidget + AutomaticKeepAliveClientMixin agar tab tidak di-dispose
// saat user pindah ke tab bottom nav lain.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sebagai Requester'),
              Tab(text: 'Sebagai Traveler'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_RequesterList(), _TravelerList()],
        ),
      ),
    );
  }
}

class _RequesterList extends StatefulWidget {
  const _RequesterList();

  @override
  State<_RequesterList> createState() => _RequesterListState();
}

class _RequesterListState extends State<_RequesterList>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<RequestModel>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().user!.uid;
    _stream = context.read<RequestProvider>().myRequests(uid);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _RequestList(stream: _stream);
  }
}

class _TravelerList extends StatefulWidget {
  const _TravelerList();

  @override
  State<_TravelerList> createState() => _TravelerListState();
}

class _TravelerListState extends State<_TravelerList>
    with AutomaticKeepAliveClientMixin {
  late final Stream<List<RequestModel>> _stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().user!.uid;
    _stream = context.read<RequestProvider>().myJastips(uid);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _RequestList(stream: _stream);
  }
}

class _RequestList extends StatelessWidget {
  final Stream<List<RequestModel>> stream;
  const _RequestList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: stream,
      builder: (context, snapshot) {
        // Tampilkan data lama (jika ada) sambil menunggu update baru,
        // sehingga card tidak menghilang saat re-subscribe.
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada pesanan',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final r = list[i];
            return RequestCard(
              request: r,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailRequestScreen(id: r.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
