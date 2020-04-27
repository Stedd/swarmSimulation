ArrayList<Edge>  edgePool;
ArrayList<Cell>  cells;
ArrayList<Cell>  cellsBuffer;
IntList   cellsToRender;

//Util
boolean bufferUpdated = false;
int NORTH = 0;
int SOUTH = 1;
int EAST = 2;
int WEST = 3;

// Pause
boolean edit = false;


class Edge {
  float sx, sy;
  float ex, ey;

  Edge(float sx_, float sy_, float ex_, float ey_) {
    sx = sx_;
    sy = sy_;
    ex = ex_;
    ey = ey_;
  }
}


class Cell {
  float probability     = 0.5;
  float mapValue        = 1.0;             
  int[] edge_id         = new int[4];
  boolean[] edge_exist  = new boolean[4];
}


void initMap() {
  //Instantiate arrays
  cells           = new ArrayList<Cell>();
  cellsBuffer     = new ArrayList<Cell>();
  edgePool        = new ArrayList<Edge>();
  cellsToRender   = new IntList();

  println("Map contains " + ((width/cellSize)*(height/cellSize)) + " cells (" + width/cellSize+ " * "+height/cellSize +") Each cell is " + realCellSize*100 + "cm * "+ realCellSize*100 + "cm. The total map is: " + (width/cellSize)*realCellSize+ "m * "+(height/cellSize)*realCellSize +"m");
  for ( int i = 0; i<((width/cellSize)*(height/cellSize)); i++) {
    cells.add(new Cell());
    cellsBuffer.add(new Cell());
    cellsToRender.append(i);
  }
}


void loadMap() {
  //Draw pre generated map
  int offset = 1;
  //some for loops drawing the map.
  for (int x = offset; x < (width/cellSize)-offset; x++) {
    for (int y = offset; y < (height/cellSize)-offset; y++) {
      int i = y*(width/cellSize) + x;
      Cell currentCell = cells.get(i);
      currentCell.mapValue=0.0;
    }
  }

  int numberOfRooms = 3;
  int roomWidth = 3*int(pixelsPerMeter);
  int roomHeight = 5*int(pixelsPerMeter);

  for (int r = 0; r < numberOfRooms; r++) {
    int startX = 1*int(pixelsPerMeter) + int(((r*roomWidth)+0.1)*pixelsPerMeter);
    println("StartX: "+startX);
    // int startY = 1*int(pixelsPerMeter);
    int startY = 150;
    println("StartY: "+startY);
    // offset = 2;
    //some for loops drawing the map.
    for (int x = startX; x < startX + (roomWidth/cellSize); x++) {
      for (int y = startY; y < startY + (roomHeight/cellSize); y++) {
        int i = y*(width/cellSize) + x;
        Cell currentCell = cells.get(i);
        currentCell.mapValue=1.0;
      }
    }
  }

  for (int x=0; x<((width/cellSize)*(height/cellSize)); x++) {
    Cell currentBufferCell = cellsBuffer.get(x);
    Cell currentCell = cells.get(x);
    currentBufferCell.mapValue = currentCell.mapValue;
  }
  updateEdges();
}


void drawRays() {
  if (edgePool.size()>0) {
    for (int i=0; i<edgePool.size(); i++) {
      stroke(0, 255, 0);
      line(edgePool.get(i).sx, edgePool.get(i).sy, mouseX, mouseY);
      line(edgePool.get(i).ex, edgePool.get(i).ey, mouseX, mouseY);
    }
  }
}


void drawEdges() {
  if (edgePool.size()>0) {

    for (int i=0; i<edgePool.size(); i++) {
      stroke(0, 255, 0);
      line(edgePool.get(i).sx, edgePool.get(i).sy, edgePool.get(i).ex, edgePool.get(i).ey);
      noStroke();
      fill(255, 0, 0, 100);
      ellipse(edgePool.get(i).sx, edgePool.get(i).sy, 10, 10);
      ellipse(edgePool.get(i).ex, edgePool.get(i).ey, 10, 10);
    }
  }
}


