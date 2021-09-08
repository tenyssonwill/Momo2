/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.
 
 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
 // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void pnlFixed_click(GPanel panel, GEvent event) { //_CODE_:pnlFixed:942169:
} //_CODE_:pnlFixed:942169:

public void pnlStage1_click(GPanel panel, GEvent event) { //_CODE_:pnlStage1:382650:
} //_CODE_:pnlStage1:382650:

public void btnGetImage_click(GButton button, GEvent event) { //_CODE_:btnGetImage:226865:
  String fname = G4P.selectInput("Get image file", "png,jpg,jpeg", "Image files");
  // If file is null then no f was selected
  if (fname.length() > 0) {
    PImage img = null;
    // Attempt to load an image
    img = loadImage(fname);
    // If img is not null then an image was loaded so use it
    if (img != null) {
      picture = img;
      jpImageFname = fname;
      int w = picture.width;
      int h = picture.height;
      if (max(w, h) != 512) {
        float ratio = ((float) w)/((float) h);
        if (ratio > 1) {
          w = 512;
          h = round(512 / ratio);
        } else {
          h = 512;
          w = round(512 * ratio);
        }
      }
      picture.resize(w, h); // Enlargement fails in 2.0b7
      Jigsaw.displayScale = 1.0f;
      Jigsaw.displayOffsetX = (width - 200 - w)/2;
      Jigsaw.displayOffsetY = (height - h)/2;
    }
  }
} //_CODE_:btnGetImage:226865:

public void btnGoto2_click(GButton button, GEvent event) { //_CODE_:btnGoto2:830053:
  jpTitle = txfTitle.getText();
  jpTitle = jpTitle.replace('"', '\'');
  if (picture == null) {
    G4P.showMessage(this, "An image is required", "Jigsaw Maker", G4P.ERROR);
  } else if (jpTitle.length() == 0) {
    G4P.showMessage(this, "A title is required", "Jigsaw Maker", G4P.ERROR);
  } else {
    stage = STAGE2;
    pnlStage1.setVisible(false);
    pnlStage3.setVisible(false);
    pnlStage2.setVisible(true);
  }
} //_CODE_:btnGoto2:830053:

public void txfName_enter(GTextField textfield, GEvent event) { //_CODE_:txfTitle:376336:
  if (event == GEvent.ENTERED) {
    jpTitle = txfTitle.getText();
    if (jpTitle.length() > 0)
      jpTitle = jpTitle.replace('"', '\'');
    txfTitle.setText(jpTitle);
  }
} //_CODE_:txfTitle:376336:

public void pnlStage2_click(GPanel panel, GEvent event) { //_CODE_:pnlStage2:428436:
} //_CODE_:pnlStage2:428436:

public void sdrNbrCols_change(GCustomSlider slider, GEvent event) { //_CODE_:sdrNbrCols:719018:
  Jigsaw.cols = slider.getValueI();
} //_CODE_:sdrNbrCols:719018:

public void sdrNbrRows_change(GCustomSlider slider, GEvent event) { //_CODE_:sdrNbrRows:257046:
  Jigsaw.rows = slider.getValueI();
} //_CODE_:sdrNbrRows:257046:

public void btnGoto3_click(GButton button, GEvent event) { //_CODE_:btnGoto3:431922:
  // Resize image to suit grid
  picture = picture.get(gridOffX, gridOffY, gridWidth, gridHeight);
  Jigsaw.displayScale = 1.0f;
  Jigsaw.displayOffsetX = (width - 200 - picture.width)/2;
  Jigsaw.displayOffsetY = (height - picture.height)/2;
  Jigsaw.editBorder = 0.5f * (min(Jigsaw.pieceW, Jigsaw.pieceH)-6) / min(Jigsaw.pieceW, Jigsaw.pieceH);
  Jigsaw.editScale = height / ((1 + 2 * Jigsaw.editBorder) * max(Jigsaw.pieceW, Jigsaw.pieceH));

  puzzle = new Jigsaw(this, Jigsaw.cols, Jigsaw.rows, Jigsaw.pieceW, Jigsaw.pieceH);
  stage = STAGE3A;
  pnlStage2.setVisible(false);
  pnlStage3.setVisible(true);
} //_CODE_:btnGoto3:431922:

