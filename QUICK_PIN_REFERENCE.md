# 🔐 Quick PIN Reference

## Launch the App
```bash
flutter run -d macos
```

## First Time Setup
1. App shows **PIN Setup Screen**
2. Enter 4-digit PIN (e.g., `1234`)
3. Confirm PIN
4. ✅ Logged in automatically

## Daily Use
1. Launch app
2. **PIN Lock Screen** appears
3. Enter your PIN
4. ✅ Access granted

## Change PIN
1. Click **"PIN Settings"** in footer
2. Enter current PIN
3. Enter new PIN
4. Confirm new PIN
5. ✅ PIN updated

## Lock App Manually
- Click **"Lock App"** in navigation footer
- PIN required to unlock

## Security Features
- ✅ 4-digit PIN required
- ✅ SHA-256 hashed storage
- ✅ 5 attempts max
- ✅ 5-minute lockout
- ✅ No recovery (by design)

## Forgot PIN?
**Uninstall → Reinstall → Setup new PIN**  
⚠️ This deletes all app data

## Files Created
```
lib/core/services/
  ├── pin_auth_service.dart       # Core logic
  └── pin_auth_provider.dart      # State management

lib/features/auth/
  ├── pin_setup_screen.dart       # First-time setup
  ├── pin_lock_screen.dart        # Authentication
  └── pin_settings_screen.dart    # Change PIN
```

## Routes
- `/pin-setup` - First-time PIN creation
- `/pin-lock` - Authentication screen
- `/pin-settings` - Change PIN
- `/dashboard` - Main app (protected)

## Quick Test
```dart
// Reset PIN for testing
final service = ref.read(pinAuthServiceProvider);
await service.resetPin();
```

## Dependencies
```yaml
flutter_secure_storage: ^9.2.2
crypto: ^3.0.5
shared_preferences: ^2.3.3
```

---
**Status**: ✅ Complete | **Platform**: macOS, iOS, Android
