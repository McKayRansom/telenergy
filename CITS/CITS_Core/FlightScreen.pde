////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - Flight GUI
//
//Displays interactive flight instruments and buttons in a GUI
//All actions should directly relate to the aircraft operation,
//not interfacing or connection or setup aspects

class FlightScreen extends Screen {
  int airspeedX = 300;
  int airspeedY = 100;
  int altimeterX = 700;
  int altimeterY = 100;
  int headingX = 500;
  int headingY = 300;
  int vertSpeedX = 700;
  int vertSpeedY = 300;
  int horizonX = 500;
  int horizonY = 100;
  int controlsX = 5;
  int controlsY = 200;

  Button[] buttons;
  FlightScreen() {
    int centerX = 900;
    int centerY = 100;
    buttons = new Button[] {
      new Button("LOWSPEED", centerX - 50, centerY -80),
      new Button("STALL",centerX +  50, centerY + -80),
      new Button("OVERSPEED", centerX + -50, centerY + -45),
      new Button("GROUND",centerX +  50, centerY + -45),
      new Button("GEAR", centerX + -50, centerY + -10, "0", true),
      new Button("FLAPS",centerX +  50, centerY + -10, "1", true),
      new Button("BRAKES", centerX + -50,centerY +  25, "3", true),
      new Button("SAS",centerX +  50,centerY +  25, "2", true),
      new Button("AUTO", centerX - 50, centerY + 60, "4", true),
      new Button("AUTOCOURSE", centerX + 50, centerY + 60, "5", true),
      new Button("AUTOSTEER", centerX - 50, centerY + 95, "6", true),
      new Button("AUTOTHROT", centerX + 50, centerY + 95, "7", true)
    };
  }
  void draw(AllData data) {
    drawHorizon(data);
    drawAirspeed(data);
    drawHeading(data);
    drawAltimeter(data);
    drawVertSpeed(data);
    drawControls(data);

    //LOWSPEED
    if (data.flight.airspeed < 60) {
      buttons[0].draw(yellow, black);
    } else {
      buttons[0].draw(black, faded);
    }
    //STALL
    if (data.flight.airspeed < 50) {
      buttons[1].draw(red, black);
    } else {
      buttons[1].draw(black, faded);
    }
    //OVERSPEED
    if (data.flight.airspeed > 260) {
      buttons[2].draw(yellow, black);
    } else {
      buttons[2].draw(black, faded);
    }
    //GROUND
    if (data.flight.altitude < 500) {
      buttons[3].draw(yellow, black);
    } else {
      buttons[3].draw(black, faded);
    }
    //GEAR
    if (data.values.gear) {
      buttons[4].draw(green, black);
    } else {
      buttons[4].draw(black, faded);
    }
    //flaps
    if (data.values.flaps) {
      buttons[5].draw(blue, black);
    } else {
      buttons[5].draw(black, faded);
    }
    //brakes
    if (data.values.brakes) {
      buttons[6].draw(green, black);
    } else {
      buttons[6].draw(black, faded);
    }
    //sas
    if (data.values.sas) {
      buttons[7].draw(blue, black);
    } else {
      buttons[7].draw(black, faded);
    }
    //auto
    if (data.values.autoEnabled) {
      buttons[8].draw(purple, black);
    } else {
      buttons[8].draw(black, faded);
    }
    //autocourse
    if (data.values.autoCourse) {
      buttons[9].draw(purple, black);
    } else {
      buttons[9].draw(black, faded);
    }
    //autosteer
    if (data.values.autoSteer) {
      buttons[10].draw(purple, black);
    } else {
      buttons[10].draw(black, faded);
    }
    //autothrottle
    if (data.values.autoThrottle) {
      buttons[11].draw(purple, black);
    } else {
      buttons[11].draw(black, faded);
    }
  }

