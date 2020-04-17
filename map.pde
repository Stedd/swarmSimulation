int cellSize = 20;

ArrayList<Edge>  edgePool;
ArrayList<Cell>  cells;
ArrayList<Cell>  cellsBuffer;

//Util
boolean bufferUpdated = false;

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
    println("writing to cellbuffer" + millis());
    for (int x=0; x<((width/cellSize)*(height/cellSize)); x++) {
      Cell currentBufferCell = cellsBuffer.get(x);
      Cell currentCell = cells.get(x);
      currentBufferCell.exist = currentCell.exist;
    }
  }
}


void updateEdges() {
  for (int i=0; i<((width/cellSize)*(height/cellSize)); i++) {
    int x = i%(width/cellSize);
    int y = floor(i/(width/cellSize));
    //println("pixel:"+x+","+y);
    for (int xx=x-1; xx<=x+1; xx++) {
      for (int yy=y-1; yy<=y+1; yy++) {  
        //Out of bounds check
        if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) {
          //Do not check self
          if (!((xx==x)&&(yy==y))) {
            int j = yy*(width/cellSize) + xx;
            Cell currentBufferCell = cellsBuffer.get(j);
            //println(j);
            if (currentBufferCell.exist) { // is checked neighbour a wall? 
              //North
              if (xx == x && yy == y-1) {
                println("pixel:"+x+","+y+" has a neighbour NORTH" );
              }
              //South
              if (xx == x && yy == y+1) {
                println("pixel:"+x+","+y+" has a neighbour SOUTH" );
              }
              //East
              if (xx == x+1 && yy == y) {
                println("pixel:"+x+","+y+" has a neighbour EAST" );
              }
              //West
              if (xx == x-1 && yy == y) {
                println("pixel:"+x+","+y+" has a neighbour WEST" );
              }
            }
          }
        }
      }
    }
  }
}
