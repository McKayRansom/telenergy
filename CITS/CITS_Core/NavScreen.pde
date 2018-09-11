////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - Navigation screen
//
//Displays all data to show where you are and where you are going
//Including waypoints and landing places etc...


class NavScreen extends Screen {

  Button[] buttons;
  //some waypoints we have manually found
  String[] availableWaypointNames = new String[] {
    "KSC WEST APRC",
    "KSC RUNWY WEST",
    "KSC RUNWY EAST",
    "ISLD RUNWY WEST",
    "ISLD RUNWY EAST",
    "LAUCHPAD"
  };
  color[] availableWaypointColors = new color[] {
    yellow,
    green,
    green,
    purple,
    purple,
    color(150, 0, 0) //faded red so it isn't as annoying
  };
  Button[] availableWaypointButtons;
  //island height is about 135m
  //main runway height is about 75m
  float[][] availableWaypoints = new float[][]{
    {-0.048568153679756428 ,-75.0337257486064, 300, 90, 90},
    {-0.048568153679756428,-74.722602513353124, 85, 90, 60},
    {-0.048568153679756428,-74.4914844200733, 60, 90, 50},
    {-1.5179223336566889, -71.966449130578837, 145, 85, 60},
    {-1.5154769033851754, -71.852481985494933, 120, 85, 50},
    {-0.097215327911969, -74.55760399678023, 100, 180, 90}
  };

  int mapX = 355;
  int mapY = 200;
  int mapEdge = mapX + 250;
  float mapZoom = 1;

  int currentEdit;
  int selectedWaypoint;
  int numberOfWaypoints = 0;
  float[] editWaypoint;
  Button[] waypointButtons;

  String keyboardInput = "";
  TextBox[] editTexts;
  String[] texts = new String[] {
    "lat: ", "lon: ", "alt: ", "head: ", "speed: "
  };

  float[][] runways = {
    {-0.048568153679756428,-74.722602513353124},
    {-0.048568153679756428,-74.4914844200733},
    {-1.5179223336566889, -71.966449130578837},
    {-1.5154769033851754, -71.852481985494933}
  };

  NavScreen() {
    selectedWaypoint = -1;
    currentEdit = -1;
    int actionButtonX = mapEdge + 130;
    int actionButtonY = 40;
    buttons = new Button[] {
      new Button("+", 70, 310, 40, 40),
      new Button("-", 70, 370, 40, 40),
      new Button("refresh", mapEdge + 300, 25, 70, 30),// blue, black),
      new Button("insert", actionButtonX, actionButtonY + 20, 60, 30),//, red, white),
      new Button("set", actionButtonX, actionButtonY + 60, 60, 30, green, black),
      new Button("add", actionButtonX, actionButtonY + 100, 60, 30),//, red, white),
      new Button("pop", actionButtonX + 65, actionButtonY + 20, 60, 30),//, red, white)
      new Button("delete", actionButtonX + 65, actionButtonY + 60, 60, 30, red, black),
      new Button("remove", actionButtonX + 65, actionButtonY + 100, 60, 30)//, red, white)
    };
    waypointButtons = new Button[10];
    for (int i = 0; i < waypointButtons.length; i++) {
      waypointButtons[i] = new Button("Way "+i,
          mapEdge + 50, 40 + 35 * i, 80, 30);
    }
    editTexts = new TextBox[5];
    for (int i = 0; i < editTexts.length; i++) {
      editTexts[i] = new TextBox(texts[i],
          mapEdge + 240, 60 + 20 * i);
    }
    availableWaypointButtons = new Button[availableWaypointNames.length];
    for (int i = 0; i < availableWaypointNames.length; i++) {
      availableWaypointButtons[i] = new Button(availableWaypointNames[i],
          mapEdge + 290, 180 + 32 * i, 110, 30,
          availableWaypointColors[i], black);
    }
    editWaypoint = new float[] {
      0, 0, 0, 0, 0
    };
  }
  void draw(AllData data) {
    drawMap(data);
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw();
    }
    //keep track of how many waypoints there are
    numberOfWaypoints = 0;
    //draw waypointbuttons
    for (int i = 0; (i < waypointButtons.length); i ++) {
      if (data.waypoint.waypoints[i].valid) {
        numberOfWaypoints = i + 1; //since it is zero indexed
        if (i == selectedWaypoint) {
          waypointButtons[i].draw(green, black);
        } else {
          waypointButtons[i].draw();
        }
      } else {
        waypointButtons[i].draw(color(30), color(60));
      }
    }
    for (int i = 0; i < availableWaypointButtons.length; i++) {
      availableWaypointButtons[i].draw();
    }


