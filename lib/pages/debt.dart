import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/tour_example.dart';
import '../pages/manage_debt.dart';
import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../components/debt_card.dart';
import '../components/showcase_frame.dart';
import '../providers/show_case_provider.dart';
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
  
  bool get _isMobile => Constant.isMobile(context);
  final List<GlobalKey> _webKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  final List<GlobalKey> _mobileKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  bool _showcasingWebView = false;
  bool _runningShowcase = false;

  @override
  void initState() {
    super.initState();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (showcaseProvider.isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mobileKeys.add(showcaseProvider.endTourKey);
        _webKeys.add(showcaseProvider.endTourKey);
        if (_isMobile) {
          ShowCaseWidget.of(context).startShowCase(_mobileKeys);
          _showcasingWebView = false;
        } else {
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
        _runningShowcase = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (kIsWeb && showcaseProvider.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_showcasingWebView && _isMobile) {
          // If the showcase is running on web and the user switches to mobile view
          await Future.delayed(const Duration(milliseconds: 300)).then((_) {
            ShowCaseWidget.of(context).startShowCase(_mobileKeys);
            _showcasingWebView = false;
          });
        } else if (!_showcasingWebView && !_isMobile) {
          // If the showcase is running on mobile and the user switches to web view
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
      });
    }
  }
  
  void _addDebt() {
    if (_isMobile && !kIsWeb) {
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
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ShowcaseFrame(
                  showcaseKey: _isMobile? _mobileKeys[0] : _webKeys[0],
                  title: "Debt",
                  description: "Calculate Surplus or Deficit for current month",
                  width: 350,
                  height: 100,
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
              ),
              _surplus != 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Tooltip(
                        message: 'Balance from the total income deduct the total expenses from tracker in this month',
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
                  )
                : Container(),
              const SizedBox(height: 20),
              _isMobile
                ? Container()
                : Container(
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    child: ShowcaseFrame(
                      showcaseKey: _webKeys[1],
                      title: 'Add Debt',
                      description: 'Click here to add new debt',
                      width: 200,
                      height: 100,
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
                  ),
              StreamBuilder<QuerySnapshot>(
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
                  if (!_runningShowcase) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No Debt Yet"),
                      );
                    }
                  }

                  List<DebtCard> debts = [];
                  for (var doc in snapshot.data!.docs) {
                    debts.add(DebtCard.fromDocument(doc));
                  }

                  return ShowcaseFrame(
                    showcaseKey: _isMobile? _mobileKeys[2] : _webKeys[2],
                    title: "Data Created",
                    description: "View your debt detail and debt payment history here",
                    width: 350,
                    height: 100,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 50),
                      itemCount: _runningShowcase ? 1 : debts.length,
                      itemBuilder: (context, index) {
                        if (_runningShowcase) {
                          return TourExample.debt;
                        }
                        return debts[index];
                      },
                      separatorBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Divider(height: 20),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: _isMobile
          ? FloatingActionButtonLocation.startFloat
          : null,
      floatingActionButton: _isMobile
          ? ShowcaseFrame(
              showcaseKey: _mobileKeys[1],
              title: 'Add Debt',
              description: 'Click here to add new debt',
              width: 200,
              height: 100,
              child: FloatingActionButton(
                backgroundColor: ColorConstant.lightBlue,
                onPressed: _addDebt,
                child: const Icon(
                  Icons.add,
                  size: 27,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }
}
