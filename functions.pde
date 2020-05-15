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
  int xCellOver = int(map(pos.x, 0, width, 0, width/cellSize));
  xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
  int yCellOver = int(map(pos.y, 0, height, 0, height/cellSize));
  yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
  // println(xCellOver + ',' + yCellOver);
  return new PVector(xCellOver, yCellOver);
}

// int cellIndex(PVector pos){
//   int xCellOver = ceil(map(pos.x, 0, width, 0, width/cellSize));
//   xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
//   int yCellOver = ceil(map(pos.y, 0, height, 0, height/cellSize));
//   yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
//   return yCellOver*(width/cellSize) + xCellOver;
// }

PVector indexRealPos(int index){
  int x = index%(width);
  int y = floor(index/(width));
  return new PVector(x,y);
}

PVector indexPos(int index){
  int x = index%(width/cellSize);
  int y = floor(index/(width/cellSize));
  return new PVector(x,y);
}

int cellRealIndex(PVector pos){
  // println(pos);
  return int((floor(pos.y)*width)) + floor(pos.x);
}

int cellIndex(PVector pos){
  // println(pos);
  return int((floor(pos.y)*width)/cellSize) + floor(pos.x);
}

float cellRealValue(int index){
  // println(pos);
  if (cells.get(index).mapValue <=0.49){
    return 100000;
  }else{
    return 1;
  }
  // return(1-cells.get(cellIndex(pos)).probability)*0.5;
}

float cellValue(PVector pos){
  if (cells.get(cellIndex(pos)).probability <=0.49){
    return 100000;
  }else if (cells.get(cellIndex(pos)).probability >0.49 && cells.get(cellIndex(pos)).probability <=0.9) {
    return 2;
  }else{
    return 1;
  }
  // return(1-cells.get(cellIndex(pos)).probability)*0.5;
}

float pathDist(PVector a, PVector b){
  return PVector.sub(a,b).mag();
}

public int getIndexOfMin(ArrayList<Node> nodes) {
    float min = Float.MAX_VALUE;
    int index = -1;
    for (int i = 0; i < nodes.size(); i++) {
        Float f = nodes.get(i).globalValue;
        if (Float.compare(f, min) < 0) {
            min = f.floatValue();
            index = i;
        }
    }
    return index;
}

void modifyNode(int id_, int parent_, boolean visited_, float globalValue_, float localValue_){
  Node tempNode = nodes.get(id_);
  tempNode.parent       = parent_;
  tempNode.pos          = indexPos(id_);
  tempNode.visited      = visited_;
  tempNode.globalValue  = globalValue_;
  tempNode.localValue   = localValue_;
}
