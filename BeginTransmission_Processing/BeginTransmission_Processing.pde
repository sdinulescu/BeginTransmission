/*
 * Listening OSC
 * Stejara Dinulescu
 * Program listens for OSC messages from motion capture webcam input and
 * uses it to drive sound
 */


/* CITATIONS: 
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 *
 * sound example taken from processing.org 
 * examples show how to create sine waves, envelopes, tri oscillator
 * sound website at https://processing.org/tutorials/sound/
 */

//silences -> stopping and starting
//amplitude

import oscP5.*;
import netP5.*;
import processing.sound.*;

OscP5 oscP5;

int DEST_PORT = 8888;
String DEST_HOST = "127.0.0.1";

//Values for Osc
float maxMotion = 0; 
float prevMaxMotion = 0;
float maxX = 0;
float prevMaxX = 0;
float maxY = 0;
float prevMaxY = 0;


//Tri oscillator and envelope -> max motion value is passed in 
TriOsc tri;
TriOsc tri2;
Env env;
Env env2;

int note = 0;

//Long-Pad
float attackTime = 0.9;
float sustainTime = 1;
float sustainLevel = 0.002;
float releaseTime = 1;


////Short-Lead
//float attackTime = 0.0001;
//float sustainTime = 0.1;
//float sustainLevel = 0.005;
//float releaseTime = 0.1;


float angle = 0; 

void setup() {
  fullScreen();
  background(0);
  frameRate(25);
  
  //set up tri oscillator and envelope
  tri = new TriOsc(this);
  tri2 = new TriOsc(this);
  env = new Env(this);
  env2 = new Env(this);
  
  /* start oscP5, listening for incoming messages at destination port */
  oscP5 = new OscP5(this, DEST_PORT);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage msg) {
  String addr = msg.addrPattern();
  /* print the address pattern and the typetag of the received OscMessage */

  if ( addr.contains("Square") ) {
    //set previous values
    prevMaxX = maxX;
    prevMaxY = maxY;
    prevMaxMotion = maxMotion;
    
    //set current values
    maxMotion = msg.get(0).floatValue();
    maxX = msg.get(1).floatValue();
    maxY = msg.get(2).floatValue();
    //println("### received an osc message: " + addr + " " + maxMotion + " " + maxX + " " + maxY);
  }
}

void checkOSC() {
  println("prevMaxX: " + prevMaxX + " currMaxX: " + maxX);
  println("prevMaxY: " + prevMaxY + " currMaxY: " + maxY);
  println("maxMotion: " + maxMotion);
}


void handleTri() {
  //map values
  float mappedX = map(maxX, 0, 640, 0, 1);
  float mappedY = map(maxY, 0, 480, 0, 1);
  float midiX = map(maxX, 0, 640, 49, 84);
  float midiY = map(maxY, 0, 640, 49, 84);
  
  float mappedMotion = map(maxMotion, 0, 90000, 0, 0.007);
  
  //sustainLevel = mappedY; //square y values change the sustainTime
  //attackTime = sqrt(mappedX*mappedX + mappedY*mappedY); //distance formula between square x and y values changes the sustain time of tri oscillator

  //println(maxX);
  //"melody" tri oscillator that plays notes based on the max square motion that is passed in
  tri.play( midiToFreq( (int)midiX ), mappedMotion  ); //square X values change amplitude
  env.play( tri, attackTime, sustainTime, sustainLevel, releaseTime );
  tri2.play( midiToFreq( (int)midiX + 7 ), mappedMotion ); //square Y values change amplitude
  env2.play( tri2, attackTime, sustainTime, sustainLevel, releaseTime );
}


void handleViz() {
  float mappedCol = map(maxMotion, 0, 300000, 0, 255);
  float mappedPrevPos = map(maxMotion, 0, 300000, 0, width/3);
  float mappedPos = map(maxMotion, 0, 300000, 0, width/3);
  
  stroke(255, mappedCol);
  noFill();
  
  strokeWeight(0.5);
  translate(width/2, height/2);
  rotate(angle);
  //ellipse(maxX, maxY, mappedCol, mappedCol);
  bezier(0, 0, prevMaxX, maxX, prevMaxY, maxY, mappedPrevPos, mappedPos);
  angle++;
}

void draw() {
  //checkOSC(); //prints values
  
  //handleSines(); 
  handleTri();
  handleViz();

}

float midiToFreq(int note) { //translates to notes (from processing documentation)
  return (pow(2, ((note-69)/12.0)))*440;
}
