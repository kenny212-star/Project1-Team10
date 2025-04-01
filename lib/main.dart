import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global favorites
List<String> favoriteMeals = [];

// Storage helper
class StorageHelper {
  static const String favoriteKey = 'favorite_meals';
  static const String plannerKey = 'meal_plan';

  static Future<void> saveFavorites(List<String> meals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(favoriteKey, meals);
  }

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(favoriteKey) ?? [];
  }

  static Future<void> saveMealPlan(Map<String, String> plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(plannerKey, plan.toString());
  }

  static Future<Map<String, String>> loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(plannerKey);
    if (raw == null) return {};
    final Map<String, String> result = {};
    raw.substring(1, raw.length - 1).split(',').forEach((pair) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0].trim()] = parts[1].trim();
      }
    });
    return result;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  favoriteMeals = await StorageHelper.loadFavorites();
  runApp(MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFFF9F9F9),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
      ),
      home: LoginScreen(),
    );
  }
}

// --- Login Screen ---
class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Meal Planner Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username')),
              SizedBox(height: 12),
              TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomeScreen())),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Home Screen ---
class HomeScreen extends StatelessWidget {
  final List<String> mealTypes = [
    'Breakfast',
    'Brunch',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
    'Smoothie',
    'Salad',
    'Soup',
    'Grill',
    'Pasta',
    'Vegan',
    'Low Carb',
    'High Protein',
    'Keto'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: MealSearchDelegate(mealTypes),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => LoginScreen())),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome! What would you like to eat today?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children:
                    mealTypes.map((type) => MealCategory(title: type)).toList(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuickAccessButton(label: 'Quick Access', icon: Icons.star),
                QuickAccessButton(
                    label: 'Nutrition Breakdown', icon: Icons.bar_chart),
                QuickAccessButton(
                    label: 'Meal Suggestions', icon: Icons.fastfood),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- App Drawer ---
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
              title: Text('Home'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()))),
          ListTile(
              title: Text('Nutrition'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NutritionScreen()))),
          ListTile(
              title: Text('Suggestions'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MealSuggestionsScreen()))),
          ListTile(
              title: Text('Meal Planner'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MealPlannerScreen()))),
          ListTile(
              title: Text('Favourites'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FavouritesScreen()))),
        ],
      ),
    );
  }
}

// --- Meal Category ---
class MealCategory extends StatelessWidget {
  final String title;
  MealCategory({required this.title});

  String? getImageForTitle() {
    switch (title.toLowerCase()) {
      case 'breakfast':
        return 'assets/breakfast.jpg';
      case 'lunch':
        return 'assets/lunch.jpg';
      case 'dinner':
        return 'assets/dinner.jpg';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = getImageForTitle();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealType: title),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imagePath,
                    height: 100, width: 100, fit: BoxFit.cover),
              )
            else
              Icon(Icons.restaurant_menu, size: 40, color: Colors.green),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// --- Meal Detail with Favourites + Filters ---
class MealDetailScreen extends StatefulWidget {
  final String mealType;
  MealDetailScreen({required this.mealType});

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  String selectedFilter = 'All';

  final List<String> filters = ['All', 'Vegetarian', 'Vegan', 'Gluten-Free'];

