import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/status_chip.dart';
import '../chat/chat_screen.dart';

class DetailRequestScreen extends StatelessWidget {
  final String id;
  const DetailRequestScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final requests = context.read<RequestProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Request')),
      body: StreamBuilder<RequestModel?>(
        stream: requests.requestStream(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final r = snapshot.data;
          if (r == null) {
            return const Center(child: Text('Request tidak ditemukan'));
          }
          return _DetailBody(request: r);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final RequestModel request;
  const _DetailBody({required this.request});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    final isRequester = me?.uid == request.requesterId;
    final isTraveler = me?.uid == request.travelerId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.itemName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                request.location,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoCard(request: request),
          if (request.note != null && request.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Catatan',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                request.note!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _PartiesCard(request: request),
          const SizedBox(height: 24),
          _Actions(
            request: request,
            isRequester: isRequester,
            isTraveler: isTraveler,
            isLoggedIn: me != null,
          ),
          if (request.travelerId != null && (isRequester || isTraveler)) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      requestId: request.id,
                      title: request.itemName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Buka Chat'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final RequestModel request;
  const _InfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _row('Estimasi Harga', Formatter.currency(request.estimatedPrice)),
          const Divider(height: 20),
          _row('Fee Awal', Formatter.currency(request.initialFee)),
          const Divider(height: 20),
          _row(
            'Fee Saat Ini',
            Formatter.currency(request.currentFee),
            highlight: true,
          ),
          const Divider(height: 20),
          _row(
            'Total Estimasi',
            Formatter.currency(request.estimatedPrice + request.currentFee),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: highlight ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PartiesCard extends StatelessWidget {
  final RequestModel request;
  const _PartiesCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _person(Icons.person_outline, 'Requester', request.requesterName),
          if (request.travelerName != null) ...[
            const Divider(height: 20),
            _person(Icons.flight_takeoff, 'Traveler', request.travelerName!),
          ],
        ],
      ),
    );
  }

  Widget _person(IconData icon, String label, String name) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.background,
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final RequestModel request;
  final bool isRequester;
  final bool isTraveler;
  final bool isLoggedIn;

  const _Actions({
    required this.request,
    required this.isRequester,
    required this.isTraveler,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) return const SizedBox.shrink();

    final provider = context.watch<RequestProvider>();
    final auth = context.read<AuthProvider>();

    Future<void> guard(Future<void> Function() action) async {
      try {
        await action();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }

    // OPEN -> traveler ambil request
    if (request.status == RequestStatus.open && !isRequester) {
      return _primaryBtn(
        'Ambil Request',
        Icons.handshake_outlined,
        provider.busy,
        () => guard(() => provider.takeRequest(
              requestId: request.id,
              traveler: auth.user!,
            )),
      );
    }

    // NEGOTIATION
    if (request.status == RequestStatus.negotiation) {
      if (isTraveler) {
        return _primaryBtn(
          'Ajukan Fee Baru',
          Icons.edit_outlined,
          provider.busy,
          () => _showProposeFeeSheet(context, request),
        );
      }
      if (isRequester) {
        return Column(
          children: [
            _primaryBtn(
              'Terima Fee ${Formatter.currency(request.currentFee)}',
              Icons.check_circle_outline,
              provider.busy,
              () => guard(() => provider.acceptFee(request.id)),
            ),
            const SizedBox(height: 8),
            _outlineBtn(
              'Tolak & Negosiasi Lagi',
              Icons.close,
              provider.busy,
              () => guard(() => provider.rejectFee(request.id)),
            ),
          ],
        );
      }
    }

    // WAITING_CONFIRMATION -> requester konfirmasi final
    if (request.status == RequestStatus.waitingConfirmation && isRequester) {
      return _primaryBtn(
        'Konfirmasi & Kunci Pesanan',
        Icons.lock_outline,
        provider.busy,
        () => guard(() => provider.confirmAccept(request.id)),
      );
    }

    // ACCEPTED -> traveler tandai sudah beli (tanpa upload)
    if (request.status == RequestStatus.accepted) {
      if (isTraveler) {
        return _primaryBtn(
          'Tandai Sudah Dibeli',
          Icons.shopping_bag_outlined,
          provider.busy,
          () => guard(() => provider.markPurchased(request.id)),
        );
      }
      if (isRequester) {
        return _infoCard(
          'Menunggu traveler membeli barang.',
          Icons.hourglass_empty,
        );
      }
    }

    // PURCHASED
    if (request.status == RequestStatus.purchased) {
      if (isRequester) {
        return Column(
          children: [
            _infoCard(
              'Silakan lakukan pembayaran secara langsung kepada traveler.',
              Icons.payments_outlined,
            ),
            const SizedBox(height: 12),
            _primaryBtn(
              'Pesanan Selesai',
              Icons.task_alt,
              provider.busy,
              () => guard(() => provider.completeOrder(request.id)),
            ),
          ],
        );
      }
      if (isTraveler) {
        return _infoCard(
          'Menunggu requester menyelesaikan pesanan.',
          Icons.hourglass_empty,
        );
      }
    }

    if (request.status == RequestStatus.completed) {
      return _infoCard(
          'Pesanan telah selesai. Terima kasih!', Icons.celebration);
    }

    return const SizedBox.shrink();
  }

  Widget _primaryBtn(String label, IconData icon, bool busy, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: busy ? null : onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _outlineBtn(String label, IconData icon, bool busy, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showProposeFeeSheet(BuildContext context, RequestModel r) {
    final ctrl = TextEditingController(text: r.currentFee.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ajukan Fee Baru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fee jastip',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final fee = num.tryParse(ctrl.text);
                    if (fee == null) return;
                    await context
                        .read<RequestProvider>()
                        .proposeFee(r.id, fee);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Kirim'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
