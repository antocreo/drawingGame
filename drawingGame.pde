import oscP5.*;
import netP5.*;
import ddf.minim.*;


OscP5 oscP5;
NetAddress destWek;
NetAddress destEval;
Timer timer;
Timer timerBefore;
Minim minim;
JSONObject drawingJ, json;

//evaluation vector model
VectorModel vectorModel;

//this sets if we are training the model or if we are playing the game
boolean bTraining = true;
//keep track of drawings done
int counter= 0;
int counterEval = 0;
//max drawings for training
int drawingsTraining = 8;

PImage drawIcon;
PImage guessIcon;
PImage titleLogo;


PFont f;

// MAXIMUM SIZE ALLOWED FOR THE NUMBER OF POINTS IN THE STROKE GESTURE
int MAXSIZE  = 250;

//case switch
int page;

//INPUTS FOR MODEL
ArrayList<Float> speed = new ArrayList<Float>();
ArrayList<PVector> velocity = new ArrayList<PVector>();
ArrayList<Float> acceleration = new ArrayList<Float>();
ArrayList<Float> xPos = new ArrayList<Float>();
ArrayList<Float> yPos = new ArrayList<Float>();
ArrayList<PVector> xyPos = new ArrayList<PVector>();
ArrayList<Float> pStatus = new ArrayList<Float>();

ArrayList<Float> receivedX = new ArrayList<Float>(); //received from Wekinator via OSC
ArrayList<Float> receivedY = new ArrayList<Float>(); //received from Wekinator via OSC

ArrayList<Viz> vizRects = new ArrayList<Viz>();


float istSpeed = 0; 

//velocity
float istVelX = 0;
float istVelY = 0;
PVector istVel;

//accel
float istAcc = 0;

//mean and std deviation of Speed/Velocity/Accel
float mSpeed = 0;
float stdSpeed = 0;

float mAccel = 0;
float stdAccel = 0;

//we also get the timing before starting the drawaing/during the drawing/and before the evaluation
float timeBeforeDrawing = 0;
float timeDrawing = 0;
float timeBeforeEval = 0;
float dTime = 0;

String folderName = "";
String gameFolder = "";

Drawing currentDrawing;
Evaluation player1, wekinator, player2;
ArrayList<PVector> p1Vec = new ArrayList<PVector>();
ArrayList<PVector> wekiVec = new ArrayList<PVector>();
ArrayList<PVector> p2Vec = new ArrayList<PVector>();
ArrayList<Float> results = new ArrayList<Float>();


void setup() {

  //default page is initial with instructions
  page = 100;

  folderName = setFolderName();
  //create the folder in the game folder alreadt to prevent nullpointer when we start the game
  //we need to use dataPath as it gets the absolute path otherwise we get permission errors... Arrrgh!!
  String gameFolder = dataPath("")+"/json/game/" + folderName;
  new File(gameFolder).mkdir();
  println(gameFolder);

  f = createFont("Arial_Bold", 25);
  textFont(f);

  //create json file
  json = new JSONObject();
  drawingJ = new JSONObject();
  json.setJSONObject("drawing", drawingJ);

  //load minim
  minim = new Minim(this);

  //load icons
  drawIcon = loadImage("draw.png");
  guessIcon = loadImage("guess.png");
  titleLogo = loadImage("titleLogo.png");


  size(800, 600, P2D);

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  destWek = new NetAddress("127.0.0.1", 6448);
  //destEval = new NetAddress("127.0.0.1", 6449);


  //create timer
  timer = new Timer();
  timerBefore = new Timer();

  //create vectorModel
  vectorModel  = new VectorModel();
}

