class Swarm {
  //Variables
  ArrayList<Bot>          bots;

  PVector move         =  new PVector();
  PVector mousePos     =  new PVector();
  //PVector mouseMove    =  new PVector();

  int     botcount     = 0;

  float  closeBoundary = 10;
  float  detBoundary   = closeBoundary+400;


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

      bot.Loop();

      //Reveal scanned cells



      //Check for line intersection

      boolean intersectionExists = false;
      PVector p1 = new PVector(bot.camera_lens_pos.x, bot.camera_lens_pos.y);
      PVector closestIntersectionPoint = new PVector(1000, 1000);

      PVector distanceToIntersection  = new PVector();

      if (edgePool.size()>0) {
        for (int k=0; k<bot.numberOfBeams; k++) {
          //rays
          PVector p2 = new PVector(bot.beamEndPoints[k].x, bot.beamEndPoints[k].y);
          PVector sub = PVector.sub(p2, p1);
          // y = a * x + b
          float a = sub.y / sub.x;
          float b = p1.y - a * p1.x;

          closestIntersectionPoint = new PVector(1000, 1000);


          for (int j=0; j<edgePool.size(); j++) {
            //edges
            PVector p3 = new PVector(edgePool.get(j).sx, edgePool.get(j).sy);
            PVector p4 = new PVector(edgePool.get(j).ex+0.1, edgePool.get(j).ey+0.1); 
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
              intersectionExists = true;

              PVector closestIntersection     = PVector.sub(p1, closestIntersectionPoint);
              PVector intersectionPoint = new PVector(x, y);
              PVector.sub(p1, intersectionPoint, distanceToIntersection);
              //println(distanceToIntersection);
              if (distanceToIntersection.mag()<closestIntersection.mag()) {
                closestIntersectionPoint.set(intersectionPoint);
              }    
              //println("intersect at pixel:"+ x + "," + y);
            }
          }

          if (intersectionExists) {
            fill(255, 0, 0);
            noStroke();
            ellipse(closestIntersectionPoint.x, closestIntersectionPoint.y, 6, 6);

            int xCellOver = int(map(closestIntersectionPoint.x, 0, width, 0, width/cellSize));
            xCellOver = constrain(xCellOver, 0, width/cellSize-1);
            int yCellOver = int(map(closestIntersectionPoint.y, 0, height, 0, height/cellSize));
            yCellOver = constrain(yCellOver, 0, height/cellSize-1);
            int l = yCellOver*(width/cellSize) + xCellOver;
            //Cell currentBufferCell = cellsBuffer.get(l);
            Cell currentCell = cells.get(l);

            //if (currentBufferCell.exist) {
            currentCell.discovered=true;
            //} else { 
            //currentCell.exist=true;
            //}
          }
        }
      }
    }
  }


  public void addBot(int id_) {
    PVector setPos = new PVector(0, 0);
    //bots.add(new Bot(setPos));
    bots.add(new Bot(botcount, bots, setPos.set(random(width), random(height)), closeBoundary, detBoundary, id_, round(225), round(225), round(225)));
  }
}
