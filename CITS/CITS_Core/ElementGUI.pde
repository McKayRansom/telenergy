////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - GUI
//
// a relatively simple Button class


boolean boxCollides(int pointX, int pointY,
  int boxX, int boxY, int boxWidth, int boxHeight) {
  return (pointX > (boxX -boxWidth/2)) && (pointX < (boxX + boxWidth/2)) &&
  (pointY > (boxY -boxHeight/2)) && (pointY < (boxY + boxHeight/2));
}

class Button {
  String label = "";
  int x = 0;
  int y = 0;
  color fillColor;
  color textColor;
  int width = 95;
  int height = 30;
  boolean sendCommandOnClicked = false;
  String action = "";
  Button(String label, int x, int y) {
    fillColor = black;
    textColor = white;
    this.x = x;
    this.y = y;
    this.label = label;
  }
  Button(String label, int x, int y, int width, int height) {
    fillColor = black;
    textColor = white;
    this.x = x;
    this.y = y;
    this.label = label;
    this.width = width;
    this.height = height;
  }
  Button(String label, int x, int y, int width, int height, color fillColor, color textColor) {
    this.fillColor = fillColor;
    this.textColor = textColor;
    this.x = x;
    this.y = y;
    this.label = label;
    this.width = width;
    this.height = height;
  }
  Button(String label, int x, int y, String action, boolean sendCommand) {
    fillColor = color(0, 0, 0);
    textColor = color(220, 220, 220);
    this.action = action;
    sendCommandOnClicked = sendCommand;
    this.x = x;
    this.y = y;
    this.label = label;
  }
  Button(String label, int x, int y, int width, int height, String action, boolean sendCommand) {
    fillColor = black;
    textColor = white;
    this.action = action;
    sendCommandOnClicked = sendCommand;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
  }
  Button(String label, int x, int y, String action) {
    fillColor = black;
    textColor = white;
    this.action = action;
    this.x = x;
    this.y = y;
    this.label = label;
  }
  // void onClicked() {
    // if (sendCommandOnClicked) {
      // sendCommand(action);
    // } else if (changeScreenOnClicked) {
      // changeScreen(action);
    // }
  // }
  public void draw() {
    fill(fillColor);
    stroke(0);
    strokeWeight(0);
    rectMode(CENTER);
    rect(x, y, width, height, 5);
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(label, x, y);
  }

  public void draw(color newColor) {
    fill(newColor);
    stroke(0);
    strokeWeight(0);
    rectMode(CENTER);
    rect(x, y, width, height, 5);
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(label, x, y);
  }

  public void draw(color buttonColor, color textColor) {
    fill(buttonColor);
    stroke(0);
    strokeWeight(0);
    rectMode(CENTER);
    rect(x, y, width, height, 5);
    textAlign(CENTER, CENTER);
    fill(textColor);
    text(label, x, y);
  }

  boolean collides() {
    if (boxCollides(mouseX, mouseY, x, y, width, height)) {
      return true;
    }
    return false;
  }
}

//Basic TextBox
//Centered on center left unlike buttons!
class TextBox {
  String text = "";
  color textColor;
  int x = 0;
  int y = 0;
  int width = 95;
  int height = 30;
  TextBox(String text, int x, int y) {
    textColor = white;
    this.x = x;
    this.y = y;
    this.text = text;
  }
  TextBox(String text, int x, int y, int width, int height) {
    textColor = white;
    this.x = x;
    this.y = y;
    this.text = text;
    this.width = width;
    this.height = height;
  }
  public void draw() {
    textAlign(LEFT, CENTER);
    fill(textColor);
    text(text, x, y);
  }
  public void draw(color newColor) {
    textAlign(LEFT, CENTER);
    fill(newColor);
    text(text, x, y);
  }

  boolean collides() {
    if (boxCollides(mouseX, mouseY, x + width/2, y, width, height)) {
      return true;
    }
    return false;
  }
}
