import 'MountainActivity.dart';

class Activities {
  static final List<MountainActivity> _db = [
    MountainActivity("Säuling", "Stefan, Jonas", DateTime(2021,9,30), 19.65, 6.25, 2047),
    MountainActivity("Schellschlicht", "Stefan, Franzi, Jonas", DateTime(2020,9,30), 13.8, 6, 2049),
    MountainActivity("Schneibstein", "Stefan, Franzi,  Jonas", DateTime(2020,6,1), 19.78, 6.2, 2276),
    MountainActivity("Kammerlingshorn", "Stefan, Franzi, Jonas", DateTime(2019,9,30), 9, 6.5, 999),
    MountainActivity("Arber", "Jonas, Franzi", DateTime(2018,8,8), 11, 5.5, 999),
    MountainActivity("Lusen", "Jonas", DateTime(2020,7,15), 11, 5.5, 999)
  ];

  static List<MountainActivity> fetchAll() {
    return _db;
  }

}