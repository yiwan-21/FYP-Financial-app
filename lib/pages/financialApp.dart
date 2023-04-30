import 'package:flutter/material.dart';
import '../constants.dart';

class FinancialApp extends StatelessWidget {
  const FinancialApp({super.key});

  Widget _getWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(180, 40)),
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text('Register'),
        ),
        const SizedBox(height: 16.0),
        Hero(
          tag: "login-button",
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 40)),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial App'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _getWidget(context),
        ),
      ),
    );
  }
}
