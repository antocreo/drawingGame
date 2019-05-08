

class Evaluation {
  JSONObject json;
  PVector[] xyPos;
  int counter = 0;

  Evaluation(String path, int idx, String coord1, String coord2) {
    loadData(path, idx, coord1, coord2);
  }

  PVector getCoordinates() {
    PVector coord = new PVector();
    if (xyPos.length>1 && xyPos.length > 0) {
      coord =  new PVector(xyPos[0].x, xyPos[0].y);
    } 
    if (xyPos.length == 1) {
      coord =  new PVector(xyPos[0].x, xyPos[0].y);
    }


    return coord;
  }


  void loadData(String path, int idx, String coord1, String coord2) {

    ArrayList<String>  currentFile = currentFile(path);
    json = loadJSONObject(currentFile.get(idx));


    JSONObject drawing = json.getJSONObject("drawing");
    //println(drawing.size());

    JSONArray xPosJ = drawing.getJSONArray(coord1);
    JSONArray yPosJ = drawing.getJSONArray(coord2);
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