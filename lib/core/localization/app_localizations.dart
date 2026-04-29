import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('vi'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _values = {
    'vi': {
      'appTitle': 'DreamRide',
      'settingsTitle': 'Cài đặt ứng dụng',
      'appearance': 'Giao diện',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'theme': 'Chế độ màu',
      'system': 'Hệ thống',
      'light': 'Sáng',
      'dark': 'Tối',
      'dataSaver': 'Tiết kiệm dữ liệu',
      'dataSaverDescription':
          'Tắt tự tải ảnh xe và chỉ hiển thị khung giữ chỗ.',
      'privacy': 'Quyền riêng tư',
      'privacyDescription':
          'Ứng dụng hỗ trợ xuất dữ liệu cá nhân và yêu cầu xóa tài khoản trong SLA 72 giờ qua API.',
      'exportData': 'Xuất dữ liệu',
      'exportSummary': 'Tóm tắt dữ liệu',
      'exportGeneratedAt': 'Thời điểm xuất',
      'exportBookings': 'Lượt đặt xe',
      'exportPayments': 'Thanh toán',
      'exportTrips': 'Chuyến đi',
      'exportReviews': 'Đánh giá',
      'exportFailed': 'Không thể xuất dữ liệu',
      'deleteAccountRequest': 'Yêu cầu xóa tài khoản',
      'deleteRequestConfirmTitle': 'Gửi yêu cầu xóa tài khoản?',
      'deleteRequestConfirmBody':
          'Yêu cầu sẽ được ghi nhận để xử lý trong vòng 72 giờ.',
      'deleteRequestCreated': 'Đã tạo yêu cầu. Hạn xử lý:',
      'deleteFailed': 'Không thể tạo yêu cầu xóa tài khoản',
      'privacyRequests': 'Yêu cầu quyền riêng tư',
      'noPrivacyRequests': 'Chưa có yêu cầu nào.',
      'requestCreatedAt': 'Tạo lúc:',
      'requestDueAt': 'Hạn xử lý:',
      'statusPending': 'Đang chờ',
      'statusCompleted': 'Hoàn tất',
      'statusRejected': 'Từ chối',
      'userAvatar': 'Ảnh đại diện người dùng',
      'networkImageHidden': 'Ảnh mạng bị ẩn do chế độ tiết kiệm dữ liệu',
      'refresh': 'Làm mới',
      'close': 'Đóng',
      'cancel': 'Hủy',
      'confirm': 'Xác nhận',
    },
    'en': {
      'appTitle': 'DreamRide',
      'settingsTitle': 'App settings',
      'appearance': 'Appearance',
      'language': 'Language',
      'vietnamese': 'Vietnamese',
      'english': 'English',
      'theme': 'Theme',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'dataSaver': 'Data saver',
      'dataSaverDescription':
          'Stops automatic vehicle image loading and shows placeholders.',
      'privacy': 'Privacy rights',
      'privacyDescription':
          'The API supports personal-data export and account deletion requests with a 72-hour SLA.',
      'exportData': 'Export data',
      'exportSummary': 'Data summary',
      'exportGeneratedAt': 'Generated at',
      'exportBookings': 'Bookings',
      'exportPayments': 'Payments',
      'exportTrips': 'Trips',
      'exportReviews': 'Reviews',
      'exportFailed': 'Unable to export data',
      'deleteAccountRequest': 'Request account deletion',
      'deleteRequestConfirmTitle': 'Send account deletion request?',
      'deleteRequestConfirmBody':
          'The request will be recorded for processing within 72 hours.',
      'deleteRequestCreated': 'Request created. Due:',
      'deleteFailed': 'Unable to create account deletion request',
      'privacyRequests': 'Privacy requests',
      'noPrivacyRequests': 'No requests yet.',
      'requestCreatedAt': 'Created:',
      'requestDueAt': 'Due:',
      'statusPending': 'Pending',
      'statusCompleted': 'Completed',
      'statusRejected': 'Rejected',
      'userAvatar': 'User avatar',
      'networkImageHidden': 'Network image hidden by data saver',
      'refresh': 'Refresh',
      'close': 'Close',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
    },
  };

  String t(String key) {
    return _values[locale.languageCode]?[key] ?? _values['vi']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(
      locale.languageCode == 'en' ? const Locale('en') : const Locale('vi'),
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
