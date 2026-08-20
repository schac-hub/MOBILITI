import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/main_screen.dart';
import '../../features/search/results_screen.dart';
import '../../features/search/trip_detail_screen.dart';
import '../../features/search/publish_trip_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/tracking/tracking_screen.dart';
import '../../features/chat/conversations_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const searchResults = '/results';
  static const tripDetail = '/trip-detail';
  static const publish = '/publish';
  static const payment = '/payment';
  static const tracking = '/tracking';
  static const conversations = '/conversations';
  static const chat = '/chat';
  static const profile = '/profile';
  static const settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings s) {
    switch (s.name) {
      case splash:
        return _fade(const SplashScreen());
      case login:
        return _slide(const LoginScreen());
      case register:
        return _slide(const RegisterScreen());
      case main:
        return _fade(const MainScreen());
      case searchResults:
        return _slide(const ResultsScreen());
      case tripDetail:
        final id = s.arguments is String
            ? s.arguments as String
            : (s.arguments as Map?)?['tripId'] as String? ?? '';
        return _slide(TripDetailScreen(tripId: id));
      case publish:
        return _modal(const PublishTripScreen());
      case payment:
        final a = s.arguments as Map<String, dynamic>?;
        return _slide(PaymentScreen(
          tripId: a?['tripId'] as String?,
          amount: (a?['amount'] as num?)?.toDouble(),
        ));
      case tracking:
        final a = s.arguments as Map<String, dynamic>?;
        return _slide(TrackingScreen(
          tripId: a?['tripId'] as String?,
        ));
      case conversations:
        return _slide(const ConversationsScreen());
      case chat:
        final a = s.arguments as Map<String, dynamic>?;
        return _slide(ChatScreen(
          conversationId: a?['conversationId'] as String? ?? '',
          otherUserName: a?['otherUserName'] as String? ?? 'Conducteur',
          otherUserPhoto: a?['otherUserPhoto'] as String?,
        ));
      case profile:
        return _slide(const ProfileScreen());
      case settings:
        return _slide(const SettingsScreen());
      default:
        return _fade(const SplashScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );

  static MaterialPageRoute _slide(Widget page) =>
      MaterialPageRoute(builder: (_) => page);

  static MaterialPageRoute _modal(Widget page) =>
      MaterialPageRoute(builder: (_) => page, fullscreenDialog: true);
}
