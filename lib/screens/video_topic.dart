class VideoTopic {
  final String title;
  final String subtitle;
  final String searchQuery;
  final String iconName;
  final String gender; // 'male' | 'female' | 'all'

  const VideoTopic({
    required this.title,
    required this.subtitle,
    required this.searchQuery,
    required this.iconName,
    this.gender = 'all',
  });
}

//////////////////////////////////////////////////////
/// CURATED VIDEO TOPICS — edit/add freely, no rebuild
/// of any feed-parsing logic needed since this is just
/// search terms, not hosted content.
//////////////////////////////////////////////////////
final List<VideoTopic> videoTopics = [
  VideoTopic(
    title: "Full Body Workout",
    subtitle: "Total-body routines for all levels",
    searchQuery: "full body workout gym",
    iconName: "fitness_center",
    gender: "all",
  ),
  VideoTopic(
    title: "Beginner Gym Guide",
    subtitle: "New to the gym? Start here",
    searchQuery: "beginner gym guide workout",
    iconName: "school",
    gender: "all",
  ),
  VideoTopic(
    title: "HIIT Workout",
    subtitle: "High-intensity fat-burning sessions",
    searchQuery: "HIIT workout gym",
    iconName: "bolt",
    gender: "all",
  ),
  VideoTopic(
    title: "Home Workout No Equipment",
    subtitle: "Train anywhere, no gear needed",
    searchQuery: "home workout no equipment",
    iconName: "home",
    gender: "all",
  ),
  VideoTopic(
    title: "Chest & Triceps Day",
    subtitle: "Push day training routines",
    searchQuery: "chest and triceps workout for men",
    iconName: "sports_gymnastics",
    gender: "male",
  ),
  VideoTopic(
    title: "Back & Biceps Day",
    subtitle: "Pull day training routines",
    searchQuery: "back and biceps workout for men",
    iconName: "sports_gymnastics",
    gender: "male",
  ),
  VideoTopic(
    title: "Leg Day Workout",
    subtitle: "Build strength from the ground up",
    searchQuery: "leg day workout gym",
    iconName: "directions_run",
    gender: "all",
  ),
  VideoTopic(
    title: "Core & Abs Workout",
    subtitle: "Strengthen your core",
    searchQuery: "core and abs workout gym",
    iconName: "accessibility_new",
    gender: "all",
  ),
  VideoTopic(
    title: "Stretching & Mobility",
    subtitle: "Recover and improve flexibility",
    searchQuery: "stretching mobility routine gym",
    iconName: "self_improvement",
    gender: "all",
  ),
  VideoTopic(
    title: "Cardio Workout",
    subtitle: "Boost endurance and heart health",
    searchQuery: "cardio workout gym",
    iconName: "favorite",
    gender: "all",
  ),
  VideoTopic(
    title: "Glutes & Toning",
    subtitle: "Sculpt and strengthen",
    searchQuery: "glutes and toning workout for women",
    iconName: "self_improvement",
    gender: "female",
  ),
  VideoTopic(
    title: "Pilates & Core",
    subtitle: "Low-impact strength and flexibility",
    searchQuery: "pilates core workout for women",
    iconName: "accessibility_new",
    gender: "female",
  ),
];