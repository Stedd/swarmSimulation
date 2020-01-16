//Variables
Swarm  swarmsystem;

void setup() {
  //Set up Canvas
  size(1200, 900);
  background(125);

  //Initialize Swarm
  swarmsystem = new Swarm(20);
  swarmsystem.Init();
}

void draw() {
  background(125);
  swarmsystem.Loop();
}

public float tanh(float x_) {
  x_ *= 1e-2;
  return (exp(x_)-exp(-x_))/(exp(x_)+exp(-x_));
}

public float sat(float val_, float min_, float max_){
  if(val_>max_){
    val_ = max_;
  }
  else if(val_<min_){
    val_ = min_;
  }

 return val_; 
}
