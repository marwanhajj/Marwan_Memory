import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Abstract interface for handling security aspects like authentication and authorization.
abstract class SecurityInterface {
  /// Authenticates the user using local device credentials (biometrics, passcode).
  Future<bool> authenticateUser(String reason);

  /// Checks if the device supports local authentication.
  Future<bool> canAuthenticate();

  // Potential future methods:
  // Future<bool> authorizeAction(String action);
  // Future<bool> grantPermissionToUser(String userId, String permission);
}

/// Implementation using the local_auth plugin.
class SecurityService implements SecurityInterface {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> canAuthenticate() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      print("Error checking authentication availability: $e");
      return false;
    }
  }

  @override
  Future<bool> authenticateUser(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason, // Displayed to the user
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep auth prompt open until success/failure
          biometricOnly: false, // Allow passcode/pattern as well
        ),
      );
    } on PlatformException catch (e) {
      print("Authentication error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      print("Unexpected authentication error: $e");
      return false;
    }
  }
}

