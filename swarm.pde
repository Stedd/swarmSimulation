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
      //edges
      for (int j=0; j<edgePool.size(); j++) {

        PVector p3 = new PVector(edgePool.get(j).sx, edgePool.get(j).sy);
        PVector p4 = new PVector(edgePool.get(j).ex+0.1, edgePool.get(j).ey+0.1); 
        PVector sub1 = PVector.sub(p4, p3);
        float a1 = sub1.y / sub1.x;
        float b1 = p3.y - a1 * p3.x;

        //rays
        for (int k=0; k<bot.numberOfBeams; k++) {
          if (edgePool.size()>0) {
            PVector p1 = new PVector(bot.camera_lens_pos.x, bot.camera_lens_pos.y);
            PVector p2 = new PVector(bot.beamEndPoints[k].x, bot.beamEndPoints[k].y);
            PVector sub = PVector.sub(p2, p1);
            // y = a * x + b
            float a = sub.y / sub.x;
            float b = p1.y - a * p1.x;




            float x = (b1 - b) / (a - a1);
            float y = a * x + b;

            //println("x: "+x+" y: "+y);
            //ellipse(x, y, 20, 20);
            //stroke(155, 155, 255);
            //line(p1.x, p1.y, p2.x, p2.y);
            //line(p3.x, p3.y, p4.x, p4.y);

            if ((x > min(p1.x, p2.x)) && (x < max(p1.x, p2.x)) && (y > min(p1.y, p2.y)) && (y < max(p1.y, p2.y))
              && (x > min(p3.x, p4.x)) && (x < max(p3.x, p4.x)) && (y > min(p3.y, p4.y)) && (y < max(p3.y, p4.y))) {
              fill(255, 0, 0);
              ellipse(x, y, 20, 20);
              println("intersect at pixel:"+ x + "," + y);
            }
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
