import 'package:flutter/material.dart';

class Debt extends StatefulWidget {
  const Debt({super.key});

  @override
  State<Debt> createState() => _DebtState();
}

class _DebtState extends State<Debt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Debt'),
      ),
    );
  }
}