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
    PVector startBehindBot = bot.heading_vec;
    startBehindBot.mult(-1.0f);
    startBehindBot.normalize();
    startBehindBot.mult(random(1.5,1.7)*fpixelsPerMeter);

    int startIndex = cellIndex(cellPos(PVector.add(bot.pos,startBehindBot)));
    // int startIndex = cellIndex(cellPos(bot.pos));
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
                    // modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos), currentNode.localValue +1);
                    modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos), currentNode.localValue + cellRealValue(neighborNode.id));
                    nodesChecked.add(neighborNode);
                    break;
                }else{
                    // if(currentNode.localValue + 1 <= neighborNode.localValue){
                    if(currentNode.localValue + cellRealValue(neighborNode.id) <= neighborNode.localValue){
                        // modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos), currentNode.localValue +1);
                        modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos) + 1000*(1-cells.get(neighborNode.id).cSpace), currentNode.localValue + cellRealValue(neighborNode.id));
                        // modifyNode(neighborIndex[i], currentNode.id, neighborNode.visited, pathDist(neighborNode.pos, goalPos) , currentNode.localValue + 300*(2-cellRealValue(neighborNode.id)));
                        if(!neighborNode.visited && cellRealValue(neighborIndex[i])<99000){
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
    while(!(pathIndex == startIndex) && ii<2000){
        currentNode = nodes.get(pathIndex);
        path.add(currentNode);
        pathIndex = currentNode.parent;
        ii+=1;        
    }
    if(ii>=2000){
      bot.needNewTarget = true;
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

PVector cellPos(PVector pos){
  int xCellOver = int(map(pos.x, 0, width, 0, width/cellSize));
  xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
  int yCellOver = int(map(pos.y, 0, height, 0, height/cellSize));
  yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
  // println(xCellOver + ',' + yCellOver);
  return new PVector(xCellOver, yCellOver);
}

// int cellIndex(PVector pos){
//   int xCellOver = ceil(map(pos.x, 0, width, 0, width/cellSize));
//   xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
//   int yCellOver = ceil(map(pos.y, 0, height, 0, height/cellSize));
//   yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
//   return yCellOver*(width/cellSize) + xCellOver;
// }

PVector indexRealPos(int index){
  int x = index%(width);
  int y = floor(index/(width));
  return new PVector(x,y);
}

PVector indexPos(int index){
  int x = index%(width/cellSize);
  int y = floor(index/(width/cellSize));
  return new PVector(x,y);
}

int cellRealIndex(PVector pos){
  // println(pos);
  return int((floor(pos.y)*width)) + floor(pos.x);
}

int cellIndex(PVector pos){
  // println(pos);
  return int((floor(pos.y)*width)/cellSize) + floor(pos.x);
}

float cellRealValue(int index){
  // println(pos);
  if (cells.get(index).probability <=0.499){ 
  // if (cells.get(index).mapValue <=0.49){
    return 100000;
  }else{
    return 1*(1-cells.get(index).probability) + 10*(1-cells.get(index).cSpace);
  }
  // return(1-cells.get(cellIndex(pos)).probability)*0.5;
}

float cellValue(PVector pos){
  if (cells.get(cellIndex(pos)).probability <=0.49){
    return 100000;
  }else if (cells.get(cellIndex(pos)).probability >0.49 && cells.get(cellIndex(pos)).probability <=0.9) {
    return 2;
  }else{
    return 1;
  }
  // return(1-cells.get(cellIndex(pos)).probability)*0.5;
}

float pathDist(PVector a, PVector b){
  return PVector.sub(a,b).mag();
}

public int getIndexOfMin(ArrayList<Node> nodes) {
    float min = Float.MAX_VALUE;
    int index = -1;
    for (int i = 0; i < nodes.size(); i++) {
        Float f = nodes.get(i).globalValue;
        if (Float.compare(f, min) < 0) {
            min = f.floatValue();
            index = i;
        }
    }
    return index;
}

void modifyNode(int id_, int parent_, boolean visited_, float globalValue_, float localValue_){
  Node tempNode = nodes.get(id_);
  tempNode.parent       = parent_;
  tempNode.pos          = indexPos(id_);
  tempNode.visited      = visited_;
  tempNode.globalValue  = globalValue_;
  tempNode.localValue   = localValue_;
}