void drawMap() {
  frameBuffer.beginDraw();
  if (cellsToRender.size() > 0) {
    for (int cell : cellsToRender){
      frameBuffer.noStroke();
      // int fill = constrain(round(255*cells.get(cell).probability), 0, 255);
      int fill = constrain(round(255*cells.get(cell).mapValue), 0, 255); // for debugging
      frameBuffer.fill(fill);
      int x = cell%(width/cellSize);
      int y = floor(cell/(width/cellSize));
      frameBuffer.rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
    frameBuffer.endDraw();
    cellsToRender.clear();
    updateCount++;
  }
}


void drawEditMap() {
  frameBuffer.beginDraw();
  if (cellsToRender.size() > 0) {
    for (int cell : cellsToRender){
      frameBuffer.noStroke();
      int fill = constrain(round(255*cells.get(cell).mapValue), 0, 255);
      frameBuffer.fill(fill);
      int x = cell%(width/cellSize);
      int y = floor(cell/(width/cellSize));
      frameBuffer.rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
    frameBuffer.endDraw();
    cellsToRender.clear();
    updateCount++;
    }
  }


void updateCell(PVector scanPoint, float targetValue, float modifier) {
  int xCellOver = int(map(scanPoint.x, 0, width, 0, width/cellSize));
  xCellOver = constrain(xCellOver, 0, (width/cellSize)-1);
  int yCellOver = int(map(scanPoint.y, 0, height, 0, height/cellSize));
  yCellOver = constrain(yCellOver, 0, (height/cellSize)-1);
  int l = yCellOver*(width/cellSize) + xCellOver;
  Cell currentCell = cells.get(l);
  float difference = targetValue - currentCell.probability;
  if ((currentCell.probability < 1.0 && difference > 0) || (currentCell.probability > 0.0 && difference < 0)) {
    currentCell.probability += difference * modifier;
    cellsToRender.append(l);
  }
}


void keyPressed() {

  if (key==' ') {
    edit = !edit;

    //Recalculate the shapes
    if (!edit) {
      println("calculating edges");
      //restart timer
      startFrame = frameCount;

    //reset probability
    for ( int i = 0; i<((width/cellSize)*(height/cellSize)); i++) {
      cells.get(i).probability = 0.5;
      cellsToRender.append(i);
  }
      updateEdges();
    }
  }
}


void editMap() {
  //clear edges
  edgePool.clear();
  for (int i= 0; i<cellsBuffer.size(); i++) {
    cells.get(i).probability = 0.5;
    cellsBuffer.get(i).probability = 0.5;
    for (int j= 0; j<4; j++) {
      cells.get(i).edge_id[j] = 0;
      cells.get(i).edge_exist[j] = false;
      cellsBuffer.get(i).edge_id[j] = 0;
      cellsBuffer.get(i).edge_exist[j] = false;
    }
  }

  if (mousePressed) {
    bufferUpdated = false;
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize-1);
    int i = yCellOver*(width/cellSize) + xCellOver;
    Cell currentBufferCell = cellsBuffer.get(i);
    Cell currentCell = cells.get(i);
    cellsToRender.append(i);
    if (currentBufferCell.mapValue == 0) {
      currentCell.mapValue = 1.0;
    } else {
      currentCell.mapValue = 0.0;
    }
  }

  if (!bufferUpdated && !mousePressed) {
    bufferUpdated = true;
    for (int x=0; x<((width/cellSize)*(height/cellSize)); x++) {
      Cell currentBufferCell = cellsBuffer.get(x);
      Cell currentCell = cells.get(x);
      currentBufferCell.mapValue = currentCell.mapValue;
      cellsToRender.append(x);
    }
  }
}

void updateEdges() {
  for (int y=1; y<((height/cellSize)-1); y++) {
    for (int x=1; x<((width/cellSize)-1); x++) {

      int i = y*(width/cellSize) + x;
      //println("scanning pixel:("+x+","+y + ")index: " + i);
      Cell currentBufferCell = cellsBuffer.get(i);
      if (currentBufferCell.mapValue==1.0) {
        //println("pixel:"+x+","+y+" exists, scanning neighbours" );
        //Neighbour indices
        int n = (y-1)*(width/cellSize) + x  ;
        int s = (y+1)*(width/cellSize) + x  ;
        int e = y  *(width/cellSize) + (x+1);
        int w = y  *(width/cellSize) + (x-1);

        //println("Current index: " + i);
        //println("North index: " + n);
        //println("South index: " + s);
        //println("East index: " + e);
        //println("West index: " + w);

        int xPixel = x*cellSize;
        int yPixel = y*cellSize;
        //println("pixel:("+xPixel+","+ yPixel + ")index: " + i);

        //Neighbour checks
        //
        if (cellsBuffer.get(n).mapValue==1.0) {
          //Has a neighbour. No edge
          //println("pixel:"+x+","+y+" has a neighbour NORTH" );
        } else {
          if (!cellsBuffer.get(w).edge_exist[NORTH]) {
            //Create a new edge, create an id for that edge and tie it to the northern edge id of this cell
            //println("Creating Norhtern edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel, yPixel, xPixel+cellSize, yPixel));
            currentBufferCell.edge_id[NORTH] = edgePool.size()-1;
            //println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[NORTH] = true;
          } else {
            //Change end point of northern edge of western neighbour cell
            //println("Western neigbour of pixel:"+x+","+y+" has a NORTHERN edge. Extending");
            edgePool.get(cellsBuffer.get(w).edge_id[NORTH]).ex += cellSize;
            currentBufferCell.edge_id[NORTH] = cellsBuffer.get(w).edge_id[NORTH];
            currentBufferCell.edge_exist[NORTH] = true;
          }
        }

        //Neighbour checks
        //
        if (cellsBuffer.get(s).mapValue==1.0) {
          //Has a neighbour. No edge
          //println("pixel:"+x+","+y+" has a neighbour SOUTH" );
        } else {
          if (!cellsBuffer.get(w).edge_exist[SOUTH]) {
            //Create a new edge, create an id for that edge and tie it to the southern edge id of this cell
            //println("Creating Southern edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel, yPixel+cellSize, xPixel+cellSize, yPixel+cellSize));
            currentBufferCell.edge_id[SOUTH] = edgePool.size()-1;
            //println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[SOUTH] = true;
          } else {
            //Change end point of northern edge of western neighbour cell
            //println("Western neigbour of pixel:"+x+","+y+" has a SOUTHERN edge. Extending");
            edgePool.get(cellsBuffer.get(w).edge_id[SOUTH]).ex += cellSize;
            currentBufferCell.edge_id[SOUTH] = cellsBuffer.get(w).edge_id[SOUTH];
            currentBufferCell.edge_exist[SOUTH] = true;
          }
        }

        //Neighbour checks
        //
        if (cellsBuffer.get(e).mapValue==1.0) {
          //Has a neighbour. No edge
          //println("pixel:"+x+","+y+" has a neighbour EAST" );
        } else {
          if (!cellsBuffer.get(n).edge_exist[EAST]) {
            //Create a new edge, create an id for that edge and tie it to the eastern edge id of this cell
            //println("Creating Eastern edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel+cellSize, yPixel, xPixel+cellSize, yPixel+cellSize));
            currentBufferCell.edge_id[EAST] = edgePool.size()-1;
            //println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[EAST] = true;
          } else {
            //Change end point of eastern edge of northern neighbour cell
            //println("Northern neigbour of pixel:"+x+","+y+" has a EASTERN edge. Extending");
            edgePool.get(cellsBuffer.get(n).edge_id[EAST]).ey += cellSize;
            currentBufferCell.edge_id[EAST] = cellsBuffer.get(n).edge_id[EAST];
            currentBufferCell.edge_exist[EAST] = true;
          }
        }

        //Neighbour checks
        //
        if (cellsBuffer.get(w).mapValue==1.0) {
          //Has a neighbour. No edge
          //println("pixel:"+x+","+y+" has a neighbour WEST" );
        } else {
          if (!cellsBuffer.get(n).edge_exist[WEST]) {
            //Create a new edge, create an id for that edge and tie it to the western edge id of this cell
            //println("Creating Western edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel, yPixel, xPixel, yPixel+cellSize));
            currentBufferCell.edge_id[WEST] = edgePool.size()-1;
            //println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[WEST] = true;
          } else {
            //Change end point of eastern edge of northern neighbour cell
            //println("Northern neigbour of pixel:"+x+","+y+" has a WESTERN edge. Extending");
            edgePool.get(cellsBuffer.get(n).edge_id[WEST]).ey += cellSize;
            currentBufferCell.edge_id[WEST] = cellsBuffer.get(n).edge_id[WEST];
            currentBufferCell.edge_exist[WEST] = true;
          }
        }

        //println("NEXT");
      }
    }
  }
}
