



// class Item {
//   String imgPath;
//   double price;
//   String Description;
//   String location;
//   String title;

//   Item({
//     required this.title,
//     required this.imgPath,
//     required this.price,  
//     required this.Description,
//     required this.location,
//   });
// }
class Item {
  String title;
  String imgPath;
  double price;
  String Description;
  String location;
  String? startDate;
  String? finalDate;
  int? peopleCount;

  Item({
    required this.title,
    required this.imgPath,
    required this.price,
    required this.Description,
    required this.location,
         this.startDate,
        this.finalDate,
        this.peopleCount,
  });
}

  final List<Item> items = [
    
    Item(
    
      title: "Sunrise Cozy Home",
      location: "Syria, Damascus",
      Description:
          "A bright and comfortable apartment located in a quiet, well-served area",
      price: 12.99,
      imgPath: "assets/images/pexels-binyaminmellish-1396132.jpg",
    ),
    Item(
    
      title: " Lakeview Apartment",
      location: "Syria, Aleppo",
      Description:
          "A clean, ready-to-move-in apartment with a practical layout",
      price: 11.99,
      imgPath: "assets/images/pexels-binyaminmellish-106399.jpg",
    ),
    Item(
    
      title: "White Garden Residence",
      location: "Syria, Homs",
      Description:
          "A comfortable apartment in a peaceful neighborhood. It features wide rooms",
      price: 10.99,
      imgPath: "assets/images/pexels-expect-best-79873-323780.jpg", 
    ),
    Item(
    
      title: "Hillside Family House",
      location: "Syria, Latakia",
      Description: "A well-lit apartment with a nice layout and good space",
      price: 09.99,
      imgPath: "assets/images/pexels-pixabay-259588.jpg", 
    ),
    Item(
      
      title: "Bluestone Modern Villa",
      location: "Syria, idlib",
      Description:
          "A move-in-ready apartment with excellent ventilation and natural light",
      price: 08.99,
      imgPath: "assets/images/pexels-pixabay-277667.jpg",
    ),
  ];

  