    //draw edit textboxes
    for (int i = 0; i < editTexts.length; i++) {
      //currently editing this textbox, change text and highlight
      if (i == currentEdit) {
        editTexts[i].text = texts[i] + keyboardInput;
        editTexts[i].draw(red);

      } else {

        // if (selectedWaypoint > 0 && !data.waypoint.waypoints[selectedWaypoint].valid) {
          //otherwise let the user know we don't really know
          // editTexts[i].text = texts[i] + "unknown or unset";
        // } else {
          editTexts[i].text = texts[i] + editWaypoint[i];
        // }
        editTexts[i].draw();
      }
    }

  }

  //called when we the remote tells us that it has recomputed course!
  void computeCourse() {
    lastLat = connection.data.flight.latitude;
    lastLng = connection.data.flight.longitude;
    lastHeading = connection.data.flight.heading;
    firstLng = lastLng;
  }

  boolean mousePressed() {
    for (int i = 0; i < buttons.length; i++) {
      if (buttons[i].collides()) {
        if (buttons[i].label == "+") {
          mapZoom += .1;
        } else if (buttons[i].label == "-") {
          mapZoom -= .1;
        } else if (buttons[i].label == "refresh") {
          if (numberOfWaypoints > 0) {
            for (int j = 0; j < numberOfWaypoints; j++) {
              sendCommand("y" + j + "\n");
            }
          }
        } else if (buttons[i].label == "insert") {
          if (numberOfWaypoints < 10 && editWaypoint[0] != 0) {
            sendWaypoint(-1);
          }
        } else if (buttons[i].label == "set") {
          if (selectedWaypoint > -1 && editWaypoint[0] != 0) {
            sendWaypoint(selectedWaypoint);
          }
        } else if (buttons[i].label == "add") {
          //add a waypoint on the end
          if (numberOfWaypoints < 10 && editWaypoint[0] != 0) {
            sendWaypoint(numberOfWaypoints);
          }
        } else if (buttons[i].label == "pop") {
          //delete the first waypoint, only if there is a waypoint to delete
          if (numberOfWaypoints > 0) {
            float[] oldEditWaypoint = editWaypoint;
            editWaypoint = new float[]{0,0,0,0,0};
            sendWaypoint(0);
            editWaypoint = oldEditWaypoint;
          }
        } else if (buttons[i].label == "delete") {
          //delete the selected waypoint,
          //if we have one selected and it is a valid waypoint
          if (selectedWaypoint >= 0 && selectedWaypoint < numberOfWaypoints) {
            editWaypoint = new float[]{0,0,0,0,0};
            sendWaypoint(selectedWaypoint);
            selectedWaypoint = -1;
          }
        } else if (buttons[i].label == "remove") {
          //remove the last waypoint only if there is a waypoint to remove
          if (numberOfWaypoints > 0) {
            float[] oldEditWaypoint = editWaypoint;
            editWaypoint = new float[]{0,0,0,0,0};
            sendWaypoint(numberOfWaypoints - 1);
            editWaypoint = oldEditWaypoint;
          }
        }
        return true;
      }
    }
    for (int i = 0; i < waypointButtons.length; i ++ ){
      if (waypointButtons[i].collides()) {
        if (connection.data.waypoint.waypoints[i].valid) {
          editWaypoint = connection.data.waypoint.waypoints[i].list.clone();
          selectedWaypoint = i;
          return true;
        }
      }
    }
    for (int i = 0; i < availableWaypointButtons.length; i++) {
      if (availableWaypointButtons[i].collides()) {
        //this passes a reference which is kinda lames...
        editWaypoint = availableWaypoints[i].clone();
        // selectedWaypoint = -1;//no waypoint selected
        return true;
      }
    }
    //check textboxes for collision
    for (int i = 0; i < editTexts.length; i ++) {
      if (editTexts[i].collides()) {
        currentEdit = i;
        keyboardInput = "";
        return true;
      }
    }
    return false;
  }

  void sendWaypoint(int which) {
    String toSend = "w" + which;
    for (int i = 0; i < 5; i ++) {
      toSend += "," + editWaypoint[i];
    }
    toSend += "\n";
    sendCommand(toSend);
  }
  float lastLat = 0;
  float lastLng = 0;
  float lastHeading = 0;
  float firstLng = 0;
  //draw map
  void drawMap(AllData data) {
    float latitude = data.flight.latitude;
    float longitude = data.flight.longitude;
    float heading = data.flight.heading;
    if (latitude == 0) {
      return;
    }
    //82 px per 10 degrees
    //2022, 793 is center
    float pixelsPerDegree = 100; //<>//
    // int equator = 793;
    // int meridian = 2022;
    int centerX = mapX;
    int centerY = mapY;
    //frequency (fraction of degrees) that lines are drawn
    float lineFrequency = .5;
    int width = 500;
    int height = 380;
    pushMatrix();
    translate(centerX, centerY);
    fill(0);
    stroke(220);
    strokeWeight(1);
    rect(0, 0, width, height);
    clip(-width/2, -height/2, width, height);

    //longitude lines
    pushMatrix();
    scale(mapZoom, 1);
    strokeWeight(.3);
    for (float i = (longitude % 1) - 2.5/mapZoom; i < (longitude % 1) + 2.5 /mapZoom; i = i +lineFrequency) {
      line(i * pixelsPerDegree, -height/2, i * pixelsPerDegree, height/2);
    }
    popMatrix();

    //latitude lines
    pushMatrix();
    scale(1, mapZoom);
    strokeWeight(.3);
    for (float i = (latitude % 1) - 2.5/mapZoom; i < (latitude % 1) + 2.5/mapZoom; i = i +lineFrequency) {
      line(-width/2, i * pixelsPerDegree, width/2, i * pixelsPerDegree);
    }
    popMatrix();

    scale(mapZoom,mapZoom);
    stroke(255);
    fill(255);
    // image(map, -meridian - longitude * pixelsPerDegree, -equator + latitude * pixelsPerDegree);
    stroke(255);
    strokeWeight(2);
    for (int i = 0; i < runways.length; i = i + 2) {
      line(
        //latitude is flipped b/c graphics coords have y revesed
        -(longitude - runways[i][1]) * pixelsPerDegree,
        (latitude - runways[i][0]) * pixelsPerDegree,
        -(longitude - runways[i+1][1]) * pixelsPerDegree,
        (latitude - runways[i+1][0]) * pixelsPerDegree
        );
    }
    textAlign(CENTER, BOTTOM);
    for (int i = 0; i < availableWaypoints.length; i = i + 1) {
      stroke(availableWaypointColors[i]);
      fill(availableWaypointColors[i]);
      strokeWeight(5);
      float x = -(longitude - availableWaypoints[i][1]) * pixelsPerDegree;
      float y = (latitude - availableWaypoints[i][0]) * pixelsPerDegree;
      point(x, y);
      // text(availableWaypointNames[i], x, y);
    }

    stroke(blue);
    strokeWeight(2);
    noFill(); //<>//
    if (lastLat == 0) {
     lastLat = latitude;
     lastLng = longitude;
     lastHeading = heading;
    } else if (firstLng != data.waypoint.waypoints[0].list[1]) {
      //the longitude has changed!
      lastLat = latitude;
      lastLng = longitude;
      lastHeading = heading;
      firstLng = data.waypoint.waypoints[0].list[1];
    }
    // float lastControlX
    float lastX = -(longitude - lastLng) * pixelsPerDegree;
    float lastY = (latitude - lastLat) * pixelsPerDegree;
    float lastAngle = radians(lastHeading);
    for (int i = 0; i < waypointButtons.length; i ++) {
      Waypoint nextWaypoint = data.waypoint.waypoints[i];
      if (nextWaypoint.valid) {
        float x = -(longitude - nextWaypoint.list[1]) * pixelsPerDegree;
        float y = (latitude - nextWaypoint.list[0]) * pixelsPerDegree;
        float angle = radians(nextWaypoint.list[3] - 180); //TODO: WHY?? this angleisn't right
        float distance = min(.4 * pixelsPerDegree,
            sqrt(pow(lastX - x, 2) + pow(lastY - y, 2))/2); //hardcoded in the autopilot...
        float control1x = lastX + distance * sin(lastAngle);
        float control1y = lastY - distance * cos(lastAngle);
        float control2x = x + distance * sin(angle);
        float control2y = y - distance * cos(angle);
        bezier(lastX, lastY, control1x, control1y, control2x, control2y, x, y);
        lastX = x;
        lastY = y;
        lastAngle = radians(nextWaypoint.list[3]);
      }
    }

    noClip();
    popMatrix();

    pushMatrix();
    translate(centerX, centerY);
    rotate(radians(heading));
    stroke(255, 108, 0);
    strokeWeight(3);
    line(0, 5, 0, -5);
    strokeWeight(3);
    noFill();
    triangle(-5, -5, 0, -10, 5, -5);
    popMatrix();

    fill(240);
    textAlign(LEFT, CENTER);
    text(latitude, centerX - 100, centerY + height/2 - 15);
    text(longitude, centerX + 100, centerY + height/2 - 15);
  }
  //keypressed, for textboxes
  boolean keyPressed() {
    if (currentEdit >= 0) {
      if (key == '\n') {
        if (currentEdit >= 0) {
          editWaypoint[currentEdit] = toFloat(keyboardInput);
        }
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
