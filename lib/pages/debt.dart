import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../components/debt_card.dart';
import '../services/debt_service.dart';
import '../services/transaction_service.dart';

class Debt extends StatefulWidget {
  const Debt({super.key});

  @override
  State<Debt> createState() => _DebtState();
}

class _DebtState extends State<Debt> {
  double _surplus = 0;

  void _addDebt() {
    Navigator.pushNamed(context, RouteName.manageDebt,
        arguments: {'isEditing': false});
  }

  Future<void> _calSurplus() async {
    if (_surplus == 0) {
      // calculate surplus
      await TransactionService.calSurplus().then((surplus) {
        setState(() {
          _surplus = surplus;
        });
      });
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
              stream: DebtService.getDebtStream(),
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
                    child: Text("No Debt Yet"),
                  );
                }
        
                List<DebtCard> debts = [];
                for (var doc in snapshot.data!.docs) {
                  debts.add(DebtCard.fromDocument(doc));
                }
        
                return ListView(
                  children: [
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: _calSurplus,
                        child: const Text(
                          'Calculate Savings',
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    if (_surplus != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Tooltip(
                            message:
                                'Surplus: Balance from the total income deduct the total expenses from tracker in this month',
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: Duration(seconds: 5),
                            child: Icon(Icons.info_outline_rounded, size: 20),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Surplus: ${_surplus.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    if (_surplus != 0) const SizedBox(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 50),
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        return debts[index];
                      },
                      separatorBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Divider(height: 20),
                        );
                      },
                    ),
                  ],
                );
              }),
        ),
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
