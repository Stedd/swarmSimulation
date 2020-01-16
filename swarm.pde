class Swarm {
  //Variables
  ArrayList<Bot>  bots;

  PVector move =  new PVector();
  PVector mousePos =  new PVector();
  PVector mouseMove =  new PVector();

  int             botcount = 0;

  float  closeBoundary = 60;
  //float  detBoundary =5.5*closeBoundary;
  float  detBoundary =closeBoundary+800;


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
        if (mousePressed) {
          bot.setPos(mousePos);
        }
      }

      bot.Loop();
    }
  }

  public void addBot(int id_) {
    PVector setPos = new PVector(0, 0);
    //bots.add(new Bot(setPos));
    bots.add(new Bot(botcount, bots, setPos.set(random(width), random(height)), closeBoundary, detBoundary, id_, round(225), round(225), round(225)));
  }
}