  boolean mousePressed() {
    if (boxCollides(mouseX, mouseY, headingX, headingY, 200, 200)) {
      float angle = atan2(mouseY-headingY, mouseX -headingX) + HALF_PI;
      float targetBearing = degrees(angle);
      if (targetBearing < 0) {
        targetBearing += 360;
      }
      println(round(targetBearing));
      sendCommand("b" + targetBearing + "\n");
      return true;
    }
    if (boxCollides(mouseX, mouseY, airspeedX, airspeedY, 200, 200)) {
      float angle = atan2(mouseY-airspeedY, mouseX -airspeedX) + HALF_PI;
      float targetAirspeed = map(angle, 0, TWO_PI, airspeed0Degrees, airspeed360Degrees);
      if (targetAirspeed < airspeed0Degrees) {
        targetAirspeed += airspeed360Degrees;
      }
      println(round(targetAirspeed));
      sendCommand("s" + targetAirspeed + "\n");
      return true;
    }
    if (boxCollides(mouseX, mouseY, vertSpeedX, vertSpeedY, 200, 200)) {
      float angle = atan2(mouseY-vertSpeedY, mouseX -vertSpeedX);
      if (angle < 0) {
        angle += TWO_PI;
      }
      float targetVertSpeed = map(angle, 0, TWO_PI, vertSpeed0Degrees, vertSpeed360Degrees);
      // if (targetVertSpeed < vertSpeed0Degrees) {
      //   targetVertSpeed += vertSpeed360Degrees;
      // }
      println(round(targetVertSpeed));
      sendCommand("v" + targetVertSpeed + "\n");
      return true;
    }
    for (int i = 0; i < buttons.length; i++) {
      if (buttons[i].collides() && buttons[i].sendCommandOnClicked) {
        //which value needs to be toggled
        int whichValue = Integer.parseInt(buttons[i].action);
        //value toggle, get the opposite of what it is now
        int value = connection.data.values.allValues[whichValue] ? 0 : 1;
        //send the set value command
        sendCommand("t" + buttons[i].action + "," + value + "\n");
        return true;
      }
    }
    return false;
  }

  //draw controls (thhrottle, pitch, roll, yaw)
  void drawControls(AllData data) {

    pushMatrix();
    rectMode(CORNER);
    translate(controlsX, controlsY);
    int throttleX = 10;
    int throttleY = 25;
    int pitchX = 40;
    int pitchY = 25;
    // roll and yaw X
    int rollX = 120;
    int rollY = 25;
    int yawX = 120;
    int yawY = 65;
    int fuelX = 120;
    int fuelY = 110;

    float cruiseHigh = .75;
    float cruiseLow = .15;
    fill(black);
    stroke(white);
    strokeWeight(2);
    rect(throttleX, throttleY, 10, 100);
    // rect(pitchX, pitchY, 15, 100);
    textAlign(LEFT, CENTER);
    fill(white);
    text("Throt", throttleX - 7, throttleY - 12);
    text("Pitch", pitchX, pitchY - 12);
    textAlign(CENTER, CENTER);
    text("Roll", rollX, rollY - 12);
    text("Yaw", yawX, yawY - 12);
    text("Fuel", fuelX, fuelY - 12);
    // text("Idle", 28, 120);
    // text("Cruise", 28, 75);
    // text("Full", 28, 30);
    stroke(red);
    line(throttleX + 12, 25, throttleX + 12, 125 - 100*cruiseHigh);
    stroke(green);
    line(throttleX + 12, 125 - 100*cruiseHigh, throttleX + 12, 125 - 100 * cruiseLow);
    stroke(yellow);
    line(throttleX + 12, 125 - 100*cruiseLow, throttleX + 12, 125);

    strokeWeight(8);
    stroke(255, 108, 0);
    int y = round(map(data.flight.throttle, 0, 1.0, 100, 0));
    line(5, 25 + y, 30, 25 + y);

    drawControlIndicator(data.flight.controlPitch, pitchX, pitchY +50, 0, false);
    drawControlIndicator(data.flight.controlRoll, rollX, rollY, HALF_PI, false);
    drawControlIndicator(data.flight.controlYaw, yawX, yawY, HALF_PI, false);
    drawControlIndicator(data.flight.fuelPercent, fuelX, fuelY, HALF_PI, true);

    popMatrix();
  }//draw control indicator
  //assumes input value is between -1, 1
  //x and y are the left center of the indicator
  //angle in radians
  void drawControlIndicator(float value, int x, int y, float angle, boolean isFuel) {
    pushMatrix();
    translate(x, y);
    rotate(angle);

    //draw frameing rectangle
    int width = 15;
    if (isFuel) {
      width = 30;
      int pos = round(map(value, 0, 1, 0, 100));
      noStroke();
      if (value < .25) {
        fill(red);
      } else if (value > .5) {
        fill(green);
      } else {
        fill(yellow);
      }
      rect(0, 50, 15, -pos);
      noFill();
    } else {
      fill(black);
    }
    stroke(white);
    strokeWeight(2);
    rect(0, -50, 15, 100);

    //draw a bunch of reference lines
    for (int i = -4; i < 4; i ++)
      line(2, i * 25/2, 8, i * 25/2);
    strokeWeight(3);
    line(3, 0, 12, 0);

    if (!isFuel) {
      int pos = round(map(value, -1, 1, 50, -50));
      //draw triangle indicating current position
      noFill();
      stroke(255, 108, 0);
      strokeWeight(2);
      triangle(0, pos, 15, pos + 8, 15, pos - 8);
    }
    popMatrix();
  }


