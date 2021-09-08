/**
 Use this sketch to create your own jigsaws.
 
 The created jigsaw will be a folder starting with "JSP"
 and can be found in the sketch's data folder.
 
 Copy the JSP folder to the data folder of the Jigsaw 
 Player sketch al then start the player. It will find any 
 jigsaw in the data folder.
 
 This sketch requires the G4P version 3.1.1 or later.
 
 */

import g4p_controls.*;

final int STAGE1  = 1;
final int STAGE2  = 2;
final int STAGE3A = 3;
final int STAGE3B = 4;
final int STAGE4  = 5;

int stage = STAGE1;

Jigsaw puzzle = null;
PFont font = null;

String jpImageFname, jpFolderName, jpTitle;
PImage picture, puzzlePicture, puzzleEdges;
// Stage 2 grid details 
int gridOffX, gridOffY, gridWidth, gridHeight, gridColour;
// Stage 3 edge details
//int edgeRGB;
int edgeRGB, edgeAlpha;
float edgeBorder;

boolean savePuzzle = false;

String path = "";

public void setup() {
  size(800, 600);
  createGUI();
  customGUI();
  gridColour = color(255, 255, 0);
  edgeRGB = 0;
  edgeAlpha = 40;
  edgeBorder = 1.2f;
  initStage1();
}

public void initStage1() {
  stage = STAGE1;
  pnlStage1.setVisible(true);
  pnlStage2.setVisible(false);
  pnlStage3.setVisible(false);
  jpFolderName = "JSP_" + System.currentTimeMillis() % 100000;
  lblFolder.setText(jpFolderName);
  jpTitle = "";
  txfTitle.setText("");
}

public void draw() {
  background(250);
  pushStyle();
  pushMatrix();
  rectMode(CENTER);
  ellipseMode(CENTER);
  imageMode(CORNER);
  switch(stage) {
  case STAGE1:
    drawStage1();
    break;
  case STAGE2:
    drawStage2();
    break;
  case STAGE3A:
    drawStage3a();
    break;
  case STAGE3B:
    drawStage3b();
    break;
  case STAGE4:
    drawStage4();
    break;
  }
  popMatrix();
  popStyle();
}

public void drawStage1() {
  if (picture != null) {
    pushStyle();
    pushMatrix();
    translate(Jigsaw.displayOffsetX, Jigsaw.displayOffsetY);
    scale(Jigsaw.displayScale);
    image(picture, 0, 0);
    popMatrix();
    pushStyle();
  }
}

public void drawStage2() {
  pushStyle();
  pushMatrix();
  translate(Jigsaw.displayOffsetX, Jigsaw.displayOffsetY);
  scale(Jigsaw.displayScale);
  image(picture, 0, 0);
  Jigsaw.pieceW = picture.width / Jigsaw.cols;
  Jigsaw.pieceH = picture.height / Jigsaw.rows;
  gridWidth = Jigsaw.pieceW * Jigsaw.cols;
  gridHeight = Jigsaw.pieceH * Jigsaw.rows;
  gridOffX = (picture.width - gridWidth)/2;
  gridOffY = (picture.height - gridHeight)/2;
  strokeWeight(1.2f);
  stroke(gridColour);
  noFill();
  for (int r = 0; r < Jigsaw.rows; r++)
    line(gridOffX, gridOffY + r * Jigsaw.pieceH, gridOffX + gridWidth, gridOffY + r * Jigsaw.pieceH);
  for (int c = 0; c < Jigsaw.cols; c++)
    line(gridOffX + c * Jigsaw.pieceW, gridOffY, gridOffX + c * Jigsaw.pieceW, gridOffY + gridHeight);
  popMatrix();  
  popStyle();
}

public void drawStage3a() {
  pushStyle();
  pushMatrix();
  translate(Jigsaw.displayOffsetX, Jigsaw.displayOffsetY);
  scale(Jigsaw.displayScale);
  image(picture, 0, 0);
  puzzle.drawJigsaw(0, 0, 1, color(edgeRGB, edgeAlpha), edgeBorder);
  popMatrix();  
  popStyle();
}

public void drawStage3b() {
  pushStyle();
  pushMatrix();
  puzzle.getEditPiece().drawPieceEdit();
  popMatrix();  
  popStyle();
}

public void drawStage4() {
  pushStyle();
  pushMatrix();
  rectMode(CORNER);
  noStroke();
  fill(255, 255, 200);
  rect(10, height/2 - 30, (width - 220) * JigsawSaver.progress, 60);
  noFill();
  stroke(128);
  strokeWeight(10);
  rect(10, height/2 - 30, width - 220, 60);
  popMatrix();  
  popStyle();    
  if (JigsawSaver.finished == 1)
    JigsawSaver.finished ++;
  else if (JigsawSaver.finished == 2) {
    G4P.showMessage(this, "The jigsaw has been saved in folder " + jpFolderName, "Jigsaw Maker", G4P.INFO);
    stage = STAGE3A;
  }
}

public void mouseReleased() {
  if (stage == STAGE3A) {
    int c = (int) ((mouseX - Jigsaw.displayOffsetX)/(Jigsaw.pieceW * Jigsaw.displayScale));
    int r = (int) ((mouseY - Jigsaw.displayOffsetY)/(Jigsaw.pieceH * Jigsaw.displayScale));
    if (puzzle.setEditPiece(c, r))
      stage = STAGE3B;
  }
}

// Use this method to add additional statements
// to customise the GUI controls
void customGUI() {
  pnlStage3.setVisible(true);
  pnlStage2.setVisible(false);
  pnlStage1.setVisible(false);

  Jigsaw.cols = sdrNbrCols.getValueI();
  Jigsaw.rows = sdrNbrRows.getValueI();
}