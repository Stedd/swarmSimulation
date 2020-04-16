int cellSize = 100;

//ArrayList<Edge>  edgePool;
//ArrayList<Cell>  cells;
int[][] cells; 
int[][] cellsBuffer; 

// Pause
boolean edit = false;

class Edge{
  float sx, sy;
  float ex, ey;
}

class Cell{
  int[] edge_id = new int[4];
  boolean[] edge_exist = new boolean[4];
  boolean exist = false;
}



void initMap() {
  // Instantiate arrays 
  //cells = new ArrayList<Cell>();
  //for ( int i = 0; i<((width/cellSize)*(height/cellSize)); i++) {
  //    cells.add(new Cell());
  //    println(i);
  //  }
  cells = new int[width/cellSize][height/cellSize];
  cellsBuffer = new int[width/cellSize][height/cellSize];

  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      float state = random (100);
      state = 0;
      cells[x][y] = int(state); // Save state of each cell
    }
  }
}

void drawMap() {
  //Draw grid
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if (cells[x][y]==1) {
        stroke(0);
        fill(0, 0, 0); // If alive
      } else {
        stroke(backgroundColor);
        fill(125, 125, 125); // If dead
      }
      if (edit) {
        stroke(60);
      }
      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
}


void keyPressed() {
 
  if (key==' ') { // On/off of pause
    edit = !edit;

    //Recalculate the shapes
    if (!edit) {
      updateEdges();  
      println("calculating edges");
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
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize-1);

    // Check against cells in buffer
    if (cellsBuffer[xCellOver][yCellOver]==1) { // Cell is alive
      cells[xCellOver][yCellOver]=0; // Kill
      fill(255, 0, 0); // Fill with kill color
    } else { // Cell is dead
      cells[xCellOver][yCellOver]=1; // Make alive
      fill(0, 0, 0); // Fill alive color
    }
  } else if (!mousePressed) { // And then save to buffer once mouse goes up
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cellsBuffer[x][y] = cells[x][y];
      }
    }
  }
}


void updateEdges() {
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      for (int xx=x-1; xx<=x+1; xx++) {
        for (int yy=y-1; yy<=y+1; yy++) {  
          if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[xx][yy]==1) { // is checked neighbour a wall? 
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
            } // End of if
          } // End of if
        } // End of yy loop
      } //End of xx loop
    } // End of y loop
  } // End of x loop
}