void draw() {
  //start time count for each frame
  //this needs to stay on the first line
  float now = millis();

  // opening page draw or guess?
  switch(page) {
  case 100:
    trainingInstructions();
    break;

  case 101:
    drawGesture();
    break;

  case 102:
    evalDrawing();
    break;

  case 0: 
    drawSelectionPage();
    break;

  case 1: 
    drawGesture();
    break;


  case 2: 
    evalDrawing();
    break;

  case 3: 
    showDrawing();
    break;
  case 4:
    evalDrawing();
    break;
  case 5:
    finalPage();
    break;
  }

  //pushStyle();
  //fill(200, 0, 0);
  //noStroke();
  //text(page, 10, 10);
  //text(counter, 10, 30);
  //text(counterEval, 10, 50);
  //popStyle();


  //end time count for each frame
  //this needs to stay on the last line
  dTime = millis() - now;
}


///////-------------------------------------------------------------///////

//                          F U N C T I O N S

///////-------------------------------------------------------------///////

///////-----------------TRAINING INSTRUCTIONS PAGE---------------------///////


void trainingInstructions() {

  pushStyle();
  background(255);
  //instructions
  image(titleLogo, width/2 - titleLogo.width/2, 40);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(15);
  String instr = "Before starting the game, we need to train our model with 5 gestures.\nIt's very simple, no worries! \nYou have 10 second to draw, in one only gesture, \nwhat you feel in that moment.\nAs soon as you lift your pen, you will see a new panel. \nThere you can point the emotional value of that specific gesture. \n";
  text(instr, width/2, height/2);
  String skip = "if you want to skip the training, don't click, press key 'G'";
  fill(250, 0, 0);
  text(skip, width/2, height/2 + 150);

  popStyle();
}


///////-----------------SELECTION PAGE---------------------///////


void drawSelectionPage() {
  background(255);
  image(titleLogo, width/2 - titleLogo.width/2, 40);

  float icon1XPos = (width/2 - drawIcon.width)/2;
  float icon2XPos = (width/2 - drawIcon.width)/2 + width/2;

  float iconYPos = (height - drawIcon.height)/2;

  image(drawIcon, icon1XPos, iconYPos);
  image(guessIcon, icon2XPos, iconYPos);
  if (page == 0) {
    if ( mouseX >=0 && mouseX <= width/2) {

      pushStyle();
      fill(255, 0, 0, 50);
      noStroke();
      rect(icon1XPos, iconYPos, drawIcon.width, drawIcon.height);

      //instructions
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(15);
      text("if you choose this, \nyou've got 10 seconds to express your emotion \nwith one drawing gesture. \nDo your best!", width/2, iconYPos + drawIcon.height + 50);
      popStyle();
    } else if ( mouseX > width/2 && mouseX <= width) {
      //let's check we have got some drawings already
      int folderSize = folderSize();
      if (folderSize > 0) {
        pushStyle();
        fill(255, 0, 0, 50);
        noStroke();
        rect(icon2XPos, iconYPos, drawIcon.width, drawIcon.height);

        //instructions
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(15);
        text("if you choose this, \nyou've got 10 seconds \nto 'feel' your friend's drawing. \nDo your best!", width/2, iconYPos + drawIcon.height + 50);
        popStyle();
      } else {
        pushStyle();
        //instructions
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(15);
        text("you can't choose this yet. \nSomeone needs to make some drawings first!", width/2, iconYPos + drawIcon.height + 50);
        popStyle();
      }
    }

    pushStyle();
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(25);
    text("MAKE YOUR CHOICE!", width/2, 150);
    popStyle();
  }
}




///////-------------DRAW GESTURE---------------------------///////

