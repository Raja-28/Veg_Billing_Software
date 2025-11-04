import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

/// Service for WhatsApp integration
/// Note: This requires url_launcher package to be added to pubspec.yaml
class WhatsAppService {
  /// Send a WhatsApp message to a phone number
  /// 
  /// [phoneNumber] should be in format: 91XXXXXXXXXX (with country code, no +)
  /// [message] is the text to send
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // Format the WhatsApp URL
      // For desktop, use web.whatsapp.com
      // For mobile, use wa.me
      final url = Platform.isWindows || Platform.isMacOS || Platform.isLinux
          ? 'https://web.whatsapp.com/send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}'
          : 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}';

      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      // Error sending WhatsApp message
      return false;
    }
  }

  /// Send a bill notification to farmer
  static Future<bool> sendBillNotification({
    required String farmerName,
    required String phoneNumber,
    required int billId,
    required double totalAmount,
  }) async {
    final message = '''
🧾 *New Bill Generated*

Dear $farmerName,

A new bill has been created for you:

📋 Bill Number: #$billId
💰 Amount: ₹${totalAmount.toStringAsFixed(2)}

Thank you for your business!

- Vegetable Trading Company
''';

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Send a payment received notification
  static Future<bool> sendPaymentNotification({
    required String farmerName,
    required String phoneNumber,
    required double paymentAmount,
    required double newBalance,
  }) async {
    final message = '''
✅ *Payment Received*

Dear $farmerName,

We have received your payment:

💵 Payment: ₹${paymentAmount.toStringAsFixed(2)}
💰 New Balance: ₹${newBalance.toStringAsFixed(2)}

Thank you!

- Vegetable Trading Company
''';

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Send a custom message
  static Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String farmerName,
    required String customMessage,
  }) async {
    final message = '''
Dear $farmerName,

$customMessage

- Vegetable Trading Company
''';

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }
}
