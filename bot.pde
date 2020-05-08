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
  int     numberOfVectors;
  float   lin_vel           = 0;
  float   theta_ref         = 0;
  float   ang_vel           = 0; 
  float   ang               = random(2*PI);
  float   moveThreshold     = 0.1;

  //depth camera sensor
  Sensor depthCamera        = new Sensor(depthCameraMinRange, depthCameraMaxRange, depthCameraNoise,  15, 59,  0);

  //ultrasonic sensor
  Sensor ultrasonic         = new Sensor(ultrasonicMinRange,  ultrasonicMaxRange, ultrasonicNoise,    1 , 30,  0);

  //IR sensors
  Sensor leftInfrared       = new Sensor(irMinRange,          irMaxRange,         irNoise,            3,  15,  30);
  Sensor rightInfrared      = new Sensor(irMinRange,          irMaxRange,         irNoise,            3,  15, -30);

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
    botcount        = botcount_;
    bots            = bots_;
    pos.set(pos_);
    botID           = id_;
    numberOfVectors = botcount*(depthCamera.numberOfBeams + ultrasonic.numberOfBeams + leftInfrared.numberOfBeams + rightInfrared.numberOfBeams);
    ruleVector      = new PVector[numberOfVectors];
    for ( int i = 0; i<numberOfVectors; i++) {
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

    //RULE: Ultrasonic
    if (Ultrasonic) {
      ruleUltrasonic();
    }

    //RULE: Infrared
    if (Infrared) {
      ruleInfrared();
    }

    swarmRulescombine();

    //Move robot
    move();

    //Display robot
    display();
  }

  void sensors(){
    depthCamera.sensorPos.set(pos.x + (botSizePixels/2)*cos(-ang), pos.y - (botSizePixels/2)*sin(-ang));
    depthCamera.ang = -ang+QUARTER_PI;
    depthCamera.update();

    ultrasonic.sensorPos.set(pos.x + (botSizePixels/4)*cos(-ang), pos.y - (botSizePixels/4)*sin(-ang));
    ultrasonic.ang = -ang+QUARTER_PI;
    ultrasonic.update();

    leftInfrared.sensorPos.set(ultrasonic.sensorPos);
    leftInfrared.ang = -ang+QUARTER_PI;
    leftInfrared.update();

    rightInfrared.sensorPos.set(ultrasonic.sensorPos);
    rightInfrared.ang = -ang+QUARTER_PI;
    rightInfrared.update();
  }

  void move() {

    //Robot heading
    heading_vec.set(PVector.fromAngle(ang)); 

    //Reference angle
    theta_ref= resultantVelocityVector.heading()-heading_vec.heading(); 

    //Speed controllers

    //linear
    lin_vel = resultantVelocityVector.mag()*cos(theta_ref); 
    lin_vel = sat(lin_vel, -0*simBotMaxLinearSpeed, simBotMaxLinearSpeed); 
    if (!(abs(resultantVelocityVector.mag())>moveThreshold)) {
      lin_vel=0;
    }
    // lin_vel = simBotMaxLinearSpeed;

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

    //Draw sensor zone
    if (Sensor_zone) {
      stroke(0, 255, 0, 75);
      depthCamera.draw();
      stroke(255, 0, 0, 75);
      ultrasonic.draw();
      stroke(0, 0, 255, 75);
      leftInfrared.draw();
      rightInfrared.draw();
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

    for ( int x = 0; x<numberOfVectors; x++) {
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


  void ruleDepthCamera(){
    w=DepthCamera_weight;

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

  void ruleUltrasonic(){
    w               = Ultrasonic_weight;
    float beamangle = ang;
    for ( int i = 0; i<ultrasonic.numberOfBeams; i++) {
      if(PVector.sub(ultrasonic.beamEndPointsIntersect[i],ultrasonic.beamStartPoints[i]).mag()<ultrasonic.span){
        // println("beam intersect, adding vector");
        float resultantMagnitude = (PVector.sub(ultrasonic.beamEndPointsIntersect[i],ultrasonic.beamStartPoints[i]).mag() - ultrasonic.span)*w;
        
        if (ultrasonic.numberOfBeams>1) {
          beamangle         = ang - (ultrasonic.fov/2) + i * (ultrasonic.fov/(float(ultrasonic.numberOfBeams)-1));
        }
        // float resultantDirection = ang - beamangle*(1/abs(ang - beamangle));
        float resultantDirection = ang;
        ruleVector[n].set(resultantMagnitude*1*cos(resultantDirection),resultantMagnitude*1*sin(resultantDirection)); 
        ruleVector[n].mult(1);
        // println("Beam: " + i + ". Resultant vector: " + ruleVector[n]);
        n+=1;
        c+=1.0f;
      }
    }
  }

  void ruleInfrared(){
    w=Infrared_weight;

    for ( int i = 0; i<leftInfrared.numberOfBeams; i++) {
      if(PVector.sub(leftInfrared.beamEndPointsIntersect[i],leftInfrared.beamStartPoints[i]).mag()<leftInfrared.span){
        // println("beam intersect, adding vector");
        float resultantMagnitude = (PVector.sub(leftInfrared.beamEndPointsIntersect[i],leftInfrared.beamStartPoints[i]).mag() - leftInfrared.span)*w;
        // float beamangle          = ang-(leftInfrared.fov/2) + i * (leftInfrared.fov/(float(leftInfrared.numberOfBeams)-1));
        // float resultantDirection = ang - beamangle*(1/abs(ang - beamangle));
        float resultantDirection = ang - HALF_PI;
        ruleVector[n].set(resultantMagnitude*1*cos(resultantDirection),resultantMagnitude*1*sin(resultantDirection)); 
        ruleVector[n].mult(1);
        // println("Beam: " + i + ". Resultant vector: " + ruleVector[n]);
        n+=1;
        c+=1.0f;
      }
    }

    for ( int i = 0; i<rightInfrared.numberOfBeams; i++) {
      if(PVector.sub(rightInfrared.beamEndPointsIntersect[i],rightInfrared.beamStartPoints[i]).mag()<rightInfrared.span){
        // println("beam intersect, adding vector");
        float resultantMagnitude = (PVector.sub(rightInfrared.beamEndPointsIntersect[i],rightInfrared.beamStartPoints[i]).mag() - rightInfrared.span)*w;
        // float beamangle          = ang-(rightInfrared.fov/2) + i * (rightInfrared.fov/(float(rightInfrared.numberOfBeams)-1));
        // float resultantDirection = ang - beamangle*(1/abs(ang - beamangle));
        float resultantDirection = ang + HALF_PI;
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
    detBoundary   = botSizePixels + 35*fpixelsPerMeter;
    
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
