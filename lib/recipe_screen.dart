import 'package:flutter/material.dart';
import 'recipe_database.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Screen',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const RecipePage(title: 'Recipe Home Page'),
    );
  }
}

class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  // Create the controller (think of this as your remote control for the text box)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void dispose() {
    // Always dispose of the controller when the screen closes to free up memory
    _nameController.dispose();
    _typeController.dispose();
    _mealController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  // Function that runs when the button is pressed
  Future<void> _addItemToDatabase() async {
    final userInputName = _nameController.text;
    final userInputType = _typeController.text;
    final userInputMeal = _mealController.text;
    final userInputInstructions = _instructionsController.text;

    // Safety check: Don't save empty text
    if (userInputName.trim().isEmpty) return;
    if (userInputType.trim().isEmpty) return;
    if (userInputMeal.trim().isEmpty) return;
    if (userInputInstructions.trim().isEmpty) return;

    // Save to database
    await RecipeDatabase.instance.insertItem(userInputName, userInputType, userInputMeal, userInputInstructions);

    // Clear the text field so it's ready for the next entry
    _nameController.clear();
    _typeController.clear();
    _mealController.clear();
    _instructionsController.clear();

    // Tell Flutter to rebuild the widget tree so the new item shows up in the list
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController, // Hook the text editing controller
                    decoration: const InputDecoration(
                      labelText: 'Add Recipe Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _typeController, // Hook the text editing controller
                    decoration: const InputDecoration(
                      labelText: 'Add Recipe Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _mealController, // Hook the text editing controller
                    decoration: const InputDecoration(
                      labelText: 'Add Recipe Meal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _instructionsController, // Hook the text editing controller
                    decoration: const InputDecoration(
                      labelText: 'Add Recipe Instructions',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItemToDatabase, // Hooking up our save function here
                  child: const Text('+'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: RecipeDatabase.instance.getRecipes(),
                builder: (context, snapshot) {
                  // Check if waiting for a response from the database
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Check if the database is empty
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('You have no recipes'));
                  }

                  final recipes = snapshot.data!;

                  // Build the scrolling list of ingreidents
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      // Grab the individual recipe map at this specific index
                      final recipe = recipes[index];

                      // Return a row widget for each item
                      return ExpansionTile(
                        title: Text(recipe['name']), // Displays the recipe name from the database
                        leading: CircleAvatar(
                          child: Text('${recipe['id']}'), // Displays the row ID
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('${recipe['meal']} : ${recipe['type']}'),
                                const SizedBox(height: 8),
                                Text('${recipe['instructions']}'),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
