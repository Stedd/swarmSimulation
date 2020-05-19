PVector[] goal_Pos = new PVector[numberOfBots];

void initExploration(){
    for (int i = 0; i<numberOfBots; i++){
        goal_Pos[i] = new PVector(random(200,1000), random(200,600));
    }
    
}

void updateAllTagets(){
    for (int i = 0; i<numberOfBots; i++){
        goal_Pos[i] = new PVector(random(200,1000), random(200,600));
    }
}

void updateTarget(int i){
    PVector tmpPos = new PVector(random(200,1000), random(200,600));
    // PVector tmpPosCell = new PVector();
    // tmpPosCell.x = tmpPos.x;
    // tmpPosCell.y = tmpPos.y;
    // tmpPosCell.mult(1/cellSize);

    
    // if(!(cells.get(cellIndex(tmpPosCell)).mapValue == 0)){
        goal_Pos[i] = tmpPos;
    // }else {
    //     println("new target not valid");
    // }
}


