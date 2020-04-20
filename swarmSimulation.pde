//Import
import controlP5.*;

//Util
PFont f;
int backgroundColor = 125;

int fcount, lastm;
float frate;
float fint = 0.5;

//Variables
ControlP5 cp5;
Swarm  swarmsystem;


void setup() {
  //Set up Canvas
  size(1200, 900);
  background(backgroundColor);

  //Util
  f = createFont("Arial", 16, true); 

  initMap();

  //Initialize buttons
  buttons();

  //Initialize Swarm
  swarmsystem = new Swarm(3);
  swarmsystem.Init();
}

void draw() {
  frameRate(500);
  background(125);
  //strokeWeight(0.5);
  drawMap();
  drawEdges();
  //drawRays();

  if (edit) {
    editMap();
  } else {
    swarmsystem.Loop();
  }
  
    fcount += 1;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m;
    //println("fps: " + frate); 
  }
  fill(0);
  textFont(f, 16);
  text("fps: " + frate, width-100, 20);
  
}

void keyReleased() {
  if (key=='r' || key == 'R') {
    swarmsystem.Init();
  }
}
