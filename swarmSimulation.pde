//Import
import controlP5.*;

//Util
PFont f;
int backgroundColor = 125;
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
  swarmsystem = new Swarm(10);
  swarmsystem.Init();
}

void draw() {
  background(125);
  drawMap();

  if (edit) {
    editMap();
  }

  swarmsystem.Loop();
}

void keyReleased() {
  if (key=='r' || key == 'R') {
    swarmsystem.Init();
  }
}
