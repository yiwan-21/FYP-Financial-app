import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/add_group.dart';
import '../components/split_group_card.dart';
import '../constants/style_constant.dart';
import '../providers/total_split_money_provider.dart';

class SplitMoney extends StatefulWidget {
  const SplitMoney({super.key});

  @override
  State<SplitMoney> createState() => _SplitMoneyState();
}

class _SplitMoneyState extends State<SplitMoney> {
  void addGroup() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AddGroup();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<TotalSplitMoneyProvider>(
            builder: (context, totalSplitMoneyProvider, _) {
              List<SplitGroupCard> groupCards =
                  totalSplitMoneyProvider.groupCards;
              return ListView(
                children: List.generate(
                  groupCards.length,
                  (index) {
                    return groupCards[index];
                  },
                ),
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.only(bottom: 20, right: 10),
          child: FloatingActionButton(
            backgroundColor: ColorConstant.lightBlue,
            onPressed: addGroup,
            child: const Icon(
              Icons.group_add_outlined,
              size: 27,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
