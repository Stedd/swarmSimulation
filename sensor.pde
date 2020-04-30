class Sensor {
    PVector     sensorPos;

    PVector[]   beamStartPoints;
    PVector[]   beamEndPoints;
    PVector[]   beamEndPointsIntersect;

    float       minRange;
    float       maxRange;
    float       span;
    float       noise;
    float       fov;
    float       ang;
    float       angOffset;

    int         numberOfBeams;

    //constructor
    Sensor(float minRange_, float maxRange_, float noise_, int numberOfBeams_, float fov_, float angOffset_){
        minRange                = minRange_*fpixelsPerMeter;
        maxRange                = maxRange_*fpixelsPerMeter;
        span                    = maxRange-minRange;
        noise                   = noise_;
        numberOfBeams           = numberOfBeams_;
        fov                     = (fov_*PI)/180;
        angOffset               = (angOffset_*PI)/180;
        
        sensorPos               = new PVector(0,0);

        beamStartPoints         = new PVector[numberOfBeams];
        beamEndPoints           = new PVector[numberOfBeams];
        beamEndPointsIntersect  = new PVector[numberOfBeams];
        for ( int i = 0; i<numberOfBeams; i++) {
            beamStartPoints[i]          = new PVector(0, 0);
            beamEndPoints[i]            = new PVector(0, 0);
            beamEndPointsIntersect[i]   = new PVector(0, 0);
        }
    }

    void update(){
        float beamAng           = ang + angOffset;
        for ( int i = 0; i<numberOfBeams; i++) {
            if (numberOfBeams>1) {
                beamAng         = ang + angOffset - (fov/2) + i * (fov/(float(numberOfBeams)-1));
            }
            beamStartPoints[i]  = new PVector(sensorPos.x + (minRange*cos(beamAng)) + ((minRange)*sin(beamAng)), sensorPos.y + (minRange*-sin(beamAng)) + ((minRange)*cos(beamAng)));
            beamEndPoints[i]    = new PVector(sensorPos.x + (maxRange*cos(beamAng)) + ((maxRange)*sin(beamAng)), sensorPos.y + (maxRange*-sin(beamAng)) + ((maxRange)*cos(beamAng)));
            // beamEndPointsIntersect[i]   = beamEndPoints[i];
        }
    }

    void draw(){
      for ( int i = 0; i<numberOfBeams; i++) {
        if(PVector.sub(beamEndPointsIntersect[i],sensorPos).mag()>PVector.sub(beamStartPoints[i],sensorPos).mag()){
        line(beamStartPoints[i].x, beamStartPoints[i].y, beamEndPointsIntersect[i].x, beamEndPointsIntersect[i].y);
        }
      }
    }

}