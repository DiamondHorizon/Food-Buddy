import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RecipeDatabase {
  // Singleton instance
  static final RecipeDatabase instance = RecipeDatabase._init();
  static Database? _database;

  RecipeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipe_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB, // This triggers only on first app launch
      onUpgrade: _upgradeDB,
    );
  }

  // Create tables and insert starter recipes here
  Future _createDB(Database db, int version) async {
    // Create the table
    // id - Unique identifier, automatically handled
    // name - Recipe name
    // type - Appetizer, Entree, Dessert, Drink
    // meal - Breakfast, Lunch, Dinner
    // instructions - Cooking instructions
    await db.execute('''
      CREATE TABLE Recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT,
        meal TEXT,
        instructions TEXT NOT NULL,
        ingredients TEXT,
        dietRestriction TEXT,
        duration REAL,
        calories REAL,
        protein REAL,
        carbs REAL,
        fat REAL,
        difficulty TEXT,
        servingSize INTEGER NOT NULL
      )
    ''');

    await _insertStarterRecipes(db);
  }

  // Insert starter recipes (runs on create and on upgrade)
  Future _insertStarterRecipes(Database db) async {
  // Source: BBC Good Food (bbcgoodfood.com). Nutrition values are per serving as listed on each recipe page.
  // duration = prep + cook time in minutes. difficulty: Easy / Medium ("More effort") / Hard ("A challenge").
  // type: Appetizer, Entree, Dessert, Drink. meal: Breakfast, Lunch, Dinner.

    // 1. Fluffy American pancakes - https://www.bbcgoodfood.com/recipes/american-pancakes
    await _insertIfMissing(db, {
      'name': 'Fluffy American pancakes',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Mix 200g self-raising flour, 1 ½ tsp baking powder, 1 tbsp golden caster sugar and a pinch of salt together in a large bowl. 2. Create a well in the centre with the back of your spoon then add 3 large eggs, 25g melted butter and 200ml milk. 3. Whisk together either with a balloon whisk or electric hand beaters until smooth then pour into a jug. 4. Heat a small knob of butter and 1 tsp of oil in a large, non-stick frying pan over a medium heat. When the butter looks frothy, pour in rounds of the batter, approximately 8cm wide. Make sure you don’t put the pancakes too close together as they will spread during cooking. 5. Cook the pancakes on one side for about 1-2 mins or until lots of tiny bubbles start to appear and pop on the surface. Flip the pancakes over and cook for a further minute on the other side. Repeat until all the batter is used up. 6. Serve your pancakes stacked up on a plate with a drizzle of maple syrup and any of your favourite toppings.',
      'ingredients': '200g self-raising flour, 1 ½ tsp baking powder, 1 tbsp golden caster sugar, 3 large eggs, 25g melted butter plus extra for cooking, 200ml milk, vegetable oil for cooking, maple syrup, toppings of your choice, such as  cooked bacon chocolate chips, blueberries or peanut butter and jam',
      'dietRestriction': 'Vegetarian',
      'duration': 55,
      'calories': 356.0,
      'protein': 13.0,
      'carbs': 46.0,
      'fat': 13.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 2. The breakfast club - https://www.bbcgoodfood.com/recipes/the-breakfast-club
    await _insertIfMissing(db, {
      'name': 'The breakfast club',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Heat the oven to 220C/200C fan/gas 7. Rub 1 tbsp of the oil over a large, shallow roasting tin. Put the hash browns on one half of the tin and line the sausages up on the other. Cook for 15 mins, then flip the hash browns, turn the sausages and return to the oven for 10-15 mins until the hash browns are golden, and the sausages browned. Push everything together to make room in the tin, then lay the bacon rashers in the space and return to the oven for 10-15 mins or until the bacon fat is crisp and sizzling. 2. About 10 mins before the bacon is ready, heat 1 tbsp of oil with the butter in a frying pan until sizzling. Scatter in the mushrooms and season with salt and pepper. Fry over a high heat, tossing occasionally until softened and any liquid released has evaporated (about 5-10 mins), then tip onto a warm plate. Wipe out the pan, heat the rest of the oil and fry the eggs however you like them. While everything is cooking heat the baked beans in a saucepan or in the microwave and lightly toast the bread, then spread the toast with butter. 3. To assemble, split the sausages in half and lay three halves on each of two slices of toast. Top the sausages with the bacon then spoon over the mushrooms and top with a second slice of toast. Spread over ketchup or brown sauce (or both), then squash the hash browns down a little and top each toast with two hash browns. Top the hash browns with an egg each, then top with the last slices of toast (spread with more sauce, if you like). Press down lightly on each sandwich and serve as they are or cut in half to get a runny yolk oozing out of each sandwich. Serve with a bowl of baked beans on the side.',
      'ingredients': '3 tbsp sunflower oil, 4 frozen hash browns, 3 pork sausages, 4 rashers smoked back bacon, 15g butter plus extra for spreading, 100g chestnut mushrooms sliced, 2 eggs, 400g can baked beans, 6 slices white bread, butter ketchup and brown sauce, to serve',
      'dietRestriction': 'None',
      'duration': 55,
      'calories': 991.0,
      'protein': 41.0,
      'carbs': 85.0,
      'fat': 51.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 3. Pain au chocolat - https://www.bbcgoodfood.com/recipes/pain-au-chocolat
    await _insertIfMissing(db, {
      'name': 'Pain au chocolat',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Make the dough in a stand mixer. Combine the flour, salt, sugar and 20g softened butter. Dissolve the yeast in around 80ml tepid water, around 38C, not too hot or it will kill the yeast. Add 20g of beaten egg and the milk to the stand mixer bowl. Pour in the yeast-water mixture and turn on to a low speed with a dough hook attachment for approximately 5 mins until the dough comes together to form a rough ball. Increase the speed to medium-high and knead for a further 6-10 mins until the dough is smooth. The exact time will depend on your stand mixer. 2. Wrap the dough tightly and rest at room temperature for 10 mins. Unwrap and roll out the dough into a rectangle around 4mm thick, about 40 x 30cm. Wrap the dough rectangle and put in the freezer for 1 hr to rest or in the fridge overnight. 3. Meanwhile, on a sheet of baking parchment, shape the remaining 200g butter into a flat rectangle (about 20 x 30cm) using a rolling pin. It should be around half the length of your dough rectangle, but the same width. Put in the fridge until needed – you want it to be cold but flexible. 4. Take the chilled dough out of the fridge or freezer and lay the butter in the centre. Fold the dough edges in to meet at the centre, covering the butter. Rotate the dough 90 degrees and roll it out to about 40cm in length, keeping the same width. Handle the dough gently and return it to the fridge for 10-20 mins if it starts getting too warm. 5. Repeat the process of folding the edges of the dough into the middle, then fold it over on itself again like a book (this is known as a double turn). Chill for 30 mins. 6. Rotate the dough 90 degrees again. Roll it out long again and fold the edges in to meet in the middle. Chill for a further 30 mins. 7. Roll out the dough to 32 x 30cm and cut 8 rectangles, 8 x 15cm each. Put a chocolate baton on one long edge of each rectangle, fold the dough inwards, then put the second chocolate baton next to the folded dough and roll the dough around the encase the chocolate, with the seams of the dough now facing down. 8. Prove the pain au chocolat at 26-29°C (this is really important as proving at any higher temperature will mean the butter between the layers melts) for around 2-3 hrs, until doubled in size. 9. Heat the oven to 175C/155C fan/gas 4, brush the pain au chocolat with the remaining egg and bake for 15-18 mins until golden brown and cooked through. Best eaten on the day but will keep in an airtight container for two days.',
      'ingredients': '420g plain flour, 8g sea salt, 60g caster sugar, 220g unsalted butter (at least 82% fat works best), 20g softened, 20g fresh yeast or 10g dried yeast, 1 egg beaten, 110ml whole milk, 16  dark chocolate batons',
      'dietRestriction': 'Vegetarian',
      'duration': 63,
      'calories': 540.0,
      'protein': 8.0,
      'carbs': 54.0,
      'fat': 31.0,
      'difficulty': 'Easy',
      'servingSize': 8
    });

    // 4. Leek & kale hash with sage fried eggs - https://www.bbcgoodfood.com/recipes/leek-kale-hash-with-sage-fried-eggs
    await _insertIfMissing(db, {
      'name': 'Leek & kale hash with sage fried eggs',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Tip the potatoes into a large pan of cold salted water, then bring to the boil and cook for 6-8 mins until just tender. Drain well and leave to steam-dry for 10 mins. 2. Meanwhile, heat half the oil and all the butter in a large frying pan over a medium heat and fry the leeks, kale stalks and sage sprig for 10-12 mins until softened to the point of falling apart. Stir in the garlic and cook for 3 mins more before mixing in the kale leaves. Cook for another 5 mins until the leaves have reduced in volume and turned dark green. Scrape the mixture into a bowl and set aside. 3. Heat the remaining oil in the frying pan over a high heat and tip in the boiled potatoes, stirring to coat in the oil. Fry for 15-20 mins until golden and crispy. Return the leek mixture to the pan and stir to combine. Season to taste and divide the hash between plates. 4. Meanwhile, cook the eggs. Heat the oil in a separate pan over a medium-high heat and fry the sage leaves for 1-2 mins until darkened and crispy. Remove to a plate lined with a sheet of kitchen paper to drain. Return the pan to the heat and crack in the eggs. Fry, basting occasionally in the sage oil, until crispy at the edges, about 2-3 mins. Top each plate of hash with a crispy fried egg, and scatter over the fried sage leaves. Garnish with a little grated cheese, if you like, and season with black pepper to serve.',
      'ingredients': '800g Maris Piper potatoes cut into large chunks, 4 tbsp olive oil, 25g butter, 2 leeks finely sliced, 75g kale thick stalks finely chopped, leaves torn, 1 sage sprig, 3 garlic cloves finely sliced, grated parmesan or vegetarian alternative, to serve (optional), 2 tbsp olive oil, 10 sage leaves, 4 eggs',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 60,
      'calories': 431.0,
      'protein': 14.0,
      'carbs': 32.0,
      'fat': 26.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 5. Air fryer omelette - https://www.bbcgoodfood.com/recipes/air-fryer-omelette
    await _insertIfMissing(db, {
      'name': 'Air fryer omelette',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Heat the air fryer to 180C with a heatproof non-stick pan inside (a round pan will create a more traditional omelette shape). Put the butter in the pan and heat for 30 seconds more. 2. Beat the eggs with a few cracks of black pepper, then mix in your chosen fillings. If using cheese, add a handful to the eggs, leaving the rest to sprinkle on at the end. 3. Pour the egg mixture into the pan and cook for 8-10 mins until puffed up and golden. If you have reserved cheese, sprinkle it over the omelette. Serve with salad.',
      'ingredients': '15g  butter, 2 eggs, fillings of your choice, such as grated cheese, fried mushrooms, wilted spinach, crumbled feta or chopped ham, salad to serve',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 12,
      'calories': 251.0,
      'protein': 13.0,
      'carbs': 0.1,
      'fat': 22.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });

    // 6. Baby pancakes - https://www.bbcgoodfood.com/recipes/baby-pancakes
    await _insertIfMissing(db, {
      'name': 'Baby pancakes',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Mash the banana in a medium bowl using a fork. 2. Whisk the eggs, flour and cinnamon together in a separate bowl until combined. Add this to the mashed banana and mix well until combined. For a smoother pancake, tip all the ingredients into a blender, or blitz using a hand blender until smooth. 3. Heat ½ tsp butter and ½ tsp vegetable oil in a large non-stick pan over a medium heat and, once foaming, spoon in 1 tbsp batter to make a small pancake. Repeat until the pan is full. Cook for 1-2 mins until set at the edges, then flip over and cook for a further minute. Repeat with the remaining batter, then serve the pancakes warm with fruit, if you like.',
      'ingredients': '2 large  bananas peeled, 2  eggs, 4 tbsp  self-raising flour, ½ tsp  ground cinnamon, 1 tsp  unsalted butter, 2 tsp  vegetable oil',
      'dietRestriction': 'Vegetarian',
      'duration': 20,
      'calories': 36.0,
      'protein': 1.0,
      'carbs': 5.0,
      'fat': 1.0,
      'difficulty': 'Easy',
      'servingSize': 17
    });

    // 7. Protein porridge - https://www.bbcgoodfood.com/recipes/protein-porridge
    await _insertIfMissing(db, {
      'name': 'Protein porridge',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Cook the oats and milk in a pan over a medium-low heat for 4-6 mins, stirring continuously until thickened and creamy. Remove from the heat and sift in the protein powder. Add a splash more milk or water to loosen, if you prefer a thinner porridge. 2. Divide between bowls and top with any toppings of your choice.',
      'ingredients': '80g  porridge oats, 500ml  milk (any kind), 30g  protein powder (vanilla, chocolate or berry work well), 4 tbsp  Greek-style yogurt, 2 tbsp  pumpkin, chia, flax or sunflower seeds, 2 tbsp  nut or seed butter, 100g  frozen or fresh fruit (like berries, bananas or sliced apples), honey or other syrup, to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 20,
      'calories': 376.0,
      'protein': 25.0,
      'carbs': 39.0,
      'fat': 13.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 8. Cheese omelette - https://www.bbcgoodfood.com/recipes/cheese-omelette
    await _insertIfMissing(db, {
      'name': 'Cheese omelette',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Crack the eggs into a jug and whisk well with a fork. Season with a pinch of salt. 2. Heat the oil and butter in a medium non-stick frying pan over a medium-low heat. Once the butter has started to foam, pour in the eggs and tilt to cover the base of the pan. Using a spatula, gently draw in the eggs from four points so there are folds in the centre. Do this once or twice, then leave the eggs to cook gently for 2-3 mins, until there\'s a little raw egg still in the middle. Sprinkle over the cheese and, using your spatula, gently fold the omelette in half. Switch off the heat and let the residual heat from the pan melt the cheese for 1 min. Slide onto your plate and sprinkle over some black pepper to serve.',
      'ingredients': '2 eggs, ½ tbsp olive oil, 1 tbsp butter, 15g mature cheddar finely grated',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 10,
      'calories': 363.0,
      'protein': 17.0,
      'carbs': 0.1,
      'fat': 33.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });

    // 9. Eggs Florentine - https://www.bbcgoodfood.com/recipes/eggs-florentine
    await _insertIfMissing(db, {
      'name': 'Eggs Florentine',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. First make the hollandaise. Put the vinegar, shallots and some cracked black pepper in a small pan, and bring to a boil. Reduce the heat and simmer for 3-4 mins until the mixture has reduced by two-thirds. Remove from the heat and leave to cool. Melt the butter in a second pan over low-medium heat and pour into a jug. 2. Fill a saucepan a third full with water, bring to a boil, then reduce to a simmer. Tip the vinegar mixture into a heatproof bowl. Add the egg yolks and whisk. Set the bowl over the pan of simmering water, ensuring it doesn’t touch the water. You can use an electric whisk for this if you have one. 3. Whisk until the yolks lighten in colour and you see trails from the whisk. Whisk in the cream, then slowly pour in the melted golden butter fat leaving the milky liquid in the jug, whisking continuously until thickened. (The liquid that\'s left in the pan is essentially buttermilk that can be chilled, then used in pancakes or baking.) Season with salt and lemon juice to taste. Remove the bowl and leave at room temperature, stirring occasionally. 4. Heat the butter for the base in a large frying pan over medium heat. Add the spinach and cook for 2-3 mins, stirring, until wilted. Tip into a sieve or colander and drain off any excess, then season with salt and pepper and a little nutmeg. Set aside and keep warm. 5. Add the vinegar to a pan of boiling water, reduce to a simmer. Crack the eggs directly into the simmering water (or into ramekins first for easier handling) and poach for 2 mins 30 secs for room temperature eggs, or 3 mins for cold eggs. Lift the eggs out with a slotted spoon, drain on kitchen paper, and trim any wispy whites, if desired. 6. Heat the grill to high and toast the muffins cut-side up. Spread a layer of the wilted spinach on each toasted muffin half. Place a poached egg on top of the spinach, then generously spoon over the hollandaise sauce. Finish with a grinding of black pepper and serve immediately.',
      'ingredients': '15g butter, 200g fresh spinach, grating of nutmeg, ½ tsp  white wine vinegar, 4 fresh eggs, 2 English muffins split, 50ml white wine vinegar, 1 shallot finely chopped, 125g unsalted butter, 2 egg yolks (freeze the whites to use in another recipe), 1 tbsp  double cream, 1-2 tbsp  lemon juice to taste',
      'dietRestriction': 'Vegetarian',
      'duration': 35,
      'calories': 768.0,
      'protein': 26.0,
      'carbs': 30.0,
      'fat': 60.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 10. Spicy Bloody Mary eggs with crunchy croutons - https://www.bbcgoodfood.com/recipes/spicy-bloody-mary-eggs-with-crunchy-croutons
    await _insertIfMissing(db, {
      'name': 'Spicy Bloody Mary eggs with crunchy croutons',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': '1. Separate the rings of the sliced onions and put in a bowl with the citrus juice, a good pinch each of salt and sugar, and the vodka, if using. Leave to pickle for at least 30 mins until softened and pink. Will keep chilled for two weeks. 2. Meanwhile heat 2 tbsp of the oil in a large, deep frying pan over a medium heat. Cook the chopped onion and celery for 5-8 mins until softened and translucent. 3. Stir in the garlic and peppers, and sizzle for a few minutes. Add the tomatoes, vinegar, 1 tbsp sugar and some seasoning. Pierce each chilli a few times with the tip of a knife, add to the sauce, put the lid on and reduce the heat. Leave to simmer gently for 20 mins. 4. Meanwhile, toss the chunks of bread in a bowl with the remaining oil and some freshly cracked black pepper. Tip onto a baking tray and bake in the oven or an air fryer for 10 mins at 180C/160C fan/gas 4, tossing halfway through cooking, until golden and crunchy. 5. Taste the sauce and adjust the seasoning, adding a few splashes of Tabasco to make it as spicy as you like – it should be thick and rich at this stage. Lift out the whole chillies using a slotted spoon, if you prefer. 6. Use a large spoon to create gaps in the sauce to drop the eggs into. Working one by one, crack an egg into a bowl then drop into a pocket in the sauce. Cover with a lid and leave to simmer gently for 3-5 mins until the egg whites are set and the yolks still runny. 7. To serve, spoon dollops of yogurt over the exposed areas of sauce and scatter with the croutons, pickled onions and celery leaves. Give the eggs a twist of pepper and a drizzle of extra virgin olive oil and serve.',
      'ingredients': '2 red onions 1 sliced into rings, 1 finely chopped, juice of ½ lemon or lime, 1 tbsp sugar plus a pinch, splash of vodka (optional), 3 tbsp olive oil, 1 stick celery finely chopped, plus leaves to garnish, 2 large garlic cloves chopped, 2 red peppers sliced, 2 x 400g cans chopped tomatoes, 1 tbsp red wine vinegar, 3 red chillies, 2 chunky slices of stale bread such as sourdough or ciabatta, torn into chunks, 5-10 shakes of Tabasco to taste, 8 eggs, 150g Greek-style yogurt, drizzle of extra virgin olive oil to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 55,
      'calories': 477.0,
      'protein': 23.0,
      'carbs': 41.0,
      'fat': 23.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 11. Pan con tomate - https://www.bbcgoodfood.com/recipes/pan-con-tomate
    await _insertIfMissing(db, {
      'name': 'Pan con tomate',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Toast the bread until golden and crisp on the outside but still slightly tender in the centre. You can use a grill, griddle pan or toaster. 2. Lightly rub one side of the toast with the cut side of the garlic clove. 3. Slice the tomato in half around the middle and grate it on the coarse side of a box grater into a sieve over a bowl. 4. Spoon the grated tomato over the toast, followed by a pinch of flaky sea salt, then drizzle over the olive oil and serve.',
      'ingredients': '1 slice of  rustic bread or sourdough, 1 garlic clove, 1 large  ripe tomato, 1 tbsp  olive oil',
      'dietRestriction': 'Vegan',
      'duration': 15,
      'calories': 249.0,
      'protein': 6.0,
      'carbs': 27.0,
      'fat': 12.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });

    // 12. Chicken & tzatziki wraps - https://www.bbcgoodfood.com/recipes/chicken-tzatziki-wraps
    await _insertIfMissing(db, {
      'name': 'Chicken & tzatziki wraps',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. For the tzatziki, tip the grated cucumber and yogurt into a bowl, mix well and season. Set aside. Season the chicken with salt and pepper and rub with 1 tbsp of the olive oil. Heat the remaining oil in a pan over a medium heat. Cook the chicken for 8-10 mins until cooked through and golden brown. 2. Warm the wraps in a dry pan or microwave. Spread 2 tbsp of the tzatziki onto each wrap, top with the chicken, tomatoes and sliced cucumber. Season with a little more pepper, if you like, then fold the sides of the wrap over the filling, roll up tightly and serve.',
      'ingredients': '1 cucumber three-quarters deseeded and coarsely grated, the rest halved and sliced, 250g Greek yogurt, 500g chicken breast thinly sliced, 2tbsp olive oil, 4 wholemeal wraps, 4 large ripe tomatoes thinly sliced',
      'dietRestriction': 'None',
      'duration': 25,
      'calories': 356.0,
      'protein': 35.0,
      'carbs': 25.0,
      'fat': 12.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 13. Spiced carrot & lentil soup - https://www.bbcgoodfood.com/recipes/spiced-carrot-lentil-soup
    await _insertIfMissing(db, {
      'name': 'Spiced carrot & lentil soup',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Heat a large saucepan and dry-fry 2 tsp cumin seeds and a pinch of chilli flakes for 1 min, or until they start to jump around the pan and release their aromas. 2. Scoop out about half with a spoon and set aside. Add 2 tbsp olive oil, 600g coarsely grated carrots, 140g split red lentils, 1l hot vegetable stock and 125ml milk to the pan and bring to the boil. 3. Simmer for 15 mins until the lentils have swollen and softened. 4. Whizz the soup with a stick blender or in a food processor until smooth (or leave it chunky if you prefer). 5. Season to taste and finish with a dollop of plain yogurt and a sprinkling of the reserved toasted spices. Serve with warmed naan breads.',
      'ingredients': '2 tsp cumin seeds, pinch chilli flakes, 2 tbsp olive oil, 600g carrots washed and coarsely grated (no need to peel), 140g split red lentils, 1l hot vegetable stock (from a cube is fine), 125ml milk (to make it dairy-free, see \'try\' below), plain yogurt and naan bread, to serve',
      'dietRestriction': 'Vegetarian, Dairy-free',
      'duration': 25,
      'calories': 263.0,
      'protein': 11.0,
      'carbs': 31.0,
      'fat': 8.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 14. Mexican bean soup with guacamole - https://www.bbcgoodfood.com/recipes/mexican-bean-soup-guacamole
    await _insertIfMissing(db, {
      'name': 'Mexican bean soup with guacamole',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Heat the oil in a medium pan, add the onion (reserving 1 tbsp to make the guacamole later) and pepper and fry, stirring frequently, for 10 mins. Stir in the garlic and spices, then tip in the tomatoes and beans with their liquid, half a can of water and the bouillon powder. Simmer, covered, for 15 mins. 2. Meanwhile, peel and de-stone the avocado and tip into a bowl, add the remaining onion, coriander and lime juice with a little chilli (if using) and mash well. Ladle the soup into two bowls, top with the guacamole and serve.',
      'ingredients': '2 tsp rapeseed oil, 1 large onion finely chopped, 1 red pepper cut into chunks, 2 garlic cloves chopped, 2 tsp mild chilli powder, 1 tsp ground coriander, 1 tsp ground cumin, 400g can chopped tomatoes, 400g can black beans, 1 tsp vegetable bouillon powder, 1 small avocado, handful chopped coriander, 1 lime juiced, ½  red chilli deseeded and finely chopped (optional)',
      'dietRestriction': 'Vegetarian',
      'duration': 30,
      'calories': 391.0,
      'protein': 15.0,
      'carbs': 38.0,
      'fat': 15.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 15. Chicken satay salad - https://www.bbcgoodfood.com/recipes/chicken-satay-salad
    await _insertIfMissing(db, {
      'name': 'Chicken satay salad',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Pour the tamari into a large dish and stir in the curry powder, cumin, garlic and honey. Mix well. Slice the chicken breasts in half horizontally to make 4 fillets in total, then add to the marinade and mix well to coat. Set aside in the fridge for at least 1 hr, or overnight, to allow the flavours to penetrate the chicken. 2. Meanwhile, mix the peanut butter with the chilli sauce, lime juice, and 1 tbsp water to make a spoonable sauce. When ready to cook the chicken, wipe a large non-stick frying pan with a little oil. Add the chicken and cook, covered with a lid, for 5-6 mins on a medium heat, turning the fillets over for the last min, until cooked but still moist. Set aside, covered, to rest for a few mins. 3. While the chicken rests, toss the lettuce wedges with the cucumber, shallot, coriander and pomegranate, and pile onto plates. Spoon over a little sauce. Slice the chicken, pile on top of the salad and spoon over the remaining sauce. Eat while the chicken is still warm.',
      'ingredients': '1 tbsp tamari, 1 tsp medium curry powder, ¼ tsp ground cumin, 1 garlic clove finely grated, 1 tsp clear honey, 2 skinless chicken breast fillets (or use turkey breast), 1 tbsp crunchy peanut butter (choose a sugar-free version with no palm oil, if possible), 1 tbsp sweet chilli sauce, 1 tbsp lime juice, sunflower oil for wiping the pan, 2 Little Gem lettuce hearts, cut into wedges, ¼ cucumber halved and sliced, 1 banana shallot halved and thinly sliced, coriander chopped, seeds from ½ pomegranate',
      'dietRestriction': 'None',
      'duration': 25,
      'calories': 353.0,
      'protein': 38.0,
      'carbs': 24.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 16. Spiced lentil & butternut squash soup - https://www.bbcgoodfood.com/recipes/spiced-lentil-butternut-squash-soup
    await _insertIfMissing(db, {
      'name': 'Spiced lentil & butternut squash soup',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Heat the oil in a large flameproof casserole dish or saucepan over a medium-high heat. Fry the onions with a pinch of salt for 7 mins, or until softened and just caramelised. Add the garlic, chilli and ras el hanout, and cook for 1 min more. 2. Stir in the squash and lentils. Pour over the stock and season to taste. Bring to the boil, then reduce the heat to a simmer and cook, covered, for 25 mins or until the squash is soft. Blitz the soup with a stick blender until smooth, then season to taste. To freeze, leave to cool completely and transfer to large freezerproof bags. 3. Stir in the coriander leaves and ladle the soup into bowls. Serve topped with the dukkah, yogurt and extra coriander leaves.',
      'ingredients': '2 tbsp olive oil, 2 onions finely chopped, 2 garlic cloves crushed, ¼ tsp hot chilli powder, 1 tbsp ras el hanout, 1 butternut squash peeled and cut into 2cm pieces, 100g red lentils, 1l hot vegetable stock, 1 small bunch coriander leaves chopped, plus extra to serve, dukkah (see tip) and natural yogurt, to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 50,
      'calories': 167.0,
      'protein': 6.0,
      'carbs': 23.0,
      'fat': 5.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 17. Vegan chickpea curry jacket potatoes - https://www.bbcgoodfood.com/recipes/vegan-chickpea-curry-jacket-potato
    await _insertIfMissing(db, {
      'name': 'Vegan chickpea curry jacket potatoes',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Heat the oven to 200C/180C fan/gas 6 or if using an air fryer heat to 200C. Prick the sweet potatoes all over with a fork, then put on a baking tray and roast in the oven for 45 mins or in air fryer basket for 50 mins or until tender when pierced with a knife. 2. Meanwhile, melt the coconut oil in a large saucepan over medium heat. Add the cumin seeds and fry for 1 min until fragrant, then add the onion and fry for 7-10 mins until softened. 3. Put the garlic, ginger and green chilli into the pan, and cook for 2-3 mins. Add the spices and tikka masala paste and cook for a further 2 mins until fragrant, then tip in the tomatoes. Bring to a simmer, then tip in the Merchant Gourmet Jumbo Chickpeas and cook for a further 20 mins until thickened. Season. 4. Put the roasted sweet potatoes on four plates and cut open lengthways. Spoon over the chickpea curry and squeeze over the lemon wedges. Season, then scatter with coriander before serving.',
      'ingredients': '4 sweet potatoes, 1 tbsp coconut oil, 1 ½ tsp  cumin seeds, 1 large onion diced, 2 garlic cloves crushed, thumb-sized piece of ginger finely grated, 1 green chilli finely chopped, 1 tsp garam masala, 1 tsp ground coriander, ½ tsp turmeric, 2 tbsp tikka masala paste, 2 x 400g can  chopped tomatoes, 800g Merchant Gourmet Jumbo Chickpeas, lemon wedges and coriander leaves, to serve',
      'dietRestriction': 'Vegan, Gluten-free',
      'duration': 60,
      'calories': 276.0,
      'protein': 12.0,
      'carbs': 32.0,
      'fat': 9.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 18. Kidney bean curry - https://www.bbcgoodfood.com/recipes/kidney-bean-curry
    await _insertIfMissing(db, {
      'name': 'Kidney bean curry',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Heat the oil in a large frying pan over a low-medium heat. Add the onion and a pinch of salt and cook slowly, stirring occasionally, until softened and just starting to colour. Add the garlic, ginger and coriander stalks and cook for a further 2 mins, until fragrant. 2. Add the spices to the pan and cook for another 1 min, by which point everything should smell aromatic. Tip in the chopped tomatoes and kidney beans in their water, then bring to the boil. 3. Turn down the heat and simmer for 15 mins until the curry is nice and thick. Season to taste, then serve with the basmati rice and the coriander leaves.',
      'ingredients': '1 tbsp vegetable oil, 1 onion finely chopped, 2 garlic cloves finely chopped, thumb-sized piece of ginger peeled and finely chopped, 1 small pack coriander stalks finely chopped, leaves roughly shredded, 1 tsp ground cumin, 1 tsp ground paprika, 2 tsp garam masala, 400g can chopped tomatoes, 400g can kidney beans in water, cooked basmati rice to serve',
      'dietRestriction': 'Vegan, Gluten-free',
      'duration': 35,
      'calories': 282.0,
      'protein': 13.0,
      'carbs': 32.0,
      'fat': 8.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 19. Courgette soup - https://www.bbcgoodfood.com/recipes/courgette-potato-cheddar-soup
    await _insertIfMissing(db, {
      'name': 'Courgette soup',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Put the potatoes in a large pan with just enough water to cover them and crumble in the stock cubes. Bring to the boil, then cover and cook for 5 mins. Add the courgettes, put the lid back on and cook for 5 mins more. Throw in the spring onions, cover and cook for a final 5 mins. 2. Take off the heat, then stir in the cheese and season with the nutmeg, salt and pepper. Whizz to a thick soup, adding more hot water until you get the consistency you like. Serve scattered with extra grated cheddar, spring onions and nutmeg or pepper. Or cool and freeze in freezer bags or containers with good lids for up to 3 months.',
      'ingredients': '500g potato unpeeled and roughly chopped, 2 vegetable stock cubes, 1kg courgettes roughly chopped, bunch spring onion sliced - save 1 for serving, if eating straight away, 100g extra-mature cheddar or vegetarian alternative, grated, plus a little extra to serve, good grating fresh nutmeg plus extra to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 30,
      'calories': 131.0,
      'protein': 7.0,
      'carbs': 14.0,
      'fat': 6.0,
      'difficulty': 'Easy',
      'servingSize': 8
    });

    // 20. Burrito bowl with chipotle black beans - https://www.bbcgoodfood.com/recipes/burrito-bowl-chipotle-black-beans
    await _insertIfMissing(db, {
      'name': 'Burrito bowl with chipotle black beans',
      'type': 'Entree',
      'meal': 'Lunch',
      'instructions': '1. Cook the rice following pack instructions, then drain and return to the pan to keep warm. In a frying pan, heat the oil, add the garlic and fry for 2 mins or until golden. Add the beans, vinegar, honey and chipotle. Season and warm through for 2 mins. 2. Boil the kale for 1 min, then drain, squeezing out any excess water. Divide the rice between big shallow bowls and top with the beans, kale, avocado, tomato and onion. Serve with hot sauce, coriander and lime wedges, if you like.',
      'ingredients': '125g basmati rice, 1 tbsp olive oil, 2 garlic cloves chopped, 400g can black beans drained and rinsed, 1 tbsp cider vinegar, 1 tsp honey, 1 tbsp chipotle paste, 100g chopped curly kale, 1 avocado halved and sliced, 1 medium tomato chopped, 1 small red onion chopped, chipotle hot sauce, coriander leaves, lime wedges',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 30,
      'calories': 573.0,
      'protein': 16.0,
      'carbs': 72.0,
      'fat': 21.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 21. Chicken pasta bake - https://www.bbcgoodfood.com/recipes/chicken-pasta-bake
    await _insertIfMissing(db, {
      'name': 'Chicken pasta bake',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat 2 tbsp of the oil in a pan over a medium heat and fry the onion gently for 10-12 mins. Add the garlic and chilli flakes and cook for 1 min. Tip in the tomatoes and sugar and season to taste. Simmer uncovered for 20 mins or until thickened, then stir through the mascarpone. 2. Heat 1 tbsp of oil in a non-stick frying pan. Season the chicken and fry for 5-7 mins or until the chicken is cooked through. 3. Heat the oven to 220C/200C fan/gas 7. Cook the penne following pack instructions. Drain and toss with the remaining oil. Tip the pasta into a medium sized ovenproof dish. Stir in the chicken and pour over the sauce. Top with the cheddar, mozzarella and parsley. Bake for 20 mins or until golden brown and bubbling.',
      'ingredients': '4 tbsp olive oil, 1 onion finely chopped, 2 garlic cloves crushed, ¼ tsp chilli flakes, 2 x 400g cans chopped tomatoes, 1 tsp caster sugar, 6 tbsp mascarpone, 4 skinless chicken breasts, sliced into strips, 300g penne, 70g mature cheddar grated, 50g grated mozzarella, ½ small bunch of parsley finely chopped',
      'dietRestriction': 'None',
      'duration': 75,
      'calories': 575.0,
      'protein': 33.0,
      'carbs': 41.0,
      'fat': 30.0,
      'difficulty': 'Easy',
      'servingSize': 6
    });

    // 22. Easy chicken curry - https://www.bbcgoodfood.com/recipes/easy-chicken-curry
    await _insertIfMissing(db, {
      'name': 'Easy chicken curry',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oil in a flameproof casserole dish or large frying pan over a medium heat. Add the onion and a generous pinch of salt and fry for 8-10 mins, or until the onion has turned golden brown and sticky. 2. Add the garlic and ginger, cooking for a further minute. 3. Chop the chicken into chunky 3cm pieces, add to the pan and fry for 5 mins before stirring through the spice paste and tomatoes, along with 250ml water. Bring to the boil, lower to a simmer and cook on a gentle heat uncovered for 25-30 mins or until rich and slightly reduced. 4. Stir though the yogurt, coriander and ground almonds, season and serve with warm naan or fluffy basmati rice.',
      'ingredients': '2 tbsp sunflower oil, 1 onion thinly sliced, 2 garlic cloves crushed, thumb-sized piece of ginger grated, 6 chicken thighs boneless and skinless, 3 tbsp medium spice paste (tikka works well), 400g can chopped tomatoes, 100g Greek yogurt, 1 small bunch of coriander leaves chopped, 50g ground almonds, naan breads or cooked basmati rice, to serve',
      'dietRestriction': 'Gluten-free',
      'duration': 50,
      'calories': 354.0,
      'protein': 24.0,
      'carbs': 10.0,
      'fat': 23.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 23. Sausage ragu - https://www.bbcgoodfood.com/recipes/sausage-ragu
    await _insertIfMissing(db, {
      'name': 'Sausage ragu',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat 2 tbsp of the oil in a saucepan over a medium heat. Fry the onion with a pinch of salt for 7 mins. Add the garlic, chilli and rosemary, and cook for 1 min more. Tip in the tomatoes and sugar, and simmer for 20 mins. 2. Heat the remaining oil in a medium frying pan over a medium heat. Squeeze the sausagemeat from the skins and fry, breaking it up with a wooden spoon, for 5-7 mins until golden. Add to the sauce with the milk and lemon zest, then simmer for a further 5 mins. To freeze, leave to cool completely and transfer to large freezerproof bags. 3. Cook the pasta following pack instructions. Drain and toss with the sauce. Scatter over the parmesan and parsley leaves to serve.',
      'ingredients': '3 tbsp olive oil, 1 onion finely chopped, 2 large garlic cloves crushed, ¼ tsp chilli flakes, 2 rosemary sprigs, leaves finely chopped, 2 x 400g cans chopped tomatoes, 1 tbsp brown sugar, 6 pork sausages, 150ml whole milk, 1 lemon zested, 350g rigatoni pasta, grated parmesan and ½ small bunch parsley, leaves roughly chopped, to serve',
      'dietRestriction': 'None',
      'duration': 50,
      'calories': 601.0,
      'protein': 21.0,
      'carbs': 73.0,
      'fat': 22.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 24. Creamy pesto & kale pasta - https://www.bbcgoodfood.com/recipes/creamy-pesto-kale-pasta
    await _insertIfMissing(db, {
      'name': 'Creamy pesto & kale pasta',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oil in a large pan over a medium heat. Fry the onions for 10 mins until softened and beginning to caramelise. Add the kale and 100ml water, then cover and cook for 5 mins more, or until the kale has wilted. 2. Cook the pasta following pack instructions. Drain, reserving a little of the cooking water. Toss the pasta with the onion mixture, soft cheese and pesto, adding a splash of the reserved cooking water to loosen, if needed. Season.',
      'ingredients': '1 tbsp rapeseed oil, 2 red onions thinly sliced, 300g kale, 300g wholemeal  pasta (penne or mafalda work well), 4 tbsp reduced-fat soft cheese, 4 tbsp fresh or jar pesto or vegetarian alternative',
      'dietRestriction': 'Vegetarian',
      'duration': 35,
      'calories': 428.0,
      'protein': 17.0,
      'carbs': 55.0,
      'fat': 13.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 25. Fish pie mac ’n’ cheese - https://www.bbcgoodfood.com/recipes/fish-pie-mac-n-cheese
    await _insertIfMissing(db, {
      'name': 'Fish pie mac ’n’ cheese',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Pour the milk into a large pan and add the flour and butter. Set over a medium heat and whisk continuously until you have a smooth, thick white sauce. Remove from the heat, add the mustard, most of the cheese (save a handful for the top), peas and parsley. 2. Meanwhile, boil the pasta in a large pan of water following pack instructions until just cooked. Drain. 3. Heat the oven to 200C/180C fan/gas 6. Tip the pasta into the sauce and add half the fish, stir everything together then tip into a large baking dish. Top with the rest of the fish, pushing it into the pasta a little, then scatter with the remaining cheese. Bake for 30 mins until golden, then serve with salad, if you like. Can be chilled and eaten within three days or frozen for up to a month. Defrost in the fridge, then reheat in a microwave or oven until piping hot.',
      'ingredients': '650ml milk, 40g plain flour, 40g butter, 2 tsp Dijon mustard, 150g mature  cheddar grated, 180g frozen peas, handful of  parsley chopped, 300g macaroni, 300g fish pie mix (smoked fish, white fish and salmon), green salad to serve (optional)',
      'dietRestriction': 'None',
      'duration': 50,
      'calories': 504.0,
      'protein': 28.0,
      'carbs': 47.0,
      'fat': 22.0,
      'difficulty': 'Easy',
      'servingSize': 6
    });

    // 26. Speedy lentil coconut curry - https://www.bbcgoodfood.com/recipes/speedy-lentil-coconut-curry
    await _insertIfMissing(db, {
      'name': 'Speedy lentil coconut curry',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Put the onion, garlic, chilli, carrot and ginger in a food processor and blitz to a smooth paste. 2. Heat the oil in a medium saucepan over a medium heat and cook the veg paste for 4-5 mins until fragrant and starting to soften. Add the curry paste and cook for 1 min more, then add the lentils and stir to combine. 3. Pour in the coconut milk and 50-75ml water, and bring to the boil. Reduce the heat to a simmer and cook for 10 mins until thickened and creamy. Add the peas in the final 5 mins, and season well. 4. Stir in most of the coriander, then divide the curry between four bowls along with the rice. Sprinkle over the remaining coriander and top with the yogurt to serve.',
      'ingredients': '1 onion roughly chopped, 2 garlic cloves roughly chopped, 1 red or green chilli roughly chopped, 1 carrot roughly chopped, 10g piece of ginger peeled and chopped, 1 tsp vegetable oil, 1 ½ tbsp tikka masala curry paste, 400g can cooked green lentils, 220ml  light coconut milk, 200g frozen peas, 10g coriander roughly chopped, 200g cooked brown rice, 4 tbsp light coconut or natural yogurt to serve',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 25,
      'calories': 282.0,
      'protein': 12.0,
      'carbs': 37.0,
      'fat': 8.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 27. Fajita-style pasta - https://www.bbcgoodfood.com/recipes/fajita-style-pasta
    await _insertIfMissing(db, {
      'name': 'Fajita-style pasta',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oil in a large shallow casserole or frying pan. Add the chicken and fry for 5 mins over a medium heat until golden all over. Remove and set aside on a plate. 2. Put the onion and peppers in the same pan and fry over a medium heat for 8-10 mins. Add the garlic, dried herbs and spices and cook for 1 min. Add the tomato purée and cook for 2 mins. Return the chicken to the pan and pour in the cream, stirring to combine. Season to taste. 3. Cook the pasta following pack instructions, then drain and reserve 150ml of the cooking water. Add the pasta to the pan with 50ml of the water and stir everything together over the heat. Add a little more water to loosen if needed. Season to taste and stir through the parsley. Divide between six bowls and top with a little cheese and extra chopped parsley, if you like. This can be packed into a lunchbox and eaten cold, too.',
      'ingredients': '2 tbsp  olive oil, 2 large skinless chicken breasts cut into strips, 1 onion thinly sliced, 1 red pepper deseeded and sliced, 1 yellow pepper deseeded and sliced, 1 garlic clove crushed, 1⁄4 tsp chilli powder, 1 heaped tsp sweet smoked paprika, 1⁄2 tsp dried oregano, 1 tsp ground coriander, 1⁄2 tsp ground cumin, 3 tbsp tomato purée, 80ml double cream, 350g penne or rigatoni pasta, 1⁄2 small bunch of flat-leaf parsley finely chopped, grated parmesan or cheddar, to serve',
      'dietRestriction': 'None',
      'duration': 35,
      'calories': 395.0,
      'protein': 23.0,
      'carbs': 41.0,
      'fat': 14.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 28. Creamy garlic pasta - https://www.bbcgoodfood.com/recipes/creamy-garlic-pasta
    await _insertIfMissing(db, {
      'name': 'Creamy garlic pasta',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Begin by cooking the pasta following pack instructions. Meanwhile, melt the Kerrygold Salted Butter in your largest frying pan. Once foaming, add the garlic and 25 twists of a black pepper mill. Cook for 4-5 mins, until the garlic is light golden and fragrant. 2. Stir in the flour to form a paste. Stir for 1-2 mins, then slowly whisk in the chicken stock until you have a smooth sauce. Pour in the double cream and sprinkle in most of the parmesan. Stir until everything is melted and combined, then season to taste. 3. Transfer the pasta straight into the sauce, alongside a good splash of the cooking water. Mix thoroughly, adding a little more pasta water if necessary, until you have a thick and glossy sauce. 4. Divide between four bowls and serve topped with the chopped parsley and remaining parmesan.',
      'ingredients': '300g tagliatelle (any long pasta will work), 20g Kerrygold Salted Butter, 6 garlic cloves finely chopped, 2 tbsp plain flour, 150ml chicken stock, 200ml double cream, 85g parmesan grated, 20g flat-leaf parsley roughly chopped',
      'dietRestriction': 'None',
      'duration': 25,
      'calories': 699.0,
      'protein': 20.0,
      'carbs': 66.0,
      'fat': 38.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 29. Meatball black bean chilli - https://www.bbcgoodfood.com/recipes/meatball-black-bean-chilli
    await _insertIfMissing(db, {
      'name': 'Meatball black bean chilli',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oil in a large flameproof casserole dish over a medium heat. Fry the meatballs for 5 mins until browned, then transfer to a plate with a slotted spoon. 2. Fry the onion and peppers with a pinch of salt for 7 mins. Add the coriander stalks, garlic, paprika and cumin and fry for 1 min more. Tip in the sugar, tomatoes and beans, and bring to a simmer. Season, return the meatballs to the pan and cook, covered, for 15 mins. To freeze, leave to cool completely and transfer to large freezerproof bags. 3. Serve the chilli with the rice and the coriander leaves scattered over.',
      'ingredients': '2 tbsp olive oil, 12 beef meatballs, 1 onion finely sliced, 2 mixed peppers sliced, ½ large bunch coriander leaves and stalks chopped, 2 large garlic cloves crushed, 1 tsp hot smoked paprika, 2 tsp ground cumin, 1 heaped tbsp light brown soft sugar, 2 x 400g cans chopped tomatoes, 2 x 400g cans black beans drained and rinsed, cooked rice to serve',
      'dietRestriction': 'Gluten-free',
      'duration': 40,
      'calories': 423.0,
      'protein': 24.0,
      'carbs': 36.0,
      'fat': 16.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 30. Creamy salmon, leek & potato traybake - https://www.bbcgoodfood.com/recipes/creamy-salmon-leek-potato-traybake
    await _insertIfMissing(db, {
      'name': 'Creamy salmon, leek & potato traybake',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oven to 200C/180C fan/gas 6. Bring a medium pan of water to the boil. Add the potatoes and cook for 8 mins. Drain and leave to steam-dry in a colander for a few minutes. Toss the potatoes with ½ of the oil and plenty of seasoning in a baking tray. Put in the oven for 20 mins, tossing halfway through the cooking time. 2. Meanwhile, heat the remaining oil in a frying pan over a medium heat. Add the leek and fry for 5 mins, or until beginning to soften. Stir through the garlic for 1 min, then add the cream, capers and 75ml hot water, then bring to the boil. Stir through the chives. 3. Heat the grill to high. Pour the creamy leek mixture over the potatoes, then sit the salmon fillets on top. Grill for 7-8 mins, or until just cooked through. Serve topped with extra chives and capers and a salad on the side, if you like.',
      'ingredients': '250g baby potatoes thickly sliced, 2 tbsp olive oil, 1 leek halved, washed and sliced, 1 garlic clove crushed, 70ml double cream, 1 tbsp capers plus extra to serve, 1 tbsp chives plus extra to serve, 2 skinless salmon fillets, mixed rocket salad to serve (optional)',
      'dietRestriction': 'Gluten-free',
      'duration': 40,
      'calories': 696.0,
      'protein': 39.0,
      'carbs': 19.0,
      'fat': 50.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 31. Spicy chickpea stew - https://www.bbcgoodfood.com/recipes/spicy-chickpea-stew
    await _insertIfMissing(db, {
      'name': 'Spicy chickpea stew',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oil in a large lidded pan over a medium heat and fry the onions for 10 mins, stirring often until golden. Stir in the peppers and cook for 5 mins more. 2. Add the chilli powder, coriander and cumin, stir briefly, then tip in the passata and chickpeas along with the liquid from the cans. 3. Stir in the bouillon powder, raisins and lemon zest, then add the cauliflower. Cover tightly and simmer over a medium heat for 15-20 mins until the cauliflower is tender. Stir in half the parsley. 4. Meanwhile, put the couscous in a heatproof bowl and pour over 175ml boiling water from the kettle. Stir in the lemon juice, then cover and let stand for about 10 mins until the couscous has absorbed the liquid and is tender. Stir in the toasted flaked almonds and most of the remaining parsley. 5. Divide half the couscous between two plates and top with half the chickpea stew and the rest of the parsley. Leave the remainder to cool for another day. Will keep covered and chilled for up to three days. Reheat the stew in a pan over a low heat with a splash of water until piping hot. Reheat the couscous in the microwave.',
      'ingredients': '1 tbsp rapeseed oil, 2 onions (320g), roughly chopped, 2 green peppers deseeded and cut into cubes, 2 tsp hot chilli powder, 1 tbsp ground coriander, 1 tsp ground cumin, 500ml carton passata, 2 x 400g cans chickpeas, 2 tsp vegetable bouillon powder, 40g flame raisins, ½ lemon juiced, flesh scooped out and white pith removed, then zest finely chopped (you’ll need 2 tsp), 350g cauliflower florets, 15g parsley chopped, 140g wholemeal couscous, 40g toasted flaked almonds',
      'dietRestriction': 'Vegetarian',
      'duration': 65,
      'calories': 514.0,
      'protein': 22.0,
      'carbs': 63.0,
      'fat': 15.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 32. Veggie sausage casserole - https://www.bbcgoodfood.com/recipes/veggie-sausage-casserole
    await _insertIfMissing(db, {
      'name': 'Veggie sausage casserole',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': '1. Heat the oil in a large flameproof casserole dish over a medium-high heat. Once shimmering, add the sausages and quickly stir to coat in the oil. Cook for 5-7 mins until browned all over, then scoop out and set aside on a plate. Turn the heat down to medium and stir in the onion, celery and carrot with a big pinch of salt. Cook for 8-10 mins until softened but not coloured. 2. Stir in the garlic, paprika and fennel seeds, if using, and cook for another 1-2 mins until fragrant. Stir in the herb sprigs and the tomato purée. Stir well to coat everything and cook for 5 mins until the tomato purée has caramelised and turned dark red. Add the vinegar, tomatoes, stock and beans, along with their liquid, then rinse out the tomato can with water and add that too. Bring to a simmer and return the sausages to the pan. Simmer gently for 40-45 mins, stirring frequently, until the sauce has thickened. Season to taste, remove the herb sprigs and discard. 3. Drizzle over the pesto and serve with warm crusty bread, if you like.',
      'ingredients': '2 tbsp olive oil, 8 vegetarian sausages, 1 large red onion finely chopped, 2 celery sticks finely chopped, 2 carrots finely chopped, 3 garlic cloves finely chopped, 1 tsp sweet smoked paprika, 1 tsp fennel seeds (optional), few sprigs of  thyme rosemary or sage, 2 tbsp tomato purée, 1 tbsp balsamic vinegar, 400g can plum tomatoes, 250ml vegetable stock, 400g can butter beans, 60g fresh vegetarian pesto, warm crusty bread to serve (optional)',
      'dietRestriction': 'Vegetarian',
      'duration': 80,
      'calories': 300.0,
      'protein': 11.0,
      'carbs': 27.0,
      'fat': 13.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 33. Baked camembert - https://www.bbcgoodfood.com/recipes/baked-camembert
    await _insertIfMissing(db, {
      'name': 'Baked camembert',
      'type': 'Appetizer',
      'meal': 'Dinner',
      'instructions': '1. Heat oven to 200C/180C fan/gas 6 or heat your air fryer to 180C for 4 mins. 2. Unwrap the camembert from its packaging, then place back into its box. Tie string around the box to secure. If using a cheese that doesn’t have a box, put into a ramekin or other ovenproof dish. 3. Slash the cheese a few times and top with vermouth, dry white wine or kirsch, thyme sprigs and a pinch of dried chilli flakes. 4. Bake on a baking tray for 20 mins, or if using an air-fryer, cook for 15-20 mins until gooey. Serve with toasted bread or crackers for dipping.',
      'ingredients': '250g camembert or brie, or other similar cheese, 1 tbsp vermouth or dry white wine, or kirsch, 2 thyme sprigs, pinch of dried chilli flakes, crackers or toasted bread to serve',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 25,
      'calories': 123.0,
      'protein': 9.0,
      'carbs': 0.1,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 6
    });

    // 34. Creamy mushroom soup - https://www.bbcgoodfood.com/recipes/creamy-mushroom-soup
    await _insertIfMissing(db, {
      'name': 'Creamy mushroom soup',
      'type': 'Appetizer',
      'meal': 'Dinner',
      'instructions': '1. Bring a kettle to the boil, then pour the water over the dried porcini just to cover. Heat half the butter in a saucepan, then gently sizzle the onion, garlic and thyme for 5 mins until softened and starting to brown. Drain the porcini, reserving the juice, then add to the onion with the mixed wild mushrooms. Leave to cook for 5 mins until they go limp. 2. Pour over the stock and the reserved juices, bring to the boil, then simmer for 20 mins. Stir in crème fraîche, then simmer for a few mins more. Blitz the soup with a hand blender or liquidiser, pass through a fine sieve, then set aside. 3. Heat the remaining butter in a frying pan, fry the bread cubes until golden, then drain on kitchen paper. To serve, heat the soup and froth up with a hand blender, if you like. Ladle the soup into bowls, scatter over the croûtons and chives and drizzle with truffle oil.',
      'ingredients': '25g dried porcini (ceps), 50g butter, 1 onion finely chopped, 1 garlic clove sliced, thyme sprigs, 400g mixed wild mushrooms, 850ml vegetable stock, 200ml tub crème fraîche, 4 slices white bread about 100g, cubed, chives and truffle oil, to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 70,
      'calories': 347.0,
      'protein': 8.0,
      'carbs': 20.0,
      'fat': 27.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 35. Baked feta with sesame & honey - https://www.bbcgoodfood.com/recipes/baked-feta-sesame-honey
    await _insertIfMissing(db, {
      'name': 'Baked feta with sesame & honey',
      'type': 'Appetizer',
      'meal': 'Dinner',
      'instructions': '1. Heat the oven to 200C/180C fan/gas 6, or if using an air-fryer, heat to 180C for 3 mins. Put the sesame seeds in a shallow dish and brush the block of feta all over with the honey. Carefully press the honey-coated feta into the sesame seeds, turning so that it’s well crusted with seeds. 2. Put the feta in a baking dish (it should fit snugly), then sprinkle over the oregano and a pinch of sea salt. Drizzle with some olive oil. Bake in the oven for 15-20 mins, or cook in the air-fryer for 15 mins until the feta is soft, then drizzle with a little extra honey and serve with the pitta breads on the side.',
      'ingredients': '1 tbsp sesame seeds toasted, 200g block feta, 2 tbsp honey plus extra to serve, 1 tsp roughly chopped   oregano, olive oil for drizzling, warmed pitta breads to serve',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 25,
      'calories': 192.0,
      'protein': 8.0,
      'carbs': 10.0,
      'fat': 13.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 36. Sarmale (Romanian cabbage rolls) - https://www.bbcgoodfood.com/recipes/sarmale-romanian-cabbage-rolls
    await _insertIfMissing(db, {
      'name': 'Sarmale (Romanian cabbage rolls)',
      'type': 'Appetizer',
      'meal': 'Dinner',
      'instructions': '1. Start by making the filling. Heat the oil in a frying pan over a medium heat and cook the onion for 20 mins until soft, golden and starting to caramelise. Add a splash of water if needed (if the onion looks like it’s starting to burn). Tip into a large bowl and set aside to cool. 2. Meanwhile, cook the rice in a pan of boiling water for 10-12 mins until just al dente. Drain and tip into the bowl with the onions. Set aside to cool. 3. Soak the slice of bread in just enough water to cover it for 5 mins, then squeeze out any excess liquid. Add to the cooled onion and rice along with 1 tsp salt, 1 tsp pepper and the remaining filling ingredients. Mix using your hands until everything is well combined. Chill the mixture while you prepare the sauerkraut. 4. Unroll the leaves and rinse under cold water (don’t pat dry; it makes them easier to roll if a little damp). Trim away the thick stem at the base of each leaf, so you\'re left with a small A-shaped gap. Turn in the sides of that A to create a whole leaf shape again. Set aside the trimmings for later. Aim for around 34–36 leaves in total. Set aside any remaining leaves with the stem trimmings. 5. Put roughly 1 tbsp of the filling mixture at the base or widest part of each leaf and press into a roughly 5cm long sausage, leaving a small gap at each edge. Roll tightly once or twice, fold in the sides, then continue rolling to seal. Arrange the rolls seam-side down on a plate or board. If your rolls seem loose, you may have added slightly too much filling. Repeat with the remaining leaves. 6. Shred the cabbage trimmings plus the remaining cabbage leaves and sprinkle over enough to cover the base of a large, wide ovenproof casserole dish or pan. Arrange the stuffed rolls on top in a circular pattern, nestling them snugly together so they hold their shape during cooking. Add in a second layer if needed, tucking the diced pancetta in between the rolls. Sprinkle over any remaining shredded cabbage. 7. In a large jug, mix together the tomato purée, paprika and dill or thyme. Gradually whisk in 750ml water until combined. Pour the liquid over the rolls, cover the pan with a lid and bring to a boil over a medium-high heat. Turn down the heat to low and simmer gently for 3 hrs until the rolls are very tender, shaking the pan occasionally to stop the rolls from sticking. For a lightly caramelised finish, uncover the pan and cook in an oven heated to 180C/160C fan/gas 4 for the final 30 mins. 8. Serve with creamy polenta, soured cream, pickled chillies and a sprinkling of fresh dill. Sarmale can be served straightaway but even better the next day. Reheat gently on the hob for about 45 mins.',
      'ingredients': '2 x 1kg vacuum-packed bags  sauerkraut leaves see tip, 150g  smoked pancetta diced, 1 tbsp  tomato purée, 2 tsp  sweet smoked paprika (or regular smoked paprika), 2 tsp  dried dill or thyme, plus extra to serve, 2 tbsp  flavourless oil, 1 onion finely chopped, 50g  white rice (long or short grain), 1 slice  white bread crust removed, 400g  pork mince, 1½ tsp  dried thyme, 1 tsp  sweet smoked paprika (or just use smoked), polenta soured cream, pickled chillies and fresh dill',
      'dietRestriction': 'None',
      'duration': 265,
      'calories': 63.0,
      'protein': 4.0,
      'carbs': 5.0,
      'fat': 3.0,
      'difficulty': 'Easy',
      'servingSize': 34
    });

    // 37. Luxury hummus - https://www.bbcgoodfood.com/recipes/luxury-houmous
    await _insertIfMissing(db, {
      'name': 'Luxury hummus',
      'type': 'Appetizer',
      'meal': 'Dinner',
      'instructions': '1. Blitz ¾ of the chickpeas and 120ml of the oil with the rest of the hummus ingredients and a good amount of seasoning in a food processor. Add a little water if it is too thick. Spoon the hummus into a serving bowl or spread it onto a plate. Can be made up to two days in advance and kept in the fridge. 2. Dry the rest of the chickpeas on kitchen paper as much as possible. Heat the remaining oil in a frying pan over a medium heat. Add the chickpeas and a large pinch of salt, and fry until golden, around 4 mins. Drain on kitchen paper. 3. Drizzle some oil over the hummus, then sprinkle with the spices, parsley and pomegranate seeds. Scatter the fried chickpeas on top and serve with crudités and warm pitta breads.',
      'ingredients': '700g chickpeas drained, 135ml extra virgin olive oil plus extra for drizzling, 2 garlic cloves roughly chopped, 1 tbsp tahini, 1½ lemons juiced, ½ tsp smoked paprika, ½ tsp sumac, ½ small pack parsley roughly chopped, 40g pomegranate seeds, crudités and warm pittas, to serve',
      'dietRestriction': 'Vegan',
      'duration': 25,
      'calories': 242.0,
      'protein': 5.0,
      'carbs': 10.0,
      'fat': 20.0,
      'difficulty': 'Easy',
      'servingSize': 8
    });

    // 38. Cured salmon with prawns, pickled salad & dill lime crème fraîche - https://www.bbcgoodfood.com/recipes/asian-cured-salmon-prawns-pickled-salad-dill-lime-creme-fraiche
    await _insertIfMissing(db, {
      'name': 'Cured salmon with prawns, pickled salad & dill lime crème fraîche',
      'type': 'Appetizer',
      'meal': 'Dinner',
      'instructions': '1. Check the fish for bones and, if needed, remove with tweezers. To make the cure, put the lemongrass, 125g sugar, the salt, lime juice, zest of 1 lime, 1 tbsp rice vinegar, 1 garlic clove, the coriander and half of the dill, including stems, into a food processor. Blitz until the lemongrass is finely chopped, then stir in a quarter of the sliced chillies. 2. Cross two large pieces of cling film in a roasting tin and spoon on a third of the cure, then top with the fish. Cover the fish with the rest of the cure. Wrap tightly and leave for 36-48 hrs, then scrape off the cure, rinse the fish in cold water and pat dry. The fillet will feel firm. 3. On the day of serving, start the other elements of the recipe. Shave the turnips into very thin slices using a mandoline, then plunge them into iced water with a dash of the vinegar. Leave for an hour, then drain well. Thinly slice the onion and mix with the turnip slices, 2 tbsp vinegar, 2 tsp sugar and a pinch of salt. Cover and steep for at least 1 hr, or chill for a few hrs. 4. Finely chop the remaining dill leaves and stir most of them into the crème fraîche with the remaining lime zest and a little seasoning, then chill. 5. For the dressing, stir together the remaining 2 tbsp sugar, 2 tbsp vinegar, another quarter of the sliced chillies and the crushed garlic and leave until the sugar dissolves. 6. Slice the fish into approx 20 slices, taking the knife down to the skin, then easing the blade underneath each piece to remove it. 7. When ready to serve, spoon and swoosh the dill crème fraîche down the middle of each plate, then top with overlapping salmon slices. Add 3 prawns per serving. Lift the salad from its juices and mound to one side. Scatter with a little extra dill and the remaining sliced chillies, then drizzle the dressing over the fish and prawns (or let your guests do that bit at the table).',
      'ingredients': '550g salmon fillet skin on, 2 sticks lemongrass roughly chopped, 125g caster or granulated sugar plus 2 tsp and another 2 tbsp, 150g coarse sea salt, 2 limes zested, 1 juiced, 5 tbsp Japanese rice vinegar plus a dash, 2 garlic cloves crushed, small bunch coriander (half of 28g pack), 20g pack dill, 2 fresh red Thai chillies sliced (deseeded if you don’t like it too hot), 140g baby turnips skin on, 1 small red onion peeled, 6 tbsp full-fat crème fraîche, 12 large cooked peeled prawns',
      'dietRestriction': 'Gluten-free',
      'duration': 40,
      'calories': 410.0,
      'protein': 21.0,
      'carbs': 13.0,
      'fat': 30.0,
      'difficulty': 'Medium',
      'servingSize': 6
    });

    // 39. Easy chocolate molten cakes - https://www.bbcgoodfood.com/recipes/easy-chocolate-molten-cakes
    await _insertIfMissing(db, {
      'name': 'Easy chocolate molten cakes',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Heat oven to 200C/180C fan/gas 6. Butter 6 dariole moulds or basins well and place on a baking tray. 2. Put 100g butter and 100g chopped dark chocolate in a heatproof bowl and set over a pan of hot water (or alternatively put in the microwave and melt in 30 second bursts on a low setting) and stir until smooth. Set aside to cool slightly for 15 mins. 3. Using an electric hand whisk, mix in 150g light brown soft sugar, then 3 large eggs, one at a time, followed by ½ tsp vanilla extract and finally 50g plain flour. Divide the mixture among the darioles or basins. 4. You can now either put the mixture in the fridge, or freezer until you\'re ready to bake them. Can be cooked straight from frozen for 16 mins, or bake now for 10-12 mins until the tops are firm to the touch but the middles still feel squidgy. 5. Carefully run a knife around the edge of each pudding, then turn out onto serving plates and serve with single cream.',
      'ingredients': '100g butter plus extra to grease, 100g dark chocolate chopped, 150g light brown soft sugar, 3 large eggs, ½ tsp vanilla extract, 50g plain flour, single cream to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 35,
      'calories': 391.0,
      'protein': 6.0,
      'carbs': 36.0,
      'fat': 24.0,
      'difficulty': 'Easy',
      'servingSize': 6
    });

    // 40. Biscoff cheesecake - https://www.bbcgoodfood.com/recipes/biscoff-cheesecake
    await _insertIfMissing(db, {
      'name': 'Biscoff cheesecake',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Line the base of a 20cm springform cake tin with baking parchment. Melt the butter in the microwave in 30-second bursts. Meanwhile, blitz the Biscoff biscuits in a food processor to make coarse crumbs. Transfer to a bowl, then stir through the melted butter until it has a texture like damp sand. 2. Tip the mixture into the lined tin, using a spoon to smooth and flatten. Keep chilled while you make the filling. 3. Gently melt the Biscoff spread in a microwave-safe bowl in short bursts in the microwave, then leave to cool slightly. Put the soft cheese in a large bowl and beat with an electric whisk to loosen. Pour in the cream and sift over the icing sugar, then add the Biscoff spread. Beat on a low speed for 2-3 mins until thick and smooth. 4. Spoon the mixture onto the chilled base, then smooth out using the back of the spoon. Chill for 4-5 hrs or overnight. 5. To decorate, melt some Biscoff spread in the microwave as before and drizzle over the top of the cheesecake, then scatter over some roughly crushed biscuits.',
      'ingredients': '120g  salted butter, 250g  Lotus Biscoff biscuits plus a few extra to decorate, 150g  smooth Lotus Biscoff spread plus extra to decorate, 500g  soft cheese, 300ml  double cream, 4 tbsp  icing sugar',
      'dietRestriction': 'Vegetarian',
      'duration': 25,
      'calories': 595.0,
      'protein': 5.0,
      'carbs': 35.0,
      'fat': 48.0,
      'difficulty': 'Easy',
      'servingSize': 10
    });

    // 41. Chocolate tiffin - https://www.bbcgoodfood.com/recipes/chocolate-tiffin
    await _insertIfMissing(db, {
      'name': 'Chocolate tiffin',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Butter and line a 15-20cm tin with baking parchment. In a large saucepan, melt the butter, sugar, syrup and cocoa. Stir through the biscuits and raisins. 2. Pour the mixture into the prepared tin and press down, then smooth the top with the back of a spoon. Microwave both chocolates in short 20 second bursts, stirring frequently, until melted. Pour them over the mixture in the tin. Use a palette knife or spoon to smooth over, so it\'s completely coated in chocolate. 3. Put the tin into the fridge and leave for about 2 hrs to set, or overnight. Run a kitchen knife under the hot tap then cut into squares.',
      'ingredients': '150g butter cubed, plus extra for the tin, 3 tbsp caster sugar, 3 tbsp golden syrup, 6 tsp cocoa powder, 225g biscuits crushed, handful of raisins, 110g milk chocolate, 110g dark chocolate',
      'dietRestriction': 'Vegetarian',
      'duration': 17,
      'calories': 266.0,
      'protein': 3.0,
      'carbs': 27.0,
      'fat': 16.0,
      'difficulty': 'Easy',
      'servingSize': 12
    });

    // 42. White chocolate cheesecake - https://www.bbcgoodfood.com/recipes/white-chocolate-cheesecake
    await _insertIfMissing(db, {
      'name': 'White chocolate cheesecake',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Crush the biscuits in a food processor until completely ground. Add butter and whizz again until you have the desired crumbly consistency. 2. Grease and line the base of a 23cm deep, loose-bottomed cake tin. Add the biscuit mixture to the cake tin and pat it flat. Leave to set in the fridge for approximately 30 mins. 3. Begin melting the chocolate in a heatproof glass bowl over a small pan of hot water on a low heat. Stir occasionally to prevent sticking. Remove from the heat and leave to cool for 10 mins until barely warm but still liquid. 4. Meanwhile whisk the cream cheese and mascarpone together. Add double cream and keep whisking until the mixture is just holding its own shape. Finally, add the melted chocolate and whisk until just combined. 5. Spoon the mixture over the cooled and set biscuit base, then smooth the top. Return to the fridge to cool for at least 6 hrs until the topping is set. Finally, decorate with fruit.',
      'ingredients': '300g digestive biscuits (make sure the products are free from any trace of nuts when preparing for someone with a nut allergy), 150g unsalted butter melted, plus extra to grease, 400g white chocolate broken into pieces, 300g full-fat cream cheese (we used Philadelphia), 250g mascarpone, 300ml double cream, 200g strawberries or raspberries, to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 25,
      'calories': 801.0,
      'protein': 8.0,
      'carbs': 43.0,
      'fat': 66.0,
      'difficulty': 'Easy',
      'servingSize': 10
    });

    // 43. Lemon sponge cake - https://www.bbcgoodfood.com/recipes/lemon-sponge
    await _insertIfMissing(db, {
      'name': 'Lemon sponge cake',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Heat oven to 170C/150C fan/gas 3. Butter a deep, loose-bottomed, 18cm cake tin and line the base with baking parchment. 2. Beat the butter and caster sugar together with an electric whisk until fluffy and pale in colour. Crack the eggs in one at a time, beating well after each addition, then stir in the lemon zest. Fold in the flour, baking powder and ½ tsp salt, then fold in the yogurt. 3. Spoon the mixture into the lined tin, smoothing the top with a spatula. Bake in the centre of the oven for 50-55 mins, or until golden brown on top and firm to the touch. Cool in the tin for 10 mins before turning out onto a wire rack to cool completely. Will keep in an airtight container for up to four days, or in the freezer for up to a month. 4. When you’re ready to decorate, sieve the icing sugar into a bowl and beat in enough of the lemon juice to create a thick icing. Set the cake on a serving plate or cake stand, then spoon over the icing, allowing it to drip down the sides a little. Top with the lemon zest or candied peel, if using (see below), and cut into generous wedges to serve. 5. To make candied lemon peel, peel large, wide strips from the lemons using a vegetable peeler. Remove any pith with a knife, then julienne the peel into very thin matchsticks. Tip the granulated sugar into a saucepan with 200ml water and set over a medium heat until the sugar has dissolved. Add the lemon peel and simmer gently for 15 mins, then scoop the peel out using a slotted spoon and set on a piece of kitchen paper to cool. Use to decorate the top of your cake.',
      'ingredients': '175g unsalted butter softened, plus extra for the tin, 175g golden caster sugar, 3 large eggs, 3 large unwaxed lemons zested, plus 4-4 ½ tbsp juice, 250g self-raising flour, ½ tsp baking powder, 100g Greek yogurt, 400g icing sugar, lemon zest or candied peel, to serve (optional), 2 large lemons, 200g granulated sugar',
      'dietRestriction': 'Vegetarian',
      'duration': 80,
      'calories': 409.0,
      'protein': 5.0,
      'carbs': 64.0,
      'fat': 15.0,
      'difficulty': 'Easy',
      'servingSize': 10
    });

    // 44. Vanilla panna cotta - https://www.bbcgoodfood.com/recipes/vanilla-panna-cotta
    await _insertIfMissing(db, {
      'name': 'Vanilla panna cotta',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Add the sheets of gelatine to a bowl of cold water and soak for 5 mins. 2. Pour the milk and cream into a saucepan with the sugar and vanilla seeds (to scrape the seeds out of the pod, use the back of a knife). Stir to combine and bring to a simmer, then remove from the heat. Take the gelatine out of the cold water and squeeze out the excess, then add to the milk mixture. Stir until completely dissolved. Tip into four ramekins and place in the fridge to set for at least a couple of hours. 3. To serve, turn each ramekin upside-down onto a serving plate. If the panna cotta won\'t drop out, carefully dip the ramekin in a bowl of warm water to loosen it. Serve with a drizzle of strawberry compote and sliced fresh strawberries.',
      'ingredients': '2 ½ sheets gelatine, 150ml milk, 400ml double cream, 60g caster sugar, 1 vanilla pod split lengthways, fresh strawberries to serve, strawberry compote to serve',
      'dietRestriction': 'Gluten-free',
      'duration': 15,
      'calories': 584.0,
      'protein': 4.0,
      'carbs': 18.0,
      'fat': 55.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });

    // 45. Easy cornflake tart - https://www.bbcgoodfood.com/recipes/easy-cornflake-tart
    await _insertIfMissing(db, {
      'name': 'Easy cornflake tart',
      'type': 'Dessert',
      'meal': 'Dinner',
      'instructions': '1. Heat the oven to 180C/160C fan/gas 4. Unroll the pastry and briefly roll out on a lightly floured work surface until it\'s large enough to fit a 23cm loose-bottomed tart tin. Use the rolling pin to lift the pastry over the tin, then press into the corners and sides so the excess pastry hangs over the rim. Trim this away, leaving just a small amount of excess hanging over the rim. 2. Line the pastry with baking parchment and fill with baking beans or uncooked rice. Bake for 15 mins. Remove the parchment and beans, then bake for another 5-10 mins until just golden. Remove from the oven and trim any excess pastry from the edges using a serrated knife. 3. Heat the butter, syrup and sugar in a small pan with a pinch of salt, stirring frequently, until melted and smooth. Fold in the cornflakes to coat in the butter mixture. 4. Spoon the jam into the cooked pastry base, then level the surface. Tip the cornflake mixture over the jam and gently press down until all of the jam is covered with a layer of the mixture. Return the tart to the oven and bake for another 5 mins until the cornflakes are golden and toasted. Leave to cool until just warm before slicing and serving with custard.',
      'ingredients': '320g ready-rolled shortcrust pastry, plain flour to dust, 50g butter, 125g golden syrup, 25g light brown soft sugar, 100g cornflakes, 125g strawberry or raspberry jam, custard to serve',
      'dietRestriction': 'Vegetarian',
      'duration': 60,
      'calories': 305.0,
      'protein': 3.0,
      'carbs': 41.0,
      'fat': 14.0,
      'difficulty': 'Easy',
      'servingSize': 8
    });

    // 46. Two-minute breakfast smoothie - https://www.bbcgoodfood.com/recipes/two-minute-breakfast-smoothie
    await _insertIfMissing(db, {
      'name': 'Two-minute breakfast smoothie',
      'type': 'Drink',
      'meal': 'Breakfast',
      'instructions': '1. Put all the ingredients in a blender and whizz for 1 min until smooth. 2. Pour the banana oat smoothie into two glasses to serve.',
      'ingredients': '1 banana, 1 tbsp porridge oats, 80g soft fruit (whatever you have – strawberries, blueberries, and mango all work well), 150ml milk, 1 tsp honey, 1 tsp vanilla extract',
      'dietRestriction': 'Vegetarian',
      'duration': 2,
      'calories': 146.0,
      'protein': 4.0,
      'carbs': 22.0,
      'fat': 4.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 47. Breakfast smoothie - https://www.bbcgoodfood.com/recipes/breakfast-smoothie
    await _insertIfMissing(db, {
      'name': 'Breakfast smoothie',
      'type': 'Drink',
      'meal': 'Breakfast',
      'instructions': '1. Slice the banana into your blender or food processor and add the berries of your choice. Whizz until smooth. With the blades whirring, pour in juice or water to make the consistency you like. Toss a few extra fruits on top, drizzle with honey and serve.',
      'ingredients': '1 small ripe banana, about 140g blackberries, blueberries, raspberries or strawberries (or use a mix), plus extra to serve, apple juice or mineral water, optional, runny honey to serve',
      'dietRestriction': 'Gluten-free',
      'duration': 5,
      'calories': 124.0,
      'protein': 2.0,
      'carbs': 25.0,
      'fat': 1.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });

    // 48. Green breakfast smoothie - https://www.bbcgoodfood.com/recipes/green-breakfast-smoothie
    await _insertIfMissing(db, {
      'name': 'Green breakfast smoothie',
      'type': 'Drink',
      'meal': 'Breakfast',
      'instructions': '1. Whizz 300ml water and the ingredients in a blender until smooth.',
      'ingredients': '1 handful spinach (about 50g/2oz), roughly chopped, 100g broccoli florets, roughly chopped, 2 celery sticks, 4 tbsp desiccated coconut, 1 banana, 300ml rice milk (good dairy alternative - we used one from Rude Health), ¼ tsp spirulina or 1 scoop of greens powder or vegan protein powder (optional)',
      'dietRestriction': 'Vegan',
      'duration': 10,
      'calories': 243.0,
      'protein': 7.0,
      'carbs': 27.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 2
    });

    // 49. Strawberry smoothie - https://www.bbcgoodfood.com/recipes/strawberry-smoothie
    await _insertIfMissing(db, {
      'name': 'Strawberry smoothie',
      'type': 'Drink',
      'meal': 'Breakfast',
      'instructions': '1. Blitz the strawberries in a blender with the banana and orange juice until smooth. 2. Pour the smoothie into a tall glass to serve.',
      'ingredients': '10 strawberries hulled (approx 175g), 1 small banana sliced, 100ml orange juice chilled',
      'dietRestriction': 'Vegan, Gluten-free',
      'duration': 5,
      'calories': 170.0,
      'protein': 3.0,
      'carbs': 34.0,
      'fat': 1.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });

    // 50. Breakfast super-shake - https://www.bbcgoodfood.com/recipes/breakfast-super-shake
    await _insertIfMissing(db, {
      'name': 'Breakfast super-shake',
      'type': 'Drink',
      'meal': 'Breakfast',
      'instructions': '1. Put the ingredients in a blender and blitz until smooth. Pour into a glass and enjoy!',
      'ingredients': '100ml full-fat milk, 2 tbsp natural yogurt, 1 banana, 150g frozen fruits of the forest, 50g blueberries, 1 tbsp chia seeds, ½ tsp cinnamon, 1 tbsp goji berries, 1 tsp mixed seeds, 1 tsp honey (ideally Manuka)',
      'dietRestriction': 'Vegetarian, Gluten-free',
      'duration': 5,
      'calories': 467.0,
      'protein': 13.0,
      'carbs': 73.0,
      'fat': 11.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });

    await _insertIfMissing(db, {
      'name': 'Rice',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': 'Mix 1 Cup Rice with 2 T Rice Wine Vinegar, 0.5 T Sugar, and 0.25 T Salt in rice cooker with 1.25 cups water per cup rice. ',
      'ingredients': 'Rice, Rice Wine Vinegar, Sugar, Salt',
      'dietRestriction': 'None',
      'duration': 30,
      'calories': 500.0,
      'protein': 20.0,
      'carbs': 60.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });
    await _insertIfMissing(db, {
      'name': 'Ground Beef',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': 'Raise pan to medium heat. Cover bottom of pan in oil. Cook until meat is browned with seasonings as desired. We reccomend Soy Sauce, Mirin, and Garlic Powder/minced Garlic. ',
      'ingredients': 'Ground Beef',
      'dietRestriction': 'None',
      'duration': 5,
      'calories': 500.0,
      'protein': 20.0,
      'carbs': 60.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 1
    });
    await _insertIfMissing(db, {
      'name': 'College Ramen',
      'type': 'Entree',
      'meal': 'Dinner',
      'instructions': 'Boil water in pot according to instructions on Ramen packet. Add 1t Chili oil, 1T honey, 2 Eggs, and ramen seasoning',
      'ingredients': 'Chili oil, Ramen Packet, Eggs, Honey',
      'dietRestriction': 'None',
      'duration': 30,
      'calories': 500.0,
      'protein': 20.0,
      'carbs': 60.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });
    await _insertIfMissing(db, {
      'name': 'Soft Boiled Egg',
      'type': 'Appetizer',
      'meal': 'Breakfast',
      'instructions': 'Boil eggs for 6.5 minutes in pot of boiling water with 1t Salt and 1t Vinegar. Immediately remove and place in ice water. ',
      'ingredients': 'egg',
      'dietRestriction': 'None',
      'duration': 30,
      'calories': 500.0,
      'protein': 20.0,
      'carbs': 60.0,
      'fat': 10.0,
      'difficulty': 'Easy',
      'servingSize': 4
    });
    await _insertIfMissing(db, {
      'name': 'Tuna',
      'type': 'Entree',
      'meal': 'Breakfast',
      'instructions': 'Prepare Marinade: 2 cups Soy Sauce, 1 T Mirin, 1 T Sesame Oil, 2 cloves garlic finely minced. Mix all together and let sit in fridge in container large enough to hold tuna steaks. Cook Tuna briefly in pan with small amount of Olive Oil or Sesame Oil, enough to brown insides but not cook through. Marinate in container for 2-24 hours. Serve with Rice or eat plain. ',
      'ingredients': 'Soy Sauce, Mirin, Sesame Oil, Garlic, Green Onion, Tuna Steaks',
      'dietRestriction': 'None',
      'duration': 30,
      'calories': 500.0,
      'protein': 20.0,
      'carbs': 60.0,
      'fat': 10.0,
      'difficulty': 'Medium',
      'servingSize': 4
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE Recipes ADD COLUMN ingredients TEXT');
    }
    if (oldVersion < 3) {
      await _insertStarterRecipes(db);
    }
  }

  // Insert a recipe only if its name isn't already in the database
  Future _insertIfMissing(Database db, Map<String, Object?> recipe) async {
    final existing = await db.query('Recipes',
        columns: ['id'], where: 'name = ?', whereArgs: [recipe['name']], limit: 1);
    if (existing.isEmpty) {
      await db.insert('Recipes', recipe);
    }
  }

  // Fetch all recipes in the database
  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await instance.database;
    return await db.query('Recipes');
  }

  // Insert a new item into the database
  Future<int> insertItem(String name, String type, String meal, String instructions,
      {String ingredients = '', String dietRestriction = '', double duration = 0.0, 
      double calories = 0.0, double protein = 0.0, double carbs = 0.0, 
      double fat = 0.0, String difficulty = '', int servingSize = 1}) async {
    final db = await instance.database;
    return await db.insert(
      'Recipes',
      {
        'name': name,
        'type': type,
        'meal': meal,
        'instructions': instructions,
        'ingredients': ingredients,
        'dietRestriction': dietRestriction,
        'duration': duration,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'difficulty': difficulty,
        'servingSize': servingSize,
      },
    );
  }
}