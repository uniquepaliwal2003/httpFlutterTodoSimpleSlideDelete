import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/widgets/new_item.dart';
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var _isLoading = true;
  List<GroceryItem> _groceryListItems = [];
  String? _error;
  void _loadItems() async {
    final url = Uri.https("flutter-prep-5440f-default-rtdb.firebaseio.com","shopping-list.json");
    final response =await http.get(url);
    if(response.statusCode >= 400){
      setState(() {
        _error = 'failed to fetch the data ';
      });
    }
    if(response.body=='null'){
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String,dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadItems = [];
    for(final item in listData.entries ){
      final category = categories.entries.firstWhere((catItem) => catItem.value.title == item.value['category']).value;
      loadItems.add(
        GroceryItem(
          id: item.key, name: item.value['name'], quantity: item.value['quantity'], category: category
        )
      );
      setState(() {
        _groceryListItems = loadItems;
        _isLoading = false;
      });
    }

  }
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  void _addItems() async {
    await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(builder: (ctx)=>const NewItem()));
    _loadItems();
  }
  void _removeItem(GroceryItem item )async{
    final index = _groceryListItems.indexOf(item);
    setState(() {
      _groceryListItems.remove(item);
    });
    final url = Uri.https("flutter-prep-5440f-default-rtdb.firebaseio.com","shopping-list/${item.id}.json");
    final response = await http.delete(url);
    if(response.statusCode >= 400){
    setState(() {
      _groceryListItems.insert(index ,item);
    });
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No items added yet"),);
    if(_isLoading){
      content  = const Center(child: CircularProgressIndicator(),);
    }
    if( _groceryListItems.isNotEmpty ){
      content = ListView.builder(
        itemCount: _groceryListItems.length,
        itemBuilder: (ctx,index)=>Dismissible(
          key:ValueKey(_groceryListItems[index].id),
          onDismissed: (direction) { _removeItem(_groceryListItems[index]);},
          child: ListTile(
            title:Text(_groceryListItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryListItems[index].category.color ,
            ),
            trailing: Text(_groceryListItems[index].quantity.toString()),
          ),
        )
      );
    }
    if( _error != null ){
      content =  Center(child: Text(_error!),);
    }
    return Scaffold(
      appBar: AppBar(
        title:const Text("Your grocery"),
        actions: [
          IconButton(onPressed: _addItems, icon: const Icon(Icons.add))
        ],
      ),
      body: content
    );
  }
}