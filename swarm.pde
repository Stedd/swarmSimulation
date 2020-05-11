class Swarm {
  //Variables
  ArrayList<Bot>          bots;

  PVector move         =  new PVector();
  PVector mousePos     =  new PVector();

  int     botcount     = 0;


  //Constructor
  Swarm(int botcount_) {
    botcount=botcount_;
  }


  public void Init() {
    bots = new ArrayList<Bot>();
    for ( int i = 0; i<botcount; i++) {
      addBot(i);
    }
  }


  public void Loop() {
    updateSwarm();
    mousePos.set(mouseX, mouseY);
  }


  public void updateSwarm() {
    for (int i = 0; i<bots.size(); i++) {
      Bot bot = bots.get(i);
      if (i==0) {
        if (mousePressed && (mouseButton == RIGHT)) {
          bot.setPos(mousePos);
        }
      }

      bot.setSize(bot_Size);

      //Assign new target to bot

      // if(frameCount%500==0){
      //   updateTarget();
      // }

      if(bot.needNewTarget){
        updateTarget(i);
      }

      //Send target to bot
      bot.target_pos = targetPos[i];

      //Path Planning
      if(bot.needNewPath){
        recalculatePath(bot);
        // bot.waypoints = calculatedpoints;
      }

      bot.Loop();

      checkIntersection(bot.depthCamera,    i, true);
      checkIntersection(bot.ultrasonic,     i, false);
      checkIntersection(bot.leftInfrared,   i, false);
      checkIntersection(bot.rightInfrared,  i, false);

    }
  }

  void checkIntersection(Sensor sensor, int i, boolean discover){
          //Detect depth camera ray intersection with bots and walls
      PVector p1                        = sensor.sensorPos;
      PVector closestIntersectionPoint  = new PVector(10000, 10000);
      PVector distanceToIntersection    = new PVector();

      for (int k=0; k<sensor.numberOfBeams; k++) {

        boolean wallintersectionExists  = false;
        boolean botintersectionExists   = false;

        PVector p2    = new PVector(sensor.beamEndPoints[k].x, sensor.beamEndPoints[k].y);
        PVector sub   = PVector.sub(p2, p1);
        // y = a * x + b
        float a       = sub.y / sub.x;
        float b       = p1.y - a * p1.x;
        closestIntersectionPoint = new PVector(10000, 10000);

        //Check for beam collision with other bots
        for (int ii = 0; ii<bots.size(); ii++) {
          Bot targetBot = bots.get(ii);
          //do not check self
          if (!(ii == i)) {
            float A = (1 + a * a);
            float B = (2 * a *( b - targetBot.pos.y) - 2 * targetBot.pos.x);
            float C = (targetBot.pos.x * targetBot.pos.x + (b - targetBot.pos.y) * (b - targetBot.pos.y)) - (targetBot.botSizePixels/2 * targetBot.botSizePixels/2);
            float delta = B * B - 4 * A * C;
            if (delta >= 0) {
              float x1 = (-B - sqrt(delta)) / (2 * A);
              float y1 = a * x1 + b;
              float x2 = (-B + sqrt(delta)) / (2 * A);
              float y2 = a * x2 + b;
              if ((x1 > min(p1.x, p2.x)) && (x1 < max(p1.x, p2.x)) && (y1 > min(p1.y, p2.y)) && (y1 < max(p1.y, p2.y))||(x2 > min(p1.x, p2.x)) && (x2 < max(p1.x, p2.x)) && (y2 > min(p1.y, p2.y)) && (y2 < max(p1.y, p2.y))) {
                botintersectionExists = true;
                PVector closestIntersection     = PVector.sub(p1, closestIntersectionPoint);
                PVector intersectionPoint1 = new PVector(x1, y1);
                PVector intersectionPoint2 = new PVector(x2, y2);
                PVector.sub(p1, intersectionPoint1, distanceToIntersection);
                if (distanceToIntersection.mag()<closestIntersection.mag()) {
                  closestIntersectionPoint.set(intersectionPoint1);
                  closestIntersection     = PVector.sub(p1, closestIntersectionPoint);
                }
                PVector.sub(p1, intersectionPoint2, distanceToIntersection);
                if (distanceToIntersection.mag()<closestIntersection.mag()) {
                  closestIntersectionPoint.set(intersectionPoint2);
                }
                p2 = new PVector(closestIntersectionPoint.x, closestIntersectionPoint.y);
              }
            }
          }
        }


        //Check for line intersection
        if (edgePool.size()>0) {
          for (int j=0; j<edgePool.size(); j++) {
            PVector p3 = new PVector(edgePool.get(j).sx, edgePool.get(j).sy);
            PVector p4 = new PVector(edgePool.get(j).ex+1, edgePool.get(j).ey+1);
            PVector sub1 = PVector.sub(p4, p3);
            float a1 = sub1.y / sub1.x;
            float b1 = p3.y - a1 * p3.x;

            float x = (b1 - b) / (a - a1);
            float y = a * x + b;

            //println("x: "+x+" y: "+y);
            //ellipse(x, y, 20, 20);
            //stroke(155, 155, 255);
            //line(p1.x, p1.y, p2.x, p2.y);
            //line(p3.x, p3.y, p4.x, p4.y);

            if ((x > min(p1.x, p2.x)) && (x < max(p1.x, p2.x)) && (y > min(p1.y, p2.y)) && (y < max(p1.y, p2.y))
              && (x > min(p3.x, p4.x)) && (x < max(p3.x, p4.x)) && (y > min(p3.y, p4.y)) && (y < max(p3.y, p4.y))) {
              wallintersectionExists = true;

              PVector closestIntersection   = PVector.sub(p1, closestIntersectionPoint);
              PVector intersectionPoint     = new PVector(x+random(-sensor.noise, sensor.noise), y+random(-sensor.noise, sensor.noise));
              PVector.sub(p1, intersectionPoint, distanceToIntersection);
              //println(distanceToIntersection);
              if (distanceToIntersection.mag()<closestIntersection.mag()) {
                closestIntersectionPoint.set(intersectionPoint);
              }
              //println("intersect at pixel:"+ x + "," + y + " millis: " + millis());
            }
          }
          if (wallintersectionExists&&(closestIntersectionPoint.x<width)&&(closestIntersectionPoint.y<height)) {
            fill(255, 0, 0);
            noStroke();
            //ellipse(closestIntersectionPoint.x, closestIntersectionPoint.y, 6, 6);

            //discoverCell(closestIntersectionPoint);

            sensor.beamEndPointsIntersect[k].set(closestIntersectionPoint);
          } else {
            sensor.beamEndPointsIntersect[k].set(sensor.beamEndPoints[k]);
          }
        }
        if (botintersectionExists&&(closestIntersectionPoint.x<width)&&(closestIntersectionPoint.y<height)) {
          sensor.beamEndPointsIntersect[k].set(closestIntersectionPoint);
        }

        if (PVector.sub(sensor.beamEndPointsIntersect[k], sensor.sensorPos).mag()>PVector.sub(sensor.beamStartPoints[k], sensor.sensorPos).mag()) {
          PVector start = sensor.beamStartPoints[k];
          PVector end   = sensor.beamEndPointsIntersect[k];
          PVector diff = PVector.sub(end, start);
          for (float m=0; m<=1; m+=float(cellSize)/(diff.mag()*1.75)) {
            //println("beam: "+a+" checking: "+b);
            if(discover){
              if((wallintersectionExists || botintersectionExists) && m>=0.95){
              updateCell(PVector.add(start, PVector.mult(diff, m)),0.0, 0.05);
              // updateCell(PVector.add(start, PVector.mult(diff, m)),0.0);

              }else{
                updateCell(PVector.add(start, PVector.mult(diff, m)),1.0, 0.05);
                // updateCell(PVector.add(start, PVector.mult(diff, m)),1.0);
              }
            }
          }
        }

      }
  }

  public void addBot(int id_) {
    PVector setPos = new PVector(0, 0);
    bots.add(new Bot(botcount, bots, setPos.set(random(100,width-100), random(100,height-100)), id_));
  }
}