//function that deal with the individual gesture on screen
void drawGesture() {
  background(255);


  //vector distance
  PVector oldCoord = new PVector(mouseX, mouseY);
  PVector newCoord = new PVector(pmouseX, pmouseY);
  float d = oldCoord.dist(newCoord);

  //speed
  //formula from Shiffman is also equal to the magnitude of the velocity 
  istSpeed = abs(mouseX-pmouseX) + abs(mouseY-pmouseY); 

  //velocity
  istVelX =  (istSpeed*(mouseX - pmouseX))/d;
  istVelY =  (istSpeed*(mouseY - pmouseY))/d;
  PVector istVel = new PVector(istVelX, istVelY);

  //accel
  istAcc = 0;

  //draw timerBar
  timerBar();


  //iterate through max size allowed 250, and fill the vectors, and draw the shape.
  if (mousePressed == true && (page == 1 || page == 101)) {

    ///stop time before
    timeBeforeDrawing = timerBefore.getElapsedTime();
    timerBefore.stop();

    ////start Recording on Wekinator
    //OscMessage msg = new OscMessage("/wekinator/control/startRecording");
    //oscP5.send(msg, destWek);

    if (xPos.size()< MAXSIZE) {

      xPos.add((float)mouseX);
      yPos.add((float)mouseY);
      xyPos.add(new PVector((float)mouseX, (float)mouseY));
      speed.add(istSpeed);
      //this avoid velocity NaN
      if (istSpeed == 0.0 ) {
        istVelX = 0;
        istVelY = 0;
      }
      velocity.add(new PVector(istVelX, istVelY));

      noFill();
      strokeWeight(2);
      beginShape();

      for (int i = 0; i < xPos.size(); i++) {
        vertex(xPos.get(i), yPos.get(i));

        if (i > 0 && dTime > 0) {
          //acceleration
          float dSpeed = abs(speed.get(i) - speed.get(i-1));
          istAcc = dSpeed/dTime;
        }
      }
      endShape();
      acceleration.add(istAcc);
      //println("speed ", istSpeed, "    accel ", istAcc, "    velX ", istVelX, "    velY ", istVelY);
      //println(xPos.size(), yPos.size(), velocity.size(), speed.size(), acceleration.size());
    }


    sendOsc();
  }
  //when the drawing reaches 
  boolean timeEnded = timer.bEnded;
  if (xPos.size()> MAXSIZE || timeEnded == true) {
    if (page == 1) {
      if (xPos.size()>0) {
        page = 2;
      } else page = 0; // go back to selection page
    }
    if (page == 101) {
      if (xPos.size()>0) {
        page = 102;
      } else page = 100; //go back to instructions
    }
  }
}

///////----------------- SHOW DRAWING --------------------///////

void showDrawing() {
  //roungr
  timerBar();

  if (counterEval < folderSize()) {
    currentDrawing.display();
  }
}


///////----------------- EVALUATE DRAWING --------------------///////

void evalDrawing() {
  background(0);

  //draw timerBar
  timerBar();

  // draw vector model
  vectorModel.display((width - vectorModel.w)/2, (height - vectorModel.h)/2);

  //when the time ends TO fix this - for now the evaluation goes further 10 seconds.
  /*
  boolean timeEnded = timer.bEnded;
   if (timeEnded == true) {
   if (page == 2) {
   if (xPos.size()>0) {
   page = 2;
   } else page = 0; // go back to selection page
   }
   if (page == 102) {
   if (xPos.size()>0) {
   page = 102;
   } else page = 100; //go back to instructions
   }
   }
   */
}

///////----------------- FINAL PAGE --------------------///////

void finalPage() {
  background(255);
  pushStyle();
  //title
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("Final Results", width/2, 70);
  textSize(15);
  text("Click anywhere to start a new game", width/2, 120);
  popStyle();

  pushStyle();
  noStroke();
  float y = 200;
  float x = 10;


  for (int i=0; i < results.size(); i++) {
    //1.4142 is the diagonal of a square with side 2 which is the maximum distance achievable on the vector model
    //we reverse the mapping because the higher the distance the worse the performance
    float w = map(results.get(i), 2.82843, 0, 0, width/2);
    float h = 20;
    float gap = 10;
    //if odd index 
    if (i%2==0) {
      //human eval
      y = y + h + gap;
      //fill(200, 50, 0);
      //rect(0, y, w, 20);

      float percentage = w*100/(width/2);
      vizRects.get(i).setColor(200, 50, 0);
      vizRects.get(i).display(x, y, w, 20, "W", percentage);
    }
    //else if is even
    else {
      y = y + h;
      //wekinator eval
      //fill(0, 250, 30);
      //rect(0, y, w, 20);

      float percentage = w*100/(width/2);
      vizRects.get(i).setColor(0, 250, 30);
      vizRects.get(i).display(x, y, w, 20, "P", percentage);
    }
  }
  popStyle();

  pushStyle();
  //legenda
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(10);
  text("W = Wekinator guess; P = player guess", width/2, height - 70);
  popStyle();
}



