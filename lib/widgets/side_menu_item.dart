import 'package:flutter/material.dart';
import '../../widgets/horizontal_menu_item.dart';
import '../../widgets/vertical_menu_item.dart';

import '../helpers/responsiveness.dart';


class SideMenuItem extends StatelessWidget {
  const SideMenuItem({ 
    Key? key,
    required this.itemName,
    required this.onTap 
  }) : super(key: key);

  final String itemName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if(ResponsiveWidget.isCustomScreen(context)){
      return VerticalMenuItem(itemName: itemName, onTap: onTap,);
    }else{
      return HorizontalMenuItem(itemName: itemName, onTap: onTap,);
    }
  }
}