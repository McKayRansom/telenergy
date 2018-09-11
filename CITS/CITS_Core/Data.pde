////////////////////////////////////////////////////////////////////////////////
//                              Ground Station                                //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//Spring 2018


public class ValuesData extends Data {
  boolean gear;
  boolean flaps;
  boolean sas;
  boolean brakes;
  boolean autoEnabled;
  boolean autoCourse;
  boolean autoSteer;
  boolean autoThrottle;

  boolean[] allValues;
  ValuesData() {
    numberOfValues = 2;
    allValues = new boolean[8];
    gear = false;
    flaps = false;
    sas = false;
    brakes = false;
    autoEnabled = false;
    autoCourse = false;
    autoSteer = false;
    autoThrottle = false;
  }
  void updateData( float[] floatData) {
    allValues[round(floatData[0])] = (round(floatData[1]) == 1);
    switch(round(floatData[0])) {
      case 0: gear = (floatData[1] == 1.0); break;
      case 1: flaps = (floatData[1] == 1.0); break;
      case 2: sas = (floatData[1] == 1.0);  break;
      case 3: brakes = (floatData[1] == 1.0); break;
      case 4: autoEnabled = (floatData[1] == 1.0);  break;
      case 5: autoCourse = floatData[1] == 1.0; break;
      case 6: autoSteer = floatData[1] == 1.0; break;
      case 7: autoThrottle = floatData[1] == 1.0; break;
    }
  }
}
//contains a list of PID gain values
//not updated by default unless the user presses buttons on the PIDScreen
public class PIDGainData extends Data {
  float[][] gains;
  boolean[] valid;
  PIDGainData() {
    numberOfValues = 4;
    gains = new float [][] {
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0}
    };
    valid = new boolean[gains.length];
  }
  void updateData( float[] floatData) {
    int which = round(floatData[0]);
    gains[which][0] = floatData[1];
    gains[which][1] = floatData[2];
    gains[which][2] = floatData[3];
    valid[which] = true;
  }
}

public class Waypoint {
  float latitude;
  float longitude;
  float altitude;
  float heading;
  float speed;
  boolean valid;
  float[] list;
  Waypoint() {
    list = new float[5];
    latitude = 0;
    longitude = 0;
    altitude = 0;
    heading = 0;
    speed = 0;
    valid = false;
  }
}

public class WaypointData extends Data {
  Waypoint[] waypoints;
  int numberOfWaypoints = 10;
  WaypointData() {
    numberOfValues = 6;
    waypoints = new Waypoint[numberOfWaypoints];
    for (int i = 0; i < numberOfWaypoints; i++) {
      waypoints[i] = new Waypoint();
    }
  }
  void updateData(float[] floatData) {
    int which = round(floatData[0]);
    //larger than the number of waypoints supported
    if (which >= numberOfWaypoints) {
      println("Error! requested " + which + " waypoints. Only support: " + numberOfWaypoints + " waypoints");

    //insert at the beginning and move the rest down
    } else if (which == -1) {
      Waypoint[] newList = new Waypoint[numberOfWaypoints];
      for (int i = 0; i < numberOfWaypoints-1; i ++ ) {
        newList[i+1] = waypoints[i];
      }
      waypoints = newList;
      waypoints[0] = new Waypoint();
      waypoints[0].latitude = floatData[1];
      waypoints[0].longitude = floatData[2];
      waypoints[0].altitude = floatData[3];
      waypoints[0].heading = floatData[4];
      waypoints[0].speed = floatData[5];
      for (int i = 0; i < 5; i ++) {
        waypoints[0].list[i] = floatData[i+1];
      }
      waypoints[0].valid = true;

    //we have removed this waypoint
    } else if (floatData[1] == 0) {
      //move the rest of the waypoints down
      for (int i = which + 1; i < numberOfWaypoints; i ++ ) {
        waypoints[i-1] = waypoints[i];
      }
      //delete the waypoint on the end
      waypoints[numberOfWaypoints-1] = new Waypoint();

    //update a waypoint's values
    } else {
      waypoints[which].latitude = floatData[1];
      waypoints[which].longitude = floatData[2];
      waypoints[which].altitude = floatData[3];
      waypoints[which].heading = floatData[4];
      waypoints[which].speed = floatData[5];
      for (int i = 0; i < 5; i ++) {
        waypoints[which].list[i] = floatData[i+1];
      }
      waypoints[which].valid = true;
    }
  }
}