///////----------------- RESET--------------------///////


void reset(String option) {
  speed.clear();
  velocity.clear();
  acceleration.clear();
  xPos.clear();
  yPos.clear();
  pStatus.clear();
  results.clear();
  p1Vec.clear();
  wekiVec.clear();
  p2Vec.clear();
  results.clear();
  receivedX.clear();
  receivedY.clear();
  vizRects.clear();

  timer.bEnded = false;
  timer.stop();

  vectorModel.bDone = false;
  if (option == "startGame") {
    counter = 0;
    counterEval = 0;
  } else if (option == "training" || option == "continueGame") {
    counter++;
  } else if (option == "newGame") {
    counter = 0;
    counterEval = 0;

    folderName  = setFolderName();
    //create the folder in the game folder alreadt to prevent nullpointer when we start the game
    //we need to use dataPath as it gets the absolute path otherwise we get permission errors... Arrrgh!!
    String gameFolder = dataPath("")+"/json/game/" + folderName;
    new File(gameFolder).mkdir();
    println(gameFolder);
  }
}

///////-------------OSC SEND---------------------///////

void sendOsc() {
  OscMessage msgWek = new OscMessage("/wek/inputs");
  //OscMessage msgEval = new OscMessage("/coords");

  //sending INTPUTS to Wekinator
  //sending messages
  //stream values
  msgWek.add((float)mouseX); //1
  msgWek.add((float)mouseY); //2
  msgWek.add(istSpeed); //3
  msgWek.add(istVelX); //4
  msgWek.add(istVelY); //5
  msgWek.add(istAcc); //6

  //single values
  msgWek.add((float)xPos.size()); //7
  msgWek.add(getMean(speed)); //8
  msgWek.add(getMean(acceleration)); //9
  msgWek.add(getStdDev(speed)); //10
  msgWek.add(getStdDev(acceleration)); //11
  msgWek.add((float)timeBeforeDrawing); //12
  msgWek.add((float)timeDrawing); //13
  msgWek.add((float)timeBeforeEval); //14

  oscP5.send(msgWek, destWek);

  //sending messages for coordinates to the other screen
  //msgEval.add((float)mouseX); 
  //msgEval.add((float)mouseY);
  //oscP5.send(msgWek, destWek);
  //oscP5.send(msgEval, destEval);
}

///////--------------OSC RECEIVED--------------------///////

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
    if (theOscMessage.checkTypetag("ff")) { // looking for 1 control value
      float x = theOscMessage.get(0).floatValue();
      float y = theOscMessage.get(1).floatValue();

      //filling the lists with the evaluations of Wekinator
      receivedX.add(x);
      receivedY.add(y);

      //println(x, y);
      //println(receivedX.size());
    } else {
      println("Error: unexpected OSC message received by Processing: ");
      theOscMessage.print();
    }
  }
}


///////----------------- TIMER BAR ---------------------///////


void timerBar() {
  //timer bar
  //println(timer.getElapsedTime());
  pushStyle();
  fill(255, 0, 0);
  noStroke();
  float barW = map(timer.getElapsedTime(), 10*1000, 0, 0, width);
  //println("barw     ", barW);
  rect(0, 0, barW, 5);
  timer.checkAlarm(10);
  popStyle();
}


void mouseMoved() {
  vectorModel.mouseMov();
}

