////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Core module responsible for loading other packages correctly

//select mode of operation
boolean USE_TELNET = true;
boolean USE_SERIAL = false;
Protocol connection;

//logfile for all the data we receive
boolean LOG_DATA = false;
PrintWriter logFile;

//The order and names of all of the Comma Seperated Values we recieve
// String[] CSVs = {
//   "altitude", "velocity", "vertSpeed", "pitch", "roll",
//   "heading", "latitude", "longitude",
//   "gear", "flaps", "sas", "brakes",
//   "auto", "autoland", "targetBearing", "targetAirspeed", "targetVertSpeed"
//   //"altitude", "gx", "gy", "gz", "ax", "ay", "az", "mx", "my", "mz", "pitch", "roll", "heading", //"inertialz", "vel", "pos", "adjustment", "compfilt",
//   //"status","dateTime","lat","lon","GPS_heading","speed","GPS_alt","satellites",
//   //"hdop","vdop","pdop","lat_err","lon_err","alt_err"
// };

//GUI
GUI gui;

/////////////////////////////////////
//            Setup                 //
//////////////////////////////////////
void setup() {
  //window setup
  size(1000, 400);
  //check that mode of operation is valid
  if (USE_TELNET == USE_SERIAL) {
    print("ERROR: must select one and only one mode!");
    exit();
  }
  //setup other modules
  if (USE_TELNET) {
    connection = new Telnet();
    connection.setup(this);
    delay(500);
    connection.send("1\n");
    delay(500);
  } else {
    connection = new SerialProtocol();
    connection.setup(this);
  }
  //tell remote we are rebooting so they can send us updates
  connection.send("reboot\n");
  //create log file TODO: Fix logging...
  // if (LOG_DATA) {
  //   String dateTime = "-" + day() + "." + month() + "." + year() + "-" + hour() + ":" + minute() + ":" + second();
  //   logFile = createWriter("logs/log" + dateTime + ".txt");
  //   for (int i = 0; i <CSVs.length; i++) {
  //     logFile.print(CSVs[i] + ", ");
  //   }
  //   logFile.println();
  // }

  //GUI
  gui = new GUI();
  gui.setup();

}

/////////////////////////////////////
//            Draw                 //
//////////////////////////////////////
void draw() {
  background(50);
  //get any incoming data
  connection.update();
  //draw guis and stuff
  gui.draw(connection.data);
}

// void mouseWheel(MouseEvent event) {
//   gui.mouseWheel(event);
// }

void keyPressed() {
  //escape key!
  if (key == 27) {
    if (LOG_DATA) {
      logFile.flush(); // Writes the remaining data to the file
      logFile.close(); // Finishes the file
    }
    connection.stop();
    exit(); // Stops the program
    return;
  }
  if (gui.keyPressed()) {
    return;
  }
  connection.keyPressed(key);
}

void sendCommand(String command) {
  if (command != "") {
    connection.send(command);
  }
}

void mousePressed() {
  //do stuff
  gui.mousePressed();
}
