//Import
import controlP5.*;

//Variables
ControlP5 cp5;
Swarm  swarmsystem;

//Util
PFont f;
int backGroundColor  = 125;

int fcount, lastm, startFrame;
float frate;
float fint           = 0.25;

//Simulation Parameters
int numberOfBots = 6;

float time;
float dt                      = 0.1;//100ms per frame

float pixelsPerMeter          = 25;
int   cellSize                = 3;
float realCellSize            = float(cellSize)/pixelsPerMeter;

float depthCameraMinRange     = 0.55;
float depthCameraMaxRange     = 2.8;
float depthCameraSpan         = depthCameraMaxRange - depthCameraMinRange;

float realBotMaxLinearSpeed   = 0.3; //[m/s]
float realBotMaxAngularSpeed  = QUARTER_PI; //[rad/s]

float simBotMaxLinearSpeed   = realBotMaxLinearSpeed*pixelsPerMeter*dt; //[pixel/frame]
float simBotMaxAngularSpeed  = realBotMaxAngularSpeed*dt; //[rad/frame]


void setup() {
  //Set up Canvas
  size(1200, 600);
  background(backGroundColor);

  //Util
  f = createFont("Arial", 16, true); 
  startFrame = 0;

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

    textMode(MODEL);
    textAlign(CENTER);
    textFont(f, 50);
    fill(0, 255, 255);
    text("Map edit mode", width/2, height/2-5);
  } else {
    if (Draw_Map) {
      drawMap();
    }

    //drawEdges();
    swarmsystem.Loop();
  }

  time();

  fps();
}
