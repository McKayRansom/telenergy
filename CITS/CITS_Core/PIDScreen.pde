////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - PID GUI
//
//Displays all data nesesary to turn PIDs
//should also be able to change KP, KI, KD

class PIDScreen extends Screen {

  Button[] buttons;
  Graph setpointGraph;
  Graph processVariableGraph;
  int currentGraph = 0;
  int currentEdit = -1;

  String keyboardInput = "";
  TextBox[] gainTexts;
  String[] gains = new String[]{
    "KP: ", "KI: ", "KD: "
  };

  PIDScreen() {
    //throttle, (altitude), vertSpeed -> pitch, turn -> roll, yaw

    buttons = new Button[] {
      new Button("throttle", 150, 20, "whichPID"),
      new Button("vertSpeed", 150, 55, "whichPID"),
      new Button("pitch", 150, 90, "whichPID"),
      new Button("roll", 150, 125, "whichPID"),
      new Button("yaw", 150, 160, "whichPID"),
      new Button("turn", 150, 195, "whichPID"),

      new Button("get?", 750, 20, 40, 30, "g", true),
      new Button("set!", 750, 100, 40, 30, "p", true)
    };
    gainTexts = new TextBox[] {
      new TextBox("KP: unknown", 800, 20),
      new TextBox("KI: unknown", 800, 60),
      new TextBox("KD: unknown", 800, 100)
    };

    setpointGraph = new Graph("", 210, 10);
    setpointGraph.lineColor = blue;
    processVariableGraph = new Graph("", 210, 10, false);
    processVariableGraph.lineColor = red;
  }
  void draw(AllData data) {
    //if we have data
    if (data.flight.graphData[currentGraph+1].size() != 0) {
      //if we have autopilot setpoint data, draw that
      if (data.auto.graphData[currentGraph].size() != 0) {
        float max = max(data.auto.graphData[currentGraph].max(),
                    data.flight.graphData[currentGraph + 1].max());
        float min = min(data.auto.graphData[currentGraph].min(),
                    data.flight.graphData[currentGraph + 1].min());
        setpointGraph.draw(data.auto.graphData[currentGraph], min, max);
        processVariableGraph.draw(data.flight.graphData[currentGraph + 1], min, max);
      } else {
        processVariableGraph.draw(data.flight.graphData[currentGraph + 1]);
      }
    }

    //draw currentButtons
    for (int i = 0; i < buttons.length; i++) {
      if (i == currentGraph) {
        buttons[i].draw(green, black);
      } else {
        buttons[i].draw();
      }
    }

    //draw gain texts boxs things
    for (int i = 0; i < gainTexts.length; i++) {
      if (currentEdit == i) {
        gainTexts[i].text = gains[i] + keyboardInput;
        gainTexts[i].draw(red);
      } else {
        if (data.pid.valid[currentGraph]) {
          gainTexts[i].text = gains[i] + data.pid.gains[currentGraph][i];
        } else {
          gainTexts[i].text = gains[i] + "unknown";
        }
        gainTexts[i].draw();
      }
    }
  }
  boolean mousePressed() {
    //check buttons for collision
    for (int i = 0; i < buttons.length; i++) {
      if (buttons[i].collides()) {
        if (buttons[i].action == "whichPID") {
          currentGraph = i;
          return true;
        } else if (buttons[i].action == "g") {
          sendCommand("g" + currentGraph + "\n");
          return true;
        } else if (buttons[i].action == "p") {
          sendCommand("p" + currentGraph + "," +
            connection.data.pid.gains[currentGraph][0] + "," +
            connection.data.pid.gains[currentGraph][1] + "," +
            connection.data.pid.gains[currentGraph][2] + "\n");
          return true;
        }
      }
    }

    //check textboxes for collision
    for (int i = 0; i < gainTexts.length; i ++) {
      if (gainTexts[i].collides()) {
        currentEdit = i;
        keyboardInput = "";
        return true;
      }
    }
    return false;
  }

  //keypressed, for textboxes
  boolean keyPressed() {
    if (currentEdit >= 0) {
      if (key == '\n') {
        connection.data.pid.gains[currentGraph][currentEdit] = toFloat(keyboardInput);
        currentEdit = -1;
        keyboardInput = "";
      } else {
        keyboardInput += key;
      }
      return true;
    }
    return false;
  }
}