  //draw altimeter
  void drawAltimeter(AllData data) {
    float altitude = data.flight.altitude;
    //first number/tick marks
    int startAltitude = 0;
    //last number/tick marks
    int endAltitude = 310;
    //position on screen
    int centerX = altimeterX;
    int centerY = altimeterY;
    //setup drawing conditions
    fill(0);
    pushMatrix();
    translate(centerX, centerY);
    stroke(0);
    strokeWeight(1);
    //draw black background circle
    ellipse(0, 0, 190, 190);
    //Altitude at exact top of indicator
    int altitude0Degrees = startAltitude - 50;
    //altitude at top of indicator after full circle
    int altitude360Degrees = endAltitude + 40;
    fill(240);
    stroke(240);
    strokeWeight(2);
    textAlign(CENTER, CENTER);
    text("ALT", 0, -35);
    // text("SPEED", 0, -20);
    // text("m", 0, 25);
    textAlign(CENTER, RIGHT);
    fill(80, 120, 255);
    text(round(altitude) + "m", 5, 5);
    //radius of tick marks and numbering
    int radius = 95;
    int innerRadius = 85;
    int smallerRadius = 90;
    int textRadius = 70;
    textAlign(CENTER, CENTER);
    fill(240);
    for (int i = startAltitude; i < endAltitude; i = i + 10) {
      float angle = map(i, altitude0Degrees, altitude360Degrees, 0, PI*2);

      //draw thicker lines every 20 m/s
      if ((i % 50) == 0) {
        line(cos(angle)*radius, sin(angle) * radius, cos(angle) * innerRadius, sin(angle) * innerRadius);
        //draw text every 40 m/s starting at 20m/s
        // if (((i + 20) % 40) == 0) {
          text(i/10, cos(angle)*textRadius, sin(angle) * textRadius);
        // }
      } else {
        //thinner line every 10 m/s (not currently used???)
        line(cos(angle)*radius, sin(angle) * radius, cos(angle) * smallerRadius, sin(angle) * smallerRadius);
      }
    }
    //actually draw the needle
    float altitudeAngle = 0;
    if (altitude < endAltitude && altitude > startAltitude) {
      altitudeAngle = map(altitude, altitude0Degrees, altitude360Degrees, 0, TWO_PI);
    }
    int needleRadius = 85;
    int needleInnerRadius = 60;
    strokeWeight(3);
    stroke(255, 90, 0);
    noFill();
    triangle(cos(altitudeAngle + .07) * needleInnerRadius, sin(altitudeAngle + .07) * needleInnerRadius,
      cos(altitudeAngle - .07) * needleInnerRadius, sin(altitudeAngle-.07) * needleInnerRadius,
      cos(altitudeAngle) * needleRadius, sin(altitudeAngle) * needleRadius);
    popMatrix();
  }

