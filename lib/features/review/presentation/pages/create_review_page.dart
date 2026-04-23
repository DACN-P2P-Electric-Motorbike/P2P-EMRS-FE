import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';

class CreateReviewPage extends StatelessWidget {
  final String vehicleId;
  final String vehicleName;

  const CreateReviewPage({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReviewBloc>(),
      child: _CreateReviewView(
        vehicleId: vehicleId,
        vehicleName: vehicleName,
      ),
    );
  }
}

class _CreateReviewView extends StatefulWidget {
  final String vehicleId;
  final String vehicleName;

  const _CreateReviewView({
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  State<_CreateReviewView> createState() => _CreateReviewViewState();
}

class _CreateReviewViewState extends State<_CreateReviewView> {
  int _rating = 0;
  final _commentController = TextEditingController();
  int _charCount = 0;
  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() => _charCount = _commentController.text.length);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
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
          'Đánh giá chuyến đi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đánh giá đã được gửi!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ReviewFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vehicle info
                _buildVehicleCard(),
                const SizedBox(height: 32),

                // Star rating
                Text(
                  'Bạn cảm thấy thế nào về chuyến đi?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildStarRating(),
                const SizedBox(height: 8),
                Text(
                  _getRatingText(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _getRatingColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Comment
                _buildCommentField(),
                const SizedBox(height: 32),

                // Trust Score info
                _buildTrustScoreInfo(),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _rating == 0 || state is ReviewLoading
                        ? null
                        : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state is ReviewLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Gửi đánh giá',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.electric_scooter,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehicleName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Đánh giá chất lượng xe',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey('$star-${star <= _rating}'),
                size: 52,
                color: star <= _rating
                    ? const Color(0xFFFFB300)
                    : Colors.grey[300],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCommentField() {
    final nearLimit = _charCount >= _maxChars * 0.85;
    final atLimit = _charCount >= _maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhận xét (tùy chọn)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$_charCount/$_maxChars',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: atLimit
                    ? AppColors.error
                    : nearLimit
                        ? AppColors.warning
                        : AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 4,
          maxLength: _maxChars,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              const SizedBox.shrink(),
          decoration: InputDecoration(
            hintText: 'Chia sẻ trải nghiệm của bạn về xe...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustScoreInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Để lại đánh giá giúp tăng Trust Score của bạn lên +1 điểm',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Không tốt';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Xuất sắc!';
      default:
        return 'Chọn đánh giá của bạn';
    }
  }

  Color _getRatingColor() {
    switch (_rating) {
      case 1:
      case 2:
        return AppColors.error;
      case 3:
        return AppColors.warning;
      case 4:
      case 5:
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  void _submit(BuildContext context) {
    context.read<ReviewBloc>().add(
      CreateReviewEvent(
        vehicleId: widget.vehicleId,
        rating: _rating,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      ),
    );
  }
}
