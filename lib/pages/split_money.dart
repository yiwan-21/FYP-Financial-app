import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/total_split_money_provider.dart';
import '../constants/style_constant.dart';

class SplitMoney extends StatefulWidget {
  const SplitMoney({super.key});

  @override
  State<SplitMoney> createState() => _SplitMoneyState();
}

class _SplitMoneyState extends State<SplitMoney> {
  void addGroup() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<TotalSplitMoneyProvider>(
            builder: (context, totalSplitMoneyProvider, _) {
              return FutureBuilder(
                future: totalSplitMoneyProvider.getGroups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    return ListView(
                      children: List.generate(
                        snapshot.data!.length,
                        (index) {
                          return snapshot.data![index];
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
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
