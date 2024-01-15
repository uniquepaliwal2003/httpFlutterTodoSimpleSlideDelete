import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = ""; 
  var _enteredQuantity = 1;
  var _enteredCategory = categories[Categories.vegetables]!;
  var _isSending = false;
  String? error;
  void _saveItem() async{
    if(_formKey.currentState!.validate()){
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();
            final url = Uri.https("flutter-prep-5440f-default-rtdb.firebaseio.com",
          "shopping-list.json");
      await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _enteredCategory.title
      }));

      if(!context.mounted){
        return;
      }      
      Navigator.of(context).pop();
      // Navigator.of(context).pop(GroceryItem(id: DateTime.now().toString() , name: _enteredName, quantity: _enteredQuantity, category: _enteredCategory));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add a new Item'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length >= 50) {
                      return 'Must be between 1 and 50 characters long';
                    }
                    return null;
                  },
                  onSaved: (value){
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(label: Text('Quantity')),
                        keyboardType: TextInputType.number,
                        initialValue: _enteredQuantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                             int.tryParse(value)!  <= 0) {
                            return 'Must be between 1 and 50 characters long';
                          }
                          return null;
                        },
                        onSaved: (value){
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _enteredCategory,
                        items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title)
                              ],
                            ),
                          )
                      ], 
                      onChanged: (value) {
                        setState(() {
                          _enteredCategory = value!;
                        });
                      }),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: _isSending? null :() { _formKey.currentState!.reset();}, child: const Text("Reset")),
                    ElevatedButton(
                        onPressed:_isSending?null: _saveItem, child: _isSending ? const SizedBox(width: 16,height: 16,child: CircularProgressIndicator(),): const Text("Add Item"))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
