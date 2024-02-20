import 'package:flutter/material.dart';

class quantity_selection extends StatefulWidget {
  final void Function(String, String) onSelectionChanged;

  quantity_selection({required this.onSelectionChanged});
  @override
  quantity_selectionState createState() =>
      quantity_selectionState();
}
class quantity_selectionState extends State<quantity_selection>{

  String selectedUnitType = 'Liquid';
  String selectedUnit = 'ml';
  String selectedQuantity = ''; // Add selectedQuantity variable

  List<String> unitTypes = ['Liquid', 'Weight', 'Quantity'];
  Map<String, List<String>> unitsMap = {
    'Liquid': ['ml', 'l', 'fl oz', 'gal'],
    'Weight': ['gm', 'kg', 'oz', 'lb'],
    'Quantity': ['units', 'dz', 'box', 'pack'],
  };

  @override
  Widget build(BuildContext context) {
    return  Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child:TextFormField(
                    onChanged: (value) {
                      setState(() {
                        selectedQuantity = value; // Update selectedQuantity
                      });
                      widget.onSelectionChanged(value, selectedUnit);
                    },
                    decoration: InputDecoration(
                      hintText: 'QUANTITY',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedUnitType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUnitType = newValue ?? 'Liquid';
                      // Reset selectedUnit when unit type changes
                      selectedUnit = unitsMap[selectedUnitType]![0];
                    });
                    // Notify the parent widget about the unit change
                    widget.onSelectionChanged(selectedQuantity, selectedUnit);
                  },
                  items: unitTypes
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                ),
                SizedBox(width: 8),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedUnit,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUnit = newValue ?? unitsMap[selectedUnitType]![0];
                    });
                    // Notify the parent widget about the unit change
                    widget.onSelectionChanged(selectedQuantity, selectedUnit);
                  },
                  items: unitsMap[selectedUnitType]!
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                ),
              ],
            ),
          ],
    );
  }
}