
class VectorModel {
  float w = 400;
  float h = 400;

  float xx = (width - w)/2;
  float yy = (height - h)/2;

  boolean bError = false;
  boolean bDone = false;
  boolean bChosen = false;
  float startTimeEval = millis();

  PVector selectedPoint =  new PVector(mouseX, mouseY);

  VectorModel() {
  };
  //--------------------------------------------------------------

  void display(float x, float y) {
    
    pushStyle();
    fill(255);
    rect(x, y, w, h);
    fill(0, 0, 0);
    line(x + w/2, y, x + w/2, y + h);
    stroke(0, 0, 0);
    line(x, y + h/2, x + w, y + h/2);
    popStyle();

    //drawfont
    pushStyle();
    textSize(15);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Aroused", x + w + textWidth("Aroused")/2 + 5, y + h/2);
    text("Calm", x - textWidth("Calm")/2 - 5, y + h/2 );
    text("Pleasant", x + (w)/2, y - textAscent() - 5 );
    text("Unpleasant", x + (w)/2, y + h + textAscent() + 5);
    String sq ="HOW DO YOU FEEL ABOUT THIS DRAWING?";
    text(sq, (width)/2, 60);

    //println(selectedPoint);  
    popStyle();

    //cursor lines
    pushStyle();
    stroke(180);
    //draw just inside the axis
    if (mouseX <= w + xx && mouseX >= x) {
      line(mouseX, y, mouseX, y + h );
    }
    if (mouseY<= h + yy && mouseY >= y) {
      line(x, mouseY, x + w, mouseY);
    }
    popStyle();


    if (bError == true) {
      pushStyle();
      textAlign(CENTER, CENTER);
      String s = "Please click inside the white box";
      fill(255, 0, 0);
      noStroke();
      rect(x, height/2 - 25, w, 50);
      textSize(20);
      fill(255);
      text(s, (width)/2, height/2);
      popStyle();
    }
  }

  //--------------------------------------------------------------
  void mouseMov() {

    selectedPoint = new PVector(mouseX, mouseY);


    if (mouseX <= w + xx && mouseX >= xx && mouseY<= h + yy && mouseY >= yy) {
      bError= false;
      selectedPoint.x = map(selectedPoint.x, xx, w + xx, -1, 1);
      selectedPoint.y = map(selectedPoint.y, yy, h + yy, 1, -1);
    } else {

      bError = true;
    }
  }
  
  

  //--------------------------------------------------------------
  void mouseRel() {

    selectedPoint = new PVector(mouseX, mouseY);

    if (mouseX <= w + xx && mouseX >= xx && mouseY<= h + yy && mouseY >= yy) {
      bError= false;
      selectedPoint.x = map(selectedPoint.x, xx, w + xx, -1, 1);
      selectedPoint.y = map(selectedPoint.y, yy, h + yy, 1, -1);
      bDone = true;
    } else {

      bError = true;
    }

    if (bDone == true) {

    }
  }
}