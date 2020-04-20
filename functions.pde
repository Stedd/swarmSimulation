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

void fps() {
  fcount += 1;
  int m = millis();
  if (m - lastm > 1000 * fint) {
    frate = float(fcount) / fint;
    fcount = 0;
    lastm = m;
    //println("fps: " + frate);
  }
  fill(0);
  textFont(f, 16);
  text("fps: " + frate, width-100, 20);
}

void keyReleased() {
  if (key=='r' || key == 'R') {
  swarmsystem.Init();
  }
}
