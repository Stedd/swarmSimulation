class Node {
    //Variables
    PVector pos;
    int id;
    int parent;
    float globalValue;
    float localValue;

    Node(PVector pos_){
        pos             = pos_;
        id              = cellIndex(int(pos.x),int(pos.y);
        parent          = 0;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_){
        pos             = pos_;
        id              = cellIndex(int(pos.x),int(pos.y);
        parent          = parent_;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_, float globalValue_, float localValue_){
        pos             = pos_;
        id              = cellIndex(int(pos.x),int(pos.y);
        parent          = parent_;
        globalValue     = globalValue_;
        localValue      = localValue_;
    }
}

//Variables
ArrayList<Node> path         = new ArrayList<Node>();   //todo: init properly for each bot
ArrayList<Node> nodesToCheck = new ArrayList<Node>();


void recalculatePath(Bot bot){
    path.clear();
    nodesToCheck.clear();
    
    PVector startPos   = bot.pos;
    PVector goalPos    = bot.target_pos;

    Node startNode  = new Node(startPos, 0, pathDist(startPos, goalPos), cellValue(startPos);

    //Add first waypoint to path
    path.add(startNode);
    nodesToCheck.add(startNode);

    //Loop until algorithm is complete
    //Find the while loop condition later

    //Get the top cell of the nodesToCheckList
    currentNode = nodesToCheck.get(0);
    
    //Calculate index of target cells
    PVector[] targetNode = new PVector[4];
    // for ( int i = 0; i<4; i++) {
    //   targetCell[i]=new PVector(0, 0);
    // }
    //n
    targetNode[0] = new PVector(currentNode.pos.x, currentNode.pos.y-1);
    //s
    targetNode[1] = new PVector(currentNode.pos.x, currentNode.pos.y+1);
    //e
    targetNode[2] = new PVector(currentNode.pos.x+1, currentNode.pos.y);
    //w
    targetNode[3] = new PVector(currentNode.pos.x-1, currentNode.pos.y);

    //Check all neighbours of current cell
    for(int i = 0; i<4;i++){

        //Check if target is a new node
        for(j = 0; j<nodesToCheck.size();j++){
            if(nodesToCheck.get(j).id != targetNode[i].id){
                //New node discovered, add it to the list
                newNode = new Node(targetNode[i]);
            }
        }

    if(currentNode.localValue+cellValue(targetNode[i])<newNode.localValue){
        newNode.parent      = currentNode.id;
        newNode.localValue  = cellValue(targetNode[i]);
        newNode.globalValue = pathDist(startPos, goalPos) + newNode.localValue;
        nodesToCheck.add(newNode);
    }

    }

    //sort nodesToCheckList

    println(nodesToCheck.get(0).localValue);

    //Use the A* algorithm to calculate a new path to the target
    println("Bot "+bot.botID + " is stuck. Recalculating route");
    //Variables
}