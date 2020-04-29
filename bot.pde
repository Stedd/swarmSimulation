class Bot {

  //Variables
  ArrayList<Bot>            bots;
  int                       botcount = 0;

  //bot movement variables
  PVector pos               = new PVector();
  PVector vel               = new PVector();
  PVector heading_vec       = new PVector();
  PVector temp_heading_vec  = new PVector();

  PVector resultantVelocityVector    = new PVector();
  PVector[] ruleVector;
  float   lin_vel           = 0;
  float   theta_ref         = 0;
  float   ang_vel           = 0; 
  float   ang               = random(2*PI);
  float   moveThreshold     = 0.1;

  //bot depth camera variables
  PVector camera_lens_pos   = new PVector();
  float cameraAng           = 0;
  float fovHorizontal       = (59*PI)/180;
  float cameraMinRange      = depthCameraMinRange*fpixelsPerMeter;
  float cameraSpan          = depthCameraSpan*fpixelsPerMeter;
  float beamLength          = 0;
  int   numberOfBeams       = 50;
  PVector[] beamStartPoints;
  PVector[] beamEndPoints;
  PVector[] beamEndPointsIntersect;

  //Swarm rule help variable
  float w;
  int   n;
  float c;

  //Sensor variables
  float    closeBoundary    = 0;
  float    detBoundary      = 0;
  PVector                   botDistVec  = new PVector();

  //Bot properties
  int   botID               = 0;
  float botSizeReal         = (closeBoundary-30)/2;
  float botSizePixels       = (closeBoundary-30)/2;
  


  //debug
  int debugTarget =5;

  //Contructor
  Bot(int botcount_, ArrayList<Bot> bots_, PVector pos_, int id_) {
    botcount = botcount_;
    bots = bots_;
    pos.set(pos_);
    botID = id_;

    ruleVector=new PVector[botcount*2];
    for ( int i = 0; i<botcount*2; i++) {
      ruleVector[i]=new PVector(0, 0);
    }
    
    beamStartPoints =new PVector[numberOfBeams];
    beamEndPoints=new PVector[numberOfBeams];
    beamEndPointsIntersect=new PVector[numberOfBeams];
    for ( int i = 0; i<numberOfBeams; i++) {
      beamStartPoints[i] = new PVector(0, 0);
      beamEndPoints[i]=new PVector(0, 0);
      beamEndPointsIntersect[i]=new PVector(0, 0);
    }
  }

  //Functions
  void Loop() {

    //Swarm rules
    swarmRulesInit();

    //RULE: Separation
    if (Separation) {
      ruleSeparation();
    }

    //RULE: Cohesion
    if (Cohesion) {
      ruleCohesion();
    }

    //RULE: Alignment
    if (Alignment) {
      ruleAlignment();
    }

    //RULE: DepthCamera
    if (DepthCamera) {
      // ruleDepthCamera();
    }

    swarmRulescombine();


    //Sensors
    sensors();
    // depthCamera();

    //Move robot
    move();

    //Display robot
    display();
  }

  void sensors(){
    camera_lens_pos.set(pos.x + (botSizePixels/2)*cos(-ang), pos.y - (botSizePixels/2)*sin(-ang));
    cameraAng = -ang+QUARTER_PI;

    depthCamera();
    // ultrasonicSensor();

  }

  void depthCamera() {
    // cameraAng = -ang+QUARTER_PI;
    beamLength = cameraSpan;

    if (numberOfBeams==1) {
      float beamAng = cameraAng;
      beamEndPoints[0]= new PVector(camera_lens_pos.x + (beamLength*cos(beamAng)) + ((beamLength)*sin(beamAng)), camera_lens_pos.y + (beamLength*-sin(beamAng)) + ((beamLength)*cos(beamAng)));
    } else {
      for ( int i = 0; i<numberOfBeams; i++) {
        float beamAng = cameraAng-(fovHorizontal/2) + i * (fovHorizontal/(float(numberOfBeams)-1));
        beamStartPoints[i] = new PVector(camera_lens_pos.x + (cameraMinRange*cos(beamAng)) + ((cameraMinRange)*sin(beamAng)), camera_lens_pos.y + (cameraMinRange*-sin(beamAng)) + ((cameraMinRange)*cos(beamAng)));
        beamEndPoints[i]   = new PVector(camera_lens_pos.x + (beamLength*cos(beamAng)) + ((beamLength)*sin(beamAng)), camera_lens_pos.y + (beamLength*-sin(beamAng)) + ((beamLength)*cos(beamAng)));
      }
    }
  }

  //   void ultrasonicSensor() {
  //     beamLength = ultrasonicSpan+botSizePixels;
  //     beamAng = cameraAng;
  //     beamEndPoints[0]= new PVector(camera_lens_pos.x + (beamLength*cos(beamAng)) + ((beamLength)*sin(beamAng)), camera_lens_pos.y + (beamLength*-sin(beamAng)) + ((beamLength)*cos(beamAng)));
  // }


  void move() {

    //Robot heading
    heading_vec.set(PVector.fromAngle(ang)); 

    //Reference angle
    theta_ref= resultantVelocityVector.heading()-heading_vec.heading(); 

    //Speed controllers

    //linear
    lin_vel = resultantVelocityVector.mag()*cos(theta_ref); 
    lin_vel = sat(lin_vel, 0, simBotMaxLinearSpeed); 
    if (!(abs(resultantVelocityVector.mag())>moveThreshold)) {
      lin_vel=0;
    }

    //angular
    ang_vel = resultantVelocityVector.mag()*sin(theta_ref); 
    ang_vel = sat(ang_vel, -simBotMaxAngularSpeed, simBotMaxAngularSpeed); 


    //Stop if velocity vector is lower than the threshold
    if (!(abs(resultantVelocityVector.mag())>moveThreshold)) {
      ang_vel=0;
    }
    //ang_vel=-0.0015;
    //iterate angle of bot
    ang += ang_vel; 

    lin_vel = simBotMaxLinearSpeed;

    //iterate position of bot
    vel.set(lin_vel*cos(ang), lin_vel*sin(ang)); 
    pos.add(vel); 

    //DEBUG OPTIONS
    if (botID == debugTarget) {
      //println(theta_ref);
    }
  }

  void display() {
    stroke(255); 
    strokeWeight(1); 

    //Bot info
    //fovAng = -ang - HALF_PI; 
    //botSize      = (closeBoundary-30)/2; 

    //Draw detection zone
    if (Detect_Zone) {
      stroke(0, 255, 255); 
      noFill(); 
      ellipse(pos.x, pos.y, detBoundary, detBoundary);
    }


    //Draw safe zone
    if (Safe_Zone) {
      stroke(255, 255, 255, 255); 
      noFill(); 
      ellipse(pos.x, pos.y, closeBoundary, closeBoundary);
    }

    //Draw Robot frame
    stroke(0); 
    fill(100);
    ellipse(pos.x, pos.y, botSizePixels, botSizePixels); 

    //Draw Robot heading indicator
    strokeWeight(2); 
    line(pos.x, pos.y, pos.x+((botSizePixels/2)*cos(ang)), pos.y+((botSizePixels/2)*sin(ang))); 

    //Draw robot name
    // text("Bot "+botID + ". pos:" + pos.x + "," + pos.y , pos.x-14, pos.y-20);

    //Draw depth camera zone
    if (Depth_camera_zone) {
      stroke(0, 255, 0, 125);
      
      for ( int i = 0; i<numberOfBeams; i++) {
        if(PVector.sub(beamEndPointsIntersect[i],camera_lens_pos).mag()>PVector.sub(beamStartPoints[i],camera_lens_pos).mag()){
        line(beamStartPoints[i].x, beamStartPoints[i].y, beamEndPointsIntersect[i].x, beamEndPointsIntersect[i].y);
        }
      }
    }


    //Draw Resultant vector
    if (Resultant) {
      strokeWeight(1); 
      stroke(0, 0, 255); 
      line(pos.x, pos.y, pos.x+10*resultantVelocityVector.x, pos.y+10*resultantVelocityVector.y);
    }
  }

  void swarmRulesInit() {
    n=0; 
    c=0.0; 
    //clear resultant vectors before new run
    resultantVelocityVector.set(0, 0); 

    for ( int x = 0; x<botcount; x++) {
      ruleVector[x].set(0, 0);
    }
  }

  void swarmRulescombine() {
    //Set the target vector
    for (int k = 0; k<n; k++) {
      if (ruleVector[k].x!=0 && ruleVector[k].y!=0) {
        resultantVelocityVector.add(ruleVector[k]);
      }
    }
    if (n!=0) {
      resultantVelocityVector.mult(1/c);
    }
  }

  void ruleSeparation() {
    w=Separation_weight; 
    //Read position of other bots
    for (int j = 0; j<botcount; j++) {
      if (j!=botID) {
        Bot targetBot = bots.get(j); 
        PVector.sub(pos(), targetBot.pos(), botDistVec); 
        if (botDistVec.mag()<detBoundary) {
          if (botDistVec.mag()<closeBoundary) {
            ruleVector[n].set(botDistVec.mult((2.5e6*w*botcount)*tanh(((closeBoundary-botDistVec.mag())*3e-6)))); 
            stroke(255, 0, 0, 100); 
            //line(pos().x, pos().y, targetBot.pos().x, targetBot.pos().y);
          }
          n+=1; 
          c+=1.0f;
        }
      }
    }
  }

  void ruleCohesion() {
    w=Cohesion_weight; 
    //Read position of other bots
    for (int j = 0; j<botcount; j++) {
      if (j!=botID) {
        Bot targetBot = bots.get(j); 
        PVector.sub(pos(), targetBot.pos(), botDistVec); 
        if (botDistVec.mag()<detBoundary) {
          if (botDistVec.mag()>closeBoundary) {
            ruleVector[n].set(botDistVec.mult(-w*tanh(((closeBoundary-botDistVec.mag()*3e-6))))); 
            stroke(0, 255, 0, 100); 
            //line(pos().x, pos().y, targetBot.pos().x, targetBot.pos().y);
          }
          n+=1; 
          c+=1.0f;
        }
      }
    }
  }

  void ruleAlignment() {
    w=Alignment_weight; 
    //Calculate average heading of group
    for (int j = 0; j<botcount; j++) {
      Bot targetBot = bots.get(j); 
      if (botDistVec.mag()<detBoundary) {
        ruleVector[n].add(targetBot.botHeading());
      }
    }

    ruleVector[n].normalize(ruleVector[n]); 
    PVector.sub(heading_vec.normalize(), ruleVector[n], temp_heading_vec); 
    ruleVector[n].mult(w*temp_heading_vec.mag()); 

    n+=1; 
    c+=1.0;
  }


  // void ruleDepthCamera(){
  //   w=DepthCamera_weight;

  //   for ( int i = 0; i<numberOfBeams; i++) {
  //     // float beamAng = cameraAng-(fovHorizontal/2) + i * (fovHorizontal/(float(numberOfBeams)-1));
  //     // beamStartPoints[i] = new PVector(camera_lens_pos.x + (cameraMinRange*cos(beamAng)) + ((cameraMinRange)*sin(beamAng)), camera_lens_pos.y + (cameraMinRange*-sin(beamAng)) + ((cameraMinRange)*cos(beamAng)));
  //     // beamEndPoints[i]   = new PVector(camera_lens_pos.x + (beamLength*cos(beamAng)) + ((beamLength)*sin(beamAng)), camera_lens_pos.y + (beamLength*-sin(beamAng)) + ((beamLength)*cos(beamAng)));
  //     //add steering vector if beam is intersecting (beam is shorter than it should be)
  //     // println(PVector.sub(beamEndPointsIntersect[0],beamStartPoints[0]).mag());
  //     if(PVector.sub(beamEndPointsIntersect[i],beamStartPoints[i]).mag()<cameraSpan){
  //       println("beam intersect, adding vector");
  //       ruleVector[n].set((PVector.sub(beamEndPointsIntersect[i],beamStartPoints[i]).mag())); // todo, calculate the steering vecto size based on the lenth of the intersect vector comparet to the expected beam lengt and use the inverted beam angle for the direction of this vector
  //       ruleVector[n].normalize();
  //       ruleVector[n].mult(w);
  //       n+=1;
  //       c+=1.0f;
  //     }
      
      
  //   }
  // }


  //return position
  public void setPos(PVector newPos_) {
    pos.set(newPos_);
  }
  public void setSize(float newSize_) {
    botSizeReal   = newSize_/100; 
    botSizePixels = fpixelsPerMeter*botSizeReal;
    closeBoundary = botSizePixels + 1.0*fpixelsPerMeter;
    detBoundary   = botSizePixels + 10*fpixelsPerMeter;
    
  }
  public PVector pos() {
    return pos;
  }
  public int id() {
    return botID;
  }
  public PVector botHeading() {
    return heading_vec;
  }
}
