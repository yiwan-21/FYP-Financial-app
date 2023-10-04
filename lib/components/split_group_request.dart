import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';

class SplitGroupRequest extends StatefulWidget {
  final String groupName;
  final String name;

  const SplitGroupRequest(this.groupName, this.name, {super.key});

  @override
  State<SplitGroupRequest> createState() => _SplitGroupRequestState();
}

class _SplitGroupRequestState extends State<SplitGroupRequest> {
  void _accept() {}
  void _ignore() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: kIsWeb ? 20.0 : 2.0,
        left: kIsWeb ? 40.0 : 10.0,
        right: kIsWeb ? 20.0 : 10.0,
      ),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'from ${widget.name}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Constant.isMobile(context) || Constant.isTablet(context)? const Size(80, 10) : const Size(100, 40) ,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: _accept,
            child: const Text('Accept'),
          ),
          SizedBox(width: Constant.isMobile(context)? 10 : 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              fixedSize: Constant.isMobile(context) || Constant.isTablet(context)? const Size(80, 10) : const Size(100, 40) ,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: _ignore,
            child: const Text(
              'Ignore',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
