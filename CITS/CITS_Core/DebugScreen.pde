////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - Data GUI
//
//should display debug info on incoming data
//any errors/problems with communication should be visible from this screen
//displays everything basically

class DebugScreen extends Screen {

  // DebugScreen() {
  //
  // }
  void draw(AllData data) {
    fill(240, 240, 240);
    textAlign(LEFT);
    //UPS stands for Updates Per Second (valid updates by the way)
    text("UPS: " + data.flight.ups, 120, 40);
    //Print errors
    if (data.error != "") {
      fill(red);
      text(data.error, 120, 20);
      fill(240, 240, 240);
    }
    //print all flight data
    for (int i = 0; i < data.flight.numberOfValues && i < data.flight.stringData.length; i ++) {
      text(data.flight.names[i] + ": " + data.flight.stringData[i], 600, 20 + (i * 20));
    }
    //print all autopilot data
    for (int i = 0; i < data.auto.names.length && i <data.auto.stringData.length; i ++) {
      text(data.auto.names[i] + ": " + data.auto.stringData[i], 800, 20 + (i * 20));
    }
  }
}
