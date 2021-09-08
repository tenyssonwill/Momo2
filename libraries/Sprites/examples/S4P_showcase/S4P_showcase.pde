/**
This sketch allows you to experiment with many of the
features of the Sprite library.

In particular movement and collision detection methods
avaialable.

This sketch requires the G4P version 3.1.1 or later.

created by Peter Lager
*/

import g4p_controls.*;

import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

Sprite[] sprite = new Sprite[3];
GSlider sdrScale, sdrRotation, sdrSpeed;
GSlider sdrAcceleration, sdrDirection, sdrWorldScale;
GCheckbox cbxColAreaOn;
GButton btnResetScale, btnResetSpeed, btnResetAccel;
GButton btnResetWorld;

Domain domain;  
// Sprite that has been clicked on
Sprite selSprite;

final int MAX_SPEED = 200;

String instruction;

StopWatch timer;

public void setup() {
  size(800, 600);
  cursor(CROSS);
  G4P.setCursor(CROSS);
  registerMethod("pre", this);
  registerMethod("mouseEvent", this);    

  // Create the GUI to control this sketch using G4P
  int dy = 16; // used to separate the componets vertically    
  GLabel lblScale = new GLabel(this, 10, 10, 200, dy, "Scale");
  sdrScale = new GSlider(this, 10, 10+dy, 180, 16, 10);
  sdrScale.setLimits(100, 50, 150);
  btnResetScale = new GButton(this, 194, 10+dy, 16, dy, "1");
  btnResetScale.setLocalColorScheme(G4P.RED_SCHEME);

  GLabel lblRotation = new GLabel(this, 10, 10+2*dy, 200, dy, "Rotation");
  sdrRotation = new GSlider(this, 10, 10+3*dy, 200, dy, 10);
  sdrRotation.setLimits(0, 0, 360);

  GLabel lblSpeed = new GLabel(this, 10, 10+4*dy, 200, dy, "Speed");
  sdrSpeed = new GSlider(this, 10, 10+5*dy, 180, dy, 10);
  sdrSpeed.setLimits(0, 0, MAX_SPEED);
  btnResetSpeed = new GButton(this, 194, 10+5*dy, 16, dy, "0");
  btnResetSpeed.setLocalColorScheme(G4P.RED_SCHEME);

  GLabel lblAcceleration = new GLabel(this, 10, 10+6*dy, 200, dy, "Acceleration");
  sdrAcceleration = new GSlider(this, 10, 10+7*dy, 180, dy, 10);
  sdrAcceleration.setLimits(0, 0, 50);
  btnResetAccel = new GButton(this, 194, 10+7*dy, 16, dy, "0");
  btnResetAccel.setLocalColorScheme(G4P.RED_SCHEME);

  GLabel lblDirection = new GLabel(this, 10, 10+8*dy, 200, dy, "Direction");
  sdrDirection = new GSlider(this, 10, 10+9*dy, 200, dy, 10);
  sdrDirection.setLimits(0, -180, 180);

  cbxColAreaOn = new GCheckbox(this, 10, 20+10*dy, 200, 16, "Show Collision Areas");


  // Create all the sprite stuff 
  // Do not show collision areas
  S4P.collisionAreasVisible = false;
  // Constrain sprites to small portion of the world
  Domain domain = new Domain(220, 0, width, height);

  GLabel lblWorldScale = new GLabel(this, 10, 10+12*dy, 200, 20, "World Scale");
  sdrWorldScale = new GSlider(this, 10, 10+13*dy, 200, dy, 10);
  sdrWorldScale.setLimits(30, 10, 50);
  btnResetWorld = new GButton(this, 10, 10+15*dy, 200, 20, "Reset World Display");

  // Create the sprites
  sprite[0] = new Sprite(this, "ct_balloon.png", 10);
  sprite[0].setVelXY(13.8f, 14.9f);
  sprite[0].setXY(320, 100);
  sprite[0].setDomain(domain, Sprite.REBOUND);
  sprite[0].respondToMouse(true);
  sprite[0].setZorder(20);

  sprite[1] = new Sprite(this, "ct_chopper.png", 10);
  sprite[1].setVelXY(-12.8f, 18.9f);
  sprite[1].setXY(width-120, 100);
  sprite[1].setDomain(domain, Sprite.REBOUND);
  sprite[1].respondToMouse(true);
  sprite[1].setZorder(10);

  sprite[2] = new Sprite(this, "ct_plane.png", 10);
  sprite[2].setVelXY(-8.8f, - 10.9f);
  sprite[2].setXY(width-120, height-100);
  sprite[2].setDomain(domain, Sprite.REBOUND);
  sprite[2].respondToMouse(true);
  sprite[2].setZorder(5);

  selSprite = sprite[0];
  updateGUI();

  instruction = "You can select a sprite to adjust by clicking on it.\n";
  instruction += "In this demo you can change which part of the world to ";
  instruction+= " display by clicking and dragging in the pane on the ";
  instruction += "right. \n Notice that the sprites are still ";
  instruction += "constrained by the original domain (screen)\n.";
  instruction += "The sprites collision area depends on rotation ";
  instruction += "and scale (see reference for more info). ";

  timer = new StopWatch();
}