public void btnBackTo1_click(GButton button, GEvent event) { //_CODE_:btnBackTo1:627800:
  stage = STAGE1;
  pnlStage3.setVisible(false);
  pnlStage2.setVisible(false);
  pnlStage1.setVisible(true);
} //_CODE_:btnBackTo1:627800:

public void btnGridCol_click(GImageButton imagebutton, GEvent event) { //_CODE_:btnGridCol:862801:
  gridColour = G4P.selectColor();
} //_CODE_:btnGridCol:862801:

public void pnlStage3_click(GPanel panel, GEvent event) { //_CODE_:pnlStage3:508810:
} //_CODE_:pnlStage3:508810:

public void optDark_click(GOption opt_selected, GEvent event) { //_CODE_:optDark:698818:
  edgeRGB = 0;
} //_CODE_:optDark:698818:

public void optLight_click(GOption opt_selected, GEvent event) { //_CODE_:optLight:550987:
  edgeRGB = 255;
} //_CODE_:optLight:550987:

public void sdrAlpha_change(GSlider horzslider, GEvent event) { //_CODE_:sdrAlpha:373226:
  edgeAlpha = horzslider.getValueI();
} //_CODE_:sdrAlpha:373226:

public void btnNorth_click(GImageButton imagebutton, GEvent event) { //_CODE_:btnNorth:768504:
  if (puzzle.getEditPiece() != null)
    puzzle.getEditPiece().flipEdge(JigsawPiece.NORTH);
} //_CODE_:btnNorth:768504:

public void btnSouth_click(GImageButton imagebutton, GEvent event) { //_CODE_:btnSouth:318521:
  if (puzzle.getEditPiece() != null)
    puzzle.getEditPiece().flipEdge(JigsawPiece.SOUTH);
} //_CODE_:btnSouth:318521:

public void btnEast_click(GImageButton imagebutton, GEvent event) { //_CODE_:btnEast:650367:
  if (puzzle.getEditPiece() != null)
    puzzle.getEditPiece().flipEdge(JigsawPiece.EAST);
} //_CODE_:btnEast:650367:

public void btnWest_click(GImageButton imagebutton, GEvent event) { //_CODE_:btnWest:217653:
  if (puzzle.getEditPiece() != null)
    puzzle.getEditPiece().flipEdge(JigsawPiece.WEST);
} //_CODE_:btnWest:217653:

public void imgButton1_Click1(GImageButton imagebutton, GEvent event) { //_CODE_:imgShowPuzzle:607674:
  stage = STAGE3A;
} //_CODE_:imgShowPuzzle:607674:

public void btnSave_click(GButton button, GEvent event) { //_CODE_:stnSave:451258:
  background(255);
  pushMatrix();
  scale(1);
  // Capture a picture of the picture edges 
  puzzle.drawJigsaw(0, 0, 1, color(0), 1);
  puzzleEdges = get(0, 0, picture.width+1, picture.height+1);
  // Capture a picture of the jigsaw with edges
  image(picture, 0, 0);
  puzzle.drawJigsaw(0, 0, 1, color(edgeRGB, edgeAlpha), edgeBorder);
  puzzlePicture = get(0, 0, picture.width + 1, picture.height + 1);
  popMatrix();

  JigsawSaver jsaver = new JigsawSaver(this, puzzle, 
    picture, puzzlePicture, puzzleEdges, 
    jpTitle, jpFolderName);
  stage = STAGE4;
  jsaver.start();
} //_CODE_:stnSave:451258:

public void btnBackTo2_click(GButton button, GEvent event) { //_CODE_:btnBackTo2:997156:
  stage = STAGE2;
  pnlStage3.setVisible(false);
  pnlStage2.setVisible(true);
} //_CODE_:btnBackTo2:997156:

public void sdrWidth_change(GSlider horzslider, GEvent event) { //_CODE_:sdrWidth:779933:
  edgeBorder = 0.1f * horzslider.getValueF();
} //_CODE_:sdrWidth:779933:


public void btnNewJigsaw_click(GButton button, GEvent event) { //_CODE_:btnNewJigsaw:657617:
  picture = null;
  initStage1();
} //_CODE_:btnNewJigsaw:657617:


