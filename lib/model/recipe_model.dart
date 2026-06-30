class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final int minutes;
  final int calories;
  final List<String> ingredients;
  final String preparation;
  final String category; // breakfast, lunch, dinner
  bool isSaved;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.minutes,
    required this.calories,
    required this.ingredients,
    required this.preparation,
    required this.category,
    this.isSaved = false,
  });
}

//////////////////////////////////////////////////////
/// STATIC SAMPLE DATA (replace with Firestore later)
//////////////////////////////////////////////////////

final List<Recipe> sampleRecipes = [
  Recipe(
    id: 'r1',
    name: 'Avocado And Egg Toast',
    imageUrl:
        'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600',
    minutes: 15,
    calories: 150,
    category: 'breakfast',
    ingredients: const [
      'Wholemeal bread',
      'Ripe avocado slices',
      'Fried or poached egg',
    ],
    preparation:
        'Toast the bread until golden. Mash the avocado with a pinch of salt '
        'and spread it on the toast. Top with the egg, season with pepper '
        'and serve immediately.',
  ),
  Recipe(
    id: 'r2',
    name: 'Spinach And Tomato Omelette',
    imageUrl:
        'https://images.unsplash.com/photo-1612240498936-65f5101365d2?w=600',
    minutes: 10,
    calories: 220,
    category: 'breakfast',
    ingredients: const [
      '2-3 eggs',
      'A handful of fresh spinach',
      '1 small tomato',
      'Salt and pepper to taste',
      'Olive oil or butter',
    ],
    preparation:
        'Whisk the eggs with salt and pepper. Saute spinach and chopped '
        'tomato in a pan, pour in the eggs and cook until set, then fold '
        'and serve.',
  ),
  Recipe(
    id: 'r3',
    name: 'Delights With Greek Yogurt',
    imageUrl:
        'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600',
    minutes: 6,
    calories: 200,
    category: 'breakfast',
    ingredients: const [
      'Greek yogurt',
      'Mixed berries',
      'Granola',
      'Honey (optional)',
    ],
    preparation:
        'Layer yogurt, berries and granola in a bowl. Drizzle with honey '
        'and serve chilled.',
  ),
  Recipe(
    id: 'r4',
    name: 'Protein Shake With Fruits',
    imageUrl:
        'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=600',
    minutes: 9,
    calories: 180,
    category: 'breakfast',
    ingredients: const [
      '1/2 cup plain Greek yogurt',
      '1/2 cup almond milk',
      'Honey or maple syrup (optional)',
      'Mixed berries',
    ],
    preparation:
        'Blend all ingredients until smooth. Pour into a glass and serve '
        'immediately.',
  ),
  Recipe(
    id: 'r5',
    name: 'Salmon And Avocado Salad',
    imageUrl:
        'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600',
    minutes: 15,
    calories: 300,
    category: 'lunch',
    ingredients: const [
      'Grilled salmon fillet',
      'Avocado slices',
      'Mixed greens',
      'Lemon vinaigrette',
    ],
    preparation:
        'Arrange greens on a plate, top with flaked salmon and avocado, '
        'then drizzle with the vinaigrette.',
  ),
  Recipe(
    id: 'r6',
    name: 'Quinoa Salad',
    imageUrl:
        'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=600',
    minutes: 25,
    calories: 300,
    category: 'lunch',
    ingredients: const [
      '1 cup cooked quinoa',
      'Vegetables to roast (peppers, zucchini, eggplant)',
      'Olive oil',
      'Salt and pepper to taste',
    ],
    preparation:
        'Roast the vegetables with olive oil, salt and pepper. Toss with '
        'cooked quinoa and fresh herbs before serving.',
  ),
  Recipe(
    id: 'r7',
    name: 'Teriyaki Chicken With Brown Rice',
    imageUrl:
        'https://images.unsplash.com/photo-1547592180-85f173990554?w=600',
    minutes: 45,
    calories: 375,
    category: 'lunch',
    ingredients: const [
      'Chicken breast',
      'Teriyaki sauce',
      'Brown rice',
      'Fresh broccoli',
    ],
    preparation:
        'Cook the chicken in teriyaki sauce until glazed and cooked '
        'through. Steam the broccoli and serve everything over brown rice.',
  ),
  Recipe(
    id: 'r8',
    name: 'Burrito With Vegetables',
    imageUrl:
        'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600',
    minutes: 20,
    calories: 250,
    category: 'lunch',
    ingredients: const [
      'Tortilla wrap',
      'Black beans',
      'Mixed peppers',
      'Shredded lettuce',
      'Salsa',
    ],
    preparation:
        'Warm the tortilla, fill with beans, peppers and lettuce, top with '
        'salsa, then roll tightly and serve.',
  ),
  Recipe(
    id: 'r9',
    name: 'Grilled Chicken Salad',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
    minutes: 20,
    calories: 240,
    category: 'dinner',
    ingredients: const [
      'Grilled chicken breast',
      'Mixed salad greens',
      'Cherry tomatoes',
      'Light dressing',
    ],
    preparation:
        'Grill the chicken until cooked through and slice. Toss the '
        'greens and tomatoes with dressing and top with the chicken.',
  ),
  Recipe(
    id: 'r10',
    name: 'Chicken Breast Stuffed With Spinach',
    imageUrl:
        'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=600',
    minutes: 30,
    calories: 250,
    category: 'dinner',
    ingredients: const [
      '1 boneless, skinless chicken breast (150 g)',
      '1 cup fresh spinach',
      '30 g crumbled feta cheese',
      'Lemon juice, garlic powder, salt and pepper',
    ],
    preparation:
        'Butterfly the chicken breast and fill with spinach and feta. '
        'Secure, season, and bake at 200C for about 25 minutes until '
        'cooked through.',
  ),
  Recipe(
    id: 'r11',
    name: 'Chickpea Salad',
    imageUrl:
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
    minutes: 25,
    calories: 300,
    category: 'dinner',
    ingredients: const [
      '1 cup cooked chickpeas',
      '1 tomato cut into cubes',
      'Sliced cucumber',
      'Chopped red onion',
      'Chopped fresh parsley',
      '1 tablespoon balsamic vinaigrette dressing',
    ],
    preparation:
        'Combine all ingredients in a bowl, drizzle with the vinaigrette '
        'and toss well before serving.',
  ),
  Recipe(
    id: 'r12',
    name: 'Baked Salmon',
    imageUrl:
        'https://images.unsplash.com/photo-1485921325833-c519f76c4927?w=600',
    minutes: 30,
    calories: 350,
    category: 'dinner',
    ingredients: const [
      'Salmon fillet',
      'Olive oil',
      'Lemon slices',
      'Mixed roasted vegetables',
    ],
    preparation:
        'Season the salmon, place on a tray with lemon slices and roasted '
        'vegetables, then bake at 200C for about 15-18 minutes.',
  ),
];

List<Recipe> recipesByCategory(String category) =>
    sampleRecipes.where((r) => r.category == category).toList();
