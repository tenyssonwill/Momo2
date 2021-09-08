import processing.core.PApplet;
import processing.core.PImage;

public class JigsawSaver implements Runnable {
  public static float progress;
  public static int finished = 0;

  private PApplet app;
  private Thread runner;
  private Jigsaw jigsaw;

  private String folder;
  private String title;
  private PImage puzzleOrg;
  private PImage puzzlePic;
  private PImage puzzleEdges;


  /**
   * @param app
   * @param jigsaw
   * @param puzzleOrg
   * @param puzzlePic
   * @param puzzleEdges
   * @param title
   * @param folder
   */
  public JigsawSaver(PApplet app, Jigsaw jigsaw, PImage puzzleOrg, PImage puzzlePic, 
    PImage puzzleEdges, String title, String folder) {
    super();
    this.app = app;
    this.jigsaw = jigsaw;
    this.puzzleOrg = puzzleOrg;
    this.puzzlePic = puzzlePic;
    this.puzzleEdges = puzzleEdges;
    this.title = title;
    this.folder = folder;
  }

  public void start() {
    progress = 0;
    finished = 0;
    runner = new Thread(this, "Make jigsaw");
    runner.start();
  }

  public void run() {
    String destFolder = app.dataPath("") + "/" + folder + "/";
    StringBuilder s;
    int nbrPieces = Jigsaw.cols * Jigsaw.rows;
    float deltaProgress = 1.0f / (nbrPieces + 1);
    String[] jinfo = new String[5];
    jinfo[0] = "" + title + " (" + nbrPieces + " pieces)";
    jinfo[1] = "" + Jigsaw.cols;
    jinfo[2] = "" + Jigsaw.rows;
    jinfo[3] = "" + Jigsaw.pieceW;
    jinfo[4] = "" + Jigsaw.pieceH;
    app.saveStrings(destFolder + "info.txt", jinfo);
    puzzleOrg.save(destFolder + "picture.jpg");
    progress += deltaProgress;
    int n = 0;
    PImage piece = null;
    for (int r = 0; r < Jigsaw.rows; r++) {
      for (int c = 0; c < Jigsaw.cols; c++) {
        piece = jigsaw.makePieceImage(puzzlePic, puzzleEdges, c, r);
        piece.save(destFolder + "piece_" + PApplet.nf(n, 3) + ".png");
        n++;
        progress += deltaProgress;
      }
    }
    finished = 1;
  }
}