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

      int xCellOver = int(map(bot.pos.x, 0, width, 0, width/cellSize));
      xCellOver = constrain(xCellOver, 0, width/cellSize-1);
      int yCellOver = int(map(bot.pos.y, 0, height, 0, height/cellSize));
      yCellOver = constrain(yCellOver, 0, height/cellSize-1);
      int j = yCellOver*(width/cellSize) + xCellOver;
      Cell currentBufferCell = cellsBuffer.get(j);
      Cell currentCell = cells.get(j);

      if (currentBufferCell.discovered) {
        currentCell.discovered=false;
      } else { 
        currentCell.discovered=true;
      }

      // Draw rays to edge nodes
      //if (edgePool.size()>0) {
      //  for (int j=0; j<=edgePool.size()-1; j++) {
      //    stroke(255, 255, 0); 
      //    line(edgePool.get(j).sx, edgePool.get(j).sy, bot.pos.x, bot.pos.y);
      //    line(edgePool.get(j).ex, edgePool.get(j).ey, bot.pos.x, bot.pos.y);
      //  }
      //}
    }
  }


  public void addBot(int id_) {
    PVector setPos = new PVector(0, 0);
    //bots.add(new Bot(setPos));
    bots.add(new Bot(botcount, cells, bots, setPos.set(random(width), random(height)), closeBoundary, detBoundary, id_, round(225), round(225), round(225)));
  }
}
