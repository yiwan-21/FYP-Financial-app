import 'package:flutter/material.dart';

import '../components/bill_card.dart';
import '../components/custom_circular_progress.dart';
import '../constants/style_constant.dart';

class Bill extends StatefulWidget {
  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  double value = 0.75;
  double radius = 90;

  void _addBill() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 50),
        children: [
          Padding(
            padding: EdgeInsets.only(top: radius + 30, bottom: radius + 20),
            child: CustomPaint(
              painter: CustomCircularProgress(
                value: value,
                strokeWidth: radius / 10,
                radius: radius,
                startAngle: 3,
                sweepAngle: 360,
                heightMultiply: 0.5,
                widthMultiply: 2,
                colors: [
                  Colors.deepPurpleAccent[100]!,
                  Colors.deepPurpleAccent[700]!,
                ]
              ),
              child: Text(
                'Paid ${(value * 100).toInt()}%',
                style: const TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Text(
            'RM 1200 / 1600',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const BillCard('Rental', 600, true, 5),
          const BillCard('Water', 8, false, 3),
          const BillCard('Internet', 52, true, 15),
          const BillCard('Rental', 600, true, 7),
          const BillCard('Water', 8, false, 20),
          const BillCard('Internet', 52, true, 30),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightBlue,
        onPressed: _addBill,
        child: const Icon(
          Icons.edit_note,
          size: 27,
          color: Colors.black,
        ),
      ),
    );
  }
}
