import 'package:financial_app/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/home_constant.dart';
import '../components/split_group_card.dart';
import '../models/home_customization.dart';
import '../services/budget_service.dart';
import '../services/home_service.dart';
import '../services/split_money_service.dart';

class HomeSettings extends StatefulWidget {
  const HomeSettings({super.key});

  @override
  State<HomeSettings> createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  final _formKey = GlobalKey<FormState>();
  List<String> _selectedItems = [];
  Future<List<SplitGroupCard>> _groupList = Future.value([]);
  String _selectedGroup = '';
  Future<List<String>> _budgetList = Future.value([]);
  String _selectedBudget = '';

  @override
  void initState() {
    super.initState();
    HomeCustomization customization = Provider.of<HomeProvider>(context, listen: false).customization;
    _selectedItems = customization.items;
    _groupList = SplitMoneyService.getGroupCards();
    _selectedGroup = customization.groupID;
    _selectedBudget = customization.budgetCategory;
    _budgetList = BudgetService.getBudgetCategories();
  }

  void _toggleCheckbox(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _updateHomeItems() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Provider.of<HomeProvider>(context, listen: false).updateDisplayedItems(_selectedItems, _selectedGroup, _selectedBudget);

      await HomeService.updateHomeItems(_selectedItems, _selectedGroup, _selectedBudget).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Settings'),
      ),
      body: Align(
        alignment:
            Constant.isMobile(context) ? Alignment.topCenter : Alignment.center,
        child: Container(
          decoration: Constant.isMobile(context)
              ? null
              : BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38.withOpacity(0.2),
                      offset: const Offset(3, 5),
                      blurRadius: 5.0,
                    )
                  ],
                ),
          width: Constant.isMobile(context) ? null : 600,
          padding: Constant.isMobile(context)
              ? null
              : const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: HomeConstant.homeItems.length,
                    itemBuilder: ((context, index) {
                      final item = HomeConstant.homeItems[index];
                      return CheckboxListTile(
                        title: Text(item),
                        value: _selectedItems.contains(item),
                        onChanged: (bool? value) {
                          _toggleCheckbox(item);
                        },
                      );
                    }),
                  ),
                  const Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Container(
                    height: Constant.isMobile(context) ? null : 70,
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 10,
                      children: _selectedItems.map((selected) {
                        return Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(selected.toString()),
                          onDeleted: () {
                            setState(() {
                              _selectedItems.remove(selected);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  FutureBuilder(
                    future: _groupList,
                    builder: (context, snapshot) {
                      if (!_selectedItems.contains(HomeConstant.recentGroupExpense)) {
                        return SizedBox(height: Constant.isMobile(context) ? null : 72);
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading groups'));
                      }
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No groups found'));
                      }

                      List<SplitGroupCard> groupList = snapshot.data!;
                      if (_selectedGroup.isEmpty || !groupList.any((group) => group.groupID == _selectedGroup)) {
                        _selectedGroup = groupList[0].groupID; // default to first group
                      }
                      return DropdownButtonFormField<String>(
                              value: _selectedGroup,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGroup = value!;
                                });
                              },
                              items: groupList
                                  .map((group) => DropdownMenuItem(
                                        value: group.groupID,
                                        child: Text(group.groupName),
                                      ))
                                  .toList(),
                              padding: const EdgeInsets.all(8.0),
                              decoration: const InputDecoration(
                                labelText: 'Select Group to track expenses',
                                labelStyle: TextStyle(color: Colors.black),
                                fillColor: Colors.white,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1),
                                ),
                              ),
                            );
                    }
                  ),
                  FutureBuilder(
                    future: _budgetList,
                    builder: (context, snapshot) {
                      if (!_selectedItems.contains(HomeConstant.budget)) {
                        return SizedBox(height: Constant.isMobile(context) ? null : 72);
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading budgets'));
                      }
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No budgets found'));
                      }

                      List<String> budgetList = snapshot.data!;
                      if (_selectedBudget.isEmpty || !budgetList.contains(_selectedBudget)) {
                        _selectedBudget = budgetList[0];
                      }
                      return DropdownButtonFormField<String>(
                              value: _selectedBudget,
                              onChanged: (value) {
                                setState(() {
                                  _selectedBudget = value!;
                                });
                              },
                              items: budgetList
                                  .map((budget) => DropdownMenuItem(
                                        value: budget,
                                        child: Text(budget),
                                      ))
                                  .toList(),
                              padding: const EdgeInsets.all(8.0),
                              decoration: const InputDecoration(
                                labelText: 'Select Budget Category',
                                labelStyle: TextStyle(color: Colors.black),
                                fillColor: Colors.white,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1),
                                ),
                              ),
                            );
                    }
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    margin:
                        const EdgeInsets.only(right: 10, bottom: 10, top: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: _updateHomeItems,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
