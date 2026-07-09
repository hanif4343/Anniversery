import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'creator_home_screen.dart';

/// Simple PIN-lock so your wife doesn't accidentally open the editing
/// screen if she's poking around the app before the big reveal.
/// First time: lets you SET a PIN. After that: asks to ENTER it.
class CreatorLockScreen extends StatefulWidget {
  const CreatorLockScreen({super.key});

  @override
  State<CreatorLockScreen> createState() => _CreatorLockScreenState();
}

class _CreatorLockScreenState extends State<CreatorLockScreen> {
  final _pinController = TextEditingController();
  final _storage = StorageService();
  String? _error;

  void _submit() {
    final entered = _pinController.text.trim();
    if (entered.isEmpty) return;

    if (!_storage.hasSetPin) {
      // First run: set this as the PIN.
      _storage.setCreatorPin(entered);
      _goToCreatorHome();
      return;
    }

    if (entered == _storage.getCreatorPin()) {
      _goToCreatorHome();
    } else {
      setState(() => _error = 'ভুল পিন, আবার চেষ্টা করুন');
    }
  }

  void _goToCreatorHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreatorHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirstTime = !_storage.hasSetPin;
    return Scaffold(
      backgroundColor: const Color(0xFF1B1029),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                isFirstTime ? 'একটা পিন সেট করুন (Creator Mode)' : 'Creator Mode পিন দিন',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isFirstTime ? 'পিন সেট করো' : 'প্রবেশ করো'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
