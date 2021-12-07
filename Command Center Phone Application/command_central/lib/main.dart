import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:gauges/gauges.dart';
import 'package:flutter_dtmf/flutter_dtmf.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';

/*
CO-BOOM COMMAND CENTER APP
The code responsible for running command center app.
Everything is located in this file.

The code can be run on an emulator or android/ios phone.
*/


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Command Center',
      theme: ThemeData(
        textTheme: GoogleFonts.spaceMonoTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//This class is responsible for showing all views in the app.
class _MyHomePageState extends State<MyHomePage> {
  int pageNumber = 0;
  bool isNextButtonVisible = false;
  bool isVersionCodeEntered = false;

  //Bomb task Answers
  String taskOneBAnswer = "1";
  String taskTwoBAnswer = "2";
  String taskThreeBAnswer = "3";
  String taskFourBAnswer = "4";

  String finalCode = "";

  //Variables
  double gaugeVal = 1;
  String taskOneVal = "";
  double taskOneAVal = 1;
  int taskTwoAVal = 15;
  String taskTwoBVal = "";
  double sliderVal = 0;
  double magnometerVal = 0;
  double taskThreeAVal = 0;
  List<int> taskFourAVal = [];
  List<int> taskFourFakeOne = [];
  List<int> taskFourFakeTwo = [];
  List<List<int>> vibrationLists = [];
  List<int> chosenVibration = [];
  String userInput = "";
  bool isListShuffled = false;
  List<int> test = [0, 1, 2, 3];

  int numberOfErrors = 0;

  List<String> obscuredButString = ['TRIANGLE', 'SPHERE', 'RECTANGLE', 'CROSS'];

  //Initstate is called after initialization, and is responsible for initializing variables
  @override
  void initState() {
    // The following lines of code toggle the wakelock based on a bool value.
    bool enable = true;
    //The following statement enables the wakelock.
    Wakelock.toggle(enable: enable);

    //Randomize variables
    Random r = new Random();

    //TASK1
    taskOneAVal = r.nextInt(10).toDouble();
    //TASK2
    taskTwoAVal = r.nextInt(25) + 5;
    //TASK3
    taskThreeAVal = r.nextInt(10) - 5;
    //TASK4

    taskFourAVal = [
      0,
      r.nextInt(1500) + 100,
      r.nextInt(1500) + 100,
      r.nextInt(1500) + 100
    ];

    taskFourFakeOne = [
      0,
      taskFourAVal[1] + 400,
      taskFourAVal[2],
      taskFourAVal[3]
    ];
    taskFourFakeTwo = [0, taskFourAVal[3], taskFourAVal[2], taskFourAVal[1]];
    chosenVibration = [0, 0, 0, 0];
    vibrationLists = [taskFourAVal, taskFourFakeOne, taskFourFakeTwo];
    vibrationLists.shuffle();
  }

  //Build method is responsible for building all widgets
  @override
  Widget build(BuildContext context) {
    //_incrementCounter();
    return Scaffold(
        appBar: AppBar(
          title: Text("COMMAND CENTRAL"),
          centerTitle: true,
        ),
        body: IntroductionScreen(
          pages: listPagesViewModel(),
          onDone: () {},
          onSkip: () {
            // You can also override onSkip callback
          },
          onChange: (t) {
            setState(() {
              if (!isVersionCodeEntered && taskOneVal != "") {
                calculateAnswers(taskOneVal);
              }
              pageNumber = t;
              isNextButtonVisible = false;
            });
          },
          showDoneButton: isNextButtonVisible,
          scrollPhysics: NeverScrollableScrollPhysics(),
          showSkipButton: false,
          skip: const Icon(Icons.skip_next),
          showNextButton: isNextButtonVisible,
          next: GestureDetector(
            child: const Icon(
              Icons.navigate_next,
              size: 30,
            ),
          ),
          dotsContainerDecorator: ShapeDecoration(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
          ),
          done:
              const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: DotsDecorator(
            size: const Size.square(5.0),
            activeSize: const Size(10.0, 10.0),
            activeColor: Theme.of(context).accentColor,
            color: Colors.red,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          ),
        ));
  }

  //listPagesViewModel return a list of all pages
  //Command central task follows the naming scheme
  //Bomb tasks are randomly chosen in _bombTaskList()
  List<PageViewModel> listPagesViewModel() {
    if (!isListShuffled) {
      test.shuffle();
      isListShuffled = true;
    }

    return [
      TaskOne(),
      Task0neA(),
      _bombTaskList()[test[0]],
      TaskTwoA("Proceed"),
      _bombTaskList()[test[1]],
      TaskThreeA(),
      _bombTaskList()[test[2]],
      TaskFourA(),
      _bombTaskList()[test[3]],
      TaskFinal()
    ];
  }

  TaskOne() {
    return PageViewModel(
        decoration: PageDecoration(pageColor: Colors.black),
        title: "TASK 1",
        bodyWidget: Column(
          children: [
            Text(
              "Enter version code of bomb",
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(height: 75),
            Text(
              taskOneVal,
              style: TextStyle(fontSize: 30, color: Colors.green),
            ),
            SizedBox(height: 75),
            NumericKeyboard(
              onKeyboardTap: (val) {
                if (taskOneVal.length < 4) {
                  setState(() {
                    taskOneVal = taskOneVal + val;
                  });
                }
                if (taskOneVal.length == 4) {
                  setState(() {
                    isNextButtonVisible = true;
                  });
                }
              },
              textColor: Colors.green,
              rightIcon: Icon(Icons.backspace, color: Colors.red),
              rightButtonFn: () {
                setState(() {
                  taskOneVal = taskOneVal.substring(0, taskOneVal.length - 1);
                  isNextButtonVisible = false;
                });
              },
            ),
          ],
        ));
  }

  Task0neA() {
    return PageViewModel(
      title: "TASK 1A",
      bodyWidget: Column(
        children: [
          Text(
            "Find the frequency of the bomb",
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(height: 40),
          RadialGauge(
            radius: 150,
            axes: [
              RadialGaugeAxis(
                minValue: 0,
                maxValue: 10,
                color: Colors.black,
                ticks: [
                  RadialTicks(
                      interval: 1,
                      length: 0.2,
                      color: Colors.green,
                      children: [
                        RadialTicks(
                            ticksInBetween: 5, length: 0.1, color: Colors.green)
                      ])
                ],
                pointers: [
                  RadialNeedlePointer(
                    knobColor: Colors.white,
                    color: Colors.red,
                    value: gaugeVal,
                    thicknessStart: 20,
                    thicknessEnd: 0,
                    length: 0.6,
                    knobRadiusAbsolute: 10,
                  )
                ],
              )
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
                onPressed: () async {
                  setState(() {
                    if (gaugeVal > 0) {
                      gaugeVal--;
                    }
                  });
                  if (taskOneAVal == gaugeVal) {
                    await FlutterDtmf.playTone(digits: "1", durationMs: 200);
                  } else {
                    await FlutterDtmf.playTone(digits: "2", durationMs: 200);
                  }
                },
                child: Icon(Icons.arrow_back_ios)),
            Text(
              gaugeVal.toString(),
              style: TextStyle(color: Colors.red),
            ),
            OutlinedButton(
                onPressed: () async {
                  setState(() {
                    if (gaugeVal < 10) {
                      gaugeVal++;
                    }
                  });
                  if (taskOneAVal == gaugeVal) {
                    await FlutterDtmf.playTone(digits: "1", durationMs: 200);
                  } else {
                    await FlutterDtmf.playTone(digits: "2", durationMs: 200);
                  }
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                ))
          ]),
          SizedBox(height: 25),
          ElevatedButton(
              onPressed: () {
                if (taskOneAVal == gaugeVal) {
                  setState(() {
                    isNextButtonVisible = true;
                  });
                  Fluttertoast.showToast(
                      msg: "Bomb Found, continue to next task");
                } else {
                  _wrongInput(context, 5);
                }
              },
              child: Text("Press to select this frequency"))
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.green),
        bodyTextStyle: TextStyle(color: Colors.green),
        pageColor: Colors.black,
      ),
    );
  }

  BombTask(String headText, String hintText, String answer) {
    return PageViewModel(
      title: "Task " + (((pageNumber + 1) / 2).floor().toString() + "B"),
      bodyWidget: Column(
        children: [
          Text(
            headText,
            style: TextStyle(color: Colors.green),
          ),
          Text(
            " Hint: " + hintText,
            style: TextStyle(color: Colors.green, fontSize: 10),
          ),
          SizedBox(height: 75),
          Text(
            userInput,
            style: TextStyle(fontSize: 30, color: Colors.green),
          ),
          SizedBox(height: 75),
          NumericKeyboard(
            onKeyboardTap: (val) {
              setState(() {
                userInput = val;
              });
            },
            textColor: Colors.green,
            rightIcon: Icon(Icons.backspace, color: Colors.red),
            rightButtonFn: () {
              setState(() {
                userInput = "";
              });
            },
          ),
          SizedBox(
            height: 20,
          ),
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: 2.0,
                    color: userInput != "" ? Colors.green : Colors.black),
              ),
              child: Text("Enter"),
              onPressed: userInput != ""
                  ? () {
                      setState(() {
                        print("Answer: " + answer);
                        print('USERINPUT' + userInput);
                        if (answer == userInput) {
                          userInput = "";
                          Fluttertoast.showToast(
                              msg: "Correct answer, continue");
                          isNextButtonVisible = true;
                        } else {
                          _wrongInput(context, 5);
                        }
                      });
                    }
                  : null)
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.green),
        bodyTextStyle: TextStyle(color: Colors.green),
        pageColor: Colors.black,
      ),
    );
  }

  TaskTwoA(String decryptedMessage) {
    return PageViewModel(
      title: "TASK 2A",
      bodyWidget: Column(
        children: [
          Text(
            "Find the right decryption key",
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(height: 50),
          Text(
            sliderVal.toStringAsFixed(5),
            style: TextStyle(color: Colors.red, fontSize: 25),
          ),
          Slider(
              value: sliderVal,
              min: 0,
              max: 30,
              onChanged: (val) {
                setState(() {
                  sliderVal = val;
                });
                int testVal = val.toInt() * 2;
                if (sliderVal >= taskTwoAVal - 0.5 &&
                    sliderVal <= taskTwoAVal + 0.5) {
                  Vibration.vibrate(amplitude: 100, duration: 100);
                } else {
                  Vibration.vibrate(amplitude: 100, duration: 20);
                }
              }),
          SizedBox(height: 50),
          ElevatedButton(
              onPressed: () {
                if (sliderVal >= taskTwoAVal - 0.5 &&
                    sliderVal <= taskTwoAVal + 0.5) {
                  setState(() {
                    isNextButtonVisible = true;
                    taskTwoBVal = decryptedMessage;
                  });
                } else {
                  const _chars =
                      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                  Random _rnd = Random();
                  setState(() {
                    taskTwoBVal = String.fromCharCodes(Iterable.generate(200,
                        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
                  });
                }
              },
              child: Text("Press to decrypt bomb message")),
          SizedBox(height: 50),
          Text(
            "DECRYPTED MESSAGE:",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Container(
              height: 130,
              child: Text(taskTwoBVal, style: TextStyle(color: Colors.white)))
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.green),
        bodyTextStyle: TextStyle(color: Colors.green),
        pageColor: Colors.black,
      ),
    );
  }

  TaskThreeA() {
    return PageViewModel(
      title: "TASK 3A",
      bodyWidget: Column(
        children: [
          Text(
            "Intercept the signal of the bomb at value: " +
                taskThreeAVal.toInt().toString(),
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(height: 40),
          RadialGauge(
            radius: 150,
            axes: [
              RadialGaugeAxis(
                minValue: -10,
                maxValue: 10,
                color: Colors.black,
                ticks: [
                  RadialTicks(
                      interval: 1,
                      length: 0.2,
                      color: Colors.green,
                      children: [
                        RadialTicks(
                            ticksInBetween: 5, length: 0.1, color: Colors.green)
                      ])
                ],
                pointers: [
                  RadialNeedlePointer(
                    knobColor: Colors.white,
                    color: Colors.red,
                    value: magnometerVal,
                    thicknessStart: 20,
                    thicknessEnd: 0,
                    length: 0.6,
                    knobRadiusAbsolute: 10,
                  )
                ],
              )
            ],
          ),
          Text(
            magnometerVal.toString(),
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 25),
          ElevatedButton(
              onPressed: () {
                Future<MagnetometerEvent> e = magnetometerEvents.first;
                e.then((value) => {
                      setState(() {
                        magnometerVal = value.x;
                      })
                    });
              },
              child: Text("Read signal")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: magnometerVal <= taskThreeAVal + 1 &&
                      magnometerVal >= taskThreeAVal - 1
                  ? () => {
                        setState(() {
                          Fluttertoast.showToast(
                              msg: "Signal intercepted, you can continue.");
                          isNextButtonVisible = true;
                        })
                      }
                  : null,
              child: Text("INTERCEPT SIGNAL"))
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.green),
        bodyTextStyle: TextStyle(color: Colors.green),
        pageColor: Colors.black,
      ),
    );
  }

  TaskFourA() {
    return PageViewModel(
      title: "Task 4A",
      bodyWidget: Column(
        children: [
          Text(
            "Upload the right code to compromise the security of the bomb",
            style: TextStyle(color: Colors.green),
          ),
          SizedBox(height: 20),
          Text(
            "PATTERN",
            style: TextStyle(color: Colors.green),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
            ),
            height: 75,
            child: Row(children: <Widget>[
              Expanded(
                flex: taskFourAVal[1], // 60% of space => (6/(6 + 4))
                child: Container(
                  color: Colors.green,
                ),
              ),
              Expanded(
                flex: taskFourAVal[2], // 40% of space
                child: Container(
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: taskFourAVal[3], // 40% of space
                child: Container(
                  color: Colors.green,
                ),
              ),
            ]),
          ),
          SizedBox(height: 50),
          ToggleSwitch(
            minWidth: 100.0,
            minHeight: 50.0,
            fontSize: 16.0,
            initialLabelIndex: 1,
            activeBgColor: [Colors.green],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.grey[900],
            totalSwitches: 3,
            labels: ['code01', 'code02', 'code03'],
            onToggle: (index) {
              Vibration.vibrate(pattern: vibrationLists[index]);
              chosenVibration = vibrationLists[index];
            },
          ),
          SizedBox(height: 30),
          ElevatedButton(
              onPressed: () {
                if (chosenVibration[1] == taskFourAVal[1] &&
                    chosenVibration[2] == taskFourAVal[2]) {
                  setState(() {
                    Fluttertoast.showToast(
                        msg: "Key uploaded to bomb succesfully");
                    isNextButtonVisible = true;
                  });
                } else {
                  _wrongInput(context, 5);
                }
              },
              child: Text("Choose this code"))
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.green),
        bodyTextStyle: TextStyle(color: Colors.green),
        pageColor: Colors.black,
      ),
    );
  }

  TaskFinal() {
    return PageViewModel(
      title: "FINAL TASK",
      bodyWidget: Column(
        children: [
          Text('THE BOMB IS CRACKED',
              style: TextStyle(color: Colors.green, fontSize: 30)),
          Text('ENTER CODE ON BOMB',
              style: TextStyle(color: Colors.green, fontSize: 30)),
          Text('USE THE KEYPAD',
              style: TextStyle(color: Colors.green, fontSize: 30)),
          Text('HURRY UP', style: TextStyle(color: Colors.green, fontSize: 30)),
          SizedBox(height: 50),
          Text(finalCode, style: TextStyle(color: Colors.red, fontSize: 70)),
          SizedBox(height: 200),
          Text(
            numberOfErrors.toString() + ' Errors',
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(color: Colors.green),
        bodyTextStyle: TextStyle(color: Colors.green),
        pageColor: Colors.black,
      ),
    );
  }

  //All bomb tasks
  List<PageViewModel> _bombTaskList() {
    return [
      BombTask(
          "Locate used CPU?", "The heat sinks might help you", taskOneBAnswer),
      BombTask(
          "Initiate shutdown",
          "What number is the " +
              obscuredButString[int.parse(taskTwoBAnswer) - 1] +
              " Button from the left?",
          taskTwoBAnswer),
      BombTask(
          "Manual Override",
          "Rearrange wires. What position should the last wire be plugged into?",
          taskThreeBAnswer),
      BombTask("Send shutdown signal", "Turn knob to find the right value",
          taskFourBAnswer)
    ];
  }

  //Calculation of the answers according to the version code.
  void calculateAnswers(String versionCode) {
    isVersionCodeEntered = true;
    int versionCodeInt = int.parse(versionCode);

    print(versionCodeInt.toString());

    int randomNumber = pow(versionCodeInt + 6337, 2).toInt();
    print('NUMBER GENERATED: ' + randomNumber.toString());

    String randomNumberString = randomNumber.toString();

    taskOneBAnswer = ((int.parse(randomNumberString[0]) % 3) + 1).toString();
    taskTwoBAnswer = ((int.parse(randomNumberString[1]) % 4) + 1).toString();
    taskThreeBAnswer = calculateWires(int.parse(randomNumberString[2]));
    print(taskThreeBAnswer);
    taskFourBAnswer = (int.parse(randomNumberString[3])).toString();

    finalCode = randomNumberString.substring(4, 8);
  }

  //Wire task correct answer calculation
  String calculateWires(int wireSeed) {
    //Initial values in string
    List<String> posS = ["1", "2", "3", "4"];
  //String holding the new order of values
    String order = "";
  //The seed that randomizes. This should be changed based on bomb number

  //Run loop for length of posS
    for (int i = 4; i > 0; i--) {
      //Get the value at randomized position from posS-string
      String val = posS[(wireSeed % (i))];
      //Remove the found value from this string
      posS.removeAt(wireSeed % (i));
      //At the value found to the new ordered string
      order += val;
    }

    return order[3];
  }

  //ShowDialog called when an incorrect value is chosen
  void _wrongInput(BuildContext context, int seconds) {
    Duration waitTime = Duration(seconds: seconds);
    numberOfErrors++;
    Timer(waitTime, () {
      Navigator.of(context).pop();
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: new Text(
            "Wrong Input",
            style: TextStyle(color: Colors.black),
          ),
          content: new Text(
              "Try again in " + waitTime.inSeconds.toString() + " seconds...",
              style: TextStyle(color: Colors.black)),
        );
      },
    );
  }
}