///////--------------MOUSE PRESSED-------------------///////

void mousePressed() {

  switch(page) {
    //instruction page
  case 100:
    break;

  case 101:
    //start Recording on Wekinator
    OscMessage msg = new OscMessage("/wekinator/control/startRecording");
    oscP5.send(msg, destWek);

    //get time before drawing
    timeBeforeDrawing = timerBefore.getElapsedTime();
    break;

  case 102:
    break;

  case 0:
    break;

  case 1:
    //start Running on Wekinator
    msg = new OscMessage("/wekinator/control/startRunning");
    oscP5.send(msg, destWek);

    //get time before drawing
    timeBeforeDrawing = timerBefore.getElapsedTime();
    break;

  case 2:
    break;
  }
}


///////--------------MOUSE RELEASED-------------------///////

void mouseReleased() {


  switch(page) {
    //instruction page
  case 100:
    reset("startGame");
    //go to training page
    page = 101;
    //start time bar
    timer.start();
    timerBefore.start();
    break;

    //drawing training
  case 101:
    if (counter < drawingsTraining) {
      //get duration of the drawing
      timeDrawing = timer.getElapsedTime();

      //stop recording on Wekinator
      OscMessage msg = new OscMessage("/wekinator/control/stopRecording");
      oscP5.send(msg, destWek);
      // if drawing gesture finishes go to evaluation page
      if (xPos.size()>10) {
        //write data from the drawing on the JSON file
        writeJSON();
        //now go to page 2
        page = 102;
        //start time bar
        timer.start();
        timerBefore.start();
      }
    }
    break;

    //evaluation training
  case 102:
    if (counter < drawingsTraining) {
      // only on page 102 evaluation
      vectorModel.mouseRel();

      //get duration of the drawing
      timeBeforeEval = timerBefore.getElapsedTime();

      //write data from the drawing on the JSON file
      writeJSON();
      if (vectorModel.bDone == true) {

        ////start Recording on Wekinator
        OscMessage msg = new OscMessage("/wekinator/control/outputs");
        msg.add(vectorModel.selectedPoint.x);
        msg.add(vectorModel.selectedPoint.y);
        oscP5.send(msg, destWek);
        //stop recording on Wekinator
        //OscMessage msg = new OscMessage("/wekinator/control/stopRecording");
        //oscP5.send(msg, destWek);

        String fileName  = str(counter);
        saveJSONObject(json, "data/json/training/" + folderName + fileName +".json");
        reset("training"); //this contains also counter++;
        page = 101;
        timer.start();
        timerBefore.start();
      }
    }
    if (counter == drawingsTraining) {
      reset("startGame");
      page = 0;
    }

    break;

    //choice between drawing and evaluate
  case 0:
    //reset for the game
    timer.bEnded = false;

    //check mouse pos
    if ( mouseX >=0 && mouseX <= width/2) {
      page = 1;
      //start time bar
      timer.start();
      timerBefore.start();
    } else if ( mouseX > width/2 && mouseX <= width) {
      //let's check we have got some drawings in the game folder
      int folderSize = folderSize();
      if (folderSize > 0) {  
        //create the drawing
        currentDrawing = new Drawing(dataPath("")+"/json/game/" + folderName, counterEval);
        //go to the page
        page = 3;
        //start time bar
        timer.start();
        timerBefore.start();
      }
    }
    break;

    //start the game and start drawing
  case 1:
    // if drawing gesture finishes go to evaluation page
    if (xPos.size()>10) {
      //get duration of the drawing
      timeDrawing = timer.getElapsedTime();

      //Stop Running on Wekinator
      OscMessage msg = new OscMessage("/wekinator/control/stopRunning");
      oscP5.send(msg, destWek);

      //write data from the drawing on the JSON file
      writeJSON();
      //now go to page 2
      page = 2;
      //start time bar
      timer.start();
      timerBefore.start();
    }    
    break;


    //evaluation of the drawing
  case 2:
    // only on page 2 evaluation
    vectorModel.mouseRel();

    //get duration of the drawing
    timeBeforeEval = timerBefore.getElapsedTime();

    //write data from the drawing on the JSON file
    writeJSON();
    if (vectorModel.bDone == true) {
      String fileName  = str(counter);
      saveJSONObject(json, "data/json/game/"+ folderName + fileName +".json");      
      reset("continueGame"); //this contains also counter++;
      page = 0;
    }
    break;

    // show the drawing
  case 3:
    if (counterEval < folderSize()) {
      page = 4;
      timer.start();
      timerBefore.start();
    } 

    break;

    // external evaluation
  case 4:
    // only on page 2 evaluation
    vectorModel.mouseRel();

    if (counterEval < folderSize()) { 
      //write data from the drawing on the JSON file
      writeJSON();
      if (vectorModel.bDone == true) {
        String fileName  = str(counterEval);
        saveJSONObject(json, "data/json/eval/"+ folderName + fileName +".json");      
        reset("continueGame"); //this contains also counter++;
        //go to the net drawing
        counterEval++;
        if (counterEval < folderSize()) {
          currentDrawing = new Drawing(dataPath("")+"/json/game/" + folderName, counterEval);
          page = 3;
          timer.start();
          timerBefore.start();
        } else {
          page = 3;
          timer.start();
          timerBefore.start();
        }
      }
    }
    if (counterEval == folderSize()) {

      for (int i =0; i < folderSize(); i++) {
        player1 = new Evaluation(dataPath("")+"/json/game/" + folderName, i, "selectedPointX", "selectedPointY");
        p1Vec.add(player1.getCoordinates());
        wekinator = new Evaluation(dataPath("")+"/json/game/" + folderName, i, "receivedX", "receivedY");
        wekiVec.add(wekinator.getCoordinates());
        player2 = new Evaluation(dataPath("")+"/json/eval/" + folderName, i, "selectedPointXb", "selectedPointYb");
        p2Vec.add(player2.getCoordinates());

        results.add(abs(p1Vec.get(i).dist(wekiVec.get(i))));
        results.add(abs(p1Vec.get(i).dist(p2Vec.get(i))));
        //println(results.get(i));
        //println(results.size());
        //adding also the rects for the viz
        vizRects.add(new Viz());
        vizRects.add(new Viz());
      }
      //println(results);

      page = 5;
    }
    break;

  case 5:
    reset("newGame");
    folderName  = setFolderName();
    page = 100;

    break;
  }
}



