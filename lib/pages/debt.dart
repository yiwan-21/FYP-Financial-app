import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../components/debt_card.dart';

class Debt extends StatefulWidget {
  const Debt({super.key});

  @override
  State<Debt> createState() => _DebtState();
}

class _DebtState extends State<Debt> {
  void _addDebt() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 50),
        itemCount: 5,
        itemBuilder: (context, index) {
          return DebtCard('Debt $index', index * 80, index.toDouble(), index * 80);
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Divider(height: 20),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightBlue,
        onPressed: _addDebt,
        child: const Icon(
          Icons.add,
          size: 27,
          color: Colors.black,
        ),
      ),
    );
  }
}
