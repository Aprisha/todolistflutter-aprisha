// services/web_notification_service.dart

import 'dart:html' as html;

class WebNotificationService {
  /// Inisialisasi dan minta izin notifikasi dari browser
  static Future<void> init() async {
    if (html.Notification.supported) {
      if (html.Notification.permission == 'default') {
        await html.Notification.requestPermission();
      }
    }
  }

  /// Tampilkan notifikasi dengan judul dan isi pesan
  static void showNotification(String title, String body) {
    if (!html.Notification.supported) {
      print('Notifikasi tidak didukung pada browser ini.');
      return;
    }

    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    } else {
      print('Izin notifikasi belum diberikan.');
    }
  }
}