  final Map<String, List<Map<String, dynamic>>> meals = {
    'Breakfast': [
      {
        'name': 'Oatmeal',
        'calories': '150',
        'protein': '5g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Scrambled Eggs',
        'calories': '200',
        'protein': '12g',
        'tags': ['vegetarian']
      },
    ],
    'Lunch': [
      {
        'name': 'Chicken Salad',
        'calories': '300',
        'protein': '25g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Veggie Wrap',
        'calories': '250',
        'protein': '10g',
        'tags': ['vegetarian']
      },
    ],
    'Dinner': [
      {
        'name': 'Salmon & Rice',
        'calories': '400',
        'protein': '30g',
        'tags': []
      },
      {
        'name': 'Pasta',
        'calories': '350',
        'protein': '12g',
        'tags': ['vegetarian']
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final allMeals = meals[widget.mealType] ?? [];
    final mealList = selectedFilter == 'All'
        ? allMeals
        : allMeals.where((meal) {
            final tags = meal['tags'] as List<String>;
            return tags.contains(selectedFilter.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.mealType} Recipes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
              items: filters.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: mealList.isEmpty
                ? Center(child: Text('No meals available.'))
                : ListView.builder(
                    itemCount: mealList.length,
                    itemBuilder: (context, index) {
                      final meal = mealList[index];
                      final mealName = meal['name'];
                      return ListTile(
                        title: Text(mealName),
                        subtitle: Text(
                            'Calories: ${meal['calories']}, Protein: ${meal['protein']}'),
                        trailing: IconButton(
                          icon: Icon(
                            favoriteMeals.contains(mealName)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            setState(() {
                              if (favoriteMeals.contains(mealName)) {
                                favoriteMeals.remove(mealName);
                              } else {
                                favoriteMeals.add(mealName);
                              }
                            });
                            await StorageHelper.saveFavorites(favoriteMeals);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Favourites Screen ---
class FavouritesScreen extends StatelessWidget {
  final Map<String, Map<String, String>> allMealInfo = {
    'Oatmeal': {'calories': '150', 'protein': '5g'},
    'Scrambled Eggs': {'calories': '200', 'protein': '12g'},
    'Chicken Salad': {'calories': '300', 'protein': '25g'},
    'Veggie Wrap': {'calories': '250', 'protein': '10g'},
    'Salmon & Rice': {'calories': '400', 'protein': '30g'},
    'Pasta': {'calories': '350', 'protein': '12g'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favourites')),
      body: favoriteMeals.isEmpty
          ? Center(child: Text('No favourite meals yet.'))
          : ListView.builder(
              itemCount: favoriteMeals.length,
              itemBuilder: (context, index) {
                final meal = favoriteMeals[index];
                final info = allMealInfo[meal] ?? {};
                return ListTile(
                  title: Text(meal),
                  subtitle: Text(
                      'Calories: ${info['calories']}, Protein: ${info['protein']}'),
                );
              },
            ),
    );
  }
}

// --- Meal Planner Screen ---
class MealPlannerScreen extends StatefulWidget {
  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> meals = [
    'Oatmeal',
    'Scrambled Eggs',
    'Chicken Salad',
    'Veggie Wrap',
    'Salmon & Rice',
    'Pasta',
  ];

  final Map<String, String> selectedMeals = {};

  @override
  void initState() {
    super.initState();
    StorageHelper.loadMealPlan().then((plan) {
      setState(() {
        selectedMeals.addAll(plan);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Planner')),
      body: ListView(
        children: days.map((day) {
          return ListTile(
            title: Text(day),
            trailing: DropdownButton<String>(
              value: selectedMeals[day],
              hint: Text('Select'),
              items: meals.map((meal) {
                return DropdownMenuItem(value: meal, child: Text(meal));
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  selectedMeals[day] = value!;
                });
                await StorageHelper.saveMealPlan(selectedMeals);
              },
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Grocery List'),
        icon: Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      GroceryListScreen(selectedMeals: selectedMeals)));
        },
      ),
    );
  }
}

// --- Grocery List Screen ---
class GroceryListScreen extends StatelessWidget {
  final Map<String, String> selectedMeals;
  GroceryListScreen({required this.selectedMeals});

  final Map<String, List<String>> mealIngredients = {
    'Oatmeal': ['Oats', 'Milk', 'Banana'],
    'Scrambled Eggs': ['Eggs', 'Butter', 'Salt'],
    'Chicken Salad': ['Chicken', 'Lettuce', 'Tomato'],
    'Veggie Wrap': ['Tortilla', 'Hummus', 'Lettuce', 'Cucumber'],
    'Salmon & Rice': ['Salmon', 'Rice', 'Soy Sauce'],
    'Pasta': ['Pasta', 'Tomato Sauce', 'Cheese'],
  };

  @override
  Widget build(BuildContext context) {
    final Set<String> items = {};
    selectedMeals.values.forEach((meal) {
      items.addAll(mealIngredients[meal] ?? []);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Grocery List')),
      body: ListView(
        children: items.map((item) => ListTile(title: Text(item))).toList(),
      ),
    );
  }
}

// --- Nutrition & Suggestions Screens ---
class NutritionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> nutritionData = [
    {'meal': 'Oatmeal', 'calories': 150, 'protein': 5},
    {'meal': 'Chicken Salad', 'calories': 300, 'protein': 25},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nutrition Breakdown')),
      body: ListView.builder(
        itemCount: nutritionData.length,
        itemBuilder: (context, index) {
          final item = nutritionData[index];
          return ListTile(
            title: Text(item['meal']),
            subtitle: Text(
                'Calories: ${item['calories']} | Protein: ${item['protein']}g'),
          );
        },
      ),
    );
  }
}

class MealSuggestionsScreen extends StatelessWidget {
  final List<String> mealTypes = [
    'Breakfast',
    'Brunch',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
    'Smoothie',
    'Salad',
    'Soup',
    'Grill',
    'Pasta',
    'Vegan',
    'Low Carb',
    'High Protein',
    'Keto'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Suggestions')),
      body: ListView.builder(
        itemCount: mealTypes.length,
        itemBuilder: (context, index) {
          final mealType = mealTypes[index];
          return ListTile(
            title: Text(mealType),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MealDetailScreen(mealType: mealType)),
            ),
          );
        },
      ),
    );
  }
}

class MealSearchDelegate extends SearchDelegate {
  final List<String> allMeals;
  MealSearchDelegate(this.allMeals);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allMeals
        .where((meal) => meal.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView(
        children: results.map((meal) => ListTile(title: Text(meal))).toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allMeals
        .where((meal) => meal.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return ListView(
        children:
            suggestions.map((meal) => ListTile(title: Text(meal))).toList());
  }
}

class QuickAccessButton extends StatelessWidget {
  final String label;
  final IconData icon;

  QuickAccessButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == 'Nutrition Breakdown') {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => NutritionScreen()));
        } else if (label == 'Meal Suggestions') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => MealSuggestionsScreen()));
        } else if (label == 'Quick Access') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuickAccessSearchPage(
                  mealTypes: [
                    'Breakfast',
                    'Brunch',
                    'Lunch',
                    'Dinner',
                    'Snack',
                    'Dessert',
                    'Smoothie',
                    'Salad',
                    'Soup',
                    'Grill',
                    'Pasta',
                    'Vegan',
                    'Low Carb',
                    'High Protein',
                    'Keto'
                  ],
                ),
              ));
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            radius: 24,
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class QuickAccessSearchPage extends StatelessWidget {
  final List<String> mealTypes;
  QuickAccessSearchPage({required this.mealTypes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Meals')),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.search),
          label: Text('Tap to Search'),
          onPressed: () => showSearch(
              context: context, delegate: MealSearchDelegate(mealTypes)),
        ),
      ),
    );
  }
}
