import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../pages/manage_debt.dart';
import '../constants/constant.dart';
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
  final Stream<QuerySnapshot> _stream = DebtService.getDebtStream();
  double _surplus = 0;

  void _addDebt() {
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.manageDebt,
          arguments: {'isEditing': false});
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const ManageDebt(false);
        },
      );
    }
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
                                'Balance from the total income deduct the total expenses from tracker in this month',
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: Duration(seconds: 5),
                            child: Icon(Icons.info_outline_rounded, size: 20),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _surplus > 0
                                ? 'Surplus: ${_surplus.toStringAsFixed(2)}'
                                : 'Deficit: ${(_surplus * -1).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (!Constant.isMobile(context))
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: _addDebt,
                          child: const Text('Add Debt'),
                        ),
                      ),
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
      floatingActionButtonLocation: Constant.isMobile(context)
          ? FloatingActionButtonLocation.startFloat
          : null,
      floatingActionButton: Constant.isMobile(context)
          ? FloatingActionButton(
              backgroundColor: ColorConstant.lightBlue,
              onPressed: _addDebt,
              child: const Icon(
                Icons.add,
                size: 27,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
