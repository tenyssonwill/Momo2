import processing.core.PApplet;

public class JigsawPiece {

  static public final int NORTH = 0;
  static public final int SOUTH = 1;
  static public final int EAST = 2;
  static public final int WEST = 3;

  private PApplet app;

  private final Edge[] edge = new Edge[4];

  public final float jpx, jpy;
  public final int col, row;

  public JigsawPiece(PApplet app, int col, int row, Edge north, Edge south, Edge east, Edge west) {
    this.app = app;
    edge[NORTH] = north;
    edge[SOUTH] = south;
    edge[EAST] = east;
    edge[WEST] = west;
    jpx = edge[NORTH].getPx();
    jpy = edge[NORTH].getPy();
    this.row = row;
    this.col = col;
  }

  public void setEditMode(boolean enable ) {
    for (Edge e : edge)
      e.setEditMode(enable);
  }

  public void flipEdge(int dir) {
    edge[dir].mirror();
  }

  public void drawPieceEdit() {
    int pw = Jigsaw.pieceW;
    int ph = Jigsaw.pieceH;
    app.pushMatrix();
    app.translate(jpx - col * pw, jpy - row * ph);
    app.scale(Jigsaw.editScale);
    app.translate(Jigsaw.editBorder * pw, Jigsaw.editBorder * ph);
    // Draw permissible area for jigsaw piece contour
    app.noStroke();
    app.fill(255, 255, 200);
    float dx = Jigsaw.editBorder * pw;
    float dy = Jigsaw.editBorder * ph;
    if (edge[NORTH].isJoin())
      app.rect(pw/2, 0, pw, 2 * dy);
    if (edge[SOUTH].isJoin())
      app.rect(pw/2, ph, pw, 2 * dy);
    if (edge[WEST].isJoin())
      app.rect(0, ph/2, 2 * dx, ph);
    if (edge[EAST].isJoin())
      app.rect(pw, ph/2, 2 * dx, ph);
    // Draw contour for editing
    edge[NORTH].drawEdgeEdit(0, 0);
    edge[WEST].drawEdgeEdit(0, 0);
    edge[SOUTH].drawEdgeEdit( 0, ph);
    edge[EAST].drawEdgeEdit(pw, 0);
    app.popMatrix();
  }
}