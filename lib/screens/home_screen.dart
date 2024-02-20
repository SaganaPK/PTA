import 'package:flutter/material.dart';
import 'record_expense_screen.dart';
import 'show_product_details_screen.dart';

class home_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => record_expense_screen()),
                );
              },
              child: Text('Record an Expense'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => show_product_details_screen()),
                );
              },
              child: Text('Show Product Details'),
            ),
          ],
        ),
      ),
    );
  }
}