// Create all the GUI controls. 
// autogenerated do not edit
void createGUI() {
  String[] e;
  G4P.setGlobalColorScheme(GCScheme.RED_SCHEME);
  G4P.messagesEnabled(false);
  pnlFixed = new GPanel(this, width - 200, 0, 200, height, "JIGSAW MAKER");
  pnlFixed.setDraggable(false);
  pnlFixed.setCollapsed(false);
  pnlFixed.addEventHandler(this, "pnlFixed_click");

  pnlStage1 = new GPanel(this, 0, 20, 199, 127, "Jigsaw Wizard (1 0f 3)");
  pnlStage1.setDraggable(false);
  pnlStage1.setCollapsible(false);
  pnlStage1.setVisible(true);
  pnlStage1.addEventHandler(this, "pnlStage1_click");
  lblTitle = new GLabel(this, 10, 40, 40, 20, "Title");
  txfTitle = new GTextField(this, 50, 40, 140, 20);
  txfTitle.setPromptText("Jigsaw title?");
  txfTitle.addEventHandler(this, "txfName_enter");
  lblDest = new GLabel(this, 10, 70, 50, 20, "Folder");
  lblFolder = new GLabel(this, 50, 70, 140, 20, "JSP_");
  btnGetImage = new GButton(this, 10, 100, 180, 20, "Get Jigsaw Image");
  btnGetImage.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnGetImage.addEventHandler(this, "btnGetImage_click");
  btnGoto2 = new GButton(this, 120, 130, 70, 20, "Next");
  btnGoto2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnGoto2.addEventHandler(this, "btnGoto2_click");
  pnlStage1.addControl(lblTitle);
  pnlStage1.addControl(btnGetImage);
  pnlStage1.addControl(btnGoto2);
  pnlStage1.addControl(txfTitle);
  pnlStage1.addControl(lblDest);
  pnlStage1.addControl(lblFolder);

  pnlStage2 = new GPanel(this, 0, 20, 200, 230, "Jigsaw Wizard (2 0f 3)");
  pnlStage2.setVisible(true);
  pnlStage2.setDraggable(false);
  pnlStage2.setCollapsible(false);
  pnlStage2.addEventHandler(this, "pnlStage2_click");
  sdrNbrCols = new GCustomSlider(this, 10, 50, 180, 60);
  sdrNbrCols.setLimits(6, 4, 16);
  sdrNbrCols.setNbrTicks(13);
  sdrNbrCols.setStickToTicks(true);
  sdrNbrCols.setShowValue(true);
  sdrNbrCols.addEventHandler(this, "sdrNbrCols_change");
  sdrNbrRows = new GCustomSlider(this, 10, 100, 180, 60);
  sdrNbrRows.setLimits(6, 4, 16);
  sdrNbrRows.setNbrTicks(13);
  sdrNbrRows.setStickToTicks(true);
  sdrNbrRows.setShowValue(true);
  sdrNbrRows.addEventHandler(this, "sdrNbrRows_change");
  label2 = new GLabel(this, 10, 30, 180, 20, "Number of columns and rows?");
  btnGoto3 = new GButton(this, 120, 230, 70, 20, "Next");
  btnGoto3.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnGoto3.addEventHandler(this, "btnGoto3_click");
  btnBackTo1 = new GButton(this, 10, 230, 70, 20, "Back");
  btnBackTo1.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnBackTo1.addEventHandler(this, "btnBackTo1_click");
  e = new String[] { 
    path + "gridcol0.png", path + "gridcol1.png", path + "gridcol2.png"
  };
  btnGridCol = new GImageButton(this, 52, 160, e);
  btnGridCol.addEventHandler(this, "btnGridCol_click");
  pnlStage2.addControl(btnGridCol);
  pnlStage2.addControl(sdrNbrCols);
  pnlStage2.addControl(sdrNbrRows);
  pnlStage2.addControl(label2);
  pnlStage2.addControl(btnGoto3);
  pnlStage2.addControl(btnBackTo1);

  pnlStage3 = new GPanel(this, 0, 20, 200, 300, "Jigsaw Wizard (3 0f 3)");
  pnlStage3.setCollapsible(false);
  pnlStage3.setDraggable(false);
  pnlStage3.addEventHandler(this, "pnlStage3_click");
  label3 = new GLabel(this, 10, 30, 180, 18, "Piece edge / border control");
  optGroup1 = new GToggleGroup();
  optDark = new GOption(this, 30, 50, 80, 20, "Dark");
  optGroup1.addControl(optDark);
  optDark.setSelected(true);
  optDark.addEventHandler(this, "optDark_click");
  optLight = new GOption(this, 110, 50, 70, 20, "Light");
  optGroup1.addControl(optLight);
  optLight.addEventHandler(this, "optLight_click");

  lblDensity = new GLabel(this, 10, 80, 50, 20, "Density");
  sdrAlpha = new GSlider(this, 60, 80, 130, 20, 10);
  sdrAlpha.setLimits(40, 1, 255);
  sdrAlpha.addEventHandler(this, "sdrAlpha_change");
  lblWidth = new GLabel(this, 10, 120, 50, 20, "Width");
  sdrWidth = new GSlider(this, 60, 120, 130, 16, 10);
  sdrWidth.setLimits(12, 10, 50);
  sdrWidth.addEventHandler(this, "sdrWidth_change");

  e = new String[] { 
    path + "puzzle0.png", path + "puzzle1.png", path + "puzzle2.png"
  };
  imgShowPuzzle = new GImageButton(this, 15, 160, e);
  imgShowPuzzle.addEventHandler(this, "imgButton1_Click1");

  e = new String[] { 
    path + "edge_n0.png", path + "edge_n1.png", path + "edge_n2.png"
  };
  btnNorth = new GImageButton(this, 115, 160, e);
  btnNorth.addEventHandler(this, "btnNorth_click");
  e = new String[] { 
    path + "edge_s0.png", path + "edge_s1.png", path + "edge_s2.png"
  };
  btnSouth = new GImageButton(this, 115, 160, e);
  btnSouth.addEventHandler(this, "btnSouth_click");
  e = new String[] { 
    path + "edge_e0.png", path + "edge_e1.png", path + "edge_e2.png"
  };
  btnEast = new GImageButton(this, 115, 160, e);
  btnEast.addEventHandler(this, "btnEast_click");
  e = new String[] { 
    path + "edge_w0.png", path + "edge_w1.png", path + "edge_w2.png"
  };
  btnWest = new GImageButton(this, 115, 160, e);
  btnWest.addEventHandler(this, "btnWest_click");

  btnBackTo2 = new GButton(this, 10, 260, 70, 20, "Back");
  btnBackTo2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnBackTo2.addEventHandler(this, "btnBackTo2_click");

  btnSave = new GButton(this, 120, 260, 70, 20, "SAVE");
  btnSave.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnSave.addEventHandler(this, "btnSave_click");

  pnlStage3.addControl(optDark);
  pnlStage3.addControl(optLight);
  pnlStage3.addControl(label3);
  pnlStage3.addControl(sdrAlpha);
  pnlStage3.addControl(btnNorth);
  pnlStage3.addControl(btnSouth);
  pnlStage3.addControl(btnEast);
  pnlStage3.addControl(btnWest);
  pnlStage3.addControl(imgShowPuzzle);
  pnlStage3.addControl(btnSave);
  pnlStage3.addControl(btnBackTo2);
  pnlStage3.addControl(lblDensity);
  pnlStage3.addControl(lblWidth);
  pnlStage3.addControl(sdrWidth);

  btnNewJigsaw = new GButton(this, 10, height - 60, 180, 30, "START A NEW JIGSAW");
  btnNewJigsaw.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  btnNewJigsaw.addEventHandler(this, "btnNewJigsaw_click");

  pnlFixed.addControl(pnlStage1);
  pnlFixed.addControl(pnlStage2);
  pnlFixed.addControl(pnlStage3);
  pnlFixed.addControl(btnNewJigsaw);
}

GPanel pnlFixed;
GPanel pnlStage1; 
GLabel lblTitle; 
GButton btnGetImage; 
GButton btnGoto2; 
GTextField txfTitle; 
GLabel lblDest; 
GLabel lblFolder; 
GPanel pnlStage2; 
GCustomSlider sdrNbrCols; 
GCustomSlider sdrNbrRows; 
GLabel label2; 
GButton btnGoto3; 
GButton btnBackTo1; 
GImageButton btnGridCol; 
GPanel pnlStage3; 
GLabel label3; 
GToggleGroup optGroup1; 
GOption optDark; 
GOption optLight; 
GSlider sdrAlpha; 
GImageButton btnNorth; 
GImageButton btnSouth; 
GImageButton btnEast; 
GImageButton btnWest; 
GImageButton imgShowPuzzle; 
GButton btnSave; 
GButton btnBackTo2; 
GLabel lblDensity; 
GLabel lblWidth; 
GSlider sdrWidth; 
GButton btnNewJigsaw; 