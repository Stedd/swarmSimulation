class Node {
    //Variables
    PVector pos;
    int id;
    int parent;
    float globalValue;
    float localValue;

    Node(PVector pos_){
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = 0;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_){
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = parent_;
        globalValue     = Float.POSITIVE_INFINITY;
        localValue      = Float.POSITIVE_INFINITY;
    }

    Node(PVector pos_, int parent_, float globalValue_, float localValue_){
        pos             = pos_;
        id              = cellIndex(pos);
        parent          = parent_;
        globalValue     = globalValue_;
        localValue      = localValue_;
    }
}

//Variables
ArrayList<Node> path         = new ArrayList<Node>();   //todo: init properly for each bot
ArrayList<Node> nodesToCheck = new ArrayList<Node>();
// PVector startPos;
// PVector goalPos;
PVector[]       checkPos;
Node            newNode;



void recalculatePath(Bot bot){
    println("Bot "+bot.botID + " is stuck. Recalculating route");
    path.clear();
    nodesToCheck.clear();
    println(bot.pos);
    PVector startPos = cellPos(bot.pos);
    PVector goalPos  = cellPos(bot.target_pos);

    Node startNode  = new Node(startPos, 0, pathDist(startPos, goalPos), cellValue(startPos));

    //Add first waypoint to path
    path.add(startNode);
    nodesToCheck.add(startNode);

    //Loop until algorithm is complete
    //Find the while loop condition later

    //Get the top cell of the nodesToCheckList
    Node currentNode = nodesToCheck.get(0);

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

    println("-----");
    println("Bot position");
    println(startPos + " index: " + cellIndex(startPos));
    println("Target positions");
    for(int i = 0; i<4;i++){
    println(checkPos[i]+ " index: " + cellIndex(checkPos[i]));
    }
    println("-----");

    //Check all neighbours of current cell
    for(int i = 0; i<4;i++){
        println("***Next neigbour***");
        //Check if target is a new node
        boolean nodeExist = false;
        for(int j = 0; j<nodesToCheck.size();j++){
            println("comparing cell:" + cellIndex(checkPos[i]) + "With check stack");
            if(nodesToCheck.get(j).id == cellIndex(checkPos[i])){
                nodeExist = true;
                println("node aleady exist");
                for(int k = 0; k<nodesToCheck.size();k++){
                    println("node id in check stack:" + nodesToCheck.get(k).id);
                }
                println(checkPos[i]);
                // break;
            }
        }

        if(!nodeExist){
            //New node discovered, add it to the list
            println("adding node with id:" + cellIndex(checkPos[i]) + " to check stack");
            newNode = new Node(checkPos[i]);
        }

        if(currentNode.localValue+cellValue(checkPos[i])<newNode.localValue){
            newNode.parent      = currentNode.id;
            newNode.localValue  = cellValue(checkPos[i]);
            newNode.globalValue = pathDist(startPos, goalPos) + newNode.localValue;
            println("updating node with id:" + cellIndex(checkPos[i]) + " in check stack");
            nodesToCheck.add(newNode);
        }

    }

    //sort nodesToCheckList
    println("***Nodes to check***");
    for(int i = 0; i<nodesToCheck.size();i++){
        println(nodesToCheck.get(i).pos);
    }

    //Use the A* algorithm to calculate a new path to the target

    //Variables
    println("***Pathfinder finished***");
}