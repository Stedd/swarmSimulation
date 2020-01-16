class Bot {

  //Variables
  ArrayList<Bot>            bots;
  int                       botcount = 0;

  //bot movement variables
  PVector pos               = new PVector();
  PVector vel               = new PVector();
  PVector heading_vec       = new PVector();
  PVector temp_heading_vec  = new PVector();
  PVector target_vec_res    = new PVector();
  PVector[]target_vecs     ;
  PVector setpoint          = new PVector(width/2, height/2);
  float   lin_vel           = 0;
  float   theta_ref         = 0;
  float   ang_vel           = 0; 
  float   ang               = random(2*PI);
  float moveThreshold  = 0.1;

  //Swarm rule help variable
  float w;
  int   n;
  float c;

  //bot properties
  int     r, g, b;
  int    botID              = 0;

  //sensor variables
  float    closeBoundary    = 0;
  float    detBoundary      = 0;
  PVector                   botDistVec  = new PVector();

  int debugTarget =5;

  //Contructor
  Bot(int botcount_, ArrayList<Bot> bots_, PVector pos_, float closeBoundary_, float detBoundary_, int id_, int r_, int g_, int b_) {
    botcount = botcount_;
    bots = bots_;
    pos.set(pos_);
    closeBoundary = closeBoundary_;
    detBoundary = detBoundary_;
    botID = id_;
    r=r_;
    g=g_;
    b=b_;

    target_vecs=new PVector[botcount*2];
    for ( int i = 0; i<botcount*2; i++) {
      target_vecs[i]=new PVector(0, 0);
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

    swarmRulescombine();

    //Move robot
    move();

    //Display robot
    display();
  }


  void swarmRulesInit() {
    n=0;
    c=0.0;
    //clear resultant vectors before new run
    target_vec_res.set(0, 0);

    for ( int x = 0; x<botcount*2; x++) {
      target_vecs[x].set(0, 0);
    }
  }

  void swarmRulescombine() {
    //Set the target vector
    for (int k = 0; k<n; k++) {
      if (target_vecs[k].x!=0 && target_vecs[k].y!=0) {
        target_vec_res.add(target_vecs[k]);
      }
    }
    if (n!=0) {
      target_vec_res.mult(1/c);
    }
  }

  void move() {

    //Robot heading
    heading_vec.set(PVector.fromAngle(ang));

    //Reference angle
    theta_ref= target_vec_res.heading()-heading_vec.heading();

    //Speed controllers

    //linear
    lin_vel = target_vec_res.mag()*cos(theta_ref);
    lin_vel = sat(lin_vel, -0.2, 0.5);
    if (!(abs(target_vec_res.mag())>moveThreshold)) {
      lin_vel=0;
    }

    //angular
    ang_vel = target_vec_res.mag()*sin(theta_ref);
    ang_vel = sat(ang_vel, -0.025, 0.025);

    //if (lin_vel<0) {
    //  ang_vel= -1 * sat(ang_vel, -0.025, 0.025);
    //} else {
    //  ang_vel = sat(ang_vel, -0.025, 0.025);
    //}

    if (!(abs(target_vec_res.mag())>moveThreshold)) {
      ang_vel=0;
    }

    ang += ang_vel;


    vel.set(lin_vel*cos(ang), lin_vel*sin(ang));
    pos.add(vel);

    //DEBUG OPTIONS
    if (botID == debugTarget) {
      //println(theta_ref);
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
            target_vecs[n].set(botDistVec.mult((2.5e6*w*botcount)*tanh(((closeBoundary-botDistVec.mag())*3e-6))));
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
            target_vecs[n].set(botDistVec.mult(-w*tanh(((closeBoundary-botDistVec.mag()*3e-6)))));
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
      target_vecs[n].add(targetBot.botHeading());
      }
    }

    target_vecs[n].normalize(target_vecs[n]);
    PVector.sub(heading_vec.normalize(), target_vecs[n], temp_heading_vec);
    target_vecs[n].mult(w*temp_heading_vec.mag());

    n+=1;
    c+=1.0;
  }

  void display() {
    stroke(255);
    strokeWeight(1);

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
    fill(r, g, b);
    ellipse(pos.x, pos.y, closeBoundary-30, closeBoundary-30);

    //Draw Robot heading indicator
    strokeWeight(2);
    line(pos.x, pos.y, pos.x+((closeBoundary-30)/2*cos(ang)), pos.y+((closeBoundary-30)/2*sin(ang)));

    //Draw robot name
    //text("Bot "+botID, pos.x-14, pos.y-20);

    //Draw Resultant vector
    if (Resultant) {
      strokeWeight(1);
      stroke(0, 0, 255);
      line(pos.x, pos.y, pos.x+10*target_vec_res.x, pos.y+10*target_vec_res.y);
    }
  }

  //return position
  public void setPos(PVector newPos_) {
    pos.set(newPos_);
  }
  public void setSize(float newSize_) {
    closeBoundary = newSize_;
    detBoundary =closeBoundary+200;
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
