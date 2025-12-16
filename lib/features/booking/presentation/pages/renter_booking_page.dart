import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_card.dart';
import 'booking_detail_page.dart';

/// Renter Bookings Page with tabs
class RenterBookingsPage extends StatelessWidget {
  const RenterBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingBloc>()..add(const LoadRenterBookingsEvent()),
      child: const _RenterBookingsContent(),
    );
  }
}

class _RenterBookingsContent extends StatefulWidget {
  const _RenterBookingsContent();

  @override
  State<_RenterBookingsContent> createState() => _RenterBookingsContentState();
}

class _RenterBookingsContentState extends State<_RenterBookingsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Load bookings based on selected tab
      BookingStatus? status;
      switch (_tabController.index) {
        case 0: // All
          status = null;
          break;
        case 1: // Pending
          status = BookingStatus.PENDING;
          break;
        case 2: // Confirmed
          status = BookingStatus.CONFIRMED;
          break;
        case 3: // History
          // Will use history endpoint
          context.read<BookingBloc>().add(const LoadRenterBookingsEvent());
          return;
      }
      context.read<BookingBloc>().add(LoadRenterBookingsEvent(status: status));
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
          'Chuyến đi của tôi',
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
            Tab(text: 'Lịch sử'),
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
            // Reload bookings
            context.read<BookingBloc>().add(const LoadRenterBookingsEvent());
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
              _buildBookingList(context, state, null, isHistory: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    BookingState state,
    BookingStatus? filterStatus, {
    bool isHistory = false,
  }) {
    if (state is BookingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BookingsLoaded) {
      var bookings = state.bookings;

      // Filter bookings
      if (filterStatus != null) {
        bookings = bookings.where((b) => b.status == filterStatus).toList();
      } else if (isHistory) {
        bookings = bookings
            .where((b) => b.isCompleted || b.isCancelled || b.isRejected)
            .toList();
      }

      if (bookings.isEmpty) {
        return _buildEmptyState(filterStatus, isHistory);
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<BookingBloc>().add(
            LoadRenterBookingsEvent(status: filterStatus),
          );
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return BookingCard(
              booking: booking,
              onTap: () => _navigateToDetail(context, booking.id),
            );
          },
        ),
      );
    }

    return _buildEmptyState(filterStatus, isHistory);
  }

  Widget _buildEmptyState(BookingStatus? status, bool isHistory) {
    String message = 'Chưa có chuyến đi nào';
    IconData icon = Icons.event_busy;

    if (status == BookingStatus.PENDING) {
      message = 'Chưa có yêu cầu đang chờ';
      icon = Icons.pending_actions;
    } else if (status == BookingStatus.CONFIRMED) {
      message = 'Chưa có chuyến đi được xác nhận';
      icon = Icons.check_circle_outline;
    } else if (isHistory) {
      message = 'Chưa có lịch sử chuyến đi';
      icon = Icons.history;
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
        builder: (_) => BookingDetailPage(bookingId: bookingId),
      ),
    );
  }
}