///////--------------WRITE JSON-------------------///////

void writeJSON() {

  JSONArray xPosJ = new JSONArray();
  JSONArray yPosJ = new JSONArray();
  JSONArray velXJ = new JSONArray();
  JSONArray velYJ = new JSONArray();
  JSONArray speedJ = new JSONArray();
  JSONArray accelearationJ = new JSONArray();

  JSONArray selectedPointXJ = new JSONArray();
  JSONArray selectedPointYJ = new JSONArray();

  JSONArray selectedPointXbJ = new JSONArray();
  JSONArray selectedPointYbJ = new JSONArray();

  JSONArray receivedXJ = new JSONArray();
  JSONArray receivedYJ = new JSONArray();

  JSONArray timeDrawingJ = new JSONArray();
  JSONArray timeBeforeDrawingJ = new JSONArray();
  JSONArray timeBeforeEvalJ = new JSONArray();


  if (page == 1 || page == 101) {

    for (int i=0; i < xPos.size(); i++) {
      //json.setInt("id", 0);
      xPosJ.setFloat(i, xPos.get(i));
      yPosJ.setFloat(i, yPos.get(i));
      velXJ.setFloat(i, velocity.get(i).x);
      velYJ.setFloat(i, velocity.get(i).y);
      speedJ.setFloat(i, speed.get(i));
      accelearationJ.setFloat(i, acceleration.get(i));
    }

    //fill the received outputs from Wekinatorzzzz
    for (int i=0; i < receivedX.size(); i++) {
      receivedXJ.setFloat(i, receivedX.get(i));
      receivedYJ.setFloat(i, receivedY.get(i));

      timeBeforeDrawingJ.setFloat(i, timeBeforeDrawing);
      timeDrawingJ.setFloat(i, timeDrawing);
    }

    drawingJ.setJSONArray("xPos", xPosJ);
    drawingJ.setJSONArray("yPos", yPosJ);
    drawingJ.setJSONArray("velX", velXJ);
    drawingJ.setJSONArray("velY", velYJ);
    drawingJ.setJSONArray("speed", speedJ);
    drawingJ.setJSONArray("accelearation", accelearationJ);

    drawingJ.setJSONArray("receivedX", receivedXJ);
    drawingJ.setJSONArray("receivedY", receivedYJ);

    drawingJ.setFloat("avgSpeed", getMean(speed));
    drawingJ.setFloat("avgAccel", getMean(acceleration));
    drawingJ.setFloat("stdSpeed", getStdDev(speed));
    drawingJ.setFloat("stdAccel", getStdDev(acceleration));
    drawingJ.setInt("size", xPos.size());

    drawingJ.setJSONArray("timeBeforeDrawing", timeBeforeDrawingJ);
    drawingJ.setJSONArray("timeDrawing", timeDrawingJ);
  
}


  if (page == 2 || page == 102) {
    selectedPointXJ.setFloat(0, vectorModel.selectedPoint.x);
    selectedPointYJ.setFloat(0, vectorModel.selectedPoint.y);

    drawingJ.setJSONArray("selectedPointX", selectedPointXJ);
    drawingJ.setJSONArray("selectedPointY", selectedPointYJ);

    timeBeforeEvalJ.setFloat(0, timeBeforeEval);
    drawingJ.setJSONArray("timeBeforeEval", timeBeforeEvalJ);
  }

  if (page == 4) {
    selectedPointXbJ.setFloat(0, vectorModel.selectedPoint.x);
    selectedPointYbJ.setFloat(0, vectorModel.selectedPoint.y);

    drawingJ.setJSONArray("selectedPointXb", selectedPointXbJ);
    drawingJ.setJSONArray("selectedPointYb", selectedPointYbJ);
  }
}


