import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/user/auth_widgets/location_status_card.dart';

class UserAuthorizationScreen extends StatefulWidget {
  const UserAuthorizationScreen({super.key});

  @override
  State<UserAuthorizationScreen> createState() =>
      _UserAuthorizationScreenState();
}

class _UserAuthorizationScreenState extends State<UserAuthorizationScreen> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      _authProvider.updateState(message: '위치 권한이 필요합니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
        title: const Text(
          '현지인 인증',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.verylightGray,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkGray),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pop(
                context,
                context.read<AuthProvider>().currentPosition != null,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Consumer<AuthProvider>(
                builder:
                    (context, auth, _) => LocationStatusCard(
                      currentPosition: auth.currentPosition,
                      message: auth.locationMessage,
                      isLoading: auth.isLoading,
                      onPressed: () => auth.getCurrentLocation(context),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
