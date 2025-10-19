// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // 1. Pedir permissão ao usuário (iOS e Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Pegar o token do dispositivo
    //final token = await _fcm.getToken();
    //print('FCM Token: $token');
    // No futuro, salvaríamos este token no Firestore junto com os dados do usuário
    // ex: _firestore.collection('users').doc(userId).update({'fcmToken': token});

    // 3. Configurar notificações locais (para quando o app está aberto)
    //const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const androidInit =
        AndroidInitializationSettings('@drawable/ic_notification');
    // Nota: A inicialização do iOS requer mais passos (feitos no Mac)
    const settings = InitializationSettings(android: androidInit);
    _localNotifications.initialize(settings);

    // 4. Ouvir por mensagens recebidas enquanto o app está aberto
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });
  }

  // Função para mostrar a notificação local
  void _showLocalNotification(RemoteNotification notification) {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // ID do canal
      'Notificações Importantes', // Nome do canal
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    _localNotifications.show(
      0,
      notification.title,
      notification.body,
      notificationDetails,
    );
  }
}
