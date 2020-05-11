public float tanh(float x_) {
  x_ *= 1e-2;
  return (exp(x_)-exp(-x_))/(exp(x_)+exp(-x_));
}

public float sat(float val_, float min_, float max_) {
  if (val_>max_) {
    val_ = max_;
  } else if (val_<min_) {
    val_ = min_;
  }
  return val_;
}

void time() {
  time = dt*(float(frameCount)-float(startFrame));
  fill(0, 50, 155);
  textFont(f, 20);
  text("t: " + nf(time, 4, 2) + " s", width-320, 40);
}

void fps() {
  fcount += 1;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m;
    //println("fps: " + frate);
  }
  fill(0, 50, 155);
  textFont(f, 20);
  text("FPS: " + frate, width-150, 40);
}

void keyReleased() {
  if (key=='r' || key == 'R') {
    swarmsystem.Init();
  }
}

float sign(float a1) {
  if (a1==0) return 0;
  if (a1<0) return -1;
  if (a1>0) return 1;
  // this would not be reached: 
  return 0;
}

PVector cellPos(PVector pos){
  int xCellOver = ceil(map(pos.x, 0, width, 0, width/cellSize));
  xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
  int yCellOver = ceil(map(pos.y, 0, height, 0, height/cellSize));
  yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
  return new PVector(xCellOver, yCellOver);
}

// int cellIndex(PVector pos){
//   int xCellOver = ceil(map(pos.x, 0, width, 0, width/cellSize));
//   xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
//   int yCellOver = ceil(map(pos.y, 0, height, 0, height/cellSize));
//   yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
//   return yCellOver*(width/cellSize) + xCellOver;
// }

int cellIndex(PVector pos){
  return int(pos.y)*cellSize*(width/cellSize) + int(pos.x)*cellSize;
}

float cellValue(PVector pos){
  return(1-cells.get(cellIndex(pos)).probability)*500;
}

float pathDist(PVector a, PVector b){
  return PVector.sub(a,b).mag();
}
