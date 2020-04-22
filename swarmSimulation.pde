//Import
import controlP5.*;

//Util
PFont f;
int backGroundColor = 125;

int fcount, lastm;
float frate;
float fint = 0.25;

//Variables
ControlP5 cp5;
Swarm  swarmsystem;

int numberOfBots = 1;


void setup() {
  //Set up Canvas
  size(1200, 900);
  background(backGroundColor);

  //Util
  f = createFont("Arial", 16, true); 
  
  //initialize map arrays
  initMap(); 
  
  //Load pre-generated map
  loadMap();

  //Initialize buttons
  buttons();

  //Initialize Swarm
  swarmsystem = new Swarm(numberOfBots);
  swarmsystem.Init();
}

void draw() {
  frameRate(600);
  background(backGroundColor);


  if (edit) {
    editMap();
    drawEditMap();

    fill(0);
    textMode(MODEL);
    textAlign(CENTER);
    textFont(f, 50);
    text("Map edit mode", width/2, height/2-5);
  } else {
    drawMap();
    //drawEdges();
    swarmsystem.Loop();
  }

  fps();
}
