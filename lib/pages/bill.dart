import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../constants/route_name.dart';
import '../constants/tour_example.dart';
import '../components/bill_card.dart';
import '../components/showcase_frame.dart';
import '../components/custom_circular_progress.dart';
import '../pages/manage_bill.dart';
import '../providers/show_case_provider.dart';
import '../services/bill_service.dart';

class Bill extends StatefulWidget {
  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  final Stream<QuerySnapshot> _stream = BillService.getBillStream();
  final double _radius = 90;

  bool get _isMobile => Constant.isMobile(context);
  final List<GlobalKey> _webKeys = [
    GlobalKey(),
    GlobalKey(),
  ];
  final List<GlobalKey> _mobileKeys = [
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
        _mobileKeys.add(showcaseProvider.navMoreKey);
        _mobileKeys.add(showcaseProvider.navDebtKey);
        _webKeys.add(showcaseProvider.navMoreKey);
        _webKeys.add(showcaseProvider.navDebtKey);
        if (_isMobile) {
          ShowCaseWidget.of(context).startShowCase(_mobileKeys);
          _showcasingWebView = false;
        } else {
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
        setState(() {
          _runningShowcase = true;
        });
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
  
  void _addBill() {
    if (_isMobile && !kIsWeb) {
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
              int totalBills = 0;
              int paidBills = 0;
              double paidPercentage = 0;
              List<BillCard> bills = [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                for (var doc in snapshot.data!.docs) {
                  if (doc['paid']) {
                    paidBills++;
                  }

                  bills.add(BillCard.fromDocument(doc));
                }
                totalBills = snapshot.data!.docs.length;
                paidPercentage = paidBills / totalBills;
              }
              return ListView(
                cacheExtent: 1000,
                physics: const BouncingScrollPhysics(),
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                      totalBills == 0
                          ? Container()
                          : Text(
                              '$paidBills / $totalBills Bills Paid',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                      _isMobile
                          ? const SizedBox(height: 20)
                          : Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                child: ShowcaseFrame(
                                  showcaseKey: _webKeys[0],
                                  title: "Bill",
                                  description: "Add your Bill here",
                                  width: 250,
                                  height: 100,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    onPressed: _addBill,
                                    child: const Text('Add Bill'),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ShowcaseFrame(
                    showcaseKey: _isMobile? _mobileKeys[1] : _webKeys[1],
                    title: "Data Created",
                    description: "View your bill detail and history here",
                    width: 300,
                    height: 100,
                    tooltipPosition: TooltipPosition.top,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 50),
                      children: List.generate(
                        _runningShowcase ? 1 : bills.length, 
                        (index) {
                          if (_runningShowcase) {
                            return TourExample.bill;
                          }
                          return bills[index];
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: _isMobile
          ? FloatingActionButtonLocation.startFloat
          : null,
      floatingActionButton: _isMobile
          ? ShowcaseFrame(
              showcaseKey: _mobileKeys[0],
              title: "Bill",
              description: "Add your Bill here",
              width: 200,
              height: 100,
              child: FloatingActionButton(
                backgroundColor: ColorConstant.lightBlue,
                onPressed: _addBill,
                child: const Icon(
                  Icons.edit_note,
                  size: 27,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }
}
