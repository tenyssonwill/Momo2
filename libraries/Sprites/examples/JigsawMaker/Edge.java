import processing.core.PApplet;
import processing.event.MouseEvent;


public class Edge {
  // Edge type. Lines are the straight edges and joins are the rest
  static final int VERT_LINE = 1;
  static final int HORZ_LINE = 2;
  static final int VERT_JOIN = 4;
  static final int HORZ_JOIN = 8;
  // Whether the edge is being edited or not
  static final int EDIT = 32;
  static final int SHOW = 33;
  static float SEL_BOX_SIZE  = 6.0f;
  static float SELECTED_BOX_SIZE  = 8.0f;

  private PApplet app;
  private int type;
  private int mode = SHOW;

  private float px, py; 
  private float[] x, y;

  float lastX, lastY;

  private int mouseIsOver = -1;

  public Edge(PApplet app, int type, float px, float py, float w, float h) {
    this.app = app;
    this.type = type;
    this.px = px;
    this.py = py;

    switch(type) {
    case HORZ_JOIN:
    case VERT_JOIN:
      calcRandomEdge();
      break;
    case HORZ_LINE:
      x = new float[] { 
        0, 100
      };
      y = new float[] { 
        0, 0
      };
      break;
    case VERT_LINE:
      x = new float[] { 
        0, 0
      };
      y = new float[] { 
        0, 100
      };
      break;
    }
    for (int i = 0; i < x.length; i++) {
      x[i] *= w/100;
      y[i] *= h/100;
    }
  }

  public boolean isLine() {
    return (type == HORZ_LINE || type == VERT_LINE);
  }

  public boolean isJoin() {
    return (type == HORZ_JOIN || type == VERT_JOIN);
  }


  public void mirror() {
    if (type == VERT_JOIN) {
      for (int i = 0; i < x.length; i++)
        x[i] *= -1;
    } else if (type == HORZ_JOIN) {
      for (int i = 0; i < y.length; i++)
        y[i] *= -1;
    }
  }


  /**
   * Need to be careful when we register / unregister for mouse
   * events
   * @param app
   */
  public void setEditMode(boolean enable) {
    if (type == VERT_JOIN || type == HORZ_JOIN) {
      if (enable == true && mode == SHOW) {
        app.registerMethod("mouseEvent", this);
        mode = EDIT;
      } else if (enable == false && mode == EDIT) {
        app.unregisterMethod("mouseEvent", this);
        mode = SHOW;
        mouseIsOver = -1;
      }
    }
  }

  public void mouseEvent(MouseEvent event) {
    // Convert to real world coordinates
    float mx = (event.getX()/Jigsaw.editScale + Jigsaw.editOffsetX);
    float my = (event.getY()/Jigsaw.editScale + Jigsaw.editOffsetY);
    float dx, dy;
    switch(event.getAction()) {
    case MouseEvent.PRESS:
      lastX = mx;
      lastY = my;
      mouseOver(mx, my);
      break;
    case MouseEvent.MOVE:
      mouseOver(mx, my);
      //      System.out.println("Jigsaw position ["+mx+", "+my+"]  Over ["+px+", "+py+"]");
      break;
    case MouseEvent.DRAG:
      if (mouseIsOver != -1) {
        dx = mx - lastX;
        dy = my - lastY;
        x[mouseIsOver] += dx;
        y[mouseIsOver] += dy;
        if (mouseIsOver % 3 == 0) { // bezier end point
          if (mouseIsOver > 0 && mouseIsOver < x.length - 1) {
            x[mouseIsOver - 1] += dx;
            y[mouseIsOver - 1] += dy;
            x[mouseIsOver + 1] += dx;
            y[mouseIsOver + 1] += dy;
          }
        } else { // control point
          x[mouseIsOver] += dx;
          y[mouseIsOver] += dy;
          int fulcrum = (mouseIsOver % 3 == 1)? mouseIsOver - 1 : mouseIsOver + 1;
          if (fulcrum > 0 && fulcrum < x.length - 1) {
            int partner = 2 * fulcrum - mouseIsOver;
            float angle = PApplet.PI + PApplet.atan2(y[mouseIsOver] - y[fulcrum], x[mouseIsOver] - x[fulcrum]);
            float len = PApplet.dist(x[partner], y[partner], x[fulcrum], y[fulcrum]);
            x[partner] = x[fulcrum] + PApplet.cos(angle) * len;
            y[partner] = y[fulcrum] + PApplet.sin(angle) * len;
          }
        }
        lastX = mx;
        lastY = my;
      }
    }
  }

  public int mouseOver(float mx, float my) {
    mouseIsOver = -1;
    mx -= px;
    my -= py;
    if (type == VERT_JOIN || type == HORZ_JOIN) {
      for (int i = 1; i < x.length - 1; i++) {
        if (PApplet.abs(mx - x[i]) < SEL_BOX_SIZE/Jigsaw.editScale && PApplet.abs(my - y[i]) < SEL_BOX_SIZE/Jigsaw.editScale) {
          mouseIsOver = i;
          break;
        }
      }
    }
    return mouseIsOver;
  }

