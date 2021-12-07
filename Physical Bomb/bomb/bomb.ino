//Pin OVERVIEW
/*
   0 = Wire1
   1 = Wire2
   2 = Wire3
   3 = Wire4 PWM
   4-7 = Keypad ROWS PWM 4 PWM 6 PWM 7
   12 = VibMotor PWM
   13 = Coil1 PWM
   14 = Coil2 PWM
   15 = Coil3 PWM
   16 = OLED1
   17 = OLED2
   18 = Speaker
   19-21 Keypad Coloums
   22 = KnobDT
   23 = KnobCLK
   25 = Green LED
   26 = Red LED
*/


//Used for SHA-1
#include <SimpleHOTP.h>

//Used for OLED display
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 //   OLED display width, in km
#define SCREEN_HEIGHT 64 //   OLED display height, in km
#define OLED_RESET     -1 //  Share Reset with arduino. This is caring
#define SCREEN_ADDRESS 0x3C //Address pin
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

//Used for beeping
int tonePin = 18;
unsigned long previousMillis = 0;
long interval = 1000;
const long initInterval = 1000;
bool tickToggle = false;

//Used for WireTask
int greenVal;
int blueVal;
int redVal;
int blackVal;
bool isWireDone = true;
long timeWire = 0;
long debounce = 500;

String posS = "1234";
String order = "";
bool prevs[] = {true, true, true, true};
int currentState[4];
int wireProg = 0;
int correctFreq = 1200;
int correctTime = 300;
int wrongFreq = 300;
int wrongTime = 300;
int wireSeed = 4;
int howMany = 0;

//Used for keypad
#include "Adafruit_Keypad.h"
const byte ROWS = 4; // rows
const byte COLS = 3; // columns
byte rowPins[ROWS] = {5, 7, 14, 15};
byte colPins[COLS] = {19, 20, 21};

char keys[ROWS][COLS] = {
  {'1', '2', '3'},
  {'4', '5', '6'},
  {'7', '8', '9'},
  {'C', '0', 'E'}
};
Adafruit_Keypad customKeypad = Adafruit_Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS);
String keyMsg = "";
int maxKeyMsg = 4;

//Used for heat coils
int heatVal = 100;

//Used for knob and vib
#include <EEPROM.h>
int knobCLK = 23;
int knobDT = 22;
float knobCounter = 0;
int currentStateCLK;
int lastStateCLK;
String currentDir = "";
int motorPin = 12;
int vibValMax = 80;
int vibValMin = 60;
int vibWaitMax = 50;
int vibWaitMin = 100;
int intervalWait = 1000;
float knobCorrect = 0.0;
unsigned long long prevVibTime = 0;

bool startVib = false;
int vibCounter = 0;
int vibCountMax = 2;

//Used for LEDS
int gLed = 25;
int rLed = 26;

//Used for whole system
int code = 0; //Random Code
int currentTask = 0; //Button state. No, jk, it's the current task yeehaw
int staticNum = 6337;
unsigned long bigGuy = 0;
String bigGuyWord = "";
String finalCode = "";

