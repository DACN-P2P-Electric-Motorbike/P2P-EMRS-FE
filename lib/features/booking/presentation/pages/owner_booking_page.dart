import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/owner_booking_card.dart';
import 'booking_detail_page.dart';

/// Owner Bookings Page - manage rental requests
class OwnerBookingsPage extends StatelessWidget {
  const OwnerBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingBloc>()..add(const LoadOwnerBookingsEvent()),
      child: const _OwnerBookingsContent(),
    );
  }
}

class _OwnerBookingsContent extends StatefulWidget {
  const _OwnerBookingsContent();

  @override
  State<_OwnerBookingsContent> createState() => _OwnerBookingsContentState();
}

class _OwnerBookingsContentState extends State<_OwnerBookingsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      BookingStatus? status;
      switch (_tabController.index) {
        case 0: // All
          status = null;
          break;
        case 1: // Pending
          context.read<BookingBloc>().add(const LoadPendingBookingsEvent());
          return;
        case 2: // Confirmed
          status = BookingStatus.CONFIRMED;
          break;
        case 3: // Ongoing
          status = BookingStatus.ONGOING;
          break;
        case 4: // Completed
          status = BookingStatus.COMPLETED;
          break;
      }
      context.read<BookingBloc>().add(LoadOwnerBookingsEvent(status: status));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Quản lý đặt xe',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã xác nhận'),
            Tab(text: 'Đang thuê'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload bookings after action
            if (_tabController.index == 1) {
              context.read<BookingBloc>().add(const LoadPendingBookingsEvent());
            } else {
              context.read<BookingBloc>().add(const LoadOwnerBookingsEvent());
            }
          } else if (state is BookingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(context, state, null),
              _buildBookingList(context, state, BookingStatus.PENDING),
              _buildBookingList(context, state, BookingStatus.CONFIRMED),
              _buildBookingList(context, state, BookingStatus.ONGOING),
              _buildBookingList(context, state, BookingStatus.COMPLETED),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    BookingState state,
    BookingStatus? filterStatus,
  ) {
    if (state is BookingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BookingsLoaded) {
      var bookings = state.bookings;

      // Filter if needed
      if (filterStatus != null) {
        bookings = bookings.where((b) => b.status == filterStatus).toList();
      }

      if (bookings.isEmpty) {
        return _buildEmptyState(filterStatus);
      }

      return RefreshIndicator(
        onRefresh: () async {
          if (filterStatus == BookingStatus.PENDING) {
            context.read<BookingBloc>().add(const LoadPendingBookingsEvent());
          } else {
            context.read<BookingBloc>().add(
              LoadOwnerBookingsEvent(status: filterStatus),
            );
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return OwnerBookingCard(
              booking: booking,
              onTap: () => _navigateToDetail(context, booking.id),
              onApprove: booking.isPending
                  ? () => _showApproveDialog(context, booking)
                  : null,
              onReject: booking.isPending
                  ? () => _showRejectDialog(context, booking)
                  : null,
            );
          },
        ),
      );
    }

    return _buildEmptyState(filterStatus);
  }

  Widget _buildEmptyState(BookingStatus? status) {
    String message = 'Chưa có yêu cầu đặt xe nào';
    IconData icon = Icons.event_busy;

    if (status == BookingStatus.PENDING) {
      message = 'Không có yêu cầu chờ duyệt';
      icon = Icons.pending_actions;
    } else if (status == BookingStatus.CONFIRMED) {
      message = 'Không có booking đã xác nhận';
      icon = Icons.check_circle_outline;
    } else if (status == BookingStatus.ONGOING) {
      message = 'Không có chuyến đi đang diễn ra';
      icon = Icons.directions_bike;
    } else if (status == BookingStatus.COMPLETED) {
      message = 'Chưa có chuyến đi hoàn thành';
      icon = Icons.task_alt;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BookingDetailPage(bookingId: bookingId, isOwnerView: true),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, BookingEntity booking) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Xác nhận booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn chấp nhận yêu cầu thuê xe này?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Tin nhắn (tùy chọn)',
                hintText: 'Gửi lời nhắn đến người thuê...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingBloc>().add(
                ApproveBookingEvent(
                  bookingId: booking.id,
                  message: messageController.text.trim().isNotEmpty
                      ? messageController.text.trim()
                      : null,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, BookingEntity booking) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Từ chối booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vui lòng cho biết lý do từ chối:',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do *',
                  hintText: 'Ví dụ: Xe đã được đặt, bảo trì...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do từ chối';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext);
                context.read<BookingBloc>().add(
                  RejectBookingEvent(
                    bookingId: booking.id,
                    reason: reasonController.text.trim(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}
