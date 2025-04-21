DateTime getDateFromFileName(String filename){
  filename = filename.split("_").last;
  String dateAsString = filename.split(".").first;
  List<String> dateAndTime = dateAsString.split(" ");
  String date = dateAndTime.first;
  String time = dateAndTime.last.replaceAll("-", ":");

  return DateTime.parse("$date $time");
}