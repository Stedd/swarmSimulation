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
}

//Variables
ArrayList<Node> path         = new ArrayList<Node>();
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
    int goalIndex  = cellIndex(cellPos(bot.goal_pos));

    startPos = indexPos(startIndex);
    goalPos = indexPos(goalIndex);   

    for ( int i = 0; i<((width/cellSize)*(height/cellSize)); i++) {
        nodes.add(new Node(i));
    }

    //Add first waypoint to path
    modifyNode(startIndex, 0, false, pathDist(startPos, goalPos), 0);
    nodesToCheck.add(nodes.get(startIndex));
    neighborIndex    = new int[4];

    int ii = 0;
    while(!finished && nodesToCheck.size()>0){

        currentNode = nodes.get(nodesToCheck.get(getIndexOfMin(nodesToCheck)).id);

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

        for(int i = 0; i<4;i++){
            if(neighborIndex[i]!=-1){
                neighborNode = nodes.get(neighborIndex[i]);
                if(neighborIndex[i] == goalIndex){
                    finished = true;
                    modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos), currentNode.localValue +1);
                    nodesChecked.add(neighborNode);
                    break;
                }else{
                    if(currentNode.localValue + 1 <= neighborNode.localValue){
                        modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos), currentNode.localValue +1);
                        if(!neighborNode.visited && cellRealValue(neighborIndex[i])<1000){
                            nodesToCheck.add(neighborNode);
                        }
                        nodesChecked.add(neighborNode);
 
                    }
                    currentNode.visited = true;
                    nodesToCheck.remove(currentNode);
                }
            }
        }
    }   
    int pathIndex = goalIndex;
    while(!(pathIndex == startIndex) && ii<3000){
        currentNode = nodes.get(pathIndex);
        path.add(currentNode);
        pathIndex = currentNode.parent;
        ii+=1;        
    }
}

void drawPoints(){
    fill(0,255,0);
    ellipse(startPos.x*cellSize + cellSize/2, startPos.y*cellSize + cellSize/2,30,30);
    fill(0,0,255);
    ellipse(goalPos.x*cellSize + cellSize/2, goalPos.y*cellSize + cellSize/2,30,30);
}

void drawChecked(){
    for(int i = 0; i<nodesChecked.size();i++){
        noStroke();
        fill(255,0,255);
        ellipse(nodesChecked.get(i).pos.x*cellSize+cellSize/2, nodesChecked.get(i).pos.y*cellSize+cellSize/2, 3, 3);
    }
}

void drawWayPoints(){
    for(int i = 0; i<path.size()-1;i++){
        strokeWeight(10);
        fill(0,255,0);
        ellipse(path.get(i).pos.x*cellSize+cellSize/2, path.get(i).pos.y*cellSize+cellSize/2, 5, 5);
    }
}