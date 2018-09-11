////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - GUI
//
// import processing.sound.*;

//some global colors
color red = color(200, 0, 0);
color yellow = color(230, 220, 0);
color blue = color(0, 40, 200);
color green = color (40, 200, 40);
color black = color(0,0,0);
color white = color(220, 220, 220);
color faded = color(100, 100, 100);
color purple = color(193, 29, 255);

//Base Screen class. Meant to be extended by child classes
public class Screen {
  void setup() { }
  void draw(AllData data) { }
  boolean mousePressed() { return false;}
  boolean keyPressed() { return false;}
}

public class GUI{
  //import a monspace font so letters are evenly spaced
  PFont monoFont;
  //map of the area (image)
  PImage map;


  // String currentScreen = "flight";
  Screen currentScreen;
  FlightScreen flight;
  NavScreen nav;
  PIDScreen pid;
  DebugScreen debug;
  //list of all the buttons we are using
  Button[] menuButtons;

  //gui setup
  public void setup() {
    //load font
    monoFont = createFont("monospaced.plain", 12);
    textFont(monoFont);

    //setup all screns
    pid = new PIDScreen();
    flight = new FlightScreen();
    debug = new DebugScreen();
    nav = new NavScreen();
    currentScreen = nav;

    //setup buttons
    menuButtons = new Button[] {
      new Button("flight", 50, 20, "flight"),
      new Button("nav", 50, 55, "nav"),
      new Button("pid", 50, 90, "pid"),
      new Button("debug", 50, 125, "debug")
    };
  }

  void clickButtons() {
    for (int i = 0; i < menuButtons.length; i++) {
      if (menuButtons[i].collides()) {
        if (menuButtons[i].action == "flight") {
          currentScreen = flight;
        } else if (menuButtons[i].action == "nav") {
          currentScreen = nav;
        } else if (menuButtons[i].action == "pid") {
          currentScreen = pid;
        } else if (menuButtons[i].action == "debug") {
          currentScreen = debug;
        }
      }
    }
  }
  //draw all GUI elements
  void draw(AllData allData) {
    for (int i = 0; i < menuButtons.length; i++) {
      menuButtons[i].draw();
    }
    currentScreen.draw(allData);
  }

  void mousePressed() {
    if (currentScreen.mousePressed()) {
      return;
    } else {
      clickButtons();
    }
  }

  boolean keyPressed() {
    return currentScreen.keyPressed();
  }

}
