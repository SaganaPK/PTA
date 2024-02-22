import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class show_product_details_screen extends StatefulWidget {
  @override
  _show_product_details_screen createState() => _show_product_details_screen();
}

class _show_product_details_screen extends State<show_product_details_screen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = ""; // Variable to hold search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Update search query and refresh UI
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                List<DocumentSnapshot> documents = snapshot.data!.docs;

                // Filter product names based on search query
                Set<String> uniqueProductNames = {};
                for (var document in documents) {
                  String productName = document['name'];
                  if (searchQuery.isEmpty || productName.toLowerCase().contains(searchQuery)) {
                    uniqueProductNames.add(productName);
                  }
                }

                List<String> productNameList = uniqueProductNames.toList();

                return ListView.builder(
                  itemCount: productNameList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(productNameList[index]),
                      // Optionally, add onTap to navigate or perform actions
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}