//contains autopilot data
public class AutopilotData extends Data {
  float targetSpeed = 0;
  float targetVertSpeed = 0;
  float targetPitch = 0;
  float targetRoll = 0;
  float targetYaw = 0;
  float targetHeading = 0;


  String[] names = {
    "targetSpeed",
    "targetVertSpeed",
    "targetPitch",
    "targetRoll",
    "targetYaw",
    "targetHeading"
  };

  AutopilotData() {
    numberOfValues = names.length;
  }

  //update flightData with raw string
  //use smart toFloat() function but catch errors?
  void updateData(float[] floatData) {
    targetSpeed = floatData[0];
    targetVertSpeed = floatData[1];
    targetPitch = floatData[2];
    targetRoll = floatData[3];
    targetYaw = floatData[4];
    targetHeading = floatData[5];
  }
}

//flight data. contains all data pertaining to the aircraft's state
public class FlightData extends Data {
  float altitude = 0;
  float airspeed = 0;
  float vertSpeed = 0;
  float pitch = 0;
  float roll = 0;
  float sideslip = 0;
  float heading = 0;
  float latitude = 0;
  float longitude = 0;
  float throttle = 0;
  float controlPitch = 0;
  float controlRoll = 0;
  float controlYaw = 0;
  float fuelPercent = 0;


  String[] names = {
    "altitude",
    "airspeed",
    "vertSpeed",
    "pitch",
    "roll",
    "sideslip",
    "heading",
    "latitude",
    "longitude",
    "throttle",
    "controlPitch",
    "controlRoll",
    "controlYaw",
    "fuelPercent"
    // "gear",
    // "flaps",
    // "sas",
    // "brakes"
  };
  // FloatList[] graphData = new FloatList[6];
  FlightData() {
    numberOfValues = names.length;
  }
  //update flightData with raw string
  //use smart toFloat() function but catch errors?
  void updateData(float[] floatData) {
    //for each value we recieve
    altitude = floatData[0];
    airspeed = floatData[1];
    vertSpeed = floatData[2];
    pitch = floatData[3];
    roll = floatData[4];
    sideslip = floatData[5];
    heading = floatData[6];
    latitude = floatData[7];
    longitude = floatData[8];
    throttle = floatData[9];
    controlPitch = floatData[10];
    controlRoll = floatData[11];
    controlYaw = floatData[12];
    fuelPercent = floatData[13];
    return;
  }
}

//basically a struct that holds all the data types
public class AllData {
  FlightData flight;
  AutopilotData auto;
  PIDGainData pid;
  ValuesData values;
  WaypointData waypoint;
  //add new entries to the constructor too!!!

  String error = "";
  AllData() {
    flight = new FlightData();
    auto = new AutopilotData();
    pid = new PIDGainData();
    values = new ValuesData();
    waypoint = new WaypointData();
  }
  //others
}
float toFloat(String data) {
  data = trim(data);
  try {
    return Float.parseFloat(data);
  } catch (NumberFormatException e) {
    println("Invalid Number!: " + data);
    return 0.0;
  }
}


public class Data {
  int numberOfValues = 17;
  FloatList[] graphData;
  String[] stringData;
  int lastUpdate = 0;
  int ups = 0;
  Data() {
    // println("creating FloatList of length: " + numberOfValues);
    graphData = new FloatList[numberOfValues];
    for (int i = 0; i < numberOfValues; i++) {
      graphData[i] = new FloatList();
      // graphData[i].append(0);
    }
    stringData = new String[numberOfValues];
  }

  void update (String rawData, boolean saveGraph) {

    stringData = rawData.split(",");
    if (stringData.length != numberOfValues) {
      println("Invalid Data! Incorrect number of values: " + rawData);
      return;
    }
    //calculate updates per second
    float dt = millis() - lastUpdate;
    dt = dt/1000.0;
    // println(dt);
    ups = round(1/dt);
    lastUpdate = millis();

    //update the floatData array. It is up to childclasses to use this data
    float[] floatData = new float[numberOfValues];
    for (int i = 0; i <numberOfValues; i++) {
      floatData[i] = toFloat(stringData[i]);
      if (saveGraph) {
        graphData[i].append(floatData[i]);
        if (graphData[i].size() > 500) {
          graphData[i].remove(0);
        }
      }
    }
    //call child-class implementation
    updateData(floatData);
  }
  //overwritten by child classes
  void updateData(float[] floatData) {}
}
