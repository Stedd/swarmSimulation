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
      int formationWidth  = 2;
      // int l = yCellOver*(width/cellSize) + xCellOver;
      float startX = width - 300 + i%(formationWidth)*bot_Size;
      float startY = 100 + bot_Size *  floor(i/(formationWidth));
      // float startX = 100 + i* bot_Size; 
      // float startY = 100 + float(floor(i/formationWidth))* bot_Size; 
      addBot(i, startX, startY);
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
        // if(cellRealValue(cellIndex(cellPos(bot.goal_pos)))>10000){
        //   bot.needNewTarget = true;
        // }
        bot.needNewPath = true;
      }

      //Send target to bot
      bot.goal_pos = goal_Pos[i];

      //Path Planning
      if(bot.needNewPath && bot.pos.x !=0 && bot.pos.y !=0 && millis()>bot.nextLoop){
        bot.nextLoop = millis()+200;
        recalculatePath(bot);
        bot.waypoints.clear();
        for (int j = path.size()-1; j >=0 ; j--) {
          float x = path.get(j).pos.x*cellSize;
          float y = path.get(j).pos.y*cellSize;
          bot.waypoints.add(new PVector(x,y));          
        }
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

            if ((x > min(p1.x, p2.x)) && (x < max(p1.x, p2.x)) && (y > min(p1.y, p2.y)) && (y < max(p1.y, p2.y))
              && (x > min(p3.x, p4.x)) && (x < max(p3.x, p4.x)) && (y > min(p3.y, p4.y)) && (y < max(p3.y, p4.y))) {
              wallintersectionExists = true;

              PVector closestIntersection   = PVector.sub(p1, closestIntersectionPoint);
              PVector intersectionPoint     = new PVector(x+random(-sensor.noise, sensor.noise), y+random(-sensor.noise, sensor.noise));
              PVector.sub(p1, intersectionPoint, distanceToIntersection);
              if (distanceToIntersection.mag()<closestIntersection.mag()) {
                closestIntersectionPoint.set(intersectionPoint);
              }
            }
          }
          if (wallintersectionExists&&(closestIntersectionPoint.x<width)&&(closestIntersectionPoint.y<height)) {
            fill(255, 0, 0);
            noStroke();
            sensor.beamEndPointsIntersect[k].set(closestIntersectionPoint);
          } else {
            sensor.beamEndPointsIntersect[k].set(sensor.beamEndPoints[k]);
          }
        }
        if (botintersectionExists&&(closestIntersectionPoint.x<width)&&(closestIntersectionPoint.y<height)) {
          sensor.beamEndPointsIntersect[k].set(closestIntersectionPoint);
        }

        if (PVector.sub(sensor.beamEndPointsIntersect[k], sensor.sensorPos).mag()>PVector.sub(sensor.beamStartPoints[k], sensor.sensorPos).mag() && PVector.sub(sensor.beamEndPointsIntersect[k], sensor.sensorPos).mag()>0) {
          PVector start = sensor.beamStartPoints[k];
          PVector end   = sensor.beamEndPointsIntersect[k];
          PVector diff = PVector.sub(end, start);
          float xLast = 0;
          float yLast = 0;
          for (float m=0; m<=1.1; m+=(cellSize)/(diff.mag()*2)) {
            PVector currentCell = PVector.add(start, PVector.mult(diff, m));
            if(currentCell.x != xLast && currentCell.y != yLast){
              if(discover){
                if((wallintersectionExists || botintersectionExists) && (m>=0.95-(cellSize)/(diff.mag()*3))){
                updateCell(currentCell,0.0, 0.03);
                // updateCell(PVector.add(start, PVector.mult(diff, m)),0.0);

                }else{
                  updateCell(currentCell,1.0, 0.03);
                  // updateCell(PVector.add(start, PVector.mult(diff, m)),1.0);
                }
              }
            }
            xLast = currentCell.x;
            yLast = currentCell.y;
          }



          // int foo = 0;
          // float dx = end.x - start.x;

          // float dy = end.y - start.y;

          // float p  = 2*dy-dx;
          // float y  = start.y;
          // float x  = start.x;

          // if(discover){
          //     println("dx: " + dx);
          //     println("dy: " + dy);
          //     println("dy/dx: " + dy/dx);
          // }


          // // println("p: " + p);
          // // for (int x=int(start.x); x <= int(end.x); x+=1) {
          // while(x<end.x && foo <50){
          //   if(discover){

          //     // println("p: " + p);
          //     if((wallintersectionExists || botintersectionExists)){
          //     updateCell(PVector.add(start, new PVector(x, y)), 0.0, 0.05);
          //     // updateCell(PVector.add(start, PVector.mult(diff, m)),0.0);

          //     }else{
          //       updateCell(PVector.add(start,new PVector(x, y)),1.0, 0.05);
          //       // updateCell(PVector.add(start, PVector.mult(diff, m)),1.0);
          //     }
          //   }
          //   if(p>=0){
          //     y += 1;
          //     p += 2*dy-2*dx;
          //     // println("p: " + p);
          //   }else{
          //     p += 2*dy;
          //     x += 1;
          //   }
          //   foo+=1;
          //   // println("x: " + x + ". y: " + y);
          // }












        }
      }
  }

  public void addBot(int id_, float x_, float y_) {
    PVector setPos = new PVector(0, 0);
    bots.add(new Bot(botcount, bots, setPos.set(x_, y_), id_));
  }
}
