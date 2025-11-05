import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pin_auth_provider.dart';

/// ==============================
/// 🔐 PIN Settings Screen
/// ==============================
/// Screen for changing or resetting PIN
class PinSettingsScreen extends ConsumerStatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  ConsumerState<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends ConsumerState<PinSettingsScreen> with SingleTickerProviderStateMixin {
  final List<String> _oldPin = [];
  final List<String> _newPin = [];
  final List<String> _confirmPin = [];
  
  int _step = 0; // 0: old PIN, 1: new PIN, 2: confirm new PIN
  String _errorMessage = '';
  String _successMessage = '';
  final FocusNode _focusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
      
      switch (_step) {
        case 0:
          if (_oldPin.length < 4) {
            _oldPin.add(number);
            if (_oldPin.length == 4) {
              _verifyOldPin();
            }
          }
          break;
        case 1:
          if (_newPin.length < 4) {
            _newPin.add(number);
            if (_newPin.length == 4) {
              Future.delayed(const Duration(milliseconds: 300), () {
                setState(() {
                  _step = 2;
                });
              });
            }
          }
          break;
        case 2:
          if (_confirmPin.length < 4) {
            _confirmPin.add(number);
            if (_confirmPin.length == 4) {
              _changePin();
            }
          }
          break;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
      
      switch (_step) {
        case 0:
          if (_oldPin.isNotEmpty) _oldPin.removeLast();
          break;
        case 1:
          if (_newPin.isNotEmpty) _newPin.removeLast();
          break;
        case 2:
          if (_confirmPin.isNotEmpty) _confirmPin.removeLast();
          break;
      }
    });
  }

  Future<void> _verifyOldPin() async {
    final oldPinString = _oldPin.join();
    final service = ref.read(pinAuthServiceProvider);
    final isValid = await service.verifyPin(oldPinString);

    if (isValid) {
      setState(() {
        _step = 1;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
        _oldPin.clear();
      });
    }
  }

  Future<void> _changePin() async {
    final newPinString = _newPin.join();
    final confirmPinString = _confirmPin.join();

    if (newPinString != confirmPinString) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _newPin.clear();
        _confirmPin.clear();
        _step = 1;
      });
      return;
    }

    final oldPinString = _oldPin.join();
    final service = ref.read(pinAuthServiceProvider);
    final success = await service.changePin(oldPinString, newPinString);

    if (success) {
      setState(() {
        _successMessage = 'PIN changed successfully!';
      });
      
      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to change PIN. Please try again.';
        _oldPin.clear();
        _newPin.clear();
        _confirmPin.clear();
        _step = 0;
      });
    }
  }

  void _reset() {
    setState(() {
      _oldPin.clear();
      _newPin.clear();
      _confirmPin.clear();
      _step = 0;
      _errorMessage = '';
      _successMessage = '';
    });
  }

  String _getTitle() {
    switch (_step) {
      case 0:
        return 'Enter Current PIN';
      case 1:
        return 'Enter New PIN';
      case 2:
        return 'Confirm New PIN';
      default:
        return 'Change PIN';
    }
  }

  String _getSubtitle() {
    switch (_step) {
      case 0:
        return 'Enter your current 4-digit PIN';
      case 1:
        return 'Create a new 4-digit PIN';
      case 2:
        return 'Re-enter your new PIN';
      default:
        return '';
    }
  }

  List<String> _getCurrentPin() {
    switch (_step) {
      case 0:
        return _oldPin;
      case 1:
        return _newPin;
      case 2:
        return _confirmPin;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;
    final currentPin = _getCurrentPin();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey.keyLabel.length == 1) {
            final char = event.logicalKey.keyLabel;
            if (RegExp(r'^[0-9]$').hasMatch(char)) {
              _onNumberPressed(char);
            }
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace();
          } else if (event.logicalKey == LogicalKeyboardKey.enter && currentPin.length == 4) {
            if (_step == 0) _verifyOldPin();
            else if (_step == 2) _changePin();
          }
        }
      },
      child: ScaffoldPage(
        header: PageHeader(
          title: const Text('Change PIN'),
          commandBar: CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.back),
                label: const Text('Back'),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.05),
                Colors.green.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Lock Icon
              Icon(
                FluentIcons.permissions,
                size: 64,
                color: _successMessage.isNotEmpty ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _successMessage.isNotEmpty ? 'Success!' : _getTitle(),
                style: typography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _successMessage.isNotEmpty ? _successMessage : _getSubtitle(),
                style: typography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN Dots
              if (_successMessage.isEmpty)
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
                            ? Colors.blue
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

              // Success Message
              if (_successMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.completed_solid,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage,
                          style: typography.body?.copyWith(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Number Pad
              if (_successMessage.isEmpty) _buildNumberPad(),

              const SizedBox(height: 24),

              // Reset Button
              if (_step > 0 && _successMessage.isEmpty)
                HyperlinkButton(
                  onPressed: _reset,
                  child: const Text('Start Over'),
                ),
              ],
            ),
          ),
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
