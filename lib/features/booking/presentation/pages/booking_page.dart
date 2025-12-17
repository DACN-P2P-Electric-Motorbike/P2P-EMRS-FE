import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_card.dart';
import '../widgets/owner_booking_card.dart';
import 'booking_detail_page.dart';

/// Unified Bookings Page - combines both renter and owner views
class UnifiedBookingsPage extends StatefulWidget {
  const UnifiedBookingsPage({super.key});

  @override
  State<UnifiedBookingsPage> createState() => _UnifiedBookingsPageState();
}

class _UnifiedBookingsPageState extends State<UnifiedBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _checkUserRole();
  }

  void _checkUserRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _isOwner = authState.user.isOwner || authState.user.isAdmin;
      });
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isOwner =
            authState is AuthAuthenticated &&
            (authState.user.isOwner || authState.user.isAdmin);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Quản lý booking',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            bottom: isOwner
                ? TabBar(
                    controller: _mainTabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Chuyến đi của tôi'),
                      Tab(text: 'Xe cho thuê'),
                    ],
                  )
                : null,
          ),
          body: isOwner
              ? TabBarView(
                  controller: _mainTabController,
                  children: const [_RenterBookingsTab(), _OwnerBookingsTab()],
                )
              : const _RenterBookingsTab(),
        );
      },
    );
  }
}

/// Renter Bookings Tab with sub-tabs
class _RenterBookingsTab extends StatefulWidget {
  const _RenterBookingsTab();

  @override
  State<_RenterBookingsTab> createState() => _RenterBookingsTabState();
}

class _RenterBookingsTabState extends State<_RenterBookingsTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      BookingStatus? status;
      switch (_tabController.index) {
        case 0:
          status = null;
          break;
        case 1:
          status = BookingStatus.PENDING;
          break;
        case 2:
          status = BookingStatus.CONFIRMED;
          break;
        case 3:
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
    super.build(context);

    return BlocProvider(
      create: (_) => sl<BookingBloc>()..add(const LoadRenterBookingsEvent()),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
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
          Expanded(
            child: BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state is BookingActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<BookingBloc>().add(
                    const LoadRenterBookingsEvent(),
                  );
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
                    _buildRenterBookingList(context, state, null),
                    _buildRenterBookingList(
                      context,
                      state,
                      BookingStatus.PENDING,
                    ),
                    _buildRenterBookingList(
                      context,
                      state,
                      BookingStatus.CONFIRMED,
                    ),
                    _buildRenterBookingList(
                      context,
                      state,
                      null,
                      isHistory: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenterBookingList(
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

      if (filterStatus != null) {
        bookings = bookings.where((b) => b.status == filterStatus).toList();
      } else if (isHistory) {
        bookings = bookings
            .where((b) => b.isCompleted || b.isCancelled || b.isRejected)
            .toList();
      }

      if (bookings.isEmpty) {
        return _buildEmptyState(filterStatus, isHistory: isHistory);
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
              onTap: () => _navigateToDetail(context, booking.id, false),
            );
          },
        ),
      );
    }

    return _buildEmptyState(filterStatus, isHistory: isHistory);
  }

  Widget _buildEmptyState(
    BookingStatus? status, {
    bool isHistory = false,
    bool isOwner = false,
  }) {
    String message = 'Chưa có chuyến đi nào';
    IconData icon = Icons.event_busy;

    if (isOwner) {
      message = 'Chưa có yêu cầu đặt xe nào';
      if (status == BookingStatus.PENDING) {
        message = 'Không có yêu cầu chờ duyệt';
        icon = Icons.pending_actions;
      }
    } else {
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

  void _navigateToDetail(
    BuildContext context,
    String bookingId,
    bool isOwnerView,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BookingDetailPage(bookingId: bookingId, isOwnerView: isOwnerView),
      ),
    );
  }
}

/// Owner Bookings Tab with sub-tabs
class _OwnerBookingsTab extends StatefulWidget {
  const _OwnerBookingsTab();

  @override
  State<_OwnerBookingsTab> createState() => _OwnerBookingsTabState();
}

class _OwnerBookingsTabState extends State<_OwnerBookingsTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

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
        case 0:
          status = null;
          break;
        case 1:
          context.read<BookingBloc>().add(const LoadPendingBookingsEvent());
          return;
        case 2:
          status = BookingStatus.CONFIRMED;
          break;
        case 3:
          status = BookingStatus.ONGOING;
          break;
        case 4:
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
    super.build(context);

    return BlocProvider(
      create: (_) => sl<BookingBloc>()..add(const LoadOwnerBookingsEvent()),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
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
          Expanded(
            child: BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state is BookingActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (_tabController.index == 1) {
                    context.read<BookingBloc>().add(
                      const LoadPendingBookingsEvent(),
                    );
                  } else {
                    context.read<BookingBloc>().add(
                      const LoadOwnerBookingsEvent(),
                    );
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
                    _buildOwnerBookingList(context, state, null),
                    _buildOwnerBookingList(
                      context,
                      state,
                      BookingStatus.PENDING,
                    ),
                    _buildOwnerBookingList(
                      context,
                      state,
                      BookingStatus.CONFIRMED,
                    ),
                    _buildOwnerBookingList(
                      context,
                      state,
                      BookingStatus.ONGOING,
                    ),
                    _buildOwnerBookingList(
                      context,
                      state,
                      BookingStatus.COMPLETED,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerBookingList(
    BuildContext context,
    BookingState state,
    BookingStatus? filterStatus,
  ) {
    if (state is BookingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BookingsLoaded) {
      var bookings = state.bookings;

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
              onTap: () => _navigateToDetail(context, booking.id, true),
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

  void _navigateToDetail(
    BuildContext context,
    String bookingId,
    bool isOwnerView,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BookingDetailPage(bookingId: bookingId, isOwnerView: isOwnerView),
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
