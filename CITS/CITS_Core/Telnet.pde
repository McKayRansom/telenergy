////////////////////////////////////////////////////////////////////////////////
//         Project Telenergy - Command Integrated Telemetry System            //
////////////////////////////////////////////////////////////////////////////////
//McKay Ransom
//July 2018
//Telemetry display application - KSP/KOS interface
//
//uses Telnet standard for communication
//see: https://ksp-kos.github.io/KOS/general/telnet.html
import processing.net.*;
import processing.core.PApplet;
public class Telnet extends Protocol {
  //library for Telnet use
  Client myClient;
  //setup
  public void setup(PApplet thisApplet) {

    //connect to kOS telnet server
    //TODO: add failure checking to connection!
    myClient = new Client(thisApplet, "127.0.0.1", 5410);
  }

  //position of the cursor
  int linePos = 0;
  int colPos = 0;
  //spacing between letters vertically and horizontally
  int columnSpace = 7;
  int lineSpace = 15;

  boolean debugPrint = false;

  //buffer for incoming data
  byte[] byteBuffer = new byte[70];
  int cursorLastBlink = 0;
  boolean cursorDrawn = false;
  void eraseCursor() {
    if (cursorDrawn) {
      fill(0);
      //int xPos = colPos * columnSpace;
      //int yPos = linePos * lineSpace + 5;
      //rect(xPos, yPos, columnSpace, lineSpace);
      cursorDrawn = false;
      cursorLastBlink = millis();
      fill(200);
    }
  }
  void sendData() {

  }

  //////////////////////////////////////
  //              Draw                //
  //////////////////////////////////////
  String lineOfData = "";
  String receive() {
    //if ((cursorLastBlink + 500 - millis()) < 0) {
    //  cursorLastBlink = millis();
    //  if (cursorDrawn) {
    //    fill(0);
    //    cursorDrawn = false;
    //  } else {
    //    cursorDrawn = true;
    //  }
    //  int xPos = colPos * columnSpace;
    //  int yPos = linePos * lineSpace+5;
    //  //rect(xPos, yPos, columnSpace, lineSpace);
    //  fill(200);
    //}
    //if we have recieved data fom KSP/kOS
    if (myClient == null) {
      return "";
    }
    String fullMessage = "";
    // if (myClient.available() > 0) {
      //read in the data
      // int dataLength = myClient.readBytes(byteBuffer);
      //go through each character
    while(myClient.available() > 0) {
      int nextChar = myClient.read();
      //int actualChar = nextChar;// + 256;
      //this is a command, so process it
      // if (actualChar == 255 || actualChar == 238 ) {
        // processCommand(byteBuffer, i+1);
      // }
      //handle other command-related chars
      if (nextChar < 32 || nextChar > 126) {
        if (nextChar < 0) {
          //processing thinks all chars are signed so this fixes negative numbers

          // print("[" + commandToString(actualChar) + "]");
        } else {
          // print("[" + commandToString(nextChar) + "]");
          if (nextChar == 13) {
            //Carriage Return (CR)
            eraseCursor();
            colPos = 0;
          } else if (nextChar == 10) {
            //Line feed (LF)
            eraseCursor();
            linePos++;
            sendData();
          }
        }
      } else if (nextChar == '/') { //stand in for \n character
        fullMessage = lineOfData + '\n';
        lineOfData = "";
        if (debugPrint) {
          println();
        }
        return fullMessage;
      } else if (nextChar < ',') {
        // weird bug character, do nothing!!!
      } else{
        //normal character so print it at cursor position
        eraseCursor();

        //text((char)nextChar, colPos * columnSpace, 15+ linePos * lineSpace);
        lineOfData += (char)nextChar;
        //advance cursor position (advance to next column)
        colPos++;
      }
      if (debugPrint) {
        //print every character to the console for debuging
        print((char)nextChar);

      }


    }
    if (outgoing != "") {
      //if we have messages to send we do it
      //this will only be reached once we have read all incoming messages
      sendOutgoing();
    } else {
      //send an idle ping every two seconds,
      //otherwise the kOS telnet server gets upset and will start
      //sending up terminal type querries just to get us to respond,
      //this sometimes messes things up
      if ((millis() - lastMessage) > 2000) {
        myClient.write(char(0));
        //print("idlePing");
        lastMessage = millis();
      }
    }
    //don't send empty data!!
    // if (fullMessage != "") {
      // return fullMessage;
    // }
    return "";
  }

  //Inputs: integer from a character (0-255) that is some kind of command
  //Outputs: string of command or else just the number of the command
  String commandToString(int command) {
    switch (command) {
      case 255: return "IAC";
      case 240: return "SE";
      case 241: return "NOP";
      case 242: return "DataMark";
      case 243: return "Break";
      case 244: return "Interrupt";
      case 250: return "Sub-Negotiation";
      case 251: return "WILL";
      case 252: return "WONT";
      case 253: return "DO";
      case 254: return "DONT";
      case 10: return "LF";
      case 13: return "CR";
      case 0: return "IS";
      case 1: return "ECHO/SEND";
      case 3: return "supGoAhead";
      case 24: return "terminalType";
      case 31: return "windowSize";
      default: return "" + (char)command;
    }
  }

