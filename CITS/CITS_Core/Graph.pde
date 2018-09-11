
class Graph {
  String label = "NONE";
  int height = 380;
  int width = 500;
  int x = 100;
  int y = 100;
  color backgroundColor = color(0, 0, 0);
  boolean drawBackground = true;
  color lineColor = color(255, 0, 0);
  Graph(String label, int x, int y) {
    this.x = x;
    this.y = y;
    this.label = label;
  }
  Graph(String label, int x, int y, boolean drawBackground) {
    this.x = x;
    this.y = y;
    this.label = label;
    this.drawBackground = drawBackground;
  }
  void draw(FloatList values) {
    draw(values, values.min(), values.max());
  }
  //function to draw the graphs on the screen
  void draw(FloatList values, float min, float max) {
    if (values.size() == 0) {
      return;
    }
    pushMatrix();
    translate(x + width/2, y + height/2);
    //draw the labels on the graph
    text(label, 0, 0);
    //draw background of graph
    if (drawBackground) {
      stroke(255, 255, 255);
      fill(backgroundColor);
      rect(0, 0, width, height);
    } else {
      noFill();
    }
    popMatrix();
    pushMatrix();
    translate(x, y);

    //draw values
    noFill();
    stroke(lineColor);
    strokeWeight(2);
    // fill(lineColor);
    //draw a 'shape' that is all of our graph data points


    //if our data set is larger than the graph, just draw what will fit
    int start;
    if (values.size() < width) {
      start = width - values.size();
    } else {
      start = 0;
    }
    // float max = values.max();
    // float min = values.min();
    if (max != min) {
      //draw the points
      beginShape();
      for(int i = max(0, values.size() - width); i < values.size();i++)
        vertex(start + i, map(values.get(i), max, min, 0, height));
      endShape();
    }
    strokeWeight(1);
    popMatrix();
  }
}
//helper function that finds a string in a list of strings
//Returns which position in the list the string is in, or -1 if it can't find it
// int listContains(String[] list, String word) {
//   for (int i = 0; i < list.length; i ++) {
//     if (list[i] == word) {
//       return i;
//     }
//   }
//   return -1;
