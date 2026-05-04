import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/chat_viewmodel.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';

import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/auth/presentation/screens/username_setup_screen.dart';
import 'features/auth/identify_screen.dart';
import 'features/home/home_screen.dart';
import 'features/chat/conversation_screen.dart';
import 'features/chat/new_message_screen.dart';
import 'features/chat/chat_folders_screen.dart';
import 'features/chat/saved_messages_screen.dart';
import 'features/settings/appearance_screen.dart';
import 'features/settings/chat_wallpapers_screen.dart';
import 'features/settings/account_screen.dart';
import 'features/settings/privacy_screen.dart';
import 'features/settings/security_screen.dart';
import 'features/settings/notification_screen.dart';
import 'features/settings/data_storage_screen.dart';
import 'features/settings/active_sessions_screen.dart';
import 'features/settings/help_screen.dart';
import 'features/profile/qr_code_screen.dart';
import 'features/profile/edit_info_screen.dart';
import 'features/profile/user_profile_screen.dart';
import 'features/groups/create_group_screen.dart';
import 'features/channels/create_channel_screen.dart';
import 'features/calls/call_history_screen.dart';

import 'presentation/viewmodels/theme_viewmodel.dart';

void main() {
  final authRepo = AuthRepositoryImpl();
  final chatRepo = ChatRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo)),
        ChangeNotifierProvider(create: (_) => ChatViewModel(chatRepo)),
      ],
      child: const PingMeApp(),
    ),
  );
}

class PingMeApp extends StatelessWidget {
  const PingMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = Provider.of<ThemeViewModel>(context);
    
    return MaterialApp(
      title: 'Ping Me',
      debugShowCheckedModeBanner: false,
      themeMode: themeVM.currentMode == AppThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,
      theme: WireTheme.light,
      darkTheme: themeVM.currentMode == AppThemeMode.defaultTheme
          ? WireTheme.defaultTheme
          : WireTheme.dark,
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/welcome':
            return MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            );
          case '/appearance':
            return MaterialPageRoute(
              builder: (context) => const AppearanceScreen(),
            );
          case '/chat_wallpapers':
            return MaterialPageRoute(
              builder: (context) => const ChatWallpapersScreen(),
            );
          case '/identify':
            final method = settings.arguments as String? ?? 'phone';
            return MaterialPageRoute(builder: (context) => IdentifyScreen(method: method));
          case '/otp':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => OtpScreen(
                identifier: args['identifier'],
                method: args['method'],
              ),
            );
          case '/username':
            return MaterialPageRoute(builder: (context) => const UsernameSetupScreen());
          case '/chats':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/conversation':
            final args = settings.arguments as String;
            return MaterialPageRoute(builder: (context) => ConversationScreen(nodeName: args));
          case '/new_message':
            return MaterialPageRoute(builder: (context) => const NewMessageScreen());
          case '/chat_folders':
            return MaterialPageRoute(builder: (context) => const ChatFoldersScreen());
          case '/qr_code':
            return MaterialPageRoute(builder: (context) => const QrCodeScreen());
          case '/edit_info':
            return MaterialPageRoute(builder: (context) => const EditInfoScreen());
          case '/create_group':
            return MaterialPageRoute(builder: (context) => const CreateGroupScreen());
          case '/create_channel':
            return MaterialPageRoute(builder: (context) => const CreateChannelScreen());
          case '/call_history':
            return MaterialPageRoute(builder: (context) => const CallHistoryScreen());
          case '/saved_messages':
            return MaterialPageRoute(builder: (context) => const SavedMessagesScreen());
          case '/account':
            return MaterialPageRoute(builder: (context) => const AccountScreen());
          case '/privacy':
            return MaterialPageRoute(builder: (context) => const PrivacyScreen());
          case '/security':
            return MaterialPageRoute(builder: (context) => const SecurityScreen());
          case '/notifications':
            return MaterialPageRoute(builder: (context) => const NotificationScreen());
          case '/data_storage':
            return MaterialPageRoute(builder: (context) => const DataStorageScreen());
          case '/active_sessions':
            return MaterialPageRoute(builder: (context) => const ActiveSessionsScreen());
          case '/help':
            return MaterialPageRoute(builder: (context) => const HelpScreen());
          case '/user_profile':
            final userName = settings.arguments as String;
            return MaterialPageRoute(builder: (context) => UserProfileScreen(userName: userName));
          default:
            return null;
        }
      },
    );
  }
}
