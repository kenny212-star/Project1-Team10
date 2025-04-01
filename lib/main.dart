import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: 'Meal Planner App',
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
              Text('Login To Your Meal Plan!',
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
              title: Text('Favorites'),
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
      case 'grill':
        return 'assets/grill.jpg';
      case 'dessert':
        return 'assets/dessert.jpg';
      case 'high protein':
        return 'assets/high protein.jpg';
      case 'keto':
        return 'assets/keto.jpg';
      case 'low carb':
        return 'assets/low carbs.jpg';
      case 'pasta':
        return 'assets/pasta.jpg';
      case 'salad':
        return 'assets/salads.jpg';
      case 'smoothie':
        return 'assets/smoothies.jpg';
      case 'snack':
        return 'assets/snacks.jpg';
      case 'soup':
        return 'assets/soups.jpg';
      case 'vegan':
        return 'assets/vegan.jpg';
      case 'brunch':
        return 'assets/brunch.jpg';
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

// --- Meal Favourites + Filters ---
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
      {
        'name': 'Pancakes',
        'calories': '350',
        'protein': '8g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Fruit Smoothie Bowl',
        'calories': '300',
        'protein': '6g',
        'tags': ['vegan']
      },
      {
        'name': 'Greek Yogurt Parfait',
        'calories': '250',
        'protein': '10g',
        'tags': ['vegetarian']
      },
    ],
    'Brunch': [
      {
        'name': 'Avocado Toast',
        'calories': '280',
        'protein': '7g',
        'tags': ['vegan']
      },
      {
        'name': 'French Toast',
        'calories': '370',
        'protein': '10g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Breakfast Burrito',
        'calories': '400',
        'protein': '16g',
        'tags': []
      },
      {
        'name': 'Smoked Salmon Bagel',
        'calories': '350',
        'protein': '22g',
        'tags': []
      },
      {
        'name': 'Shakshuka',
        'calories': '320',
        'protein': '14g',
        'tags': ['vegetarian', 'gluten-free']
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
      {
        'name': 'Quinoa Bowl',
        'calories': '380',
        'protein': '14g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Grilled Cheese Sandwich',
        'calories': '400',
        'protein': '12g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Turkey Sandwich',
        'calories': '320',
        'protein': '22g',
        'tags': []
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
        'name': 'Pasta Primavera',
        'calories': '350',
        'protein': '12g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Stuffed Peppers',
        'calories': '390',
        'protein': '20g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Beef Stir-Fry',
        'calories': '430',
        'protein': '28g',
        'tags': []
      },
      {
        'name': 'Grilled Chicken & Veggies',
        'calories': '420',
        'protein': '35g',
        'tags': ['gluten-free']
      },
    ],
    'Snack': [
      {
        'name': 'Protein Bar',
        'calories': '210',
        'protein': '20g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Apple Slices & Peanut Butter',
        'calories': '200',
        'protein': '6g',
        'tags': ['vegan']
      },
      {
        'name': 'Trail Mix',
        'calories': '250',
        'protein': '8g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Cheese & Crackers',
        'calories': '250',
        'protein': '10g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Yogurt Cup',
        'calories': '180',
        'protein': '9g',
        'tags': ['vegetarian']
      },
    ],
    'Dessert': [
      {
        'name': 'Chocolate Chip Cookies',
        'calories': '300',
        'protein': '3g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Fruit Salad',
        'calories': '150',
        'protein': '2g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Cheesecake',
        'calories': '400',
        'protein': '7g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Brownies',
        'calories': '350',
        'protein': '5g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Chia Pudding',
        'calories': '180',
        'protein': '6g',
        'tags': ['vegan', 'gluten-free']
      },
    ],
    'Smoothie': [
      {
        'name': 'Berry Blast',
        'calories': '180',
        'protein': '3g',
        'tags': ['vegan']
      },
      {
        'name': 'Peanut Butter Banana',
        'calories': '220',
        'protein': '7g',
        'tags': ['vegan']
      },
      {
        'name': 'Green Detox',
        'calories': '160',
        'protein': '4g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Mango Lassi',
        'calories': '250',
        'protein': '5g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Protein Power Shake',
        'calories': '300',
        'protein': '20g',
        'tags': ['gluten-free']
      },
    ],
    'Salad': [
      {
        'name': 'Greek Salad',
        'calories': '300',
        'protein': '8g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Lentil Salad',
        'calories': '280',
        'protein': '12g',
        'tags': ['vegan']
      },
      {
        'name': 'Tuna Salad',
        'calories': '310',
        'protein': '25g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Caprese Salad',
        'calories': '290',
        'protein': '9g',
        'tags': ['vegetarian', 'gluten-free']
      },
      {
        'name': 'Caesar Salad',
        'calories': '350',
        'protein': '10g',
        'tags': ['vegetarian']
      },
    ],
    'Soup': [
      {
        'name': 'Tomato Soup',
        'calories': '150',
        'protein': '3g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Chicken Noodle Soup',
        'calories': '220',
        'protein': '15g',
        'tags': []
      },
      {
        'name': 'Minestrone',
        'calories': '180',
        'protein': '6g',
        'tags': ['vegan']
      },
      {
        'name': 'Broccoli Cheddar',
        'calories': '250',
        'protein': '10g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Lentil Soup',
        'calories': '230',
        'protein': '12g',
        'tags': ['vegan', 'gluten-free']
      },
    ],
    'Grill': [
      {
        'name': 'Grilled Chicken',
        'calories': '330',
        'protein': '35g',
        'tags': ['gluten-free']
      },
      {'name': 'BBQ Ribs', 'calories': '500', 'protein': '28g', 'tags': []},
      {
        'name': 'Grilled Veggie Skewers',
        'calories': '200',
        'protein': '6g',
        'tags': ['vegan']
      },
      {
        'name': 'Grilled Shrimp',
        'calories': '240',
        'protein': '22g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Turkey Burger',
        'calories': '350',
        'protein': '28g',
        'tags': []
      },
    ],
    'Pasta': [
      {
        'name': 'Spaghetti Bolognese',
        'calories': '450',
        'protein': '22g',
        'tags': []
      },
      {
        'name': 'Mac & Cheese',
        'calories': '400',
        'protein': '14g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Pesto Pasta',
        'calories': '420',
        'protein': '12g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Gluten-Free Penne',
        'calories': '380',
        'protein': '11g',
        'tags': ['vegetarian', 'gluten-free']
      },
      {
        'name': 'Creamy Alfredo',
        'calories': '460',
        'protein': '15g',
        'tags': ['vegetarian']
      },
    ],
    'Vegan': [
      {
        'name': 'Tofu Stir-Fry',
        'calories': '320',
        'protein': '18g',
        'tags': ['vegan']
      },
      {
        'name': 'Lentil Curry',
        'calories': '340',
        'protein': '16g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Vegan Chili',
        'calories': '300',
        'protein': '14g',
        'tags': ['vegan', 'gluten-free']
      },
      {
        'name': 'Black Bean Tacos',
        'calories': '280',
        'protein': '12g',
        'tags': ['vegan']
      },
      {
        'name': 'Vegan Burger',
        'calories': '350',
        'protein': '20g',
        'tags': ['vegan']
      },
    ],
    'Low Carb': [
      {
        'name': 'Zucchini Noodles',
        'calories': '230',
        'protein': '6g',
        'tags': ['vegetarian', 'gluten-free']
      },
      {
        'name': 'Cauliflower Fried Rice',
        'calories': '240',
        'protein': '9g',
        'tags': ['vegan']
      },
      {
        'name': 'Egg Muffins',
        'calories': '200',
        'protein': '12g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Tuna Lettuce Wraps',
        'calories': '250',
        'protein': '20g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Grilled Salmon & Asparagus',
        'calories': '350',
        'protein': '28g',
        'tags': ['gluten-free']
      },
    ],
    'High Protein': [
      {
        'name': 'Grilled Chicken Breast',
        'calories': '330',
        'protein': '35g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Beef & Broccoli',
        'calories': '400',
        'protein': '30g',
        'tags': []
      },
      {
        'name': 'Protein Smoothie',
        'calories': '280',
        'protein': '25g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Cottage Cheese & Berries',
        'calories': '180',
        'protein': '15g',
        'tags': ['vegetarian']
      },
      {
        'name': 'Hard Boiled Eggs',
        'calories': '140',
        'protein': '12g',
        'tags': ['vegetarian', 'gluten-free']
      },
    ],
    'Keto': [
      {
        'name': 'Keto Chicken Alfredo',
        'calories': '420',
        'protein': '30g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Stuffed Avocados',
        'calories': '300',
        'protein': '15g',
        'tags': ['keto', 'gluten-free']
      },
      {
        'name': 'Zucchini Lasagna',
        'calories': '360',
        'protein': '22g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Bacon & Eggs',
        'calories': '350',
        'protein': '18g',
        'tags': ['gluten-free']
      },
      {
        'name': 'Keto Salad Bowl',
        'calories': '380',
        'protein': '20g',
        'tags': ['gluten-free']
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final allMeals = meals[widget.mealType] ?? [];

    final mealList = selectedFilter == 'All'
        ? allMeals
        : allMeals.where((meal) {
            final tags = List<String>.from(meal['tags'] ?? []);
            return tags
                .map((tag) => tag.toLowerCase())
                .contains(selectedFilter.toLowerCase());
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

//Favourites Screen
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

//Grocery List Screen
class GroceryListScreen extends StatelessWidget {
  final Map<String, String> selectedMeals;
  GroceryListScreen({required this.selectedMeals});

  final Map<String, List<String>> mealIngredients = {
    'Oatmeal': ['Oats', 'Milk', 'Banana'],
    'Scrambled Eggs': ['Eggs', 'Butter', 'Salt'],
    'Pancakes': ['Flour', 'Milk', 'Eggs', 'Baking Powder'],
    'Fruit Smoothie Bowl': [
      'Mixed Berries',
      'Banana',
      'Almond Milk',
      'Granola'
    ],
    'Greek Yogurt Parfait': ['Greek Yogurt', 'Berries', 'Granola'],

    'Avocado Toast': ['Bread', 'Avocado', 'Lemon Juice'],
    'French Toast': ['Bread', 'Eggs', 'Milk', 'Cinnamon'],
    'Breakfast Burrito': ['Tortilla', 'Eggs', 'Cheese', 'Bell Peppers'],
    'Smoked Salmon Bagel': ['Bagel', 'Cream Cheese', 'Smoked Salmon'],
    'Shakshuka': ['Tomatoes', 'Eggs', 'Bell Peppers', 'Onions'],

    'Chicken Salad': ['Chicken', 'Lettuce', 'Tomato'],
    'Veggie Wrap': ['Tortilla', 'Hummus', 'Lettuce', 'Cucumber'],
    'Grilled Cheese Sandwich': ['Bread', 'Cheddar Cheese', 'Butter'],
    'Turkey Sandwich': ['Bread', 'Turkey', 'Lettuce', 'Tomato'],
    'Quinoa Bowl': ['Quinoa', 'Chickpeas', 'Avocado', 'Spinach'],

    'Salmon & Rice': ['Salmon', 'Rice', 'Soy Sauce'],
    'Pasta Primavera': ['Pasta', 'Zucchini', 'Bell Peppers', 'Tomato Sauce'],
    'Grilled Chicken & Veggies': ['Chicken Breast', 'Zucchini', 'Broccoli'],
    'Stuffed Peppers': ['Bell Peppers', 'Rice', 'Black Beans', 'Cheese'],
    'Beef Stir-Fry': ['Beef', 'Broccoli', 'Soy Sauce', 'Garlic'],

    'Apple Slices & Peanut Butter': ['Apple', 'Peanut Butter'],
    'Trail Mix': ['Nuts', 'Raisins', 'Dark Chocolate'],
    'Yogurt Cup': ['Yogurt'],
    'Protein Bar': ['Protein Bar'], // store-bought
    'Cheese & Crackers': ['Cheddar Cheese', 'Crackers'],

    'Chocolate Chip Cookies': ['Flour', 'Butter', 'Sugar', 'Chocolate Chips'],
    'Fruit Salad': ['Apple', 'Banana', 'Grapes', 'Orange'],
    'Cheesecake': ['Cream Cheese', 'Sugar', 'Graham Crackers'],
    'Brownies': ['Cocoa Powder', 'Flour', 'Butter', 'Eggs'],
    'Chia Pudding': ['Chia Seeds', 'Almond Milk', 'Honey'],

    'Berry Blast': ['Strawberries', 'Blueberries', 'Banana', 'Almond Milk'],
    'Peanut Butter Banana': ['Banana', 'Peanut Butter', 'Almond Milk'],
    'Green Detox': ['Spinach', 'Pineapple', 'Cucumber', 'Coconut Water'],
    'Mango Lassi': ['Mango', 'Yogurt', 'Honey'],
    'Protein Power Shake': ['Protein Powder', 'Banana', 'Milk'],

    'Caesar Salad': [
      'Romaine Lettuce',
      'Croutons',
      'Parmesan',
      'Caesar Dressing'
    ],
    'Greek Salad': ['Tomatoes', 'Cucumber', 'Feta', 'Olives'],
    'Lentil Salad': ['Lentils', 'Carrot', 'Cucumber', 'Olive Oil'],
    'Tuna Salad': ['Tuna', 'Lettuce', 'Mayo', 'Pickles'],
    'Caprese Salad': ['Tomatoes', 'Mozzarella', 'Basil'],

    'Tomato Soup': ['Tomatoes', 'Onion', 'Garlic'],
    'Chicken Noodle': ['Chicken', 'Noodles', 'Carrot', 'Celery'],
    'Minestrone': ['Beans', 'Zucchini', 'Carrots', 'Tomato Broth'],
    'Broccoli Cheddar': ['Broccoli', 'Cheddar Cheese', 'Milk'],
    'Lentil Soup': ['Lentils', 'Onion', 'Garlic', 'Cumin'],

    'Grilled Chicken': ['Chicken Breast', 'Paprika', 'Olive Oil'],
    'BBQ Ribs': ['Pork Ribs', 'BBQ Sauce'],
    'Grilled Veggie Skewers': ['Zucchini', 'Bell Peppers', 'Onion'],
    'Grilled Shrimp': ['Shrimp', 'Garlic', 'Olive Oil'],
    'Turkey Burger': ['Ground Turkey', 'Bun', 'Lettuce', 'Tomato'],

    'Spaghetti Bolognese': ['Ground Beef', 'Spaghetti', 'Tomato Sauce'],
    'Mac & Cheese': ['Macaroni', 'Cheese', 'Milk'],
    'Pesto Pasta': ['Pasta', 'Pesto Sauce', 'Parmesan'],
    'Gluten-Free Penne': ['Gluten-Free Penne', 'Tomato Sauce'],
    'Creamy Alfredo': ['Fettuccine', 'Cream', 'Parmesan'],

    'Tofu Stir-Fry': ['Tofu', 'Broccoli', 'Soy Sauce'],
    'Vegan Chili': ['Kidney Beans', 'Tomato', 'Corn'],
    'Lentil Curry': ['Lentils', 'Coconut Milk', 'Curry Powder'],
    'Black Bean Tacos': ['Black Beans', 'Tortilla', 'Lettuce'],
    'Vegan Burger': ['Vegan Patty', 'Bun', 'Lettuce', 'Tomato'],

    'Zucchini Noodles': ['Zucchini', 'Pesto', 'Cherry Tomatoes'],
    'Egg Muffins': ['Eggs', 'Spinach', 'Cheddar'],
    'Cauliflower Fried Rice': ['Cauliflower', 'Peas', 'Carrots', 'Soy Sauce'],
    'Tuna Lettuce Wraps': ['Tuna', 'Lettuce', 'Avocado'],
    'Grilled Salmon & Asparagus': ['Salmon', 'Asparagus', 'Lemon'],

    'Grilled Chicken Breast': ['Chicken Breast', 'Garlic', 'Paprika'],
    'Beef & Broccoli': ['Beef Strips', 'Broccoli', 'Soy Sauce'],
    'Protein Smoothie': ['Protein Powder', 'Banana', 'Milk'],
    'Cottage Cheese & Berries': ['Cottage Cheese', 'Blueberries'],
    'Hard Boiled Eggs': ['Eggs'],

    'Bacon & Eggs': ['Bacon', 'Eggs'],
    'Keto Salad Bowl': ['Spinach', 'Avocado', 'Boiled Eggs', 'Cheese'],
    'Zucchini Lasagna': ['Zucchini', 'Ricotta', 'Tomato Sauce'],
    'Keto Chicken Alfredo': ['Chicken', 'Cream', 'Parmesan'],
    'Stuffed Avocados': ['Avocados', 'Tuna', 'Onion'],
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

//Nutrition & Suggestions Screens
class NutritionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> nutritionData = [
    {'meal': 'Oatmeal', 'calories': 150, 'protein': 5},
    {'meal': 'Scrambled Eggs', 'calories': 200, 'protein': 12},
    {'meal': 'Pancakes', 'calories': 350, 'protein': 8},
    {'meal': 'Fruit Smoothie Bowl', 'calories': 300, 'protein': 6},
    {'meal': 'Greek Yogurt Parfait', 'calories': 250, 'protein': 15},
    {'meal': 'Avocado Toast', 'calories': 280, 'protein': 7},
    {'meal': 'French Toast', 'calories': 370, 'protein': 10},
    {'meal': 'Breakfast Burrito', 'calories': 400, 'protein': 16},
    {'meal': 'Smoked Salmon Bagel', 'calories': 420, 'protein': 22},
    {'meal': 'Shakshuka', 'calories': 320, 'protein': 14},
    {'meal': 'Chicken Salad', 'calories': 300, 'protein': 25},
    {'meal': 'Veggie Wrap', 'calories': 250, 'protein': 10},
    {'meal': 'Grilled Cheese Sandwich', 'calories': 400, 'protein': 12},
    {'meal': 'Turkey Sandwich', 'calories': 350, 'protein': 18},
    {'meal': 'Quinoa Bowl', 'calories': 380, 'protein': 14},
    {'meal': 'Salmon & Rice', 'calories': 400, 'protein': 30},
    {'meal': 'Pasta Primavera', 'calories': 420, 'protein': 13},
    {'meal': 'Grilled Chicken & Veggies', 'calories': 370, 'protein': 28},
    {'meal': 'Stuffed Peppers', 'calories': 390, 'protein': 20},
    {'meal': 'Beef Stir-Fry', 'calories': 450, 'protein': 30},
    {'meal': 'Apple Slices & Peanut Butter', 'calories': 200, 'protein': 6},
    {'meal': 'Trail Mix', 'calories': 250, 'protein': 8},
    {'meal': 'Yogurt Cup', 'calories': 180, 'protein': 9},
    {'meal': 'Protein Bar', 'calories': 210, 'protein': 20},
    {'meal': 'Cheese & Crackers', 'calories': 220, 'protein': 7},
    {'meal': 'Chocolate Chip Cookies', 'calories': 300, 'protein': 3},
    {'meal': 'Fruit Salad', 'calories': 150, 'protein': 2},
    {'meal': 'Cheesecake', 'calories': 430, 'protein': 6},
    {'meal': 'Brownies', 'calories': 350, 'protein': 4},
    {'meal': 'Chia Pudding', 'calories': 200, 'protein': 5},
    {'meal': 'Berry Blast', 'calories': 180, 'protein': 3},
    {'meal': 'Peanut Butter Banana', 'calories': 220, 'protein': 7},
    {'meal': 'Green Detox', 'calories': 160, 'protein': 2},
    {'meal': 'Mango Lassi', 'calories': 250, 'protein': 5},
    {'meal': 'Protein Power Shake', 'calories': 300, 'protein': 20},
    {'meal': 'Caesar Salad', 'calories': 350, 'protein': 10},
    {'meal': 'Greek Salad', 'calories': 300, 'protein': 8},
    {'meal': 'Lentil Salad', 'calories': 280, 'protein': 12},
    {'meal': 'Tuna Salad', 'calories': 320, 'protein': 25},
    {'meal': 'Caprese Salad', 'calories': 290, 'protein': 7},
    {'meal': 'Tomato Soup', 'calories': 150, 'protein': 3},
    {'meal': 'Chicken Noodle', 'calories': 220, 'protein': 15},
    {'meal': 'Minestrone', 'calories': 180, 'protein': 6},
    {'meal': 'Broccoli Cheddar', 'calories': 250, 'protein': 10},
    {'meal': 'Lentil Soup', 'calories': 230, 'protein': 12},
    {'meal': 'Grilled Chicken', 'calories': 330, 'protein': 35},
    {'meal': 'BBQ Ribs', 'calories': 500, 'protein': 28},
    {'meal': 'Grilled Veggie Skewers', 'calories': 200, 'protein': 5},
    {'meal': 'Grilled Shrimp', 'calories': 220, 'protein': 24},
    {'meal': 'Turkey Burger', 'calories': 350, 'protein': 26},
    {'meal': 'Spaghetti Bolognese', 'calories': 450, 'protein': 22},
    {'meal': 'Mac & Cheese', 'calories': 400, 'protein': 14},
    {'meal': 'Pesto Pasta', 'calories': 420, 'protein': 12},
    {'meal': 'Gluten-Free Penne', 'calories': 380, 'protein': 11},
    {'meal': 'Creamy Alfredo', 'calories': 460, 'protein': 15},
    {'meal': 'Tofu Stir-Fry', 'calories': 320, 'protein': 18},
    {'meal': 'Vegan Chili', 'calories': 300, 'protein': 14},
    {'meal': 'Lentil Curry', 'calories': 340, 'protein': 16},
    {'meal': 'Black Bean Tacos', 'calories': 280, 'protein': 12},
    {'meal': 'Vegan Burger', 'calories': 350, 'protein': 20},
    {'meal': 'Zucchini Noodles', 'calories': 230, 'protein': 6},
    {'meal': 'Egg Muffins', 'calories': 200, 'protein': 14},
    {'meal': 'Cauliflower Fried Rice', 'calories': 240, 'protein': 9},
    {'meal': 'Tuna Lettuce Wraps', 'calories': 220, 'protein': 22},
    {'meal': 'Grilled Salmon & Asparagus', 'calories': 370, 'protein': 30},
    {'meal': 'Grilled Chicken Breast', 'calories': 330, 'protein': 35},
    {'meal': 'Beef & Broccoli', 'calories': 400, 'protein': 30},
    {'meal': 'Protein Smoothie', 'calories': 280, 'protein': 25},
    {'meal': 'Cottage Cheese & Berries', 'calories': 180, 'protein': 15},
    {'meal': 'Hard Boiled Eggs', 'calories': 140, 'protein': 12},
    {'meal': 'Bacon & Eggs', 'calories': 350, 'protein': 18},
    {'meal': 'Keto Salad Bowl', 'calories': 380, 'protein': 20},
    {'meal': 'Zucchini Lasagna', 'calories': 360, 'protein': 22},
    {'meal': 'Keto Chicken Alfredo', 'calories': 420, 'protein': 30},
    {'meal': 'Stuffed Avocados', 'calories': 300, 'protein': 15},
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
              'Calories: ${item['calories']} | Protein: ${item['protein']}g',
            ),
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
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allMeals
        .where((meal) => meal.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map((meal) {
        return ListTile(
          title: Text(meal),
          onTap: () {
            close(context, null); // Close the search
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(mealType: meal),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allMeals
        .where((meal) => meal.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions.map((meal) {
        return ListTile(
          title: Text(meal),
          onTap: () {
            query = meal;
            showResults(context); // Show result when tapped from suggestion
          },
        );
      }).toList(),
    );
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

