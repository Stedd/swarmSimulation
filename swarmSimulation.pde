//Import
import controlP5.*;

//Variables
ControlP5 cp5;
Swarm     swarmsystem;

//Map variables
PGraphics frameBuffer;
int       updateCount             = 0;

//Util
PFont     f;
int       backGroundColor         = 125;

//Framerate variables
int       fcount; 
int       lastm; 
int       startFrame;
float     frate;
float     fint                    = 0.25;

//Simulation Parameters

int       numberOfBots            = 4;

float     time;
float     dt                      = 0.05; //50ms per frame


float     fpixelsPerMeter         = 30;
int       ipixelsPerMeter         = int(fpixelsPerMeter);
float     fpixelsPerCentimeter    = fpixelsPerMeter/100;
int       ipixelsPerCentimeter    = int(fpixelsPerCentimeter);
int       cellSize                = 3;
int       icellPerMeter           = int(ipixelsPerMeter/cellSize);
float     realCellSize            = float(cellSize)/fpixelsPerMeter;

float     ultrasonicMinRange      = 0.25; 
float     ultrasonicMaxRange      = 1.5;  
int       ultrasonicNoise         = 0;    //wiggle this amount of pixels on intersection

float     irMinRange              = 0.25;  
float     irMaxRange              = 1.4;  
int       irNoise                 = 0;    //wiggle this amount of pixels on intersection

float     depthCameraMinRange     = 0.8;
float     depthCameraMaxRange     = 2.8;
int       depthCameraNoise        = 3;    //wiggle this amount of pixels on intersection

float     realBotMaxLinearSpeed   = 0.2; //[m/s]
float     realBotMaxAngularSpeed  = 0.5; //[rad/s]

float     simBotMaxLinearSpeed    = realBotMaxLinearSpeed*fpixelsPerMeter*dt; //[pixel/frame]
float     simBotMaxAngularSpeed   = realBotMaxAngularSpeed*dt; //[rad/frame]


void setup() {
  //Set up Canvas
  size(1500, 900);
  frameBuffer = createGraphics(width,height);
  println(width);
  //r
  // randomSeed(42);

  //Util
  f = createFont("Arial", 16, true);
  startFrame = 0;

  //init Exploration
  initExploration();

  //initialize map arrays
  initMap();

  //pre-generate map
  createMap();

  //Initialize buttons
  buttons();

  // //debug
  // simBotMaxLinearSpeed    = 0; //[pixel/frame]
  // simBotMaxAngularSpeed   = 0; //[rad/frame]

  //Initialize Swarm
  swarmsystem = new Swarm(numberOfBots);
  swarmsystem.Init();
}

void draw() {
  frameRate(300);
  background(backGroundColor);


  if (edit) {
    editMap();
    drawEditMap();
    if (Draw_Map) {
      image(frameBuffer,0,0);
    }
    textMode(MODEL);
    textAlign(CENTER);
    textFont(f, 50);
    fill(0, 255, 255);
    text("Map edit mode", width/2, height/2-5);
  } else {
    drawMap();
    if (Draw_Map) {
      image(frameBuffer,0,0);
    }
    text("Map updates: " + updateCount, width-600, 40);
    // drawEdges();
    // drawChecked();
    // drawWayPoints();
    // drawPoints();
    swarmsystem.Loop();
  }
  time();
  fps();
}