///////--------------STATISTICS-------------------///////
// adapted from https://stackoverflow.com/a/7988556

float getMean(ArrayList<Float> data) {
  float sum = 0;
  for (float a : data)
    sum += a;
  return sum/data.size();
}


float getVariance(ArrayList<Float> data) {
  float mean = getMean(data);
  float temp = 0;
  for (float a : data)
    temp += (a-mean)*(a-mean);
  return temp/(data.size()-1);
}

float getStdDev(ArrayList<Float> data) {
  float std =  (float)Math.sqrt(getVariance(data));
  if (! Float.isNaN(std)) {
    return std;
  } else {
    return 0;
  }
}

///////--------------SET FOLDER-----------------------///////

String setFolderName() {

  //save image vars//
  String d = str(day());    // Values from 1 - 31
  String m = str(month());  // Values from 1 - 12
  String y = str(year());   // 2003, 2004, 2005, etc.
  String sec = str(second());  // Values from 0 - 59
  String min = str(minute());  // Values from 0 - 59
  String h = str(hour());    // Values from 0 - 23
  //end save image vars//


  return d+m+y+ "_" + h+min+sec + "/";
}

///////--------------FOLDER SIZE--------------------///////

int folderSize() {
  String folderPath =  "data/json/game/" + folderName;
  File[] files = listFiles(folderPath);

  int folderSize = files.length;
  //print(folderSize);
  return folderSize;
}



///////--------------KEY PRESSED------------------------///////


void keyPressed() {

  if (key == 'g') {
    page = 0;
  }
}