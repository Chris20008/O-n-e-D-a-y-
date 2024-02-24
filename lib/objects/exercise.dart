class Exercise{

  String name;
  List<Set> sets;
  String? originalName;

  Exercise({
    this.name = "",
    this.sets = const []
  }){
    this.name = name;
    if (sets.isEmpty){
      sets = [];
      addSet();
    }
  }

  Exercise.clone(Exercise ex): this(
      name: ex.name,
      sets: List.from(ex.sets.map((set) => Set(weight: set.weight, amount: set.amount)))
  );

  void addSet({int? weight, int? amount}){
    sets.add(Set(weight: weight, amount: amount));
  }

}

class Set{
  int? weight;
  int? amount;

  Set({
    this.weight,
    this.amount
  });
}