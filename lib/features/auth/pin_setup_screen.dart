import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pin_auth_provider.dart';

/// ==============================
/// 🔐 PIN Setup Screen
/// ==============================
/// First-time PIN setup for new users
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin.add(number);
          if (_pin.length == 4) {
            // Move to confirmation
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _isConfirming = true;
              });
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin.add(number);
          if (_confirmPin.length == 4) {
            _verifyAndSetup();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _errorMessage = '';
      if (!_isConfirming) {
        if (_pin.isNotEmpty) {
          _pin.removeLast();
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin.removeLast();
        }
      }
    });
  }

  Future<void> _verifyAndSetup() async {
    final pinString = _pin.join();
    final confirmPinString = _confirmPin.join();

    if (pinString != confirmPinString) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _pin.clear();
        _confirmPin.clear();
        _isConfirming = false;
      });
      return;
    }

    // Setup PIN
    final service = ref.read(pinAuthServiceProvider);
    final success = await service.setupPin(pinString);

    if (success && mounted) {
      // Authenticate and navigate to dashboard
      ref.read(authStateProvider.notifier).unlock();
      context.go('/dashboard');
    } else {
      setState(() {
        _errorMessage = 'Failed to setup PIN. Please try again.';
        _pin.clear();
        _confirmPin.clear();
        _isConfirming = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _pin.clear();
      _confirmPin.clear();
      _isConfirming = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;
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
                FluentIcons.lock,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _isConfirming ? 'Confirm Your PIN' : 'Setup Your PIN',
                style: typography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _isConfirming
                    ? 'Re-enter your 4-digit PIN'
                    : 'Create a 4-digit PIN to secure your app',
                style: typography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN Dots
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
                      color: index < currentPin.length
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
              const SizedBox(height: 24),

              // Number Pad
              _buildNumberPad(),

              const SizedBox(height: 24),

              // Reset Button
              if (_isConfirming)
                HyperlinkButton(
                  onPressed: _reset,
                  child: const Text('Start Over'),
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
