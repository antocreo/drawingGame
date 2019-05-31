class Timer {


AudioSample endSound;

  int startTime = 0;
  int stopTime = 0;
  boolean isRunning = false;  
  boolean bEnded = false;

  Timer() {
    endSound = minim.loadSample( "endSound.mp3", 512);
  }

  void start() {
    startTime = millis();
    isRunning = true;
  }

  void stop() {
    stopTime = millis();
    isRunning = false;
  }

  //get elapsed time in seconds
  int getElapsedTime() {
    int elapsed;
    if (isRunning) {
      elapsed = (millis() - startTime);
    } else {
      elapsed = (stopTime - startTime);
    }
    return elapsed;
  }

  void checkAlarm(int sec) {
    if (getElapsedTime() >= sec * 1000 && getElapsedTime() < sec*1000 + 50 ) {
      endSound.trigger();
      bEnded = true;
      //println(bEnded);
      stop();
    }
  }
}