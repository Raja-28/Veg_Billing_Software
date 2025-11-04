# 🔐 PIN Authentication System

## Overview
This application now includes a robust 4-digit PIN authentication system that secures access to the app. Users must enter a PIN to unlock the application every time they start it.

## Features

### ✅ Core Security Features
- **4-digit PIN protection** - Simple yet secure authentication
- **Encrypted storage** - PIN is hashed using SHA-256 and stored securely
- **Brute force protection** - Maximum 5 attempts before lockout
- **Auto-lockout** - 5-minute lockout after failed attempts
- **First-time setup** - Guided PIN creation for new users
- **PIN change** - Users can change their PIN anytime
- **Lock button** - Manually lock the app when needed

### 🎯 User Experience
- **Clean UI** - Modern, intuitive PIN entry interface
- **Visual feedback** - PIN dots show entry progress
- **Error messages** - Clear feedback for incorrect attempts
- **Attempt counter** - Shows remaining attempts
- **Lockout timer** - Displays remaining lockout time

## How It Works

### First Time Setup
1. **Launch the app** - First-time users are redirected to PIN setup
2. **Create PIN** - Enter a 4-digit PIN
3. **Confirm PIN** - Re-enter the PIN to confirm
4. **Access granted** - Automatically logged in after setup

### Daily Usage
1. **Launch the app** - Redirected to PIN lock screen
2. **Enter PIN** - Type your 4-digit PIN
3. **Access granted** - Redirected to dashboard on success
4. **Lock manually** - Click "Lock App" in the navigation footer

### Changing PIN
1. **Navigate to PIN Settings** - Click "PIN Settings" in footer
2. **Enter current PIN** - Verify your identity
3. **Enter new PIN** - Create a new 4-digit PIN
4. **Confirm new PIN** - Re-enter to confirm
5. **Success** - PIN updated and saved securely

## Security Implementation

### Storage
- **Hashing**: PIN is hashed using SHA-256 before storage
- **Secure Storage**: Uses `flutter_secure_storage` for encrypted storage
- **No plaintext**: PIN is never stored in plaintext

### Brute Force Protection
- **Attempt limit**: Maximum 5 incorrect attempts
- **Lockout duration**: 5 minutes after max attempts
- **Counter reset**: Resets after successful authentication

### Authentication Flow
```
App Launch
    ↓
Is PIN Set?
    ├─ No → PIN Setup Screen
    │           ↓
    │       Create & Confirm PIN
    │           ↓
    └─ Yes → PIN Lock Screen
                ↓
            Enter PIN
                ↓
            Verify PIN
                ├─ Correct → Dashboard
                └─ Incorrect → Retry (max 5 attempts)
                                    ↓
                                Lockout (5 min)
```

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── pin_auth_service.dart       # Core PIN authentication logic
│   │   └── pin_auth_provider.dart      # Riverpod state management
│   ├── navigation/
│   │   └── router.dart                 # Updated with PIN routes
│   └── app_shell.dart                  # Updated with lock button
├── features/
│   └── auth/
│       ├── pin_setup_screen.dart       # First-time PIN setup
│       ├── pin_lock_screen.dart        # PIN entry/authentication
│       └── pin_settings_screen.dart    # Change PIN
└── main.dart                           # Initialize PIN service
```

## API Reference

### PinAuthService

#### Methods
- `isPinSet()` - Check if PIN is configured
- `setupPin(String pin)` - Create new PIN
- `verifyPin(String pin)` - Verify PIN and track attempts
- `changePin(String oldPin, String newPin)` - Change existing PIN
- `resetPin()` - Clear PIN (admin/recovery)
- `getRemainingAttempts()` - Get remaining attempts before lockout
- `getLockoutRemainingSeconds()` - Get remaining lockout time

### AuthStateProvider

#### States
- `unauthenticated` - User needs to enter PIN
- `authenticated` - User has entered correct PIN
- `locked` - Account locked due to failed attempts

#### Methods
- `authenticate(String pin)` - Authenticate user with PIN
- `lock()` - Lock the app manually
- `unlock()` - Unlock the app (internal use)

## Navigation Routes

- `/pin-setup` - First-time PIN setup screen
- `/pin-lock` - PIN authentication screen
- `/pin-settings` - Change PIN screen
- `/dashboard` - Main app (requires authentication)

## Testing the System

### Test PIN Setup
1. Delete app data to reset
2. Launch app
3. Should redirect to PIN setup
4. Create PIN: `1234`
5. Confirm PIN: `1234`
6. Should redirect to dashboard

### Test PIN Lock
1. Close and reopen app
2. Should show PIN lock screen
3. Enter correct PIN
4. Should unlock and show dashboard

### Test Failed Attempts
1. Enter wrong PIN 5 times
2. Should show lockout message
3. Wait 5 minutes or restart app
4. Counter should reset

### Test PIN Change
1. Navigate to PIN Settings
2. Enter current PIN
3. Enter new PIN
4. Confirm new PIN
5. Should update successfully

## Configuration

### Customize Settings
Edit constants in `pin_auth_service.dart`:

```dart
static const int _maxAttempts = 5;           // Max failed attempts
static const int _lockoutDurationMinutes = 5; // Lockout duration
```

### Disable PIN (Development Only)
To temporarily disable PIN for development:
1. Comment out the redirect logic in `router.dart`
2. Or use `pinAuthService.resetPin()` to clear PIN

## Security Best Practices

### ✅ DO
- Use a unique PIN for each app
- Change PIN regularly
- Lock app when leaving computer
- Keep app updated

### ❌ DON'T
- Share your PIN with others
- Use obvious PINs (1234, 0000)
- Write down your PIN
- Disable security features

## Troubleshooting

### Forgot PIN?
Currently, there's no recovery mechanism. You'll need to:
1. Uninstall the app
2. Reinstall the app
3. Set up a new PIN

**Note**: This will clear all app data.

### App Won't Unlock?
1. Wait for lockout period to expire (5 minutes)
2. Ensure you're entering the correct PIN
3. Check for keyboard input issues
4. Restart the app

### PIN Not Saving?
1. Check storage permissions
2. Ensure sufficient device storage
3. Check app logs for errors

## Future Enhancements

Potential improvements:
- [ ] Biometric authentication (fingerprint/face)
- [ ] PIN recovery via email/security questions
- [ ] Configurable PIN length (4-8 digits)
- [ ] Auto-lock after inactivity
- [ ] PIN strength indicator
- [ ] Multiple user accounts
- [ ] Admin override PIN

## Dependencies

```yaml
flutter_secure_storage: ^9.2.2  # Encrypted storage
crypto: ^3.0.5                   # SHA-256 hashing
shared_preferences: ^2.3.3       # Settings storage
```

## Support

For issues or questions:
1. Check this documentation
2. Review error messages
3. Check app logs
4. Contact support team

---

**Version**: 1.0.0  
**Last Updated**: November 2024  
**Author**: VegBill Development Team
