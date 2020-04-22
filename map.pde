int cellSize =10;

ArrayList<Edge>  edgePool;
ArrayList<Cell>  cells;
ArrayList<Cell>  cellsBuffer;

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
  int[] edge_id = new int[4];
  boolean[] edge_exist = new boolean[4];
  boolean exist = false;
  boolean discovered = false;
}


void initMap() {
  //Instantiate arrays 
  cells           = new ArrayList<Cell>();
  cellsBuffer     = new ArrayList<Cell>();
  edgePool        = new ArrayList<Edge>();

  println("generating" + ((width/cellSize)*(height/cellSize)) + "cells");
  for ( int i = 0; i<((width/cellSize)*(height/cellSize)); i++) {
    cells.add(new Cell());
    cellsBuffer.add(new Cell());
  }
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
  for (int i=0; i<((width/cellSize)*(height/cellSize)); i++) {
    if (cells.get(i).discovered) {
      if (cells.get(i).exist) {
        //stroke(0);
        noStroke();
        fill(0);
        int x = i%(width/cellSize);
        int y = floor(i/(width/cellSize));
        rect (x*cellSize, y*cellSize, cellSize, cellSize);
      } else {
        //stroke(backGroundColor);
        noStroke();
        fill(255);
        int x = i%(width/cellSize);
        int y = floor(i/(width/cellSize));
        rect (x*cellSize, y*cellSize, cellSize, cellSize);
      }
    }
  }
}


void keyPressed() {

  if (key==' ') {
    edit = !edit;

    //Recalculate the shapes
    if (!edit) {
      println("calculating edges");
      updateEdges();
    }
  }
}


void drawEditMap() {
  for (int i=0; i<((width/cellSize)*(height/cellSize)); i++) {
    if (edit) {
      if (cells.get(i).exist) {
        //stroke(0);
        noStroke();
        fill(0);
      } else {
        //stroke(255);
        noStroke();
        fill(255);
      }
      //stroke(80);
      int x = i%(width/cellSize);
      int y = floor(i/(width/cellSize));

      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
}

void editMap() {

  //clear edges
  edgePool.clear();
  for (int i= 0; i<cellsBuffer.size(); i++) {
    cells.get(i).discovered = false;
    cellsBuffer.get(i).discovered = false;
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

    if (currentBufferCell.exist) {
      currentCell.exist=false;
    } else { 
      currentCell.exist=true;
    }
  }
  if (!bufferUpdated && !mousePressed) {
    bufferUpdated = true;  
    for (int x=0; x<((width/cellSize)*(height/cellSize)); x++) {
      Cell currentBufferCell = cellsBuffer.get(x);
      Cell currentCell = cells.get(x);
      currentBufferCell.exist = currentCell.exist;
    }
  }
}

void updateEdges() {
  for (int y=1; y<((height/cellSize)-1); y++) {
    for (int x=1; x<((width/cellSize)-1); x++) {

      int i = y*(width/cellSize) + x;
      //println("scanning pixel:("+x+","+y + ")index: " + i);
      Cell currentBufferCell = cellsBuffer.get(i);
      if (currentBufferCell.exist) {
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
        println("pixel:("+xPixel+","+ yPixel + ")index: " + i);

        //Neighbour checks 
        // 
        if (cellsBuffer.get(n).exist) { 
          //Has a neighbour. No edge
          println("pixel:"+x+","+y+" has a neighbour NORTH" );
        } else {
          if (!cellsBuffer.get(w).edge_exist[NORTH]) {
            //Create a new edge, create an id for that edge and tie it to the northern edge id of this cell
            println("Creating Norhtern edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel, yPixel, xPixel+cellSize, yPixel));
            currentBufferCell.edge_id[NORTH] = edgePool.size()-1;
            println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[NORTH] = true;
          } else {
            //Change end point of northern edge of western neighbour cell
            println("Western neigbour of pixel:"+x+","+y+" has a NORTHERN edge. Extending");
            edgePool.get(cellsBuffer.get(w).edge_id[NORTH]).ex += cellSize;
            currentBufferCell.edge_id[NORTH] = cellsBuffer.get(w).edge_id[NORTH];
            currentBufferCell.edge_exist[NORTH] = true;
          }
        }

        //Neighbour checks 
        // 
        if (cellsBuffer.get(s).exist) { 
          //Has a neighbour. No edge
          println("pixel:"+x+","+y+" has a neighbour SOUTH" );
        } else {
          if (!cellsBuffer.get(w).edge_exist[SOUTH]) {
            //Create a new edge, create an id for that edge and tie it to the southern edge id of this cell
            println("Creating Southern edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel, yPixel+cellSize, xPixel+cellSize, yPixel+cellSize));
            currentBufferCell.edge_id[SOUTH] = edgePool.size()-1;
            println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[SOUTH] = true;
          } else {
            //Change end point of northern edge of western neighbour cell
            println("Western neigbour of pixel:"+x+","+y+" has a SOUTHERN edge. Extending");
            edgePool.get(cellsBuffer.get(w).edge_id[SOUTH]).ex += cellSize;
            currentBufferCell.edge_id[SOUTH] = cellsBuffer.get(w).edge_id[SOUTH];
            currentBufferCell.edge_exist[SOUTH] = true;
          }
        }

        //Neighbour checks 
        // 
        if (cellsBuffer.get(e).exist) { 
          //Has a neighbour. No edge
          println("pixel:"+x+","+y+" has a neighbour EAST" );
        } else {
          if (!cellsBuffer.get(n).edge_exist[EAST]) {
            //Create a new edge, create an id for that edge and tie it to the eastern edge id of this cell
            println("Creating Eastern edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel+cellSize, yPixel, xPixel+cellSize, yPixel+cellSize));
            currentBufferCell.edge_id[EAST] = edgePool.size()-1;
            println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[EAST] = true;
          } else {
            //Change end point of eastern edge of northern neighbour cell
            println("Northern neigbour of pixel:"+x+","+y+" has a EASTERN edge. Extending");
            edgePool.get(cellsBuffer.get(n).edge_id[EAST]).ey += cellSize;
            currentBufferCell.edge_id[EAST] = cellsBuffer.get(n).edge_id[EAST];
            currentBufferCell.edge_exist[EAST] = true;
          }
        }

        //Neighbour checks 
        // 
        if (cellsBuffer.get(w).exist) { 
          //Has a neighbour. No edge
          println("pixel:"+x+","+y+" has a neighbour WEST" );
        } else {
          if (!cellsBuffer.get(n).edge_exist[WEST]) {
            //Create a new edge, create an id for that edge and tie it to the western edge id of this cell
            println("Creating Western edge to pixel:"+x+","+y);
            edgePool.add(new Edge(xPixel, yPixel, xPixel, yPixel+cellSize));
            currentBufferCell.edge_id[WEST] = edgePool.size()-1;
            println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[WEST] = true;
          } else {
            //Change end point of eastern edge of northern neighbour cell
            println("Northern neigbour of pixel:"+x+","+y+" has a WESTERN edge. Extending");
            edgePool.get(cellsBuffer.get(n).edge_id[WEST]).ey += cellSize;
            currentBufferCell.edge_id[WEST] = cellsBuffer.get(n).edge_id[WEST];
            currentBufferCell.edge_exist[WEST] = true;
          }
        }

        println("NEXT");
      }
    }
  }
}
