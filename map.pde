int cellSize = 100;

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
}

class Cell {
  int[] edge_id = new int[4];
  boolean[] edge_exist = new boolean[4];
  boolean exist = false;
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

void drawMap() {
  for (int i=0; i<((width/cellSize)*(height/cellSize)); i++) {
    if (cells.get(i).exist) {
      stroke(0);
      fill(0);
    } else {
      stroke(backgroundColor);
      fill(backgroundColor);
    }
    int x = i%(width/cellSize);
    int y = floor(i/(width/cellSize));

    if (edit) {
      stroke(80);
    }
    rect (x*cellSize, y*cellSize, cellSize, cellSize);
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


void editMap() {

  fill(255);
  textMode(MODEL);
  textAlign(CENTER);
  textFont(f, 50);
  text("Map edit mode", width/2, height/2-5);

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


//void updateEdges() {
//  for (int i=0; i<((width/cellSize)*(height/cellSize)); i++) {
//    int x = i%(width/cellSize);
//    int y = floor(i/(width/cellSize));
//    //println("pixel:"+x+","+y);
//    for (int xx=x-1; xx<=x+1; xx++) {
//      for (int yy=y-1; yy<=y+1; yy++) {  
//        //Out of bounds check
//        if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) {
//          //Do not check self
//          if (!((xx==x)&&(yy==y))) {
//            int j = yy*(width/cellSize) + xx;
//            Cell currentBufferCell = cellsBuffer.get(i);
//            Cell neighbourCell = cellsBuffer.get(j);
//            //println(j);
//            if (currentBufferCell.exist) { // is checked neighbour a wall? 
//              //Neighbour checks             
//              boolean n = xx == x   && yy == y-1;
//              boolean s = xx == x   && yy == y+1;
//              boolean e = xx == x+1 && yy == y  ;
//              boolean w = xx == x-1 && yy == y  ;
//              //North
//              if (n) {
//                //println("pixel:"+x+","+y+" has a neighbour NORTH" );
//                currentBufferCell.edge_exist[NORTH] = true;
//                println("Adding Norhtern edge to pixel:"+x+","+y);
//              }
//              //else{ 
//              //  currentBufferCell.edge_exist[NORTH] = true;
//              //  println("Adding Norhtern edge to pixel:"+x+","+y);
//              //  //edgePool.add(new Edge());
//              //}


//              //South
//              if (s) {
//                //println("pixel:"+x+","+y+" has a neighbour SOUTH" );
//                currentBufferCell.edge_exist[SOUTH] = true;
//                println("Adding Southern edge to pixel:"+x+","+y);
//              }
//              //else{
//              //  currentBufferCell.edge_exist[SOUTH] = true;
//              //  println("Adding Southern edge to pixel:"+x+","+y);
//              //}


//              //East
//              if (e) {
//                //println("pixel:"+x+","+y+" has a neighbour EAST" );
//                currentBufferCell.edge_exist[EAST] = true;
//                println("Adding Eastern edge to pixel:"+x+","+y);
//              }
//              //else{
//              //  currentBufferCell.edge_exist[EAST] = true;
//              //  println("Adding Eastern edge to pixel:"+x+","+y);
//              //}


//              //West
//              if (w) {
//                //println("pixel:"+x+","+y+" has a neighbour WEST" );
//                currentBufferCell.edge_exist[WEST] = true;
//                println("Adding Western edge to pixel:"+x+","+y);
//              }
//              //else{
//              //  currentBufferCell.edge_exist[WEST] = true;  
//              //  println("Adding Western edge to pixel:"+x+","+y);
//              //}
//            }
//          }
//        }
//      }
//    }
//  }
//}



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

        //Neighbour checks 
        // 
        if (cellsBuffer.get(n).exist) { 
          println("pixel:"+x+","+y+" has a neighbour NORTH" );
        } 
        else {
          if (!cellsBuffer.get(w).edge_exist[NORTH]) {
            //Create a new edge, create an id for that edge and tie it to the northern edge id of this cell
            edgePool.add(new Edge());
            currentBufferCell.edge_id[NORTH] = edgePool.size();
            println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[NORTH] = true;
            println("Adding Norhtern edge to pixel:"+x+","+y);
          }else{
            //Change end point of northern edge of western neighbour cell
            println("Western neigbour of pixel:"+x+","+y+" has a NORTHERN edge. Extending");
            cellsBuffer.get(n).edge_exist[NORTH] = true;
          }
        }


        //South
        if (cellsBuffer.get(s).exist) {
                      edgePool.add(new Edge());
            currentBufferCell.edge_id[SOUTH] = edgePool.size();
            println("edgepoolsize:"+edgePool.size());
            currentBufferCell.edge_exist[NORTH] = true;
          println("pixel:"+x+","+y+" has a neighbour SOUTH" );
        } else {
          currentBufferCell.edge_exist[SOUTH] = true;
          println("Adding Southern edge to pixel:"+x+","+y);
        }


        //East
        if (cellsBuffer.get(e).exist) {
          println("pixel:"+x+","+y+" has a neighbour EAST" );
        } else {
          currentBufferCell.edge_exist[EAST] = true;
          println("Adding Eastern edge to pixel:"+x+","+y);
        }


        //West
        if (cellsBuffer.get(w).exist) {
          println("pixel:"+x+","+y+" has a neighbour WEST" );
        } else {
          currentBufferCell.edge_exist[WEST] = true;  
          println("Adding Western edge to pixel:"+x+","+y);
        }
        println("NEXT");
      }
    }
  }
}