  //draw heading indicator
  void drawHeading(AllData data) {
    float heading = data.flight.heading;

    //position on screen
    int centerX = headingX;
    int centerY = headingY;
    // int centerX = 100;
    // int centerY = 100;
    //setup drawing conditions
    fill(0);
    pushMatrix();
    translate(centerX, centerY);
    stroke(0);
    strokeWeight(1);
    //draw black background circle
    ellipse(0, 0, 190, 190);
    noFill();
    //draw title with units
    fill(240);
    stroke(240);
    strokeWeight(2);
    textAlign(CENTER, CENTER);
    // text("SURF VEL", 0, -30);
    // text("m/s", 0, 25);
    //radius of tick marks and numbering
    int radius = 75;
    int innerRadius = 60;
    int smallerRadius = 70;
    int textRadius = 85;
    //cardinal direction radius
    int cardinalRadius = 50;
    rotate(radians(-heading));
    for (int i = 0; i < 360; i = i + 10) {
      if (i == 0) {
        text("N", 0, -cardinalRadius);
      } else if (i == 90) {
        text("E", 0, -cardinalRadius);
      } else if (i == 180) {
        text("S", 0, -cardinalRadius);
      } else if (i == 270) {
        text("W", 0, -cardinalRadius);
      }
      // float angle = map(i, 0, 360, 0, TWO_PI) - HALF_PI - heading;
      //draw thicker lines every 20 m/s
      if ((i % 30) == 0) {
        line(0, -radius, 0, -innerRadius);
        //draw text every 40 m/s starting at 20m/s
        // if (((i +20) % 40) == 0) {
          text(i/10, 0, -textRadius);
        // }
      } else {
        line(0, -innerRadius, 0, -smallerRadius);
      }
      rotate(radians(10));
    }
    popMatrix();
    //targetBearing
    if (data.values.autoEnabled) {
      float targetHeading = data.auto.targetHeading;
      pushMatrix();
      translate(centerX, centerY);
      rotate(radians(targetHeading - heading));
      int outerTargetRadius = 92;
      int innerTargetRadius = 60;
      // stroke(60, 70, 255);
      stroke(purple);
      strokeWeight(3);
      line(0, -innerTargetRadius, 0, -outerTargetRadius);
      popMatrix();
    }
    //current Bearing triangle
    pushMatrix();
    translate(centerX, centerY);
    strokeWeight(3);
    stroke(255, 90, 0);
    noFill();
    float triangleAngle = .6;
    int needleRadius = 60;
    int needleInnerRadius = 30;
    triangle(sin(triangleAngle) * needleInnerRadius, -cos(+ triangleAngle) * needleInnerRadius,
      sin(-triangleAngle) * needleInnerRadius, -cos(-triangleAngle) * needleInnerRadius,
      0, -needleRadius);
    popMatrix();
  }
  //speed at exact top of indicator
  int vertSpeed0Degrees = -21 - 2;
  //speed at top of indicator after full circle
  int vertSpeed360Degrees = 22 + 1;
  //draw vertical speed indicator
  void drawVertSpeed(AllData data) {
    float speed = data.flight.vertSpeed;
    //first number/tick marks
    int startSpeed = -21;
    //last number/tick marks
    int endSpeed = 22;
    //position on screen
    int centerX = vertSpeedX;
    int centerY = vertSpeedY;
    //setup drawing conditions
    fill(0);
    pushMatrix();
    translate(centerX, centerY);
    stroke(0);
    strokeWeight(1);
    //draw black background circle
    ellipse(0, 0, 190, 190);
    //speed at exact top of indicator
    int speed0Degrees = vertSpeed0Degrees;
    //speed at top of indicator after full circle
    int speed360Degrees = vertSpeed360Degrees;
    fill(240);
    stroke(240);
    strokeWeight(2);
    textAlign(CENTER, CENTER);
    text("VERTICAL", 0, -35);
    text("SPEED", 0, -20);
    text("m/s", 0, 25);
    //radius of tick marks and numbering
    int radius = 95;
    int innerRadius = 85;
    int smallerRadius = 90;
    int textRadius = 70;
    for (int i = startSpeed; i < endSpeed; i = i + 1) {
      float angle = map(i, speed0Degrees, speed360Degrees, 0, PI*2);

      //draw thicker lines every 20 m/s
      if ((i % 5) == 0) {
        line(cos(angle)*radius, sin(angle) * radius, cos(angle) * innerRadius, sin(angle) * innerRadius);
        //draw text every 40 m/s starting at 20m/s
        // if (((i + 20) % 40) == 0) {
          text(i, cos(angle)*textRadius, sin(angle) * textRadius);
        // }
      } else {
        //thinner line every 10 m/s (not currently used???)
        line(cos(angle)*radius, sin(angle) * radius, cos(angle) * smallerRadius, sin(angle) * smallerRadius);
      }
    }
    //targetBearing
    if (data.values.autoEnabled) {
      float targetVertSpeed = data.auto.targetVertSpeed;
      pushMatrix();
      rotate(map(targetVertSpeed, speed0Degrees, speed360Degrees, 0, TWO_PI));
      int outerTargetRadius = 92;
      int innerTargetRadius = 85;
      stroke(purple);
      strokeWeight(5);
      line(innerTargetRadius, 0, outerTargetRadius, 0);
      popMatrix();
    }
    //actually draw the needle
    float speedAngle = 0;
    if (speed < endSpeed && speed > startSpeed) {
      speedAngle = map(speed, speed0Degrees, speed360Degrees, 0, TWO_PI);
    }
    int needleRadius = 80;
    strokeWeight(5);
    stroke(240);
    line(0,0, cos(speedAngle) * needleRadius, sin(speedAngle) * needleRadius);
    popMatrix();
  }
  //draw artificial horizon
  void drawHorizon(AllData data) {
    float roll = radians(data.flight.roll);
    float pitch = radians(data.flight.pitch);
    int centerX = horizonX;
    int centerY = horizonY;
    strokeWeight(4);
    fill(200);
    stroke(220);
    //line(centerX - x, centerY - y, centerX +x, centerY +y);
    strokeWeight(2);

    //int pitchPixels = round(map(pitch, -90, 90, -100, 100));
    textAlign(CENTER, CENTER);
    pushMatrix();
    translate(centerX, centerY);
    rotate(roll);

    //ground
    //fill(51, 35, 19);
    fill(109, 75, 53);
    arc(0,0, 190, 190, 0 + pitch, PI - pitch, CHORD);
    //sky
    fill(1, 140, 135);
    //fill(166, 198, 197);
    arc(0,0, 190, 190, PI - pitch, 2* PI + pitch, CHORD);
    fill(220);
    for (int i = - 180; i < 180; i = i + 10) {
      if (abs(degrees(pitch) - i) < 60) {//too far away
        int displayName = abs(i);
        if(displayName > 90) {
          displayName = abs(displayName - 180);
        }
        float yPos = 95*sin(pitch - radians(i));
        text(displayName, 0, yPos);
        line(-20, yPos, -10, yPos);
        line(20, yPos, 10, yPos);
      }
    }
    noFill();
    rotate(-roll);
    stroke(255, 108, 0);
    strokeWeight(2);
    arc(0,0, 40, 40, 0, PI);
    line(20, 0, 50, 0);
    line(-20, 0, -50, 0);
    strokeWeight(4);
    point(0,0);
    popMatrix();
  }
  //speed at exact top of indicator
  int airspeed0Degrees = 20 - 20;
  //speed at top of indicator after full circle
  int airspeed360Degrees = 290 + 10;
  //draw airspeed indicator
  void drawAirspeed(AllData data) {
    float speed = data.flight.airspeed;
    //first number/tick marks
    int startSpeed = 20;
    //last number/tick marks
    int endSpeed = 290;
    //position on screen
    int centerX = airspeedX;
    int centerY = airspeedY;
    //setup drawing conditions
    fill(0);
    pushMatrix();
    translate(centerX, centerY);
    stroke(0);
    strokeWeight(1);
    //draw black background circle
    ellipse(0, 0, 190, 190);
    noFill();
    //start of green
    int minSpeed = 60;
    //transition green/yellow
    int cruiseSpeed = 180;
    //transition yellow/red
    int maxSpeed = 260;
    //speed at exact top of indicator
    int speed0Degrees = airspeed0Degrees;
    //speed at top of indicator after full circle
    int speed360Degrees = airspeed360Degrees;
    strokeWeight(4);
    //green section
    stroke(0, 150, 0);
    arc(0, 0, 189, 189, map(minSpeed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI,
        map(cruiseSpeed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI);
    //yellow section
    stroke(200, 200, 0);
    arc(0, 0, 189, 189, map(cruiseSpeed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI,
        map(maxSpeed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI);
    //red section
    stroke(170, 0, 0);
    arc(0, 0, 189, 189, map(maxSpeed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI,
        map(endSpeed-10, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI);
    //draw title with units
    fill(240);
    stroke(240);
    strokeWeight(2);
    textAlign(CENTER, CENTER);
    text("SURF VEL", 0, -30);
    text("m/s", 0, 25);
    //radius of tick marks and numbering
    int radius = 95;
    int innerRadius = 85;
    int smallerRadius = 90;
    int textRadius = 70;
    for (int i = startSpeed; i < endSpeed; i = i + 10) {
      float angle = map(i, speed0Degrees, speed360Degrees, 0, PI*2) - HALF_PI;
      //draw thicker lines every 20 m/s
      if ((i % 20) == 0) {
        line(cos(angle)*radius, sin(angle) * radius, cos(angle) * innerRadius, sin(angle) * innerRadius);
        //draw text every 40 m/s starting at 20m/s
        if (((i +20) % 40) == 0) {
          text(i, cos(angle)*textRadius, sin(angle) * textRadius);
        }
      } else {
        //thinner line every 10 m/s (not currently used???)
        line(cos(angle)*radius, sin(angle) * radius, cos(angle) * smallerRadius, sin(angle) * smallerRadius);
      }
    }
    if (data.values.autoEnabled) {
      float targetAirspeed = data.auto.targetSpeed;
      //targetAirspeed
      pushMatrix();
      // translate(centerX, centerY);
      rotate(map(targetAirspeed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI);
      int outerTargetRadius = 92;
      int innerTargetRadius = 82;
      // stroke(60, 70, 255);
      stroke(purple);
      strokeWeight(5);
      line(innerTargetRadius, 0, outerTargetRadius, 0);
      popMatrix();
    }

    //actually draw the needle
    float speedAngle = map(speed, speed0Degrees, speed360Degrees, 0, TWO_PI) - HALF_PI;
    int needleRadius = 80;
    strokeWeight(5);
    stroke(240);
    line(0,0, cos(speedAngle) * needleRadius, sin(speedAngle) * needleRadius);
    popMatrix();
  }
}
