
//Variables
boolean Separation, Cohesion, Alignment, DepthCamera, Ultrasonic, Infrared;
float bot_Size;

//Swarm rule weights
float Separation_weight, Cohesion_weight, Alignment_weight, DepthCamera_weight, Ultrasonic_weight, Infrared_weight;

//Debug
boolean Draw_Map, Sensor_zone, Detect_Zone, Safe_Zone, Resultant;

void buttons() {
  //Buttons
  cp5 = new ControlP5(this);

  cp5.addSlider("bot_Size")
    .setValue(57)
    .setPosition(20, 10)
    //.setSize(20, 60)
    .setRange(10, 100)
    ;

  cp5.addToggle("Separation")
    .setValue(1)
    .setPosition(20, 50)
    .setSize(20, 20)
    ;

  cp5.addSlider("Separation_weight")
    .setValue(0.07)
    .setPosition(60, 50)
    //.setSize(20, 60)
    .setRange(0, 0.1)
    ;

  cp5.addToggle("Cohesion")
    .setValue(1)
    .setPosition(20, 100)
    .setSize(20, 20)
    ;

  cp5.addSlider("Cohesion_weight")
    .setValue(0.09)
    .setPosition(60, 100)
    //.setSize(20, 60)
    .setRange(0, 0.3)
    ;

  cp5.addToggle("Alignment")
    .setValue(0)
    .setPosition(20, 150)
    .setSize(20, 20)
    ;

  cp5.addSlider("Alignment_weight")
    .setValue(40)
    .setPosition(60, 150)
    //.setSize(20, 60)
    .setRange(0, 300)
    ;

  cp5.addToggle("DepthCamera")
    .setValue(1)
    .setPosition(20, 200)
    .setSize(20, 20)
    ;

  cp5.addSlider("DepthCamera_weight")
    .setValue(0.39)
    .setPosition(60, 200)
    //.setSize(20, 60)
    .setRange(0, 5)
    ;

  cp5.addToggle("Ultrasonic")
    .setValue(1)
    .setPosition(20, 250)
    .setSize(20, 20)
    ;

  cp5.addSlider("Ultrasonic_weight")
    .setValue(5)
    .setPosition(60, 250)
    //.setSize(20, 60)
    .setRange(0, 5)
    ;

  cp5.addToggle("Infrared")
    .setValue(1)
    .setPosition(20, 300)
    .setSize(20, 20)
    ;

  cp5.addSlider("Infrared_weight")
    .setValue(5)
    .setPosition(60, 300)
    //.setSize(20, 60)
    .setRange(0, 5)
    ;

  cp5.addToggle("Draw_Map")
    .setValue(1)
    .setPosition(20, height-200)
    .setSize(20, 20)
    ;

  cp5.addToggle("Sensor_zone")
    .setValue(1)
    .setPosition(20, height-160)
    .setSize(20, 20)
    ;

  cp5.addToggle("Detect_Zone")
    .setValue(0)
    .setPosition(20, height-120)
    .setSize(20, 20)
    ;

  cp5.addToggle("Safe_Zone")
    .setValue(0)
    .setPosition(20, height-80)
    .setSize(20, 20)
    ;

  cp5.addToggle("Resultant")
    .setValue(1)
    .setPosition(20, height-40)
    .setSize(20, 20)
    ;
}
