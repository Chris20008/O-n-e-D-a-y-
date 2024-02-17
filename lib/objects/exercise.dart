class Exercise{

  String name;
  List<Set> sets = [];

  Exercise({
    this.name = "",
  });

  void addSet(int weight, int amount){
    sets.add(Set(weight: weight, amount: amount));
  }


}

class Set{
  int weight;
  int amount;

  Set({
    required this.weight,
    required this.amount
  });
}