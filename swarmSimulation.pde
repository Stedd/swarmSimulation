//Import
import controlP5.*;

//Util
PFont f;
int backgroundColor = 125;

int fcount, lastm;
float frate;
float fint = 0.25;

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
  swarmsystem = new Swarm(2);
  swarmsystem.Init();
}

void draw() {
  frameRate(500);
  background(125);

  drawMap();
  drawEdges();
  //drawRays();


  if (edit) {
    editMap();
  } else {
    swarmsystem.Loop();
  }


  fps();
  
}
