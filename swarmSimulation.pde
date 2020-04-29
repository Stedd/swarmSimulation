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
int       numberOfBots            = 3;

float     time;
float     dt                      = 0.05;//50ms per frame

float     fpixelsPerMeter         = 30;
int       ipixelsPerMeter         = int(fpixelsPerMeter);
float     fpixelsPerCentimeter    = fpixelsPerMeter/100;
int       ipixelsPerCentimeter    = int(fpixelsPerCentimeter);
int       cellSize                = 2;
int       icellPerMeter           = int(ipixelsPerMeter/cellSize);
float     realCellSize            = float(cellSize)/fpixelsPerMeter;

float     ultrasonicMinRange      = 0.25; //todo: Update values from manual
float     ultrasonicMaxRange      = 1.2;  //todo: Update values from manual
float     ultrasonicSpan          = ultrasonicMaxRange - ultrasonicMinRange;

float     irMinRange              = 0.5;  //todo: Update values from manual
float     irMaxRange              = 1.5;  //todo: Update values from manual
float     irSpan                  = irMaxRange - irMinRange;

float     depthCameraMinRange     = 0.1;
float     depthCameraMaxRange     = 2.8;
float     depthCameraSpan         = depthCameraMaxRange - depthCameraMinRange;

float     realBotMaxLinearSpeed   = 0.2; //[m/s]
float     realBotMaxAngularSpeed  = 0.3; //[rad/s]

float     simBotMaxLinearSpeed    = realBotMaxLinearSpeed*fpixelsPerMeter*dt; //[pixel/frame]
float     simBotMaxAngularSpeed   = realBotMaxAngularSpeed*dt; //[rad/frame]


void setup() {
  //Set up Canvas
  size(1500, 900);
  frameBuffer = createGraphics(width,height);

  //
  randomSeed(4);

  //Util
  f = createFont("Arial", 16, true);
  startFrame = 0;

  //initialize map arrays
  initMap();

  //pre-generate map
  createMap();

  //Initialize buttons
  buttons();

  //Initialize Swarm
  swarmsystem = new Swarm(numberOfBots);
  swarmsystem.Init();
}

void draw() {
  frameRate(100);
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
    //drawEdges();
    swarmsystem.Loop();
  }
  time();
  fps();
}
