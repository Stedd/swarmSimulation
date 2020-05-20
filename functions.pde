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
  return 0;
}