  public void drawEdge(int offX, int offY, float scale) {
    app.pushMatrix();
    app.scale(scale);
    app.translate(px, py);
    if (type == VERT_LINE || type == HORZ_LINE) {
      app.line(x[0], y[0], x[1], y[1]);
    } else {
      for (int i = 0; i < x.length - 1; i += 3) {
        app.bezier(x[i], y[i], x[i+1], y[i+1], x[i+2], y[i+2], x[i+3], y[i+3]);
      }
    }
    app.popMatrix();
  }


  public void drawEdgeEdit(float offsetW, float offsetH) {
    app.pushMatrix();
    app.translate(offsetW, offsetH);
    app.noFill();
    app.strokeWeight(1.4f/Jigsaw.editScale);
    if (type == VERT_LINE || type == HORZ_LINE) {
      app.stroke(0);
      app.line(x[0], y[0], x[1], y[1]);
    } else {
      app.noFill();
      app.stroke(255, 0, 255);
      // Draw tangents
      for (int i = 0; i < x.length; i += 3) {
        if (i > 0)
          app.line(x[i-1], y[i-1], x[i], y[i]);
        if (i < 17)
          app.line(x[i], y[i], x[i+1], y[i+1]);
      }
      // Draw edge shape
      app.strokeWeight(1.6f/Jigsaw.editScale);
      app.stroke(0);
      for (int i = 0; i < x.length - 1; i += 3) {
        app.bezier(x[i], y[i], x[i+1], y[i+1], x[i+2], y[i+2], x[i+3], y[i+3]);
      }
      // Draw selectors
      app.strokeWeight(1.1f/Jigsaw.editScale);
      app.fill(255);
      for (int i = 1; i < x.length - 1; i++) {
        app.stroke(255, 0, 0);
        if (mouseIsOver != i)
          app.stroke(100, 100, 255);
        app.rect(x[i], y[i], SEL_BOX_SIZE/Jigsaw.editScale, SEL_BOX_SIZE/Jigsaw.editScale);
      }
    }
    app.popMatrix();
  }

  /**
   * Calculates a random join
   */
  public void calcRandomEdge() {
    x = new float[19];
    y = new float[19];
    // Fix end points
    x[0] = 0;           
    y[0] = 0;
    x[3] = app.random(38, 40);  
    y[3] = app.random(-3, 3);
    x[6] = app.random(27, 33);  
    y[6] = app.random(13, 19);
    x[9] = app.random(46, 54);  
    y[9] = app.random(24, 30);
    x[12] = app.random(67, 73); 
    y[12] = app.random(13, 19);
    x[15] = app.random(62, 65); 
    y[15] = app.random(-3, 3);
    x[18] = 100;         
    y[18] = 0;
    // Fix control points
    float angle, sinA, cosA, len;
    // point 1
    angle = PApplet.radians(app.random(5, 10));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(10, 14);
    x[1] = x[0] + len * cosA;  
    y[1] = y[0] + len * sinA; 
    // point 17
    angle = PApplet.radians(app.random(185, 195));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(10, 14);
    x[17] = x[18] + len * cosA;  
    y[17] = y[18] + len * sinA; 
    // points 2 and 4
    angle = PApplet.radians(app.random(70, 90));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(10, 15);
    x[2] = x[3] - len * cosA;  
    y[2] = y[3] - len * sinA; 
    len = app.random(9, 13);
    x[4] = x[3] + len * cosA;  
    y[4] = y[3] + len * sinA; 
    // Points 14 16
    angle = PApplet.radians(app.random(270, 290));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(9, 13);
    x[14] = x[15] - len * cosA;  
    y[14] = y[15] - len * sinA; 
    len = app.random(10, 15);
    x[16] = x[15] + len * cosA;  
    y[16] = y[15] + len * sinA; 
    // Points 5 and 7
    angle = PApplet.radians(app.random(85, 95));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(9, 12);
    x[5] = x[6] - len * cosA;  
    y[5] = y[6] - len * sinA; 
    len = app.random(9, 12);
    x[7] = x[6] + len * cosA;  
    y[7] = y[6] + len * sinA; 
    // points 11  and 13
    angle = PApplet.radians(app.random(265, 275));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(9, 12);
    x[11] = x[12] - len * cosA;  
    y[11] = y[12] - len * sinA; 
    len = app.random(9, 12);
    x[13] = x[12] + len * cosA;  
    y[13] = y[12] + len * sinA; 
    // points 8 and 10
    angle = PApplet.radians(app.random(-10, 10));
    sinA = PApplet.sin(angle);
    cosA = PApplet.cos(angle);
    len = app.random(6, 12);
    x[8] = x[9] - len * cosA;  
    y[8] = y[9] - len * sinA; 
    len = app.random(6, 12);
    x[10] = x[9] + len * cosA;  
    y[10] = y[9] + len * sinA; 

    if (type == VERT_JOIN) {
      float temp;
      for (int p = 0; p < x.length; p++) {
        temp = x[p];
        x[p] = y[p];
        y[p] = temp;
      }
    }
    if (app.random(0, 100) < 50)
      mirror();
  }

  /**
   * @return the px
   */
  public float getPx() {
    return px;
  }

  /**
   * @return the py
   */
  public float getPy() {
    return py;
  }

  public String toString() {
    String s =  "Edge ["+px+", "+py+"]  ";
    if (x[0] ==  x[x.length-1])
      s += "WEST";
    else
      s += "NORTH";
    return s;
  }
}