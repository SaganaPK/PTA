import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:PTA/utils/date_utils.dart';
import 'package:intl/intl.dart';
import 'package:PTA/utils/quantity_selection.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../model/product.dart';

class record_expense_screen extends StatefulWidget  {
  @override
  record_expense_screen_state createState() => record_expense_screen_state();
}

class record_expense_screen_state extends State<record_expense_screen> {
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
//  final TextEditingController _priceController = TextEditingController();

  String productName = '';
  String storeName = '';
  double productPrice = 0.0;
  DateTime selectedDate = DateTime.now();
  String selectedQuantity = '';
  String selectedQuantityUnit = '';

  List<String> productSuggestions = []; // Add product names from Firestore
  List<String> storeSuggestions = [];   // Add store names from Firestore

  @override
  void initState() {
    super.initState();
    _productNameController.addListener(_onProductTextChanged);
    _storeNameController.addListener(_onStoreTextChanged);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  void _onProductTextChanged() {
    _fetchSuggestions('products', 'name', _productNameController.text);
  }

  void _onStoreTextChanged() {
    _fetchSuggestions('products', 'store', _storeNameController.text);
  }

  Future<List<String>> _fetchSuggestions(String collection, String field, String enteredText) async {
    enteredText = enteredText.toLowerCase();
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where(field, isGreaterThanOrEqualTo: enteredText)
          .where(field, isLessThanOrEqualTo: enteredText + '\uf8ff')
          .get();

      print('Entered Text : ***** $enteredText *****');

      // Use a Set to store unique suggestions without duplicates
      Set<String> suggestionsSet = {};
      snapshot.docs.forEach((doc) {
        // Add each suggestion to the set
        suggestionsSet.add(doc[field] as String);
      });

     // Convert the set back to a list
      List<String> suggestionsList = suggestionsSet.toList();

      setState(() {
        suggestionsList.clear();
        suggestionsList.addAll(suggestionsSet);
      });
      print('suggestionslist :***** ${suggestionsList.isNotEmpty ? suggestionsList[0] : 'is empty'} *****');

      return suggestionsList;
    } catch (e) {
      print('Error fetching suggestions: $e');
      return[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Enter the new Product'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                // Product text field with suggestions
                TypeAheadField<String?>(
                  suggestionsCallback: (search) async {
                    return await _fetchSuggestions('products','name',search);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion!),
                    );
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      _productNameController.text = suggestion!;
                      productName = suggestion!;
                      productSuggestions.clear(); // Clear suggestions after selection
                    });
                  },
                  builder: (context, controller, focusNode) => TextField(
                    controller: _productNameController,
                    focusNode: focusNode,
                    autofocus: true,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontStyle: FontStyle.italic),
                    decoration: InputDecoration(
                      hintText: 'PRODUCT',
                      labelText: 'Product',
                    ),
                    onChanged: (value) {
                      value = capitalize(value);
                      // Set productName to the manually entered value
                      productName = value;
                    },
                  ),
                ),
                // Display product suggestions
                if (productSuggestions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productSuggestions
                        .map((suggestion) => ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        setState(() {
                          _productNameController.text = suggestion;
                          productSuggestions.clear();
                        });
                      },
                    ))
                        .toList(),
                  ),
                // Quantity text field
                SizedBox(height: 10),
                quantity_selection(
                  onSelectionChanged: (quantity, unit) {
                    selectedQuantity = quantity;
                    selectedQuantityUnit = unit;
                  },
                ),
                SizedBox(height: 10),
                TypeAheadField<String?>(
                  suggestionsCallback: (search) async {
                    return await _fetchSuggestions('products','store',search);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion!),
                    );
                  },
                  onSelected: (suggestion) {
                    setState(() {
                      _storeNameController.text = suggestion!;
                      storeName = suggestion!;
                      storeSuggestions.clear(); // Clear suggestions after selection
                    });
                  },
                  builder: (context, controller, focusNode) => TextField(
                    controller: _storeNameController,
                    focusNode: focusNode,
                    autofocus: true,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontStyle: FontStyle.italic),
                    decoration: InputDecoration(
                      hintText: 'STORE',
                      labelText: 'Store',
                    ),
                    onChanged: (value) {
                      // Set productName to the manually entered value
                      value = capitalize(value);
                      storeName = value;
                    },
                  ),
                ),
                // Display store suggestions
               if (storeSuggestions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: storeSuggestions
                        .map((suggestion) => ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        setState(() {
                          _storeNameController.text = suggestion;
                          storeSuggestions.clear();
                        });
                      },
                    ))
                        .toList(),
                  ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    try {
                      setState(() {
                        selectedDate = DateFormat('MM/dd/yyyy').parse(value);
                        print('Selected Date(TextField): ***** $selectedDate *****');
                      });
                    } catch (e) {
                      print('Error parsing date: $e');
                    }
                  },
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: 'DATE',
                    suffixIcon: IconButton(
                      onPressed: () {
                        var selectedDateFuture = Date_Utils.selectDate(context, _dateController);
                        selectedDateFuture.then((value) => (value != null) ? selectedDate = value : selectedDate = selectedDate);
                        log("Here is the $selectedDate");
                      },
                      icon: Icon(Icons.calendar_today),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField (
               //   controller: _priceController,
                  onChanged: (value) {
                    setState(() {
                      productPrice = double.tryParse(value) ?? 0.0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'PRICE',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    addProductToFirestore();
                    // Reset the form
                    _formKey.currentState?.reset();
                    _dateController.clear();
                    _productNameController.clear();
                    _storeNameController.clear();
                  },
                  child: Text('ADD PRODUCT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to add the product to Firestore
  Future<void> addProductToFirestore() async {
    try {
      // Create a Firestore collection reference
      CollectionReference products =
      FirebaseFirestore.instance.collection('products');

      // Create an instance of the product class
      product newProduct = product(
        name: productName,
        store: storeName,
        date: selectedDate,
        price: productPrice,
        quantity: selectedQuantity,
        quantityUnit: selectedQuantityUnit,
      );

      print('Selected Date (before formatting):***** $selectedDate *****');
      print('Formatted Date:***** ${DateFormat('MM/dd/yyyy').format(selectedDate.toLocal())}*****');

      DateTime utcDate = selectedDate.toUtc();

      // Add the product to Firestore
      await products.add({
        'name': productName,
        'store': storeName,
        'date': DateFormat('MM/dd/yyyy').format(selectedDate.toLocal()),
        'price': productPrice,
        'quantity': selectedQuantity,
        'quantityUnit': selectedQuantityUnit,
      });

    } catch (e) {
      print('Error adding product: $e');
    }
  }
  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}