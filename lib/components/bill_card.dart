import 'package:flutter/material.dart';

import '../constants/style_constant.dart';

class BillCard extends StatefulWidget {
  final String title;
  final double amount;
  final bool paid;
  final int dueIn;
  
  const BillCard(this.title, this.amount, this.paid, this.dueIn, {super.key});

  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  void _editBill() {}

  void _payBill() {}
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title, 
                      style: const TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Due in ${widget.dueIn} days',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      )  
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'RM ${widget.amount.toStringAsFixed(2)}', 
                      style: const TextStyle(
                        fontWeight: FontWeight.w500, 
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: widget.paid? Colors.greenAccent[700] : Colors.grey[300],
                      child: widget.paid ? const Icon (
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ) 
                      : null,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Divider(thickness: 0.5,),
            ),
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Past Bills',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          'Aug',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )  
                        ),
                        SizedBox(width: 30),
                        Text(
                          'RM 55000',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )  
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          'July',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )  
                        ),
                        SizedBox(width: 30),
                        Text(
                          'RM 800',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )  
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(const Size(80, 20)),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _editBill, 
                      child: const Text(
                        'Edit Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(const Size(80, 20)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: MaterialStateProperty.all<Color>(widget.paid ? Colors.grey[400]! : lightRed),
                      ),
                      onPressed: widget.paid? null : _payBill, 
                      child: Text(
                        widget.paid? 'Paid':'Pay Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
