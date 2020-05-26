PVector[] goal_Pos = new PVector[numberOfBots];

void initExploration(){


    // for ( int i = 0; i<240; i++) {
    //   int formationWidth  = 20;
    //   float startX = 200 + i%(formationWidth)*bot_Size;
    //   float startY = 100 + bot_Size * floor(i/(formationWidth));
    //   fill(0,125,125);
    //   ellipse(startX, startY, 10, 10);
    // }

    
    for (int i = 0; i<numberOfBots; i++){
        goal_Pos[i] = new PVector(1,1);
    }
    
}

void updateAllTagets(){
    for (int i = 0; i<numberOfBots; i++){
        goal_Pos[i] = new PVector(random(200,1000), random(200,600));
    }
}

// void updateTarget(Bot bot, int i){
//     goal_Pos[i] = new PVector(random(100,width-100), random(100,height-100));
// }

void updateTarget(Bot bot, int i){

    int numberOfscanPoints  = 16;
    int roiSize             = 3*icellPerMeter;
    int roiTarget           = -1;
    float roiSum            = 0;
    float roiSumLast        = 0;
    float scanDist          = 2.5*fpixelsPerMeter;
    PVector cellScanPoint   = new PVector(0, 0);
    PVector[] scanPoints    = new PVector[numberOfscanPoints];
    for ( int j = 0; j<numberOfscanPoints; j++) {
      scanPoints[j]=new PVector(0, 0);
    }
    while(roiTarget==-1){
    int k = 0;
    for (float ang = 0; ang <= TWO_PI-0.1; ang+=(TWO_PI/numberOfscanPoints)) {
        scanPoints[k]  = new PVector(bot.pos.x + (scanDist*cos(ang)) + ((scanDist)*sin(ang)), bot.pos.y + (scanDist*-sin(ang)) + ((scanDist)*cos(ang)));
        roiSum = 0;
        
        // if(scanPoints[k].x+5*fpixelsPerMeter-((roiSize/2)*cellSize) > 0 && scanPoints[k].x-5*fpixelsPerMeter+((roiSize/2)*cellSize) < width && scanPoints[k].y+5*fpixelsPerMeter-((roiSize/2)*cellSize) > 0 && scanPoints[k].y-5*fpixelsPerMeter+((roiSize/2)*cellSize) < height){
        if(scanPoints[k].x-((roiSize/2)*cellSize) > 0+2.5*fpixelsPerMeter && scanPoints[k].x+((roiSize/2)*cellSize) < width-2.5*fpixelsPerMeter && scanPoints[k].y-((roiSize/2)*cellSize) > 0+2.5*fpixelsPerMeter && scanPoints[k].y+((roiSize/2)*cellSize) < height-2.5*fpixelsPerMeter){
            // cellIndex(cellPos(scanPoints[k]));
            cellScanPoint = cellPos(scanPoints[k]);
            
            for (int x = int(cellScanPoint.x)-roiSize/2; x < int(cellScanPoint.x)+roiSize/2; ++x) {
                for (int y = int(cellScanPoint.y)-roiSize/2; y < int(cellScanPoint.y)+roiSize/2; ++y) {
                    //iterate through roi and sum 
                    float prob = cells.get(cellIndex(new PVector(x,y))).probability;
                    if( 0.95 > prob && prob > 0.1){
                        roiSum+=1;
                    }
                    // roiSum+=1-cells.get(cellIndex(new PVector(x,y))).probability;
                    
                }
            }

            boolean tooClose = false;
            for (int l = 0; l < numberOfBots; ++l) {
                if(l!=i && PVector.sub(goal_Pos[l], scanPoints[k]).mag() < (3*fpixelsPerMeter)){
                    tooClose = true;
                    println("target is too close to other bots target");
                }
                
            }


            if (roiSum>roiSumLast && roiSum>300 && cells.get(cellIndex(cellScanPoint)).probability>0.3 && !tooClose){
                roiTarget = k;
                roiSumLast = roiSum;
            }

            println(roiSum);
            ellipse(scanPoints[k].x,scanPoints[k].y,roiSize,roiSize);
            println(k);
            println(ang);
            println(scanPoints[k]);
            
        }
        k++;
    }
    
    if(roiTarget==-1){
        scanDist += 1*fpixelsPerMeter;
    }
    
    }

    // goal_Pos[i] = new PVector(random(100,width-100), random(100,height-100));
    println("setting goal");
    println(roiTarget);
    goal_Pos[i] = scanPoints[roiTarget];
}


