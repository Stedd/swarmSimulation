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
    goal_Pos[i] = new PVector(random(200,1000), random(200,600));
}