//RESET FABER FUCK
bool isDone = false; //Should be false
unsigned long long startTime = 0;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(4, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(13, OUTPUT);
  randomSeed(analogRead(A0));
  code = random(1000, 9999);
  bigGuy = code + staticNum;
  bigGuy = bigGuy * bigGuy;
  bigGuyWord = String(bigGuy);

  Serial.println(bigGuyWord);

  //Set the right CPU
  Serial.println("CPU no: " + String((String(bigGuyWord[0]).toInt() % 3) + 1));
  if (String(String(bigGuyWord[0]).toInt() % 3) == "0") analogWrite(4, 65);
  if (String(String(bigGuyWord[0]).toInt() % 3) == "1") analogWrite(6, 65);
  if (String(String(bigGuyWord[0]).toInt() % 3) == "2") analogWrite(13, 75);
  //analogWrite(13 + String(bigGuyWord[0]).toInt() % 3, heatVal);


  //Set the seed for wire game
  wireSeed = String(bigGuyWord[2]).toInt();

  knobCorrect = String(bigGuyWord[3]).toFloat();
  Serial.println("Correct knob value: " + String(knobCorrect));

  finalCode = bigGuyWord.substring(4, 8);

  //Init OLED
  if (!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for (;;); // Don't proceed, loop forever
  }

  customKeypad.begin();

  refreshDisplay();

  pinMode(tonePin, OUTPUT);

  pinMode(0, INPUT_PULLUP);
  pinMode(1, INPUT_PULLUP);
  pinMode(2, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  pinMode(gLed, OUTPUT);
  pinMode(rLed, OUTPUT);
  pinMode(knobCLK, INPUT);
  pinMode(knobDT, INPUT);
  pinMode(motorPin, OUTPUT);
  lastStateCLK = digitalRead(knobCLK);

  digitalWrite(gLed, LOW);

  for (int i = 4; i > 0; i--) {
    char val = posS.charAt(wireSeed % (i));
    posS.remove(wireSeed % (i), 1);
    order += val;
  }
  Serial.println(order);
  startTime = millis();
}

void loop() {
  // put your main code here, to run repeatedly:
  greenVal = !digitalRead(0);
  blueVal = !digitalRead(1);
  redVal = !digitalRead(2);
  blackVal = !digitalRead(3);

  howMany = greenVal + blueVal + redVal + blackVal;
  //Serial.println(howMany);

  if (isWireDone && greenVal == 0 && blueVal == 0 && redVal == 0 && blackVal == 0) {
    isWireDone = false;
    delay(500);
  }

  if (!isWireDone) {
    if (greenVal == 1 && !prevs[0] && millis() - timeWire > debounce) {
      if (currentState[0] == 1) currentState[0] = 0;
      else currentState[0] = 1;
      if (order[wireProg] == '1') {
        wireProg++;
        Serial.println("Correct!");
        Serial.println(wireProg);
        isWireDone = wireProg == 4;
        tone(tonePin, correctFreq, correctTime);
      } else {
        Serial.println("WRONG!");
        tone(tonePin, wrongFreq, wrongTime);
      }
    }

    if (blueVal == 1 && !prevs[1] && millis() - timeWire > debounce) {
      if (currentState[1] == 1) currentState[1] = 0;
      else currentState[1] = 1;
      if (order[wireProg] == '2') {
        wireProg++;
        Serial.println("Correct!");
        Serial.println(wireProg);
        isWireDone = wireProg == 4;
        tone(tonePin, correctFreq, correctTime);
      } else {
        Serial.println("WRONG!");
        tone(tonePin, wrongFreq, wrongTime);
      }
    }

    if (redVal == 1 && !prevs[2] && millis() - timeWire > debounce) {
      if (currentState[2] == 1) currentState[2] = 0;
      else currentState[2] = 1;
      if (order[wireProg] == '3') {
        wireProg++;
        Serial.println("Correct!");
        Serial.println(wireProg);
        isWireDone = wireProg == 4;
        tone(tonePin, correctFreq, correctTime);
      } else {
        Serial.println("WRONG!");
        tone(tonePin, wrongFreq, wrongTime);
      }
    }

    if (blackVal == 1 && !prevs[3] && millis() - timeWire > debounce) {
      if (currentState[3] == 1) currentState[3] = 0;
      else currentState[3] = 1;
      if (order[wireProg] == '4') {
        wireProg++;
        Serial.println("Correct!");
        Serial.println(wireProg);
        isWireDone = wireProg == 4;
        tone(tonePin, correctFreq, correctTime);
      } else {
        Serial.println("WRONG!");
        tone(tonePin, wrongFreq, wrongTime);
      }
    }

    wireProg = howMany;
    prevs[0] = greenVal;
    prevs[1] = blueVal;
    prevs[2] = redVal;
    prevs[3] = blackVal;

  }

  customKeypad.tick();
  while (customKeypad.available()) {
    keypadEvent e = customKeypad.read();
    if (e.bit.EVENT == KEY_JUST_PRESSED) {
      //Serial.print((char)e.bit.KEY);
      inputKey(String((char)e.bit.KEY), keyMsg.length());

    }
  }
  knobThing();
  if (!isDone) beeping();

  //bool startVib = false;
  //int vibCounter = 0;
  //int vibCountMax = 2;

  if (startVib) {
    if (millis() - prevVibTime >= intervalWait) {
      prevVibTime = millis();
      if (vibCounter % 2 == 0) {
        //Serial.println("Set Motor HIGH");
        analogWrite(motorPin, 60);
      } else {
        //Serial.println("Set Motor LOW");
        analogWrite(motorPin, 0);
      }
      vibCounter++;
      if (vibCounter > vibCountMax) {
        startVib = false;
        vibCounter = 0;
      }
    }
  }

  //Decreases beeping interval time
  if (millis() - startTime >= 30000) {
    interval -= 100;
    if (interval <= 300) interval = 300;
    startTime = millis();
  }

  delay(1);
}

void knobThing() {
  currentStateCLK = digitalRead(knobCLK);

  if (currentStateCLK != lastStateCLK  && currentStateCLK == 1) {
    if (digitalRead(knobDT) != currentStateCLK) {
      knobCounter -= 0.5;
      if (knobCounter < 0.0 ) {
        knobCounter = 9.5;
      }
      currentDir = "CCW";
      if (knobCounter == int(knobCounter)) {
        if (knobCounter == knobCorrect) {
          /*analogWrite(motorPin, vibValMax);
            delay(50);
            analogWrite(motorPin, 0);
            delay(50);
            analogWrite(motorPin, vibValMax);
            delay(50);
            analogWrite(motorPin, 0);*/
          startVib = true;
          vibCountMax = 3;
          intervalWait = 50;
        } else {
          startVib = true;
          vibCountMax = 1;
          intervalWait = 100;
          /*analogWrite(motorPin, vibValMin);
            delay(vibWaitMin);
            analogWrite(motorPin, 0);*/
        }
      }
    } else {
      knobCounter += 0.5;
      if (knobCounter > 9.5) knobCounter = 0.0;
      currentDir = "CW";
      if (knobCounter == int(knobCounter)) {
        if (knobCounter == knobCorrect) {
          /*analogWrite(motorPin, vibValMax);
            delay(50);
            analogWrite(motorPin, 0);
            delay(50);
            analogWrite(motorPin, vibValMax);
            delay(50);
            analogWrite(motorPin, 0);*/
          startVib = true;
          vibCountMax = 3;
          intervalWait = 50;
        } else {
          startVib = true;
          vibCountMax = 1;
          intervalWait = 100;
          /*analogWrite(motorPin, vibValMin);
            delay(vibWaitMin);
            analogWrite(motorPin, 0);*/
        }
      }
    }
    Serial.println(knobCounter);
  }
  lastStateCLK = currentStateCLK;
}

void inputKey(String letter, int sizeOfMsg) {
  if ( letter == "C") {
    if (sizeOfMsg > 0) keyMsg.remove(sizeOfMsg - 1);
    refreshDisplay();
  } else if (letter == "E") {
    //Check correct code...
    if (keyMsg == finalCode) {
      Serial.println("Success!");
      isDone = true;
      digitalWrite(gLed, HIGH);
      digitalWrite(rLed, LOW);
      analogWrite(motorPin, 0);
    } else {
      keyMsg = "";
      refreshDisplay();
    }
  } else {
    if (keyMsg.length() < maxKeyMsg) {
      keyMsg += letter;
    }
  }
  display.setTextSize(2);
  display.setCursor(24, 31);
  display.print(String(keyMsg[0]) + " " + String(keyMsg[1]) + " " + String(keyMsg[2]) + " " + String(keyMsg[3]));
  display.display();
}

void refreshDisplay() {
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(10, 2);
  display.print("Bomb Code:" + String(code));
  display.setCursor(10, 12);
  display.print("Unlock:");

  display.setTextSize(2);
  display.setCursor(24, 36);
  display.print("_ _ _ _");

  display.display();
}


void beeping() {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    if (tickToggle) {
      //tone(tonePin, 1000, 200);
      tickToggle = false;
      digitalWrite(rLed, LOW);
      //analogWrite(motorPin, 0);
    } else {
      //tone(tonePin, 1000, 200);
      tickToggle = true;
      digitalWrite(rLed, HIGH);
      //analogWrite(motorPin, 18);
    }
  }
}