/**
 * Method provided by Processing and is called every 
 * loop before the draw method. It has to be activated
 * with the following statement in setup() <br>
 * <pre>registerPre(this);</pre>
 */
public void pre() {
  // Calculate time since last called and update 
  // sprite's state
  // Bit of a fix to cap velocities due to 
  // acceleration otherwise my be difficult
  // to select sprite with mouse.
  for (int i = 0; i < 3; i++) {
    if (sprite[i].getAcceleration() > 0) {
      if (sprite[i].getSpeed() > MAX_SPEED) {
        sprite[i].setSpeed(MAX_SPEED);
        sprite[i].setAcceleration(0);
      }
    }
  }
}

public void draw() {
  double deltaTime = timer.getElapsedTime();
  background(color(192, 192, 255));
  updateGUI();
  S4P.updateSprites(deltaTime);
  S4P.drawSprites();

  // Draw GUI after sprites
  noStroke();
  fill(color(128, 128, 255));
  rect(0, 0, 220, height);
  fill(0);
  text(instruction, 10, 300, 200, 300);
}

public void mouseEvent(MouseEvent event) {
  switch(event.getAction()) {
  case MouseEvent.DRAG:
    if (pmouseX > 220 && mouseX > 220) {
      PointD2D old = S4P.pixel2world(pmouseX, pmouseY);
      PointD2D curr = S4P.pixel2world(mouseX, mouseY);
      S4P.moveWorldBy(old.x-curr.x, old.y-curr.y);
    }
    break;
  }
}

/**
 * S4P Eventhandler called mouse is PRESSED, RELEASED
 * or CLICKED over the sprite.
 * 
 * @param sprite
 */
public void handleSpriteEvents(Sprite sprite) { 
  if (sprite.eventType == Sprite.CLICK) {
    selSprite = sprite;
    updateGUI();
  }
}

/**
 * Update the GUI components based on selected sprite
 */
public void updateGUI() {
  // The second parameter in setValue prevents events being created
  // and get in with a fight with handleSliderEvents
  sdrScale.setValue((float)selSprite.getScale()*100);
  sdrSpeed.setValue((float) selSprite.getSpeed());
  sdrAcceleration.setValue((float) selSprite.getAcceleration());
  sdrRotation.setValue((float) (PApplet.degrees((float) selSprite.getRot())));
  sdrDirection.setValue((float) (PApplet.degrees((float) selSprite.getDirection())));
}

/**
 * G4P Eventhandler
 * @param checkbox
 */
public void handleToggleControlEvents(GToggleControl checkbox, GEvent event) {
  if (checkbox == cbxColAreaOn)
    S4P.collisionAreasVisible = checkbox.isSelected();
}

/**
 * G4P Eventhandler
 * @param slider
 */
public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if (slider == sdrScale)
    selSprite.setScale(slider.getValueF()/100.0f);
  else if (slider == sdrSpeed)
    selSprite.setSpeed(slider.getValueF());
  else if (slider == sdrAcceleration)
    selSprite.setAcceleration(slider.getValueF());
  else if (slider == sdrRotation)
    selSprite.setRot(radians(sdrRotation.getValueF()));
  else if (slider == sdrDirection)
    selSprite.setDirection(radians(sdrDirection.getValueF()));
  else if (slider == sdrWorldScale)
    S4P.resizeWorld(30.0f/slider.getValueF());
}

/**
 * G4P Eventhandler
 * @param button
 */
public void handleButtonEvents(GButton button, GEvent event) {
  if (button == btnResetScale) {
    sdrScale.setValue(100);
    selSprite.setScale(1.0f);
  }
  else if (button == btnResetSpeed) {
    sdrSpeed.setValue(0);
    selSprite.setSpeed(0);
  }
  else if (button == btnResetAccel) {
    sdrAcceleration.setValue(0);
    selSprite.setAcceleration(0);
  }
  else if (button == btnResetWorld) {
    S4P.resetWorld();
    sdrWorldScale.setValue(30);
  }
}
