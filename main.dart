import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FruitProvider(),
      child: ItemListApp(),
    ),
  );
}

class ItemListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: ItemListScreen(),
      routes: {
        '/details': (context) => ItemDetailsScreen(),
      },
    );
  }
}

class Fruit {
  final String name;
  final String description;

  Fruit({required this.name, required this.description});

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      name: json['name'],
      description: json['description'],
    );
  }
}

class FruitProvider extends ChangeNotifier {
  List<Fruit> _fruits = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Fruit> get fruits => _fruits;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final List<Fruit> _fallbackFruits = [
    Fruit(name: 'Apple', description: 'Apples are nutritious and delicious.'),
    Fruit(
        name: 'Banana',
        description: 'Bananas are high in potassium and great for snacks.'),
    Fruit(
        name: 'Cherry',
        description: 'Cherries are small, round, and red or black in color.'),
    Fruit(
        name: 'Date',
        description: 'Dates are sweet fruits of the date palm tree.'),
    Fruit(
        name: 'Elderberry',
        description:
            'Elderberries are small, dark berries that grow in clusters.'),
    Fruit(
        name: 'Fig',
        description: 'Figs are soft, sweet fruits with a thin skin.'),
    Fruit(
        name: 'Grape',
        description:
            'Grapes can be eaten fresh or used to make wine, juice, and jelly.'),
    Fruit(
        name: 'Honeydew',
        description: 'Honeydew melons are sweet and green-fleshed.'),
    Fruit(
        name: 'Iced Apple',
        description: 'Iced apples are frozen versions of regular apples.'),
    Fruit(
        name: 'Jackfruit',
        description:
            'Jackfruits are large, tropical fruits with a spiky exterior.'),
  ];

  Future<void> fetchFruits() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/fruits'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _fruits = data.map((json) => Fruit.fromJson(json)).toList();
      } else {
        _errorMessage =
            'Failed to load fruits fallback fruits are empty may be';
        _fruits = _fallbackFruits;
      }
    } catch (e) {
      _errorMessage = 'An error occurred';
      _fruits = _fallbackFruits;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class ItemListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fruitProvider = Provider.of<FruitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Fruits List'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: fruitProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : fruitProvider.errorMessage.isNotEmpty &&
                  fruitProvider.fruits == fruitProvider._fallbackFruits
              ? Center(child: Text(fruitProvider.errorMessage))
              : ListView.builder(
                  itemCount: fruitProvider.fruits.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Card(
                        margin: EdgeInsets.all(4.0),
                        child: ListTile(
                          title: Text(
                            fruitProvider.fruits[index].name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/details',
                              arguments: fruitProvider.fruits[index],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fruitProvider.fetchFruits();
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class ItemDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Fruit item = ModalRoute.of(context)!.settings.arguments as Fruit;

    return Scaffold(
      appBar: AppBar(
        title: Text('${item.name} Details'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                item.description,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  } // giving comments for my code clearity
}
