class Node {
    //Variables
    boolean obstacle;
    boolean visited;
    PVector pos;
    int id;
    int parent;
    float globalValue;
    float localValue;

    Node(PVector pos_){
        obstacle        = false;
        visited         = false;
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = 0;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_){
        obstacle        = false;
        visited         = false;
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = parent_;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_, float globalValue_, float localValue_){
        obstacle        = false;
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
ArrayList<Node> nodesChecked = new ArrayList<Node>();
ArrayList<Node> nodesToCheck = new ArrayList<Node>();
// PVector startPos;
// PVector goalPos;
PVector[]       checkPos;
Node            neigbourNode;



void recalculatePath(Bot bot){
    // println("Bot "+bot.botID + " is stuck. Recalculating route");
    path.clear();
    nodesChecked.clear();
    nodesToCheck.clear();

    boolean finished = false;
    PVector startPos = cellPos(bot.pos);
    PVector goalPos  = cellPos(bot.target_pos);
    println("bot pos: " +startPos);
    println("goal pos: " + goalPos);
    Node startNode  = new Node(startPos, 0, pathDist(startPos, goalPos), cellRealValue(startPos));
    Node currentNode = startNode;
    //Add first waypoint to path
    nodesToCheck.add(startNode);

    //Loop until algorithm is complete
    //Find the while loop condition later
    int ii = 0;
    // while(nodesToCheck.size()>0 && currentNode.pos != goalPos || ii<50){
    // while(pathDist(currentNode.pos, goalPos)>0 || ii<50){
    // while(!(pathDist(currentNode.pos, goalPos)==0)&&ii<40){
    while(!finished){
    // while(!finished&&ii<40){
        // println("Distance to goal:" + pathDist(currentNode.pos, goalPos));
    // while(nodesToCheck.size()>0){
        int indexOfCurrentNode = getIndexOfMin(nodesToCheck);
        //Get the top cell of the nodesToCheckList
        currentNode = nodesToCheck.get(indexOfCurrentNode);



        while(currentNode.visited){
            for(int j = 0; j<nodesChecked.size();j++){
                if(nodesChecked.get(j).id == currentNode.id){
                    // println("node has been visited, skipping");
                    nodesToCheck.remove(indexOfCurrentNode);
                    break;
                }
            }
            indexOfCurrentNode = getIndexOfMin(nodesToCheck);
            currentNode = nodesToCheck.get(indexOfCurrentNode);
        }


        //Calculate index of target cells
        checkPos = new PVector[4];
        // for ( int i = 0; i<4; i++) {
        //   targetCell[i]=new PVector(0, 0);
        // }
        //n
        checkPos[0] = new PVector(currentNode.pos.x, currentNode.pos.y-1);
        //s
        checkPos[1] = new PVector(currentNode.pos.x, currentNode.pos.y+1);
        //e
        checkPos[2] = new PVector(currentNode.pos.x+1, currentNode.pos.y);
        //w
        checkPos[3] = new PVector(currentNode.pos.x-1, currentNode.pos.y);

        // println("-----");
        // println("Bot position");
        // println(currentNode.pos + " index: " + cellIndex(currentNode.pos));
        // println("Target positions");
        // for(int i = 0; i<4;i++){
        // println(checkPos[i]+ " index: " + cellIndex(checkPos[i]));
        // }
        // println("-----");

        //Check all neighbours of current cell
        for(int i = 0; i<4;i++){
            boolean update = false;
            // println(cellPos(checkPos[i]));
            if(pathDist(checkPos[i], goalPos)==0){
                finished = true;
                println("FINISHED!!!!!!!!!");
                // nodesChecked.add(new Node(checkPos[i],currentNode.id));
            }else{
            // println("***Next neigbour***");
            // Check if target is a new node
            boolean nodeExist = false;
            for(int j = 0; j<nodesToCheck.size();j++){
                // println("comparing cell:" + cellIndex(checkPos[i]) + "With check stack");
                if(nodesToCheck.get(j).id == cellIndex(checkPos[i])){
                    nodeExist = true;
                    // println("neighbour node has been added before, may be updated.");
                    neigbourNode = nodesToCheck.get(j);
                    update = true;
                    // println("node aleady exist");
                    // for(int k = 0; k<nodesToCheck.size();k++){
                    //     println("node id in check stack:" + nodesToCheck.get(k).id);
                    // }
                    // println(checkPos[i]);
                    break;
                }
            }

            if(!nodeExist){
                boolean visited = false;
                for(int j = 0; j<nodesChecked.size();j++){
                    if(nodesChecked.get(j).id == cellIndex(checkPos[i])){
                        // println("node has been visited, skipping");
                        visited = true;
                        break;
                    }
                }
                if(!visited && cellRealValue(checkPos[i])<10 ){
                    //New node discovered, add it to the list
                    // println("NEW NODE. index:" + cellIndex(checkPos[i]));
                    neigbourNode = new Node(checkPos[i]);
                    update = true;
                }
            }
            // println("currentlocal: ("+currentNode.localValue+") + value: ("+cellRealValue(checkPos[i])+") = "+ (currentNode.localValue + cellRealValue(checkPos[i])) + " < neighbourlocal: ("+neigbourNode.localValue+")");
            // println("currentlocal: ("+currentNode.localValue+" <= neighbourlocal: ("+cellRealValue(checkPos[i])+")");
            // if(update && currentNode.localValue<=cellRealValue(checkPos[i])){
            if(update && pathDist(currentNode.pos, startPos)<=pathDist(checkPos[i], startPos)){
            // if(currentNode.localValue+cellRealValue(checkPos[i])<neigbourNode.localValue){
                // println("+++node is closer, editing+++");
                neigbourNode.parent      = currentNode.id;
                // println("+++Parent:" + currentNode.id);
                // neigbourNode.localValue  = cellRealValue(checkPos[i]);
                neigbourNode.localValue  = pathDist(checkPos[i], startPos);
                
                // println("+++Local value:" + cellRealValue(checkPos[i]));
                // neigbourNode.localValue  = currentNode.localValue+cellRealValue(checkPos[i]);
                // println("+++Local value:" + currentNode.localValue+cellRealValue(checkPos[i]));
                neigbourNode.globalValue = pathDist(neigbourNode.pos, goalPos) + neigbourNode.localValue;
                // println("+++Distance to goal:" + pathDist(neigbourNode.pos, goalPos));
                // println("+++Global value:" + (pathDist(neigbourNode.pos, goalPos) + neigbourNode.localValue));
                // println("updating node with id:" + cellIndex(checkPos[i]) + " in check stack");
                nodesToCheck.add(neigbourNode);
                // println("+++Neighbour node edit complete+++");
            }else{
                // println("node is not closer, skipping");
            }


            }



        }

        //all neighbours visited, remove the current node from the nodesToCheck list and add it to the nodesChecked list
        // println("Adding the current node to nodesChecked and removing from nodesToCheck");
        currentNode.visited = true;
        nodesChecked.add(currentNode);
        // nodesToCheck.remove(currentNode);
        // println("***Nodes to check***");
        // for(int i = 0; i<nodesToCheck.size();i++){
        //     println(nodesToCheck.get(i).pos + ", global value: " + nodesToCheck.get(i).globalValue);
        // }




        //Use the A* algorithm to calculate a new path to the target
        //Variables

        // if(pathDist(currentNode.pos, goalPos)==0){
            
        //     // break;
        // }

        


        ii+=1;
    }
    // println("***Pathfinder finished***");

    // DEBUG: print the nodes to check list
    println("startPos");
    println(startPos);
    println("goalPos");
    println(goalPos);
    println("***Nodes checked***");
    for(int i = 0; i<nodesChecked.size();i++){
        // println(nodesChecked.get(i).pos + ", global value: " + nodesChecked.get(i).globalValue);
        println(nodesChecked.get(i).id + ", parent: " + nodesChecked.get(i).parent);
    }
    int pathIndex = 0;
    int goalIndex = cellIndex(goalPos);
    int startIndex = cellIndex(startPos);
    boolean pathError = false;
    ii = 0;
    pathIndex = nodesChecked.size()-1;
    for (int i = 0; i < nodesChecked.size(); i++) {
        if (goalIndex == nodesChecked.get(i).id) {
            pathIndex = i;
        }
    } 

    while(!(pathIndex == startIndex) && ii<100){
        currentNode = nodesChecked.get(pathIndex);
        path.add(currentNode);
        for (int i = 0; i < nodesChecked.size(); i++) {
            if (currentNode.parent == nodesChecked.get(i).id) {
                pathIndex = i;
            }
        }   
        ii+=1;        
    }





    // for(int i = 0; i<path.size();i++){
    //     fill(0,255,0);
    //     ellipse(nodesToCheck.get(i).pos.x*cellSize, nodesToCheck.get(i).pos.y*cellSize, 3, 3);
    // }


    
}

void drawWayPoints(){
    for(int i = 0; i<nodesChecked.size();i++){
        fill(0,255,0);
        ellipse(nodesChecked.get(i).pos.x*cellSize+cellSize/2, nodesChecked.get(i).pos.y*cellSize+cellSize/2, 3, 3);

    }
}