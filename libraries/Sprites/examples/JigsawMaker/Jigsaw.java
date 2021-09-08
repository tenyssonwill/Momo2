import java.awt.Point;
import java.util.LinkedList;

import processing.core.PApplet;
import processing.core.PImage;

public class Jigsaw {
  // Edit variables
  static public float editScale;
  static public float editOffsetX;
  static public float editOffsetY;
  static public float editBorder;
  // Display variables
  static public int displayOffsetX;
  static public int displayOffsetY;
  static public float displayScale;
  // Jigsaw piece data  
  public static int cols, rows;
  public static int pieceW, pieceH;


  private PApplet app;

  private final Edge[][] horzEdges;
  private final Edge[][] vertEdges;

  private JigsawPiece editPiece = null;

  public Jigsaw(PApplet app, int nbrAcross, int nbrDown, int pW, int pH) {
    this.app = app;
    horzEdges = new Edge[cols][rows+1];
    vertEdges = new Edge[cols+1][rows];

    // calc Edges
    int px, py = 0;
    for (int r = 0; r < rows + 1; r++) {
      px = 0;
      for (int c = 0; c < cols + 1; c++) {
        // Horz edges
        if (c < cols) {
          if (r == 0 || r == rows)
            horzEdges[c][r] = new Edge(app, Edge.HORZ_LINE, px, py, pieceW, pieceH);
          else if ( r < rows)
            horzEdges[c][r] = new Edge(app, Edge.HORZ_JOIN, px, py, pieceW, pieceH);
        }
        // Vert edges
        if (r < rows) {
          if (c == 0 || c == cols)
            vertEdges[c][r] = new Edge(app, Edge.VERT_LINE, px, py, pieceW, pieceH);
          else if ( r < rows)
            vertEdges[c][r] = new Edge(app, Edge.VERT_JOIN, px, py, pieceW, pieceH);
        }
        px += pieceW;
      }
      py += pieceH;
    }
  }

  /**
   * Modified flood fill algorithm to create jigsaw piece images.
   * 
   * @param picture
   * @param edges
   * @param col
   * @param row
   * @return
   */
  public PImage makePieceImage(PImage picture, PImage edges, int col, int row) {
    LinkedList<Point> q = new LinkedList<Point>();

    // Create a blank transparent piece
    int c = app.color(0, 0);
    //   PImage jsp = new PImage(2*pieceW, 2*pieceH, PApplet.ARGB);
    PImage jsp = app.createImage(2*pieceW, 2*pieceH, PApplet.ARGB);
    for (int i=0; i < jsp.pixels.length; i++)
      jsp.pixels[i] = c;
    jsp.updatePixels();

    // Calculate start position in source
    int x0, y0;
    x0 = col * pieceW - pieceW / 2;
    y0 = row * pieceH - pieceH / 2;
    Point p = new Point(x0 + pieceW, y0 + pieceH);
    // Get target and replacement colours
    int targetB = edges.get(p.x, p.y);
    int targetE = app.color(0);
    int rep = targetB - 1;
    int srcColor;

    q.addLast(p);
    while (!q.isEmpty ()) {
      p = q.removeFirst();
      c = edges.get(p.x, p.y);
      // If this pixel matches the target background or edge,
      // copy to piece image
      if (c == targetB || c == targetE) {
        srcColor = picture.get(p.x, p.y);
        jsp.set(p.x - x0, p.y - y0, srcColor);
      }
      // If it is background add NSEW positions to queue for 
      // further processing
      if (c == targetB) {
        edges.set(p.x, p.y, rep);
        if (p.x-1 >= 0)
          q.addLast(new Point(p.x-1, p.y));
        if (p.x < edges.width)
          q.addLast(new Point(p.x+1, p.y));
        if (p.y-1 >= 0)
          q.addLast(new Point(p.x, p.y-1));
        if (p.y+1 < edges.height)
          q.addLast(new Point(p.x, p.y+1));
      }
    }
    return jsp;
  }

  public boolean setEditPiece(int c, int r) {
    if (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (editPiece != null)
        editPiece.setEditMode(false);
      editPiece = new JigsawPiece(app, c, r, horzEdges[c][r], horzEdges[c][r+1], vertEdges[c+1][r], vertEdges[c][r]);
      editPiece.setEditMode(true);
      editOffsetX = (c - Jigsaw.editBorder) * pieceW; 
      editOffsetY = (r - Jigsaw.editBorder) * pieceH;
      return true;
    }
    return false;
  }

  /**
   * Draw all jigsaw cuts. 
   * 
   * Perform a transformation by a physical offset (offX, offY)
   * @param app
   * @param offX
   * @param offY
   * @param scale
   */
  public void drawJigsaw(int offX, int offY, float scale, int colour, float weight) {
    app.pushMatrix();
    app.translate(offX, offY);
    app.noFill();
    app.stroke(colour);
    app.strokeWeight(weight/scale);
    for (int r = 0; r < rows + 1; r++) {
      for (int c = 0; c < cols + 1; c++) {
        if (c < cols)
          horzEdges[c][r].drawEdge(offX, offY, scale);
        if (r < rows)
          vertEdges[c][r].drawEdge(offX, offY, scale);
      }
    }
    app.popMatrix();
  }

  public JigsawPiece getEditPiece() {
    return editPiece;
  }
}