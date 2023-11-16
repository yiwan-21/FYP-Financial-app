import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../constants/route_name.dart';
import '../components/bill_card.dart';
import '../components/custom_circular_progress.dart';
import '../pages/manage_bill.dart';
import '../services/bill_service.dart';

class Bill extends StatefulWidget {
  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  final Stream<QuerySnapshot> _stream = BillService.getBillStream();
  final double _radius = 90;

  void _addBill() {
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.manageBill,
          arguments: {'isEditing': false});
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const ManageBill(false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 768,
          ),
          child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Bill Yet"),
                  );
                }

                List<BillCard> bills = [];
                int paidBills = 0;
                for (var doc in snapshot.data!.docs) {
                  if (doc['paid']) {
                    paidBills++;
                  }

                  bills.add(BillCard.fromDocument(doc));
                }

                double paidPercentage = paidBills / bills.length;
                if (bills.isEmpty) {
                  paidPercentage = 0;
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 50),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: _radius + 30, bottom: _radius + 20),
                      child: CustomPaint(
                        painter: CustomCircularProgress(
                            value: paidPercentage,
                            strokeWidth: _radius / 10,
                            radius: _radius,
                            startAngle: 3,
                            sweepAngle: 360,
                            heightMultiply: 0.5,
                            widthMultiply: 2,
                            colors: [
                              Colors.deepPurpleAccent[100]!,
                              Colors.deepPurpleAccent[700]!,
                            ]),
                        child: Text(
                          'Paid ${(paidPercentage * 100).toInt()}%',
                          style: const TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Text(
                      '$paidBills / ${bills.length} Bills Paid',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!Constant.isMobile(context)) // if not in mobile view
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: _addBill,
                            child: const Text('Add Bill'),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ...List.generate(bills.length, (index) => bills[index]),
                  ],
                );
              }),
        ),
      ),
      floatingActionButtonLocation: Constant.isMobile(context)
          ? FloatingActionButtonLocation.startFloat
          : null,
      floatingActionButton: Constant.isMobile(context)
          ? FloatingActionButton(
              backgroundColor: ColorConstant.lightBlue,
              onPressed: _addBill,
              child: const Icon(
                Icons.edit_note,
                size: 27,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
