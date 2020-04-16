//Import
import controlP5.*;


//Variables
ControlP5 cp5;
Swarm  swarmsystem;


void setup() {
  //Set up Canvas
  size(1200, 900);
  background(125);

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

  editMap();

  swarmsystem.Loop();
}

void keyReleased() {
  swarmsystem.Init();
}
