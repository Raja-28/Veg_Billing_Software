import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pin_auth_provider.dart';

/// ==============================
/// 🔐 PIN Lock Screen
/// ==============================
/// Authentication screen for returning users
class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final List<String> _pin = [];
  String _errorMessage = '';
  int _remainingAttempts = 5;
  bool _isLocked = false;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _checkLockoutStatus();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLockoutStatus() async {
    final service = ref.read(pinAuthServiceProvider);
    final lockoutSeconds = await service.getLockoutRemainingSeconds();
    
    if (lockoutSeconds > 0) {
      setState(() {
        _isLocked = true;
        _lockoutSeconds = lockoutSeconds;
      });
      _startLockoutTimer();
    } else {
      final remaining = await service.getRemainingAttempts();
      setState(() {
        _remainingAttempts = remaining;
      });
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockoutSeconds--;
        if (_lockoutSeconds <= 0) {
          _isLocked = false;
          _remainingAttempts = 5;
          timer.cancel();
        }
      });
    });
  }

  void _onNumberPressed(String number) {
    if (_isLocked) return;

    setState(() {
      _errorMessage = '';
      if (_pin.length < 4) {
        _pin.add(number);
        if (_pin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  void _onBackspace() {
    if (_isLocked) return;

    setState(() {
      _errorMessage = '';
      if (_pin.isNotEmpty) {
        _pin.removeLast();
      }
    });
  }

  Future<void> _verifyPin() async {
    final pinString = _pin.join();
    final authNotifier = ref.read(authStateProvider.notifier);
    final success = await authNotifier.authenticate(pinString);

    if (success && mounted) {
      // Navigate to dashboard
      context.go('/dashboard');
    } else {
      final service = ref.read(pinAuthServiceProvider);
      final remaining = await service.getRemainingAttempts();
      final lockoutSeconds = await service.getLockoutRemainingSeconds();

      setState(() {
        _pin.clear();
        _remainingAttempts = remaining;
        
        if (lockoutSeconds > 0) {
          _isLocked = true;
          _lockoutSeconds = lockoutSeconds;
          _errorMessage = 'Too many attempts. Account locked.';
          _startLockoutTimer();
        } else {
          _errorMessage = remaining > 0
              ? 'Incorrect PIN. $remaining attempts remaining.'
              : 'Account locked. Please wait.';
        }
      });
    }
  }

  String _formatLockoutTime() {
    final minutes = _lockoutSeconds ~/ 60;
    final seconds = _lockoutSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    return ScaffoldPage(
      content: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Lock Icon
              Icon(
                _isLocked ? FluentIcons.lock_solid : FluentIcons.lock,
                size: 64,
                color: _isLocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _isLocked ? 'Account Locked' : 'Enter Your PIN',
                style: typography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _isLocked
                    ? 'Please wait ${_formatLockoutTime()}'
                    : 'Enter your 4-digit PIN to unlock',
                style: typography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN Dots
              if (!_isLocked)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pin.length
                            ? Colors.green
                            : Colors.grey[60],
                        border: Border.all(
                          color: Colors.grey[100],
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.error_badge,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: typography.body?.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Remaining Attempts
              if (!_isLocked && _remainingAttempts < 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Remaining attempts: $_remainingAttempts',
                    style: typography.caption?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Number Pad
              if (!_isLocked) _buildNumberPad(),

              // Lockout Message
              if (_isLocked)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        FluentIcons.warning,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Too many failed attempts',
                        style: typography.subtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your account has been temporarily locked for security reasons.',
                        style: typography.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 12),
        // Row 4: empty, 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80, height: 60), // Empty space
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 70,
      height: 60,
      child: Button(
        onPressed: () => _onNumberPressed(number),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.grey[20]),
        ),
        child: Text(
          number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 70,
      height: 60,
      child: Button(
        onPressed: _onBackspace,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.grey[20]),
        ),
        child: const Icon(FluentIcons.back, size: 20),
      ),
    );
  }
}
