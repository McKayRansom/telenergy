

//serial connection
import processing.serial.*;


public class SerialProtocol extends Protocol {
  Serial serialPort;
  public void setup(PApplet thisApplet) {
    // list serial ports, helpful for figuring out which to connect to
    // printArray(Serial.list());
    // on my computer the 32nd port is the serial port.
    // This depends on the computer
    try {
     String portName = Serial.list()[0];
     serialPort = new Serial(thisApplet, portName, 9600);
    } catch (RuntimeException e) {
     print("ERROR: Arduino not connected!");
     exit();
     //exit doesn't exit immediatly, the rest of init will run
     return;
    }
  }

  public String receive() {
    //when we receive data, update all the data
    if (serialPort.available() > 0) {  //serial data available!
      String received = serialPort.readStringUntil('\n');
      //if we actually got data
      if (received != null) {
        return received;
      }
    }
    return "";
  }
  void send(String data) {
    //TODO: finish this
  }
  void stop() {
    serialPort.stop();
  }
}