  //helper function to report the window size to the telnet server
  void sendWindowSize() {
    byte byteWidth = 10;//char(floor(width/columnSpace));
    byte byteHeight = 40;//char(floor(height/lineSpace));
    byte[] command = new byte[10];
    command[0] = IAC_byte;
    command[1] = SB_byte;
    command[2] = byte(windowSize);
    command[3] = byte(IS);
    command[5] = 0;
    command[4] = byteWidth;
    command[7] = 0;
    command[6] = byteHeight;
    command[8] = IAC_byte;
    command[9] = SE_byte;
    myClient.write(command);
  }

  void sendTerminalType() {
    byte[] commandReply = new byte[11];
    commandReply[0] = IAC_byte;
    commandReply[1] = SB_byte;
    commandReply[2] = byte(terminalType);
    commandReply[3] = byte(IS);
    commandReply[4] = 'V';
    commandReply[5] = 'T';
    commandReply[6] = '1';
    commandReply[7] = '0';
    commandReply[8] = '0';
    commandReply[9] = IAC_byte;
    commandReply[10] = SE_byte;
    myClient.write(commandReply);
  }

  //commands
  char IAC = 255;
  char SE = 240;
  char SB = 250;
  char WILL = 251;
  char WONT = 252;
  char DO = 253;
  char DONT = 254;
  char NOP = 241;
  //byte commands
  byte IAC_byte = 255 - 256;
  byte SE_byte = 240- 256;
  byte SB_byte = 250- 256;
  byte WILL_byte = 251- 256;
  byte WONT_byte = 252- 256;
  byte DO_byte = 253- 256;
  byte DONT_byte = 254- 256;
  byte NOP_byte = 241- 256;

  //sub-negotiations
  char ECHO = 1;
  char SEND = 1;
  char IS = 0;
  char suppressGoAhead = 3;
  char terminalType = 24;
  char windowSize = 31;

  String outgoing = "";
  //processes a command received from the server,
  void processCommand(byte[] byteBuffer, int cmdPos) {

    if ((byteBuffer.length -3) <= cmdPos) {
      // print("ERROR: command cutoff!!!");
      return;
    }
    int command = byteBuffer[cmdPos] + 256;
    int option = byteBuffer[cmdPos+1];
    //String reply = "";
    if (command == WILL) {
      if (option == ECHO) {
        //reply = "" + IAC + DO + ECHO;
        print("<server is echoing>");
      } else if (option == suppressGoAhead) {
        //reply = "" + IAC + DO + suppressGoAhead;
        print("<suppressing GoAhead>");
      } else {
        //reply = "" + IAC + DONT + option;
        print("<unsupported option requrested!!>");
      }
    } else if (command == DONT) {
      if (option == ECHO) {
      }
    } else if (command == DO) {
      if (option == windowSize) {
        //reply = "" + IAC + WILL + windowSize;
        //sendWindowSize();
      } else if (option == terminalType) {
        //reply = "" + IAC + WILL + terminalType;
        //sendTerminalType();
      } else {
        print("<unspported action requested!");
      }
    } else if (command == SE) {
      //do nothing, this is end of sub-negotiation
    } else if (command == SB) {
      if (option == terminalType) {
        //reply = "" + IAC + SB + terminalType + IS + "VT100" + IAC + SE;
        sendTerminalType();
      } else if (option == windowSize) {
        //sendWindowSize();
        sendWindowSize();
      }
    } else if (command == 128) {
      int actualOption = option + 256;
      if (actualOption == 134) {
        // print("<<cursor pos set?>>");
        eraseCursor();
        colPos = byteBuffer[cmdPos + 2];
        linePos = byteBuffer[cmdPos + 3];
        sendData(); //<>//
      } else if (actualOption == 130) {
        // print("<<clearscreen???");
        //background(0);
        colPos = 0;
        linePos = 0;
      } else {
        // print("<unknown terminal command: " + option + ">");
      }

    } else {
      //reply = "" + IAC + NOP;
      // print("<unsupported command received: " + command + ">");
    }
    //outgoing = outgoing + reply;
  }

  int lastMessage = 0;
  //send outgoing messeges
  void sendOutgoing() {
    if (outgoing == "") {
      return;
    }
    myClient.write(outgoing);
    lastMessage = millis();
    print("Reply:");
    for (int i =0; i < outgoing.length(); i++) {
      char nextChar = outgoing.charAt(i);
      if (nextChar < 0) {
        print("<" + commandToString((int)nextChar + 256) + ">");
      } else {
        print("<" + commandToString((int)nextChar) + ">");
      }
    }
    print("\n");
    outgoing = "";
  }

  public void send(String data) {
    outgoing += data;
    sendOutgoing();
  }

  void sendCommand(byte[] command) {
    myClient.write(command);
    lastMessage = millis();
    print("SentCMD:");
    for (int i =0; i < command.length; i++) {
      byte nextChar = command[i];
      if (nextChar < 0) {
        print("<" + commandToString((int)nextChar + 256) + ">");
      } else {
        print("<" + commandToString((int)nextChar) + ">");
      }
    }
    print("\n");

    //outgoing = "";
  }

  void keyPressed(char key) {
    if ((int)key == 65535) { //shift
      return;
    }

    outgoing += key;
    //sendWindowSize();
    //println("sending keypress: " + (int)key);
  }
}
