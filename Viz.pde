class Viz {

  color rectColor;

  Viz() {
  };


  void display(float x, float y, float w, float h, String player, float percentage) {
    noStroke();
    fill(rectColor);
    rect(x+30 , y, w, h);

    //text
    fill(rectColor);
    textAlign(LEFT, CENTER);
    textSize(20);
    text(player, x, y + textAscent()/2);
    text(percentage + "%", x+w+30, y + textAscent()/2);
  }

  void setColor(int r, int g, int b) {   
    rectColor =  color(r,g,b);
  }
}