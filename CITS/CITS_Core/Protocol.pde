
import processing.core.PApplet;
public class Protocol {
  //this list of errors must be managed accross all remotes
  String[] errors = new String[] {
    "Error: default error: ",
    "Error: unrecognized input: ",
    "Error: failed to convert number: ",
    "Error: incorrectly formated command: ",
    "Error: value outside of range: ",
    "Error: no course: ",
    "Error: off course: "
  };
  AllData data;
  Protocol() {
    data = new AllData();
  }
  public void setup(PApplet _) {}
  public void update() {

    //we need to repeatedly receive data until none is left!
    while (true) {
      String received = receive();
      //if we received nothing
      if (received == "") {
        return;
      }
      // print("!!protocol received: " + received + "!!");
      //TODO: fix logging data!
      // if (LOG_DATA){
      //   logFile.print(received);
      //   // logFile.flush();
      // }
      char which = received.charAt(0);

      if (which == 'F') {
        //F: Flight Data
        data.flight.update(received.substring(1), true);
      } else if (which == 'A') {
        //A: autopilot data
        data.auto.update(received.substring(1), true);
      } else if (which == 'P') {
        //P: PID data
        data.pid.update(received.substring(1), false);
      } else if (which == 'V') {
        //V: values update
        data.values.update(received.substring(1), false);
      } else if (which == 'W') {
        //W: waypoint update
        data.waypoint.update(received.substring(1), false);
      } else if (which == 'C') {
        //C: course update
        gui.nav.computeCourse();
      } else if (which == 'B') {
        //B: Boot
        println("REMOTE REBOOOT");
        data = new AllData();
      } else if (which == 'E') {
        //E: Error message!
        String error = handleError(received);
        data.error = error;
        println(error);
      } else {
        // don't spam the console at the begining
        // if (millis() > 5000) {
          println("Received Unknown Command: " + received);
        // }
      }
    }
  }

  String handleError(String received) {
    String[] parts = received.substring(1).split(":");
    if (parts.length != 2) {
      return "INVALID ERROR: " + received;
    } else {
      try {
        int whichError = Integer.parseInt(parts[0]);
        return errors[whichError] + parts[1];
      } catch (NumberFormatException e) {
        return "INVALID ERROR NUMBER: " + received;
      }
    }
  }

  //implemented by sub-classes!
  void stop() {

  }
  //keyPressed
  void keyPressed(char key) {}
  //send data over connection
  public void send(String data) {}
  //receive data from connection
  String receive() { return "";}
}
