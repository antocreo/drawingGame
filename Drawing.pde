
class Drawing {
  JSONObject json;
  PVector[] xyPos;
  int counter = 0;

  Drawing(String path, int idx) {
    loadData(path, idx);
  }

  void display() {
    background(255);
    noFill();
    strokeWeight(2);
    stroke(0);
    beginShape();

    // Display all points
    for (int i = 0; i < xyPos.length; i++) {
      vertex(xyPos[i].x, xyPos[i].y);
    }
    endShape();
  }


  void loadData(String path, int idx) {

    ArrayList<String>  currentFile = currentFile(path);
    json = loadJSONObject(currentFile.get(idx));


    JSONObject drawing = json.getJSONObject("drawing");
    //println(drawing.size());

    JSONArray xPosJ = drawing.getJSONArray("xPos");
    JSONArray yPosJ = drawing.getJSONArray("yPos");
    //println(xPosJ, yPosJ);


    xyPos = new PVector[xPosJ.size()];
    //println(xPosJ.size());


    for (int i = 0; i < xPosJ.size(); i++) {
      xyPos[i] = new PVector(xPosJ.getFloat(i), yPosJ.getFloat(i));
    }
  }

  ArrayList<String> currentFile(String folderPath) {

    File[] files = listFiles(folderPath);
    //println(files.length);
    ArrayList<String> filePaths =  new ArrayList<String>();

    for (int i = 0; i < files.length; i++) {
      filePaths.add(files[i].getAbsolutePath());
      //println(filePaths.get(i));
    }
    return filePaths;
  }
}