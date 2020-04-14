public float tanh(float x_) {
  x_ *= 1e-2;
  return (exp(x_)-exp(-x_))/(exp(x_)+exp(-x_));
}

public float sat(float val_, float min_, float max_) {
  float deadband_ = 0.1f;
  if (val_>max_) {
    val_ = max_;
  } else if (val_<min_) {
    val_ = min_;
  }
  return val_;
}
