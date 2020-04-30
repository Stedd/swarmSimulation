class Bot {

  //Variables
  ArrayList<Bot>            bots;
  int                       botcount = 0;

  //movement variables
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

  //depth camera sensor
  Sensor depthCamera        = new Sensor(depthCameraMinRange, depthCameraMaxRange,  15,  59, 0);

  //ultrasonic sensor
  Sensor ultrasonic         = new Sensor(ultrasonicMinRange,  ultrasonicMaxRange,   1 , 30, 0);

  //IR sensors
  Sensor infrared           = new Sensor(irMinRange,          irMaxRange,           2,  80, 0);

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

    ruleVector=new PVector[botcount*depthCamera.numberOfBeams];
    for ( int i = 0; i<botcount*depthCamera.numberOfBeams; i++) {
      ruleVector[i]=new PVector(0, 0);
    }
  }

  //Functions
  void Loop() {

    //Swarm rules
    swarmRulesInit();

    //Sensors
    sensors();

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
      ruleDepthCamera();
    }

    swarmRulescombine();


    
    // depthCamera();

    //Move robot
    move();

    //Display robot
    display();
  }

  void sensors(){
    depthCamera.sensorPos.set(pos.x + (botSizePixels/2)*cos(-ang), pos.y - (botSizePixels/2)*sin(-ang));
    depthCamera.ang = -ang+QUARTER_PI;
    depthCamera.update();

    ultrasonic.sensorPos.set(depthCamera.sensorPos);
    ultrasonic.ang = -ang+QUARTER_PI;
    ultrasonic.update();

    infrared.sensorPos.set(depthCamera.sensorPos);
    infrared.ang = -ang+QUARTER_PI;
    infrared.update();
  }

  void move() {

    //Robot heading
    heading_vec.set(PVector.fromAngle(ang)); 

    //Reference angle
    theta_ref= resultantVelocityVector.heading()-heading_vec.heading(); 

    //Speed controllers

    //linear
    lin_vel = resultantVelocityVector.mag()*cos(theta_ref); 
    lin_vel = sat(lin_vel, -0.1*simBotMaxLinearSpeed, simBotMaxLinearSpeed); 
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

    // lin_vel = simBotMaxLinearSpeed;

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
    if (Sensor_zone) {
      stroke(0, 255, 0, 75);
      depthCamera.draw();
      stroke(255, 0, 0, 75);
      ultrasonic.draw();
      stroke(0, 0, 255, 75);
      infrared.draw();
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

    for ( int x = 0; x<botcount*depthCamera.numberOfBeams; x++) {
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
    w=Separation_weight/botcount; 
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
    w=Cohesion_weight/botcount; 
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
    w=Alignment_weight/botcount; 
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


  void ruleDepthCamera(){
    w=DepthCamera_weight/(botcount+depthCamera.numberOfBeams);

    for ( int i = 0; i<depthCamera.numberOfBeams; i++) {
      if(PVector.sub(depthCamera.beamEndPointsIntersect[i],depthCamera.beamStartPoints[i]).mag()<depthCamera.span){
        // println("beam intersect, adding vector");
        float resultantMagnitude = (PVector.sub(depthCamera.beamEndPointsIntersect[i],depthCamera.beamStartPoints[i]).mag() - depthCamera.span)*w;
        float beamangle          = ang-(depthCamera.fov/2) + i * (depthCamera.fov/(float(depthCamera.numberOfBeams)-1));
        // float resultantDirection = ang - beamangle*(1/abs(ang - beamangle));
        float resultantDirection = ang + HALF_PI*sign(ang - beamangle);
        ruleVector[n].set(resultantMagnitude*1*cos(resultantDirection),resultantMagnitude*1*sin(resultantDirection)); 
        ruleVector[n].mult(1);
        // println("Beam: " + i + ". Resultant vector: " + ruleVector[n]);
        n+=1;
        c+=1.0f;
      }
      
      
    }
  }


  //return position
  public void setPos(PVector newPos_) {
    pos.set(newPos_);
  }
  public void setSize(float newSize_) {
    botSizeReal   = newSize_/100; 
    botSizePixels = fpixelsPerMeter*botSizeReal;
    closeBoundary = botSizePixels + 2.0*fpixelsPerMeter;
    detBoundary   = botSizePixels + 17*fpixelsPerMeter;
    
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
