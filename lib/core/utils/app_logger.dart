// lib/utils/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Số dòng stack trace hiển thị
      errorMethodCount: 8, // Nhiều hơn cho error
      lineLength: 120, // Độ dài dòng
      colors: true, // Màu sắc
      printEmojis: true, // Icon đẹp
      printTime: true, // Thời gian
    ),
    level: Level.debug, // Thay đổi theo môi trường ở bước sau
  );

  static Logger get instance => _logger;
}
