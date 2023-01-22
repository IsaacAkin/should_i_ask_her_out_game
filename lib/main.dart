import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:should_i_ask_her_out_game/decision_map.dart';

late Box<DecisionMap> box;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // UI Widgets are initialised
  await Hive.initFlutter(); // Initialises Flutter App with Hive
  Hive.registerAdapter(DecisionMapAdapter()); // Registers adapter
  box = await Hive.openBox<DecisionMap>('decisionMap'); // Builds Hive DB

  // Populate list code
  String csv = "assets/data.csv"; // path to csv file asset
  String fileData = await rootBundle.loadString(csv);
  print(fileData);
  List<String> rows = fileData.split("\n");
  for (int i = 0; i < rows.length; i++) {
    // selects item from the row and places it
    String row = rows[i];
    List<String> itemInRow = row.split(",");
    // code to map item into the DecisionMap object
    DecisionMap decMap = DecisionMap();
    decMap.ID = int.parse(itemInRow[0]);
    decMap.option1ID = int.parse(itemInRow[1]);
    decMap.option2ID = int.parse(itemInRow[2]);
    decMap.description = itemInRow[3];
    decMap.response1 = itemInRow[4];
    decMap.response2 = itemInRow[5];

    int key = int.parse(itemInRow[0]);
    box.put(key, decMap); // key makes it easier to navigate
  }

  runApp(
    const MaterialApp(
      home: MyFlutterApp(),
    ),
  );
}

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyFlutterState();
  }
}

class MyFlutterState extends State<MyFlutterApp> {
  //Place variables here
  late int ID;
  late int option1ID;
  late int option2ID;
  String description = "";
  String response1 = "";
  String response2 = "";

  @override
  void initState() {
    super.initState();
    // Code to initialise server objects

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Code you want to execute immediately after
        // The UI is built
        DecisionMap? current = box.get(0);

        ID = current!.ID;
        option1ID = current.option1ID;
        option2ID = current.option2ID;
        description = current.description;
        response1 = current.response1;
        response2 = current.response2;
      });
    });
  }

  void clickHandler() {
    setState(() {
      DecisionMap? current = box.get(option1ID);
      if (current != null) {
        ID = current.ID;
        option1ID = current.option1ID;
        description = current.description;
        option2ID = current.option2ID;
        response1 = current.response1;
        response2 = current.response2;
      }
    });
  }

  void clickHandler2() {
    setState(() {
      DecisionMap? current = box.get(option2ID);
      if (current != null) {
        ID = current.ID;
        option2ID = current.option2ID;
        description = current.description;
        option1ID = current.option1ID;
        response1 = current.response1;
        response2 = current.response2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Should I Ask Her Out?',
          style: TextStyle(fontFamily: 'Rubik'),
        ),
        backgroundColor: Color.fromARGB(96, 4, 108, 58),
      ),
      backgroundColor: Color.fromARGB(255, 76, 214, 148),
      body: Align(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              //  "Yes" button
              Align(
                alignment: const Alignment(0.0, 0.4),
                child: MaterialButton(
                  onPressed: () {
                    clickHandler();
                  },
                  color: Color.fromARGB(255, 255, 255, 255),
                  elevation: 3,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textColor: Color.fromARGB(255, 0, 0, 0),
                  height: 40,
                  minWidth: 140,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Text(
                    response1,
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
              // "No" button
              Align(
                alignment: const Alignment(0.0, 0.7),
                child: MaterialButton(
                  onPressed: () {
                    clickHandler2();
                  },
                  color: Color.fromARGB(255, 255, 255, 255),
                  elevation: 3,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textColor: Color.fromARGB(255, 0, 0, 0),
                  height: 40,
                  minWidth: 140,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Text(
                    response2,
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
              // "Description" Text
              Align(
                alignment: const Alignment(0.05, -0.5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 25,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
