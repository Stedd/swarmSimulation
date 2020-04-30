class Sensor {
    float minRange;
    float maxRange;
    float span;
    float beamLength;
    int   numberOfBeams;
    PVector[] beamStartPoints;
    PVector[] beamEndPoints;
    PVector[] beamEndPointsIntersect;

    //constructor
    Sensor(float minRange_, float maxRange_, int numberOfBeams_){
        minRange                = minRange_*fpixelsPerMeter;
        maxRange                = maxRange_*fpixelsPerMeter;
        span                    = maxRange-minRange;
        beamLength              = 20;
        numberOfBeams           = numberOfBeams_;

        beamStartPoints         = new PVector[numberOfBeams];
        beamEndPoints           = new PVector[numberOfBeams];
        beamEndPointsIntersect  = new PVector[numberOfBeams];
        for ( int i = 0; i<numberOfBeams; i++) {
            beamStartPoints[i]          = new PVector(0, 0);
            beamEndPoints[i]            = new PVector(0, 0);
            beamEndPointsIntersect[i]   = new PVector(0, 0);
        }
    }
}