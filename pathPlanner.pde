class Node {
    //Variables
    int     id;
    int     parent;
    PVector pos;
    boolean visited;
    float   globalValue;
    float   localValue;

    Node(int id_){
        visited         = false;
        pos             = indexPos(id_);
        id              = id_;
        parent          = 0;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(int id_, int parent_, float globalValue_, float localValue_){
        visited         = false;
        pos             = indexPos(id_);
        id              = id_;
        parent          = parent_;
        globalValue     = globalValue_;
        localValue      = localValue_;
    }

    Node(PVector pos_){
        visited         = false;
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = 0;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_){
        visited         = false;
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = parent_;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_, float globalValue_, float localValue_){
        visited         = false;
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = parent_;
        globalValue     = globalValue_;
        localValue      = localValue_;
    }
}

//Variables
ArrayList<Node> path         = new ArrayList<Node>();   //todo: init properly for each bot
ArrayList<Node> nodes        = new ArrayList<Node>();
ArrayList<Node> nodesChecked = new ArrayList<Node>();
ArrayList<Node> nodesToCheck = new ArrayList<Node>();
// PVector startPos;
// PVector goalPos;
PVector[]       neighborPos;
int[]           neighborIndex;
Node            currentNode;
Node            neighborNode;

PVector startPos = new PVector(0,0);
PVector goalPos = new PVector(0,0);  


void recalculatePath(Bot bot){
    println("Bot "+bot.botID + " is stuck. Recalculating route");
    path.clear();
    nodes.clear();
    nodesChecked.clear();
    nodesToCheck.clear();
    boolean finished = false;
    
    //Move from pixel to cell coordinates
    int startIndex = cellIndex(cellPos(bot.pos));
    int goalIndex  = cellIndex(cellPos(bot.target_pos));
    // println("Start index: " + startIndex);
    // println("Goal index: " + goalIndex);
    startPos = indexPos(startIndex);
    goalPos = indexPos(goalIndex);   
    // println("Start pos: " + bot.pos);
    // println("Goal pos: " + bot.target_pos);
    

    for ( int i = 0; i<((width/cellSize)*(height/cellSize)); i++) {
        nodes.add(new Node(i));
    }

    //Add first waypoint to path
    modifyNode(startIndex, 0, false, pathDist(startPos, goalPos), 0);
    nodesToCheck.add(nodes.get(startIndex));
    neighborIndex    = new int[4];

    int ii = 0;
    while(!finished && nodesToCheck.size()>0 &&  ii<1500){
        // for(int i = 0; i<nodesToCheck.size();i++){
        //     println(nodesToCheck.get(i).pos + ", global value: " + nodesToCheck.get(i).globalValue+ ", id: " + nodesToCheck.get(i).id);
        //     // println(nodesChecked.get(i).id + ", parent: " + nodesChecked.get(i).parent);
        // }

        currentNode = nodes.get(nodesToCheck.get(getIndexOfMin(nodesToCheck)).id);
        while(currentNode.visited){
            println("node is already visited, removing");
            nodesToCheck.remove(getIndexOfMin(nodesToCheck));
            currentNode = nodes.get(nodesToCheck.get(getIndexOfMin(nodesToCheck)).id);
        }

        

        // println("node: " + currentNode.id + " selected");
        //Calculate index of target cells

        for (int i = 0; i < 4; ++i) {
            neighborIndex[i] = -1;
        }

        if(currentNode.pos.y>0){
            neighborIndex[0] = cellIndex(new PVector(currentNode.pos.x, currentNode.pos.y-1));
        }
        if(currentNode.pos.y<(height/cellSize)-1){
            neighborIndex[1] = cellIndex(new PVector(currentNode.pos.x, currentNode.pos.y+1));
        }
        if(currentNode.pos.x<(width/cellSize)-1){
            neighborIndex[2] = cellIndex(new PVector(currentNode.pos.x+1, currentNode.pos.y));
        }
        if(currentNode.pos.x>0){
            neighborIndex[3] = cellIndex(new PVector(currentNode.pos.x-1, currentNode.pos.y));
        }
        
        
        

        // for (int i = 0; i < 4; ++i) {
        //     println(indexPos(neighborIndex[i]));
        // }

        //     // println("-----");
        //     // println("Bot position");
        //     // println(currentNode.pos + " index: " + cellIndex(currentNode.pos));
        //     // println("Target positions");
        //     // for(int i = 0; i<4;i++){
        //     // println(neighborPos[i]+ " index: " + cellIndex(neighborPos[i]));
        //     // }
        //     // println("-----");

        //Check all neighbours of current cell
        for(int i = 0; i<4;i++){
            if(neighborIndex[i]!=-1){
                neighborNode = nodes.get(neighborIndex[i]);
                // modifyNode(neighborIndex[i], currentNode.id, false, pathDist(neighborNode.pos, goalPos) + cellRealValue(neighborIndex[i]), cellRealValue(neighborIndex[i]));

                // println("finished criteria: Neighbor id " + neighborIndex[i] + ". Goal id " + goalIndex);
                if(neighborIndex[i] == goalIndex){
                    
                    finished = true;
                    println("FINISHED!!!!!!!!!");
                    modifyNode(neighborIndex[i], currentNode.id, false, pathDist(neighborNode.pos, goalPos) + cellRealValue(neighborIndex[i]), cellRealValue(neighborIndex[i]));
                    nodesChecked.add(neighborNode);
                    break;
                }else{
                    // println("***Next neigbour***");
                    // Check if target is a new node

                    // boolean nodeExist = false;
                    // for(int j = 0; j<nodesToCheck.size();j++){
                    //     // println("comparing cell:" + cellIndex(neighborPos[i]) + "With check stack");
                    //     if(nodesToCheck.get(j).id == cellIndex(neighborPos[i])){
                    //         nodeExist = true;
                    //         // println("neighbour node has been added before, may be updated.");
                    //         neighborNode = nodesToCheck.get(j);
                    //         // println("node aleady exist");
                    //         // for(int k = 0; k<nodesToCheck.size();k++){
                    //         //     println("node id in check stack:" + nodesToCheck.get(k).id);
                    //         // }
                    //         // println(neighborPos[i]);
                    //         break;
                    //     }
                    // }

                    // if(!nodeExist){
                    //     neighborNode = new Node(neighborPos[i],currentNode.id);
                    // }
                    // println("currentlocal: ("+currentNode.localValue+") + value: ("+cellRealValue(neighborPos[i])+") = "+ (currentNode.localValue + cellRealValue(neighborPos[i])) + " < neighbourlocal: ("+neighborNode.localValue+")");
                    // println("currentlocal: ("+currentNode.localValue+" <= neighbourlocal: ("+cellRealValue(neighborPos[i])+")");
                    // if(update && currentNode.localValue<=cellRealValue(neighborPos[i])){
                    // if(pathDist(currentNode.pos, startPos)<=pathDist(neighborNode.pos, startPos)){
                    // if(currentNode.localValue<=cellRealValue(neighborIndex[i])){
                    if(currentNode.localValue<=neighborNode.localValue){
                        // println("+++node is closer, editing+++");
                        modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos) + cellRealValue(neighborIndex[i]), pathDist(neighborNode.pos, startPos));
                        if(!neighborNode.visited && cellRealValue(neighborIndex[i])<1000){
                            nodesToCheck.add(neighborNode);
                        }
                        nodesChecked.add(neighborNode);
                    // if(currentNode.localValue+cellRealValue(neighborPos[i])<neighborNode.localValue){
                        // println("+++node is closer, editing+++");
                        // modifyNode(neighborIndex[i], currentNode.id, false, 1, 1);
                        // modifyNode(neighborIndex[i], currentNode.id, false, pathDist(neighborNode.pos, goalPos) + neighborNode.localValue, pathDist(neighborPos[i], startPos));

                        // neighborNode.parent      = currentNode.id;
                        // println("+++Parent:" + currentNode.id);
                        // neighborNode.localValue  = cellRealValue(neighborPos[i]);
                        // neighborNode.localValue  = pathDist(neighborPos[i], startPos);
                        
                        // println("+++Local value:" + cellRealValue(neighborPos[i]));
                        // neighborNode.localValue  = currentNode.localValue+cellRealValue(neighborPos[i]);
                        // println("+++Local value:" + currentNode.localValue+cellRealValue(neighborPos[i]));
                        // neighborNode.globalValue = pathDist(neighborNode.pos, goalPos) + neighborNode.localValue;
                        // println("+++Distance to goal:" + pathDist(neighborNode.pos, goalPos));
                        // println("+++Global value:" + (pathDist(neighborNode.pos, goalPos) + neighborNode.localValue));
                        // println("updating node with id:" + cellIndex(neighborPos[i]) + " in check stack");
                        // nodesToCheck.add(neighborNode);
                        // println("+++Neighbour node edit complete+++");
                    }else{
                        // println("node is not closer, skipping");
                    }

                    currentNode.visited = true;
                    nodesToCheck.remove(currentNode);
                
                }

                // println(neighborNode.id);
                // println(neighborNode.parent);
                // println(neighborNode.visited);
                // println(neighborNode.globalValue);
                // println(neighborNode.localValue);
            }
        }

        //     //all neighbours visited, remove the current node from the nodesToCheck list and add it to the nodesChecked list
        //     // println("Adding the current node to nodesChecked and removing from nodesToCheck");
        //     currentNode.visited = true;
        //     nodesChecked.add(currentNode);
        //     // nodesToCheck.remove(currentNode);
        //     // println("***Nodes to check***");
        //     // for(int i = 0; i<nodesToCheck.size();i++){
        //     //     println(nodesToCheck.get(i).pos + ", global value: " + nodesToCheck.get(i).globalValue);
        //     // }




        //     //Use the A* algorithm to calculate a new path to the target
        //     //Variables

        //     // if(pathDist(currentNode.pos, goalPos)==0){
                
        //     //     // break;
        //     // }

        


        ii+=1;
    }
    println("***Pathfinder finished***");

    // // DEBUG: print the nodes to check list
    // println("startPos");
    // println(startPos);
    // println("goalPos");
    // println(goalPos);
    // println("***Nodes checked***");
    // for(int i = 0; i<nodesChecked.size();i++){
    //     println(nodesChecked.get(i).pos + ", global value: " + nodesChecked.get(i).globalValue);
    //     // println(nodesChecked.get(i).id + ", parent: " + nodesChecked.get(i).parent);
    // }
    
    // int goalIndex = cellIndex(goalPos);
    // int startIndex = cellIndex(startPos);
    // boolean pathError = false;
    // ii = 0;
    // pathIndex = nodesChecked.size()-1;
    // for (int i = 0; i < nodesChecked.size(); i++) {
    //     if (goalIndex == nodesChecked.get(i).id) {
    //         pathIndex = i;
    //     }
    // } 
    int pathIndex = goalIndex;
    while(!(pathIndex == startIndex) && ii<500){
        currentNode = nodes.get(pathIndex);
        path.add(currentNode);
        pathIndex = currentNode.parent;
        ii+=1;        
    }


    // println("goal position:" + cellPos(bot.target_pos));
    // println("start position:" + cellPos(bot.pos));
    // //     int startIndex = cellIndex(cellPos(bot.pos));
    // // int goalIndex  = cellIndex(cellPos(bot.target_pos));
    // println("****Path****");
    // for(int i = 0; i<path.size();i++){
    //     println(path.get(i).pos + ", global value: " + path.get(i).globalValue);
    //     println(path.get(i).id + ", parent: " + path.get(i).parent);
    // }



    // // for(int i = 0; i<path.size();i++){
    // //     fill(0,255,0);
    // //     ellipse(nodesToCheck.get(i).pos.x*cellSize, nodesToCheck.get(i).pos.y*cellSize, 3, 3);
    // // }


    
}

void drawPoints(){
    fill(0,255,0);
    ellipse(startPos.x*cellSize + cellSize/2, startPos.y*cellSize + cellSize/2,30,30);
    fill(0,0,255);
    ellipse(goalPos.x*cellSize + cellSize/2, goalPos.y*cellSize + cellSize/2,30,30);
}

void drawChecked(){
    for(int i = 0; i<nodesChecked.size();i++){
        fill(255,0,255);
        ellipse(nodesChecked.get(i).pos.x*cellSize+cellSize/2, nodesChecked.get(i).pos.y*cellSize+cellSize/2, 6, 6);

    }
}

void drawWayPoints(){
    for(int i = 0; i<path.size()-1;i++){
        strokeWeight(3);
        fill(0,255,0);
        line(path.get(i).pos.x*cellSize+cellSize/2, path.get(i).pos.y*cellSize+cellSize/2, path.get(i+1).pos.x*cellSize+cellSize/2, path.get(i+1).pos.y*cellSize+cellSize/2); 

    }
}