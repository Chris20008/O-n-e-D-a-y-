import 'package:objectbox/objectbox.dart';

@Entity()
class ObExercise{

  /// Id properties
  @Id()
  int id;

  /// Indexed Fields
  @Index()
  String name;

  /// Data Fields
  List<double> weights;
  List<int> amounts;
  List<int> setTypes;
  int restInSeconds;
  int? seatLevel;
  String? linkName;

  /// category = 1 => isReps
  /// category = 1 => isCardio
  /// category = 1 => isStaticHold
  int category;
  bool blockLink;
  double bodyWeightPercent;

  String get checksumString{
    if(id <= 0){
      return "";
    }
    final buffer = StringBuffer();

    buffer.write(name);
    // buffer.write(id);
    buffer.write(weights.toString());
    buffer.write(amounts.toString());
    buffer.write(setTypes.toString());
    buffer.write(category);
    buffer.write(seatLevel);
    buffer.write(linkName);
    buffer.write(restInSeconds);
    buffer.write(blockLink);
    buffer.write(bodyWeightPercent);

    return buffer.toString();
  }

  /// Constructor
  ObExercise({
    this.id = 0,
    required this.name,
    required this.weights,
    required this.amounts,
    required this.restInSeconds,
    required this.setTypes,
    this.seatLevel,
    this.linkName,
    this.category = 1,
    this.blockLink = false,
    this.bodyWeightPercent = 0.0
  });

  factory ObExercise.fromMap(Map data){
    final weights = List<double>.from(List.from(data["weights"]?? [0.0]).map((w) => double.parse(w.toString())));
    return ObExercise(
        name:data["name"],
        weights: weights,
        amounts: List<int>.from(List.from(data["amounts"]?? List.generate(weights.length, (item) => 0)).map((a) => int.parse(a.toString()))),
        setTypes: List<int>.from(List.from(data["setTypes"]?? List.generate(weights.length, (item) => 0)).map((a) => int.parse(a.toString()))),
        restInSeconds: data["restInSeconds"]?? 0,
        seatLevel: data["seatLevel"],
        linkName: data["linkName"],
        category: data["category"]?? 1,
        blockLink: data["blockLink"]?? false,
        bodyWeightPercent: data["bodyWeightPercent"]?? 0.0
    );
  }

  Map asMap(){
    Map m = {
      "id": id,
      "name": name,
      "weights": weights,
      "amounts": amounts,
      "setTypes": setTypes,
      "restInSeconds": restInSeconds,
      "seatLevel": seatLevel,
      "linkName": linkName,
      "category": category,
      "blockLink": blockLink,
      "bodyWeightPercent": bodyWeightPercent
    };
    if(m["category"] == 1){
      m.remove("category");
    }
    if(m["seatLevel"] == 0 || m["seatLevel"] == null){
      m.remove("seatLevel");
    }
    if(m["linkName"] == "" || m["linkName"] == null){
      m.remove("linkName");
    }
    if(m["restInSeconds"] == 0){
      m.remove("restInSeconds");
    }
    if(!blockLink){
      m.remove("blockLink");
    }
    if(bodyWeightPercent == 0.0){
      m.remove("bodyWeightPercent");
    }
    return m;
  }

  int getHash(){
    final listHashW = Object.hashAll(weights);
    final listHashA = Object.hashAll(amounts);
    final listHashS = Object.hashAll(setTypes);
    return Object.hash(name, restInSeconds, seatLevel, linkName, listHashW, listHashA, listHashS, category, blockLink, bodyWeightPercent);
  }

  bool equals(ObExercise ex){
    return getHash() == ex.getHash();
  }
}