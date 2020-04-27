//Import
import controlP5.*;

//Variables
ControlP5 cp5;
Swarm     swarmsystem;

//Map variables
PGraphics frameBuffer;
boolean   updated = true;
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
int       numberOfBots = 6;

float     time;
float     dt                      = 0.016;//100ms per frame

float pixelsPerMeter          = 50;
int   cellSize                = 5;
float realCellSize            = float(cellSize)/pixelsPerMeter;

float     ultrasonicMinRange      = 0.25; //todo: Update values from manual
float     ultrasonicMaxRange      = 1.2;  //todo: Update values from manual
float     ultrasonicSpan          = ultrasonicMaxRange - ultrasonicMinRange;

float     irMinRange              = 0.5;  //todo: Update values from manual
float     irMaxRange              = 1.5;  //todo: Update values from manual
float     irSpan                  = irMaxRange - irMinRange;

float     depthCameraMinRange     = 0.55;
float     depthCameraMaxRange     = 2.8;
float     depthCameraSpan         = depthCameraMaxRange - depthCameraMinRange;

float     realBotMaxLinearSpeed   = 0.3; //[m/s]
float     realBotMaxAngularSpeed  = 0.5; //[rad/s]

float     simBotMaxLinearSpeed    = realBotMaxLinearSpeed*pixelsPerMeter*dt; //[pixel/frame]
float     simBotMaxAngularSpeed   = realBotMaxAngularSpeed*dt; //[rad/frame]


void setup() {
  //Set up Canvas
  size(1300, 900);
  frameBuffer = createGraphics(1300,900);

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
    drawMap();
    if (Draw_Map & updated) {
      image(frameBuffer,0,0);
    }

    text("Map updates: " + updateCount, width-600, 40);

    //drawEdges();

    swarmsystem.Loop();
  }

  time();

  fps();
}
