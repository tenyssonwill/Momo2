// Author: David Hanna
//
// Components are attached to Game Objects to provide their data and behaviour.
//======================================================================================================



//-------------------------------------------------------------------
// INTERFACE
//-------------------------------------------------------------------



public enum ComponentType
{
  RENDER,
  RIGID_BODY,
  PLAYER_CONTROLLER,
  PLATFORM_MANAGER_CONTROLLER,
  BONUS_PLATFORM_MANAGER,
  COIN_EVENT_HANDLER,
  COIN_SPAWNER_CONTROLLER,
  SCORE_TRACKER,
  CALIBRATE_WIZARD,
  COUNTDOWN,
  BUTTON,
  LEVEL_DISPLAY,
  LEVEL_PARAMETERS,
  MUSIC_PLAYER,
  SLIDER,
  STATS_COLLECTOR,
  POST_GAME_CONTROLLER,
  ANIMATION_CONTROLLER,
  GAME_OPTIONS_CONTROLLER,
  IO_OPTIONS_CONTROLLER,
  CALIBRATE_CONTROLLER,
  ID_COUNTER,
  MODAL,
  CALIBRATION_DISPLAY,
  FITTS_STATS,
  LOG_RAW_DATA,
  BONUS_SCORE,
  SINGLE_COUNTER,
}

public interface IComponent
{
  public void            destroy();
  public void            fromXML(XML xmlComponent);
  public ComponentType   getComponentType();
  public IGameObject     getGameObject();
  public void            update(int deltaTime);
}


// Can't declare here without implementing, so just a comment made to let you know it's here.
// Constructs and returns new component from XML data.
//
// IComponent componentFactory(XML xmlComponent);

//-----------------------------------------------------------------
// IMPLEMENTATION
//-----------------------------------------------------------------

public abstract class Component implements IComponent
{
  protected IGameObject gameObject;
  
  public Component(IGameObject _gameObject)
  {
    gameObject = _gameObject;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  // There is no need to change this in subclasses.
  @Override final public IGameObject getGameObject()
  {
    return gameObject;
  }
  
  // This is the only one enforced on all subclasses.
  @Override abstract public ComponentType getComponentType();
  
  @Override public void update(int deltaTime)
  {
  }
}

public class RenderComponent extends Component
{
  public class OffsetPShape
  {
    public PShape pshape;
    public PVector translation;
    public PVector scale;
    
    public OffsetPShape(PShape _pshape, PVector _translation, PVector _scale)
    {
      pshape = _pshape;
      translation = _translation;
      scale = _scale;
    } 
  }
  

  public class OffsetPImage
  {
    public String pimageName;
    public PVector translation;
    public PVector scale;

    public OffsetPImage(String _pimageName, PVector _translation, PVector _scale)
    {
      pimageName = _pimageName;
      translation = _translation;
      scale = _scale;
    }
  }
  
  public class OffsetSheetSprite
  {
    public Sprite sheetSprite;
    public PVector translation;
    public PVector scale;
    public String zone;
    public long initTime;
    public int timeLapsed;
    public int flashCount;
    
    public OffsetSheetSprite(Sprite _sheetSprite, PVector _translation, PVector _scale, String _zone, long _initTime, int _timeLapsed)
    {
      sheetSprite = _sheetSprite;
      translation = _translation;
      scale = _scale;
      zone = _zone;
      initTime = _initTime;
      timeLapsed = _timeLapsed;
    }
  }
  
  public class Text
  {
    public String string;
    public PFont font;
    public int alignX;
    public int alignY;
    public PVector translation;
    public color fillColor;
    public color strokeColor;
    public float strokeWeight;
    
    public Text(String _string, PFont _font, int _alignX, int _alignY, PVector _translation, color _fillColor, color _strokeColor, float _strokeWeight)
    {
      string = _string;
      font = _font;
      alignX = _alignX;
      alignY = _alignY;
      translation = _translation;
      fillColor = _fillColor;
      strokeColor = _strokeColor;
      strokeWeight = _strokeWeight;
    }
  }
  
  // Used only for the sprites on the Customize page
  public class CustomSprite
  {
    public OffsetPImage pimage;
    public int cost;
    public String actualSrc;
    public int horzCount;
    public int vertCount;
    public int defaultCount;
    public float frameFreq;
    public boolean unlocked;
    public boolean active;
    public String name;

    public CustomSprite(OffsetPImage _pimage, int _cost, String _actualSrc, int _horzCount, int _vertCount, int _defaultCount, float _frameFreq, String _unlocked, String _active, String _name)
    {
      pimage = _pimage;
      cost = _cost;
      actualSrc = _actualSrc;
      horzCount = _horzCount;
      vertCount = _vertCount;
      defaultCount = _defaultCount;
      frameFreq = _frameFreq;
      name = _name;
      if (_unlocked.equals("true"))
      {
        unlocked = true;
      }
      else {
        unlocked = false;
      }

      if (_active.equals("true"))
      {
        active = true;
      }
      else {
        active = false;
      }
    }
  }

  private long totalTime;
  private ArrayList<OffsetPShape> offsetShapes;
  private ArrayList<Text> texts;
  private ArrayList<OffsetSheetSprite> offsetSheetSprites;
  private ArrayList<OffsetPImage> offsetPImages;
  private ArrayList<CustomSprite> customSprites;

  public RenderComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    offsetShapes = new ArrayList<OffsetPShape>();
    texts = new ArrayList<Text>();
    offsetSheetSprites = new ArrayList<OffsetSheetSprite>();
    offsetPImages = new  ArrayList<OffsetPImage>();
    customSprites = new ArrayList<CustomSprite>();
    totalTime = 0;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlRenderable : xmlComponent.getChildren())
    {
      if (xmlRenderable.getName().equals("Point"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(POINT, 0.0, 0.0), 
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Line"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            LINE,
            xmlRenderable.getFloat("x1"), xmlRenderable.getFloat("y1"),
            xmlRenderable.getFloat("x2"), xmlRenderable.getFloat("y2")
          ), 
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Triangle"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            TRIANGLE,
            xmlRenderable.getFloat("x1"), xmlRenderable.getFloat("y1"),
            xmlRenderable.getFloat("x2"), xmlRenderable.getFloat("y2"),
            xmlRenderable.getFloat("x3"), xmlRenderable.getFloat("y3")
          ),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Quad"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            QUAD,
            xmlRenderable.getFloat("x1"), xmlRenderable.getFloat("y1"),
            xmlRenderable.getFloat("x2"), xmlRenderable.getFloat("y2"),
            xmlRenderable.getFloat("x3"), xmlRenderable.getFloat("y3"),
            xmlRenderable.getFloat("x4"), xmlRenderable.getFloat("y4")
          ),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Rect"))
      {
        OffsetPShape offsetShape = new OffsetPShape( 
          createShape(RECT, 0.0, 0.0, 1.0, 1.0),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("halfWidth"), xmlRenderable.getFloat("halfHeight"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Ellipse"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(ELLIPSE, 0.0, 0.0, 1.0, 1.0),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("halfWidth"), xmlRenderable.getFloat("halfHeight"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Arc"))
      {
        OffsetPShape offsetShape = new OffsetPShape(
          createShape(
            ARC,
            0.0, 0.0,
            1.0, 1.0,
            xmlRenderable.getFloat("startAngle"), xmlRenderable.getFloat("stopAngle")
          ),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("halfWidth"), xmlRenderable.getFloat("halfHeight"))
        );
        parseShapeComponents(xmlRenderable, offsetShape);
        offsetShapes.add(offsetShape);
      }
      else if(xmlRenderable.getName().equals("SVG")){
         OffsetPShape offsetShape = new OffsetPShape(
         loadShape(xmlRenderable.getString("src")),
          new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
          new PVector(xmlRenderable.getFloat("width"), xmlRenderable.getFloat("height"))
        );
         offsetShapes.add(offsetShape);
      }
      else if (xmlRenderable.getName().equals("Sprite")){
       for (XML xmlSpriteComponent : xmlRenderable.getChildren()){
         int timeLapsed = 0;
         if(gameObject.getTranslation().y < 115)
         {
          timeLapsed = (int)random(2000, 5000);
         }
         else if(gameObject.getTranslation().y < 191)
         {
           timeLapsed = (int)random(7000, 11000);
         }
         else if(gameObject.getTranslation().y < 267)
         {
          timeLapsed = (int)random(13000, 17000);
         }
         else if(gameObject.getTranslation().y < 343)
         {
          timeLapsed = (int)random(19000, 23000);
         }
         else if(gameObject.getTranslation().y < 419)
         {
          timeLapsed = (int)random(25000, 29000);
         }
         else if(gameObject.getTranslation().y < 490)
         {
          timeLapsed = (int)random(31000, 35000);
         }
         else
         {
           timeLapsed = (int)random(7000, 35000);
         }
         if(xmlSpriteComponent.getName().equals("SpriteSheet")){
           OffsetSheetSprite offsetSheetSprite = new OffsetSheetSprite(
               new Sprite(Momo2.this, xmlSpriteComponent.getString("src"),xmlSpriteComponent.getInt("horzCount"), xmlSpriteComponent.getInt("vertCount"), xmlSpriteComponent.getInt("zOrder")),
               new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
               new PVector(1, (xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height"))),
               xmlSpriteComponent.getString("zone"), totalTime, timeLapsed 
            );
            offsetSheetSprite.sheetSprite.setFrameSequence(0, xmlSpriteComponent.getInt("defaultCount"), xmlSpriteComponent.getFloat("farmeFreq"));  
            offsetSheetSprite.sheetSprite.setDomain(-100,-100,width+100,height+100,Sprite.HALT);
            offsetSheetSprite.sheetSprite.setScale(xmlSpriteComponent.getFloat("scaleHeight")/xmlSpriteComponent.getFloat("height"));
            offsetSheetSprites.add(offsetSheetSprite);
         }
          else if(xmlSpriteComponent.getName().equals("Image")){
            OffsetPImage offsetsprite = new OffsetPImage(
              xmlSpriteComponent.getString("src"),
              new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
              new PVector(xmlSpriteComponent.getFloat("width"), xmlSpriteComponent.getFloat("height"))
            );
            offsetPImages.add(offsetsprite);
         }
       }
     }
     else if (xmlRenderable.getName().equals("Text"))
      {
        int alignX = CENTER;
        int alignY = BASELINE;
        String stringAlignX = xmlRenderable.getString("alignX");
        String stringAlignY = xmlRenderable.getString("alignY");
        
        if (stringAlignX.equals("left"))
        {
          alignX = LEFT;
        }
        else if (stringAlignX.equals("center"))
        {
          alignX = CENTER;
        }
        else if (stringAlignX.equals("right"))
        {
          alignX = RIGHT;
        }
        
        if (stringAlignY.equals("baseline"))
        {
          alignY = BASELINE;
        }
        else if (stringAlignY.equals("top"))
        {
          alignY = TOP;
        }
        else if (stringAlignY.equals("center"))
        {
          alignY = CENTER;
        }
        else if (stringAlignY.equals("bottom"))
        {
          alignY = BOTTOM;
        }
        
        float[] strokeWeight = new float[1];
        color[] fillAndStrokeColor = parseColorComponents(xmlRenderable, strokeWeight);
        if(xmlRenderable.getString("fontName").equals("Moire"))
        {
          texts.add(new Text(
            xmlRenderable.getString("string"),
            createFont("fonts/Raleway-Heavy.ttf", xmlRenderable.getInt("size"), xmlRenderable.getString("antialiasing").equals("true") ? true : false),
            alignX,
            alignY,
            new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
            fillAndStrokeColor[0],
            fillAndStrokeColor[1],
            strokeWeight[0]
          ));
        }
        else if(xmlRenderable.getString("fontName").equals("monofonto"))
        {
          texts.add(new Text(
            xmlRenderable.getString("string"),
            createFont("fonts/monofonto.ttf", xmlRenderable.getInt("size"), xmlRenderable.getString("antialiasing").equals("true") ? true : false),
            alignX,
            alignY,
            new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
            fillAndStrokeColor[0],
            fillAndStrokeColor[1],
            strokeWeight[0]
          ));
        }
        else{
          texts.add(new Text(
            xmlRenderable.getString("string"),
            createFont("fonts/testfont.ttf", xmlRenderable.getInt("size"), xmlRenderable.getString("antialiasing").equals("true") ? true : false),
            alignX,
            alignY,
            new PVector(xmlRenderable.getFloat("x"), xmlRenderable.getFloat("y")),
            fillAndStrokeColor[0],
            fillAndStrokeColor[1],
            strokeWeight[0]
          ));
        }
      }
      else if (xmlRenderable.getName().equals("CustomSprite"))
      {
        for (XML xmlSpriteComponent : xmlRenderable.getChildren()){
         if(xmlSpriteComponent.getName().equals("SpriteSheet")){
           CustomSprite customSprite = new CustomSprite(
                 new OffsetPImage(
                 xmlSpriteComponent.getString("src"),
                 new PVector(xmlSpriteComponent.getFloat("x"), xmlSpriteComponent.getFloat("y")),
                 new PVector(xmlSpriteComponent.getFloat("width"), (xmlSpriteComponent.getFloat("height")))),
                 xmlRenderable.getInt("cost"),
                 xmlRenderable.getString("actualSrc"),
                 xmlSpriteComponent.getInt("horzCount"),
                 xmlSpriteComponent.getInt("vertCount"),
                 xmlSpriteComponent.getInt("defaultCount"),
                 xmlSpriteComponent.getFloat("farmeFreq"),
                 xmlRenderable.getString("unlocked"),
                 xmlRenderable.getString("active"),
                 xmlRenderable.getString("name")
            );
            offsetPImages.add(customSprite.pimage);
            customSprites.add(customSprite);
          }
        }
      }
    }
  }
  
  private void parseShapeComponents(XML xmlShape, OffsetPShape offsetShape)
  {
    float[] strokeWeight = new float[1];
    color[] fillAndStrokeColor = parseColorComponents(xmlShape, strokeWeight);
    offsetShape.pshape.setFill(fillAndStrokeColor[0]);
    offsetShape.pshape.setStroke(fillAndStrokeColor[1]);
    offsetShape.pshape.setStrokeWeight(strokeWeight[0]);
  }
  
  // returns fill color in position 0 and stroke color in position 1
  private color[] parseColorComponents(XML xmlParent, float[] outStrokeWeight)
  {
    color[] fillAndStrokeColor = new color[2];
    
    for (XML xmlShapeComponent : xmlParent.getChildren())
    {
      if (xmlShapeComponent.getName().equals("FillColor"))
      {
        fillAndStrokeColor[0] = parseColor(xmlShapeComponent);
      }
      else if (xmlShapeComponent.getName().equals("StrokeColor"))
      {
        fillAndStrokeColor[1] = parseColor(xmlShapeComponent);
        outStrokeWeight[0] = xmlShapeComponent.getFloat("strokeWeight");
      }
    }
    
    return fillAndStrokeColor;
  }
  
  private color parseColor(XML xmlColor)
  {
    return color(xmlColor.getInt("r"), xmlColor.getInt("g"), xmlColor.getInt("b"), xmlColor.getInt("a"));
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.RENDER;
  }
 
  @Override public void update(int deltaTime)
  { 
    totalTime += deltaTime;
    for (OffsetPShape offsetShape : offsetShapes)
    {
      offsetShape.pshape.resetMatrix();
      offsetShape.pshape.translate(gameObject.getTranslation().x + offsetShape.translation.x, gameObject.getTranslation().y + offsetShape.translation.y);
      offsetShape.pshape.scale(gameObject.getScale().x * offsetShape.scale.x, gameObject.getScale().y * offsetShape.scale.y);
      shape(offsetShape.pshape); // draw
    }
  
    for (OffsetSheetSprite offsetSprite: offsetSheetSprites)
    {
      offsetSprite.sheetSprite.setXY(gameObject.getTranslation().x + offsetSprite.translation.x, gameObject.getTranslation().y + offsetSprite.translation.y);
  
      if(gameObject.getTag().equals("player"))
      {
         IComponent animaionComponent = gameObject.getComponent(ComponentType.ANIMATION_CONTROLLER);
         AnimationControllerComponent animationComponent = (AnimationControllerComponent)animaionComponent;
         float[] direction = animationComponent.getDirection();
         if(actions == Actions.NORMAL)
         {
          
           offsetSprite.sheetSprite.setFrameSequence((int)direction[0], (int)direction[1], direction[2]);
           
           offsetSprite.sheetSprite.setScale(gameObject.getScale().y * offsetSprite.scale.y);
           S4P.updateSprites(deltaTime / 1000.0f);
           if(offsetSprite.zone.equals("NEUTRAL") && zone == Zone.NEUTRAL){
             offsetSprite.sheetSprite.draw();
           } 
           else if (offsetSprite.zone.equals("HAPPY") && zone == Zone.HAPPY){
             offsetSprite.sheetSprite.draw();
           } 
           else if(offsetSprite.zone.equals("DANGER") && zone == Zone.DANGER){
             offsetSprite.sheetSprite.draw();
           } 
           else if(offsetSprite.zone.equals("ALL")){
             offsetSprite.sheetSprite.draw();
           }
         }
         else if(actions == Actions.SWING)
         {
          if(offsetSprite.zone.equals("SWING"))
          {
           if((int)direction[0] == 0)
             offsetSprite.sheetSprite.setFrameSequence(0, 0, 0); // look left
           else
             offsetSprite.sheetSprite.setFrameSequence(1, 1, 0); //look right
           offsetSprite.sheetSprite.setScale(gameObject.getScale().y * offsetSprite.scale.y);
           S4P.updateSprites(deltaTime / 1000.0f);
           offsetSprite.sheetSprite.draw();
          }
         }
      }
      else if(gameObject.getTag().equals("coin"))
      {
        offsetSprite.sheetSprite.setScale(gameObject.getScale().y * offsetSprite.scale.y);
        S4P.updateSprites(deltaTime / 1000.0f);
        if(abs(offsetSprite.initTime - totalTime) > offsetSprite.timeLapsed)
        {
          gameStateController.getGameObjectManager().removeGameObject(gameObject.getUID());
        }
        else if(abs(offsetSprite.initTime - totalTime) > (offsetSprite.timeLapsed - 10000))
        {
        //This is for the transparent coin  
          int framesequence = ((int)(abs(offsetSprite.initTime - totalTime) - (offsetSprite.timeLapsed - 10000))/1000);
          offsetSprite.sheetSprite.setFrameSequence(framesequence, framesequence, 0f);
          offsetSprite.sheetSprite.draw();
        }
        else
        {
          offsetSprite.sheetSprite.draw();
        }
      }
      else
      {
        offsetSprite.sheetSprite.setScale(gameObject.getScale().y * offsetSprite.scale.y);
        S4P.updateSprites(deltaTime / 1000.0f);
        offsetSprite.sheetSprite.draw(); 
      }
     
    }
    
    for (OffsetPImage offsetImage : offsetPImages)
    {
      if(gameObject.getTag().equals("platform") || gameObject.getTag().equals("break_platform") || gameObject.getTag().equals("portal_platform"))
      {
        PImage cropImg = allImages.get(offsetImage.pimageName).get(0,0,ceil(gameObject.getScale().x), (int)gameObject.getScale().y);
        image(cropImg, gameObject.getTranslation().x + offsetImage.translation.x+0.5, gameObject.getTranslation().y + offsetImage.translation.y, gameObject.getScale().x *  offsetImage.scale.x, gameObject.getScale().y * offsetImage.scale.y);
      }
      else 
      {
        image(allImages.get(offsetImage.pimageName), gameObject.getTranslation().x + offsetImage.translation.x, gameObject.getTranslation().y + offsetImage.translation.y,gameObject.getScale().x *  offsetImage.scale.x,gameObject.getScale().y * offsetImage.scale.y);
      }
    }
    
    for (Text text : texts)
    {
      textFont(text.font);
      textAlign(text.alignX, text.alignY);
      fill(text.fillColor);
      stroke(text.strokeColor);
      strokeWeight(text.strokeWeight);
      text(text.string, text.translation.x + gameObject.getTranslation().x, text.translation.y + gameObject.getTranslation().y);
    }
  }
 
  public ArrayList<OffsetPShape> getShapes()
  {
    return offsetShapes;
  }
 
  public ArrayList<OffsetPImage> getImages()
  {
    return offsetPImages;
  }
 
  public ArrayList<OffsetSheetSprite> getSheetSprite()
  {
    return offsetSheetSprites;
  }
  
  public ArrayList<Text> getTexts()
  {
    return texts;
  } 

  public ArrayList<CustomSprite> getCustomSprites()
  {
    return customSprites;
  }
}

public class RigidBodyComponent extends Component
{
  private class OnCollideEvent
  {
    public String collidedWith;
    public EventType eventType;
    public HashMap<String, String> eventParameters;
  }

  private class OnExitEvent
  {
    public String exitFrom;
    public EventType eventType;
    public HashMap<String, String> eventParameters;
  }

  private Body body;
  public PVector latestForce;
  private ArrayList<OnCollideEvent> onCollideEvents;
  private ArrayList<OnExitEvent> onExitEvents;

  public RigidBodyComponent(IGameObject _gameObject) 
  {
    super(_gameObject);

    latestForce = new PVector();
    onCollideEvents = new ArrayList<OnCollideEvent>();
    onExitEvents = new ArrayList<OnExitEvent>();
  }
 
  @Override public void destroy() 
  {
    if(gameStateController.getCurrentState() instanceof GameState_InGame){
      physicsWorld.destroyBody(body);
    }
    else{
       bonusPhysicsWorld.destroyBody(body);
    }
  }  
 
  @Override public void fromXML(XML xmlComponent)  
  {  
    BodyDef bodyDefinition = new BodyDef();  
  
    String bodyType = xmlComponent.getString("type");  
    if (bodyType.equals("static")) 
    { 
      bodyDefinition.type = BodyType.STATIC; 
    }  
    else if (bodyType.equals("kinematic")) 
    {  
      bodyDefinition.type = BodyType.KINEMATIC; 
    }  
    else if (bodyType.equals("dynamic")) 
    {  
      bodyDefinition.type = BodyType.DYNAMIC; 
    } 
    else 
    {  
      print("Unknown rigid body type: " + bodyType); 
      assert(false); 
    }  
 
    bodyDefinition.position.set(pixelsToMeters(gameObject.getTranslation().x), pixelsToMeters(gameObject.getTranslation().y));  
    bodyDefinition.angle = 0.0f;  
    bodyDefinition.linearDamping = xmlComponent.getFloat("linearDamping");  
    bodyDefinition.angularDamping = xmlComponent.getFloat("angularDamping");  
    bodyDefinition.gravityScale = xmlComponent.getFloat("gravityScale");  
    bodyDefinition.allowSleep = xmlComponent.getString("allowSleep").equals("true") ? true : false;  
    bodyDefinition.awake = xmlComponent.getString("awake").equals("true") ? true : false;  
    bodyDefinition.fixedRotation = xmlComponent.getString("fixedRotation").equals("true") ? true : false;  
    bodyDefinition.bullet = xmlComponent.getString("bullet").equals("true") ? true : false;  
    bodyDefinition.active = xmlComponent.getString("active").equals("true") ? true : false;  
    bodyDefinition.userData = gameObject; 
    if((gameStateController.getCurrentState() instanceof GameState_InGame)){
      body = physicsWorld.createBody(bodyDefinition); 
    }
    else{
      body = bonusPhysicsWorld.createBody(bodyDefinition); 
    }
    
    for (XML rigidBodyComponent : xmlComponent.getChildren())
    { 
      if (rigidBodyComponent.getName().equals("Fixture")) 
      {
        FixtureDef fixtureDef = new FixtureDef(); 
        fixtureDef.density = rigidBodyComponent.getFloat("density"); 
        fixtureDef.friction = rigidBodyComponent.getFloat("friction");
        fixtureDef.restitution = rigidBodyComponent.getFloat("restitution");
        fixtureDef.isSensor = rigidBodyComponent.getString("isSensor").equals("true") ? true : false;
        fixtureDef.userData = gameObject;

        for (XML xmlShape : rigidBodyComponent.getChildren())
        { 
          if (xmlShape.getName().equals("Shape"))  
          {  
            String shapeType = xmlShape.getString("type");  
 
            if (shapeType.equals("circle"))
            {
              CircleShape circleShape = new CircleShape();
              circleShape.m_p.set(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y")));
              circleShape.m_radius = pixelsToMeters(xmlShape.getFloat("radius")) * gameObject.getScale().x;
               
              fixtureDef.shape = circleShape; 
            } 
            else if (shapeType.equals("box"))  
            {  
              PolygonShape boxShape = new PolygonShape(); 
              boxShape.m_centroid.set(new Vec2(pixelsToMeters(xmlShape.getFloat("x")), pixelsToMeters(xmlShape.getFloat("y"))));
              boxShape.setAsBox(
                pixelsToMeters(xmlShape.getFloat("halfWidth")) * gameObject.getScale().x,
                pixelsToMeters(xmlShape.getFloat("halfHeight")) * gameObject.getScale().y
              );

              fixtureDef.shape = boxShape;
            }
            else
            {
              print("Unknown fixture shape type: " + shapeType);
              assert(false);
            }
          }
        }
        
        body.createFixture(fixtureDef);
      }
      else if (rigidBodyComponent.getName().equals("OnCollideEvents")) 
      {
        for (XML xmlOnCollideEvent : rigidBodyComponent.getChildren())
        {
          if (xmlOnCollideEvent.getName().equals("Event"))
          {
            OnCollideEvent onCollideEvent = new OnCollideEvent();
            onCollideEvent.collidedWith = xmlOnCollideEvent.getString("collidedWith");
             
            String stringEventType = xmlOnCollideEvent.getString("eventType");
            if (stringEventType.equals("COIN_COLLECTED"))  
            { 
              onCollideEvent.eventType = EventType.COIN_COLLECTED;
              onCollideEvent.eventParameters = new HashMap<String, String>(); 
              onCollideEvent.eventParameters.put("coinParameterName", xmlOnCollideEvent.getString("coinParameterName"));
            }
            else if (stringEventType.equals("GAME_OVER"))
            {
              onCollideEvent.eventType = EventType.GAME_OVER;
            }
            else if (stringEventType.equals("DESTROY_COIN"))
            {
              onCollideEvent.eventType = EventType.DESTROY_COIN;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("coinParameterName", xmlOnCollideEvent.getString("coinParameterName"));
            }
            else if (stringEventType.equals("PLAYER_PLATFORM_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_PLATFORM_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("platformParameterName", xmlOnCollideEvent.getString("platformParameterName"));
            }
            else if (stringEventType.equals("PLAYER_BREAK_PLATFORM_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_BREAK_PLATFORM_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("breakPlatformParameterName", xmlOnCollideEvent.getString("breakPlatformParameterName"));
            }
            else if (stringEventType.equals("PLAYER_GROUND_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_GROUND_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("groundParameterName", xmlOnCollideEvent.getString("groundParameterName"));
            }
            else if (stringEventType.equals("PLAYER_PORTAL_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_PORTAL_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("portalParameterName", xmlOnCollideEvent.getString("portalParameterName"));
            }
            else if (stringEventType.equals("PLAYER_END_PORTAL_COLLISION"))
            {
              onCollideEvent.eventType = EventType.PLAYER_END_PORTAL_COLLISION;
              onCollideEvent.eventParameters = new HashMap<String, String>();
              onCollideEvent.eventParameters.put("endPortalParameterName", xmlOnCollideEvent.getString("endPortalParameterName"));
            }

            onCollideEvents.add(onCollideEvent);
          }
        }
      }
      else if (rigidBodyComponent.getName().equals("OnExitEvents"))
      {
        for (XML xmlOnCollideEvent : rigidBodyComponent.getChildren())
        {
          if (xmlOnCollideEvent.getName().equals("Event"))
          {
            OnExitEvent onExitEvent = new OnExitEvent();
            onExitEvent.exitFrom = xmlOnCollideEvent.getString("exitFrom");

            String stringEventType = xmlOnCollideEvent.getString("eventType");
            if (stringEventType.equals("PLAYER_PLATFORM_EXIT"))
            {
              onExitEvent.eventType = EventType.PLAYER_PLATFORM_EXIT;
              onExitEvent.eventParameters = new HashMap<String, String>();
              onExitEvent.eventParameters.put("platformParameterName", xmlOnCollideEvent.getString("platformParameterName"));
            }
            else if (stringEventType.equals("PLAYER_BREAK_PLATFORM_EXIT"))
            {
              onExitEvent.eventType = EventType.PLAYER_BREAK_PLATFORM_EXIT;
              onExitEvent.eventParameters = new HashMap<String, String>();
              onExitEvent.eventParameters.put("breakPlatformParameterName", xmlOnCollideEvent.getString("breakPlatformParameterName"));
            }

            onExitEvents.add(onExitEvent);
          }
        }
      }
    }
  }
  
  

  @Override public ComponentType getComponentType()
  {
    return ComponentType.RIGID_BODY;
  }
   
  @Override public void update(int deltaTime)
  {
    // Reverse sync the physically simulated position to the Game Object position.
    gameObject.setTranslation(new PVector(metersToPixels(body.getPosition().x), metersToPixels(body.getPosition().y)));
  }

  public void onCollisionEnter(IGameObject collider)
  {
    for (OnCollideEvent onCollideEvent : onCollideEvents)
    {
      if (onCollideEvent.collidedWith.equals(collider.getTag()))
      {
        if (onCollideEvent.eventType == EventType.COIN_COLLECTED)
        {
          Event event = new Event(EventType.COIN_COLLECTED);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.GAME_OVER)
        {
          eventManager.queueEvent(new Event(EventType.GAME_OVER));
        }
        else if (onCollideEvent.eventType == EventType.DESTROY_COIN) 
        {
          Event event = new Event(EventType.DESTROY_COIN);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("coinParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_PLATFORM_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_PLATFORM_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("platformParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_BREAK_PLATFORM_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_BREAK_PLATFORM_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("breakPlatformParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_GROUND_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_GROUND_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("groundParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_PORTAL_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_PORTAL_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("portalParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_END_PORTAL_COLLISION)
        {
          Event event = new Event(EventType.PLAYER_END_PORTAL_COLLISION);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("endPortalParameterName"), collider);
          eventManager.queueEvent(event);
        }
      }
    }
  }

  public void onExitEvent(IGameObject collider)
  {
    for (OnExitEvent onCollideEvent : onExitEvents)
    {
      if (onCollideEvent.exitFrom.equals(collider.getTag()))
      {
        if (onCollideEvent.eventType == EventType.PLAYER_PLATFORM_EXIT)
        {
          Event event = new Event(EventType.PLAYER_PLATFORM_EXIT);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("platformParameterName"), collider);
          eventManager.queueEvent(event);
        }
        else if (onCollideEvent.eventType == EventType.PLAYER_BREAK_PLATFORM_EXIT)
        {
          Event event = new Event(EventType.PLAYER_BREAK_PLATFORM_EXIT);
          event.addGameObjectParameter(onCollideEvent.eventParameters.get("breakPlatformParameterName"), collider);
          eventManager.queueEvent(event);
        }
      }
    }
  }
  
  public PVector getPosition()
  { 
    return new PVector(metersToPixels(body.getPosition().x), metersToPixels(body.getPosition().y)); 
  } 
  
  public PVector getLinearVelocity()
  {
    return new PVector(metersToPixels(body.getLinearVelocity().x), metersToPixels(body.getLinearVelocity().y));
  }

  public float getSpeed()
  {
    PVector linearVelocity = getLinearVelocity();
    return sqrt((linearVelocity.x * linearVelocity.x) + (linearVelocity.y * linearVelocity.y));
  }
  
  public PVector getAcceleration()
  { 
    return new PVector(metersToPixels(latestForce.x), metersToPixels(latestForce.y)); 
  }
  
  public void setPosition(PVector pos)  
  {  
    body.setTransform(new Vec2(pixelsToMeters(pos.x), body.getPosition().y),0);  
  }
  
  public void setPlatformPosition(PVector pos)  
  {  
    body.setTransform(new Vec2(body.getPosition().x, pixelsToMeters(pos.y)),0);  
  }
  
  public void setLinearVelocity(PVector linearVelocity)  
  {  
    body.setLinearVelocity(new Vec2(pixelsToMeters(linearVelocity.x), pixelsToMeters(linearVelocity.y)));  
  }  

  public void applyForce(PVector force, PVector position)  
  {  
    latestForce = force;  
    body.applyForce(new Vec2(pixelsToMeters(force.x), pixelsToMeters(force.y)), new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)));  
  }  
  
  public void applyLinearImpulse(PVector impulse, PVector position, boolean wakeUp)  
  {  
    body.applyLinearImpulse( 
      new Vec2(pixelsToMeters(impulse.x), pixelsToMeters(impulse.y)),
      new Vec2(pixelsToMeters(position.x), pixelsToMeters(position.y)), 
      wakeUp
    );
  }

  private float pixelsToMeters(float pixels) 
  { 
    return pixels / 50.0f; 
  }

  private float metersToPixels(float meters)
  {
    return meters * 50.0f;
  }
}

public class PlayerControllerComponent extends Component
{
  public PVector latestMoveVector;
  private float acceleration;
  private float maxSpeed;
  private float jumpForce;

  private String currentSpeedParameterName;

  private String collidedPlatformParameterName;
  private String collidedBreakPlatformParameterName;
  private String gapDirection;

  private boolean upButtonDown;
  private boolean leftButtonDown;
  private boolean rightButtonDown;


  private boolean leftMyoForce;
  private boolean rightMyoForce;

  private int jumpDelay;
  private int jumpTime;
  private int directionChanges;
  private boolean goingRight;
  private boolean goingLeft;
  private boolean notMoving;
  private int undershootCount;
  private int overshootCount;
  private int errors;
  private float currGapPosition;
  private float currGapWidth;
  private float currStartPoint;
  private boolean firstMove;
  private boolean onLeftSide;
  private boolean onRightSide;
  private int jumpCount;
 
  private SoundObject jumpSound;
  private float amplitude;
  private SoundObject platformFallSound;
   
  private boolean onPlatform; 
  private boolean onRegPlatform; 
  private boolean onBreakPlatform;
  private boolean stopOnBreakPlatform;
  private boolean stopOnBreakPlatformError;
  private IGameObject breakPlatform;
  private IGameObject portalPlatform;
  private long breakTimerStart;
  private long crumbleTimerStart;
  private String crumblingPlatformFile;
  private int platformLevelCount;
  private boolean justJumped;
  private HashMap<String, Float> rawInput;
  private float distanceTravelled;
  private float lastXPos;
  
  private IGameObject playerPlatform;
  private float gapDistance;

  public PlayerControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);

    upButtonDown = false;
    leftButtonDown = false;
    rightButtonDown = false;
    onPlatform = false;
    onRegPlatform = false;
    onBreakPlatform = false;
    jumpCount = 0;
    justJumped = false;
    breakTimerStart = (long)Double.POSITIVE_INFINITY;
    latestMoveVector = new PVector();
    platformLevelCount = 1;

    distanceTravelled = 0;
    lastXPos = gameObject.getTranslation().x;
    playerPlatform = null;
    gapDistance = 0;
    stopOnBreakPlatform = false;
  }

  @Override public void destroy()
  {

  }

  @Override public void fromXML(XML xmlComponent)
  {
    acceleration = xmlComponent.getFloat("acceleration");
    maxSpeed = xmlComponent.getFloat("maxSpeed");
    jumpForce = xmlComponent.getFloat("jumpForce");
    currentSpeedParameterName = xmlComponent.getString("currentSpeedParameterName");

    collidedPlatformParameterName = xmlComponent.getString("collidedPlatformParameterName");
    collidedBreakPlatformParameterName = xmlComponent.getString("collidedBreakPlatformParameterName");
    gapDirection = LEFT_DIRECTION_LABEL;
    jumpSound = soundManager.loadSoundFile(xmlComponent.getString("jumpSoundFile"));
    jumpSound.setPan(xmlComponent.getFloat("pan"));
    amplitude = xmlComponent.getFloat("amp");
    jumpDelay = 500;
    platformFallSound = soundManager.loadSoundFile(xmlComponent.getString("fallSoundFile"));
    platformFallSound.setPan(xmlComponent.getFloat("pan"));
    crumblingPlatformFile = xmlComponent.getString("crumblePlatform");
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLAYER_CONTROLLER;
  }

  @Override public void update(int deltaTime)
  {
    handleEvents();
    float newXPos = gameObject.getTranslation().x;
    distanceTravelled += abs(lastXPos - newXPos);
    lastXPos = newXPos;
    rawInput = gatherRawInput();
    PVector moveVector = new PVector();
    
    applySpeedWarning();
    
    if((!options.getGameOptions().isFittsLaw() && !bonusLevel) || onPlatform)
    {
      actions = Actions.NORMAL;
      switch (options.getGameOptions().getControlPolicy()) {
        case NORMAL:
          moveVector = applyNormalControls(rawInput);
          break;
        case DIRECTION_ASSIST:
          moveVector = applyDirectionAssistControls(rawInput);
          if (onPlatform)
            gapDistance = determineGapDistance(gapDirection, playerPlatform);
          break;
        case SINGLE_MUSCLE:
          moveVector = applySingleMuscleControls(rawInput);
          break;
        default:
          println("[ERROR] Invalid Control policy found in PlayerControllerComponent::update()");

      }
    }

    smoothControls(moveVector, deltaTime);
    latestMoveVector = moveVector;

    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      
      if(onBreakPlatform && moveVector.x == 0)
      {
        stopOnBreakPlatform = true;
        stopOnBreakPlatformError = true;
      }
      
      if(!onBreakPlatform && stopOnBreakPlatformError)
      {
        errors++;
        stopOnBreakPlatformError = false;
      }
      
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      if(options.getGameOptions().isLogFitts() || bonusLevel)
      {
        calculateOverShoots(rigidBodyComponent.getPosition());
        calculateDirectionChanges(moveVector, rigidBodyComponent.getPosition());
      }
      
      if (options.getGameOptions().getBreakthroughMode() == BreakthroughMode.CO_CONTRACTION)
      {
        if (jumpCount >= 1 && onPlatform)
        {
          Event fittsLawLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
          fittsLawLevelUp.addIntParameter("platformLevel", ++platformLevelCount);
          eventManager.queueEvent(fittsLawLevelUp);

          jumpCount = 0;
          gameStateController.getGameObjectManager().removeGameObject(breakPlatform.getUID());
          platformFallSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
          platformFallSound.play();
          float crumbleScale = breakPlatform.getScale().x/2; 
          int crumblePlatforms = int(crumbleScale*2/5);
          for(int i = 0; i < crumblePlatforms; i++){
            IGameObject crumblePlatform = gameStateController.getGameObjectManager().addGameObject(crumblingPlatformFile, new PVector(breakPlatform.getTranslation().x -crumbleScale+5+i*5, random(breakPlatform.getTranslation().y-5,breakPlatform.getTranslation().y+5)), new PVector(10, 10));
            crumblePlatform.setTag("crumble_platform");
            pc.setPlatformDescentSpeed(crumblePlatform);
          }

          if(options.getGameOptions().isLogFitts() || bonusLevel)
          {
            fsc.endLogLevel();
          }
          
          // explicitly set Momo's position after "breaking through" a
          // breakthrough platform. to ensure consistent fitts configurations,
          // Momo is always centered in the new gap and all x-velocity zeroed.
          // Velocity is futher zero-ed in the handleEvents() method, to
          // account for input between this frame (when the "break through"
          // event is fired) and the next frame (when the event is handled, and
          // the breakthrough platform disappears).
          rigidBodyComponent.setPosition(new PVector(breakPlatform.getTranslation().x, 0));
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, rigidBodyComponent.getLinearVelocity().y));

          if(options.getGameOptions().isStillPlatforms())
          {
            pc.spawnPlatformLevelNoRiseSpeed();
            pc.incrementPlatforms();
          }
        }
      }
      else
      {
        if (System.currentTimeMillis() - crumbleTimerStart > 450 && onBreakPlatform)
        {
          crumbleTimerStart = System.currentTimeMillis();
          float crumbleScale = breakPlatform.getScale().x/2; 
          IGameObject crumblePlatform = gameStateController.getGameObjectManager().addGameObject(crumblingPlatformFile, new PVector(breakPlatform.getTranslation().x + random(-crumbleScale,crumbleScale), breakPlatform.getTranslation().y), new PVector(10, 10));
          crumblePlatform.setTag("crumble_platform");
          pc.setPlatformDescentSpeed(crumblePlatform);
        }
        if (System.currentTimeMillis() - breakTimerStart > options.getGameOptions().getDwellTime()*1000 && onBreakPlatform)
        {
          ++platformLevelCount;
          Event fittsLawLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
          fittsLawLevelUp.addIntParameter("platformLevel", platformLevelCount);
          eventManager.queueEvent(fittsLawLevelUp);
          
          gameStateController.getGameObjectManager().removeGameObject(breakPlatform.getUID());
          
          pc.setPlatformDescentSpeed(breakPlatform);
          platformFallSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
          platformFallSound.play();
          
          if(options.getGameOptions().isLogFitts() || bonusLevel)
          {
            fsc.endLogLevel();
          }

          // explicitly set Momo's position after "breaking through" a
          // breakthrough platform. to ensure consistent fitts configurations,
          // Momo is always centered in the new gap and all x-velocity zeroed.
          // Velocity is futher zero-ed in the handleEvents() method, to
          // account for input between this frame (when the "break through"
          // event is fired) and the next frame (when the event is handled, and
          // the breakthrough platform disappears).
          rigidBodyComponent.setPosition(new PVector(breakPlatform.getTranslation().x, 0));
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, rigidBodyComponent.getLinearVelocity().y));

          if(options.getGameOptions().isStillPlatforms())
          {
            pc.spawnPlatformLevelNoRiseSpeed();
            pc.incrementPlatforms();
          }
        }
      }

      if (rigidBodyComponent.getLinearVelocity().y == 0)
      {
        onPlatform = true;
      }

      if (rigidBodyComponent.getLinearVelocity().x < 0 && (rightButtonDown || rightMyoForce)) {
        if (bonusLevel || options.getGameOptions().isFittsLaw()) {
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, 0.0));
        }
      }

      if (rigidBodyComponent.getLinearVelocity().x > 0 && (leftButtonDown || leftMyoForce)) {
        if (bonusLevel || options.getGameOptions().isFittsLaw()) {
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, 0.0));
        }
      }

      if ((options.getGameOptions().isFittsLaw() && rigidBodyComponent.gameObject.getTag().equals("player")) || (bonusLevel && options.getGameOptions().getControlPolicy()!=ControlPolicy.SINGLE_MUSCLE))
      {
        if (onPlatform && (!leftButtonDown && !leftMyoForce) && (!rightButtonDown && !rightMyoForce) && !upButtonDown && !justJumped)
        {
          rigidBodyComponent.setLinearVelocity(new PVector(0,0));
        }
      }
      

      //This is too eliminate momo from being launch off the platform
      if(isRising  && options.getGameOptions().isFittsLaw() && options.getGameOptions().isStillPlatforms())
      {
        rigidBodyComponent.applyForce(new PVector(0, -4.5f), new PVector(gameObject.getTranslation().x, 270));
      }
      
      if(gameObject.getTranslation().y < 195)
      {
        zone = Zone.DANGER;
      } 
      else if(gameObject.getTranslation().y < 340)
      {
        zone = Zone.NEUTRAL;
      }
      else
      {
        zone = Zone.HAPPY;
      }

      PVector linearVelocity = rigidBodyComponent.getLinearVelocity();  
      if (  (moveVector.x > 0 && linearVelocity.x < maxSpeed)
         || (moveVector.x < 0 && linearVelocity.x > -maxSpeed))
      {
        float forwardForceX = (moveVector.x * acceleration * deltaTime);
        if (options.getGameOptions().getControlPolicy() == ControlPolicy.DIRECTION_ASSIST 
           && onPlatform 
           && gapDistance < pc.getMinGapSize())
        {
          PVector middleOfGap = new PVector(0.0, 0.0);
          if (gapDirection == LEFT_DIRECTION_LABEL) {
            middleOfGap.x = playerPlatform.getTranslation().x - playerPlatform.getScale().x/2 - pc.getMinGapSize()/2;
          }
          else
          {
            middleOfGap.x = playerPlatform.getTranslation().x + playerPlatform.getScale().x/2 + pc.getMinGapSize()/2;
          }
          rigidBodyComponent.setPosition(middleOfGap);
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, 0.0));
        }
        else
        {
          rigidBodyComponent.applyForce(new PVector(forwardForceX, 0.0), gameObject.getTranslation());
        }
      }

      ArrayList<IGameObject> platformManagerList = gameStateController.getGameObjectManager().getGameObjectsByTag("platform_manager");
      if (!platformManagerList.isEmpty())
      {
        IComponent tcomponent = platformManagerList.get(0).getComponent(ComponentType.PLATFORM_MANAGER_CONTROLLER);  
        if (tcomponent != null)
        { 
          if (moveVector.y < -0.5f)
          {
            rigidBodyComponent.applyLinearImpulse(new PVector(0.0f, jumpForce), gameObject.getTranslation(), true); 
            jumpSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
            jumpSound.play();
            justJumped = true;
          }
        } 
      }
      
      //This is to check if half of momo is on break platform.
      //Because Momo is a box in bonus mode this is needed.
      if(bonusLevel && breakPlatform != null && (((breakPlatform.getTranslation().x - breakPlatform.getScale().x/2) < gameObject.getTranslation().x) && ((breakPlatform.getTranslation().x + breakPlatform.getScale().x/2) > gameObject.getTranslation().x))){
        if (!onBreakPlatform)
        {
          breakTimerStart = System.currentTimeMillis();
          crumbleTimerStart = System.currentTimeMillis();
        }

        onBreakPlatform = true;
      }
      
      ArrayList<IGameObject> BonusplatformManagerList = gameStateController.getGameObjectManager().getGameObjectsByTag("bonus_platform_manager");
      if (!BonusplatformManagerList.isEmpty())
      {
        IComponent tcomponent = BonusplatformManagerList.get(0).getComponent(ComponentType.BONUS_PLATFORM_MANAGER);  
        if (tcomponent != null)
        { 
          if (moveVector.y < -0.5f)
          {
            if(onBreakPlatform && options.getGameOptions().getBreakthroughMode() == BreakthroughMode.CO_CONTRACTION){
              if(((breakPlatform.getTranslation().x - breakPlatform.getScale().x/2) < gameObject.getTranslation().x) && ((breakPlatform.getTranslation().x + breakPlatform.getScale().x/2) > gameObject.getTranslation().x))
              {
                justJumped = true;
                ++platformLevelCount;
                Event fittsLawLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
                fittsLawLevelUp.addIntParameter("platformLevel", platformLevelCount);
                eventManager.queueEvent(fittsLawLevelUp);
                actions = Actions.SWING;

                jumpCount = 0;
                //pc.setPlatformDescentSpeed(breakPlatform);
                rigidBodyComponent.setPosition(new PVector(breakPlatform.getTranslation().x, 0));
                swingSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
                swingSound.play();
                long delay = System.currentTimeMillis();
                int counter = 0;
                while(counter<20)
                {
                  float crumbleScale = breakPlatform.getScale().x/2;
                  float xScale = 0;
                  
                  if(counter % 2 ==1)
                    xScale = breakPlatform.getTranslation().x + random(-crumbleScale,0);
                  else
                    xScale = breakPlatform.getTranslation().x + random(0,crumbleScale);
                  
                  IGameObject crumblePlatform = gameStateController.getGameObjectManager().addGameObject(crumblingPlatformFile, new PVector(xScale, random(breakPlatform.getTranslation().y+10,breakPlatform.getTranslation().y+25)), new PVector(5, 5));
                  crumblePlatform.setTag("crumble_platform");
                  pc.setPlatformDescentSpeed(crumblePlatform);
                  counter++;
                }
      
                gameStateController.getGameObjectManager().removeGameObject(breakPlatform.getUID());
                actions = Actions.SWING;
                if(options.getGameOptions().isLogFitts() || bonusLevel)
                {
                  fsc.endLogLevel();
                }
      
                
      
                if(options.getGameOptions().isStillPlatforms())
                {
                  pc.spawnPlatformLevelNoRiseSpeed();
                  pc.incrementPlatforms();
                }
              }
            }
          }
        } 
      } 

      IEvent currentSpeedEvent = new Event(EventType.PLAYER_CURRENT_SPEED);
      currentSpeedEvent.addFloatParameter(currentSpeedParameterName, rigidBodyComponent.getSpeed()); 
      eventManager.queueEvent(currentSpeedEvent);

      // explicitly stop momo from "bouncing" off of break platforms in bonus level
      if (bonusLevel)
        rigidBodyComponent.setLinearVelocity(new PVector(rigidBodyComponent.getLinearVelocity().x, max(rigidBodyComponent.getLinearVelocity().y, 0.0)));

    } 
  }

  private HashMap<String, Float> gatherRawInput()
  {
    HashMap<String, Float> rawInput = (HashMap<String, Float>) processedReadings.clone();

    Float keyboardLeftMagnitude;
    Float keyboardRightMagnitude;
    Float keyboardJumpMagnitude;

    Float myoLeftMagnitude;
    Float myoRightMagnitude;
    Float myoJumpMagnitude;

    if (options.getGameOptions().isFittsLaw() || bonusLevel)
    {
      if (onPlatform)
      {
        keyboardLeftMagnitude = leftButtonDown ? 1.0 : 0.0;
        keyboardRightMagnitude = rightButtonDown ? 1.0 : 0.0;
        keyboardJumpMagnitude = upButtonDown ? 1.0 : 0.0;

        myoLeftMagnitude = rawInput.get(LEFT_DIRECTION_LABEL);
        myoRightMagnitude = rawInput.get(RIGHT_DIRECTION_LABEL);
        myoJumpMagnitude = rawInput.get(JUMP_DIRECTION_LABEL);
      }
      else
      {
        // set left and right to zero - can't control movement when in the air
        keyboardLeftMagnitude = 0.0;
        keyboardRightMagnitude = 0.0;
        keyboardJumpMagnitude = 0.0;

        myoLeftMagnitude = 0.0;
        myoRightMagnitude = 0.0;
        myoJumpMagnitude = 0.0;
      }
    }
    else
    {
      keyboardLeftMagnitude = leftButtonDown ? 1.0 : 0.0;
      keyboardRightMagnitude = rightButtonDown ? 1.0 : 0.0;
      keyboardJumpMagnitude = upButtonDown ? 1.0 : 0.0;

      myoLeftMagnitude = rawInput.get(LEFT_DIRECTION_LABEL);
      myoRightMagnitude = rawInput.get(RIGHT_DIRECTION_LABEL);
      myoJumpMagnitude = rawInput.get(JUMP_DIRECTION_LABEL);
    }

    leftMyoForce = rawInput.get(LEFT_DIRECTION_LABEL) > emgManager.getMinimumActivationThreshold(LEFT_DIRECTION_LABEL) ? true : false;
    rightMyoForce = rawInput.get(RIGHT_DIRECTION_LABEL) > emgManager.getMinimumActivationThreshold(RIGHT_DIRECTION_LABEL) ? true : false;

    rawInput.put(LEFT_DIRECTION_LABEL, myoLeftMagnitude+keyboardLeftMagnitude);
    rawInput.put(RIGHT_DIRECTION_LABEL, myoRightMagnitude+keyboardRightMagnitude);
    rawInput.put(JUMP_DIRECTION_LABEL, myoJumpMagnitude+keyboardJumpMagnitude);
    return rawInput;
  }

  private PVector applyNormalControls(HashMap<String, Float> input)
  {
    PVector moveVector = new PVector();
    moveVector.x = input.get(RIGHT_DIRECTION_LABEL) - input.get(LEFT_DIRECTION_LABEL);
    moveVector.y = -input.get(JUMP_DIRECTION_LABEL);
    return moveVector;
  }
  
  private HashMap<String, Float> getRawInput()
  {
    return rawInput; 
  }

  private PVector applyDirectionAssistControls(HashMap<String, Float> input)
  {
    Float magnitude = 0.0;
    DirectionAssistMode mode = options.getGameOptions().getDirectionAssistMode();
    if (mode == DirectionAssistMode.LEFT_ONLY)
      magnitude = input.get(LEFT_DIRECTION_LABEL);
    else if (mode == DirectionAssistMode.RIGHT_ONLY)
      magnitude = input.get(RIGHT_DIRECTION_LABEL);
    else if (mode == DirectionAssistMode.BOTH)
      magnitude = input.get(LEFT_DIRECTION_LABEL) + input.get(RIGHT_DIRECTION_LABEL);
    else 
      println("[ERROR] Unrecognized control mode in PlayerControllerComponent::applyDirectionAssistControls"); 
    
    PVector moveVector = new PVector(); 
    if (gapDirection == LEFT_DIRECTION_LABEL) 
      moveVector.x = -magnitude;
    else 
      moveVector.x = magnitude;

    return moveVector;
  }

  private PVector applySingleMuscleControls(HashMap<String, Float> input)
  {
    PVector moveVector = new PVector();

    SingleMuscleMode mode = options.getGameOptions().getSingleMuscleMode();
    if (mode == SingleMuscleMode.AUTO_LEFT)
      moveVector.x = -1 + 2*input.get(RIGHT_DIRECTION_LABEL);
    else if (mode == SingleMuscleMode.AUTO_RIGHT)
      moveVector.x = 1 - 2*input.get(LEFT_DIRECTION_LABEL);
    else
      println("[ERROR] Unrecognized single muscle mode in PlayerControllerComponent::applySingleMuscleControls");
    //if moveVector.z has less than 0.1 difference momo stays still
    if(abs(moveVector.x) <0.2)
      moveVector.x = 0;
    return moveVector; 
  }

  private void applySpeedWarning() {
    Float left = rawReadings.get(LEFT_DIRECTION_LABEL);
    Float right = rawReadings.get(RIGHT_DIRECTION_LABEL);

    Float severity = max(left, right);
    if (severity > 1.0) {
      drawSpeedWaring(severity);
    }
  }

  // TODO: the speed warning circle should really be encapsulated into a game-object
  // that gets added and removed from the game world as necessary. This is
  // really just a quick solution.
  private void drawSpeedWaring(Float severity) {
    float x = gameObject.getTranslation().x;
    float y = gameObject.getTranslation().y;
    int radius = 30;

    stroke(255, 0, 0);
    fill(255, 255, 255, 0.0);

    if (severity > 1.75)
      strokeWeight(4);
    else if (severity > 1.5)
      strokeWeight(2);
    else if (severity > 1.25)
      strokeWeight(1);
    else if (severity > 1.1)
      strokeWeight(0.5);
    else
      strokeWeight(0);

    ellipse(x, y, radius, radius);
  }

  public PVector getLatestMoveVector()
  {
    return latestMoveVector;
  }
  
  public void calculateOverShoots(PVector pos)
  {
    if((pos.x > (currGapPosition + currGapWidth)))
    {
      if(onLeftSide)
      {
        if(!stopOnBreakPlatform)
        {
          overshootCount++;
        }
        onLeftSide = false;
        onRightSide = true;
        stopOnBreakPlatform = false;
      }
      else if(onRightSide)
      {
        stopOnBreakPlatform = false;
      }
    }
    else if((pos.x < (currGapPosition - currGapWidth)))
    {
      if(onRightSide)
      {
        if(!stopOnBreakPlatform)
        {
          overshootCount++;
        }
        onLeftSide = true;
        onRightSide = false;
        stopOnBreakPlatform = false;
      }
      else if(onLeftSide)
      {
        stopOnBreakPlatform = false;
      }
    }
  }
  
  //And UnderShoots
  public void calculateDirectionChanges(PVector mVector, PVector pos)
  { 
    if(mVector.x < 0)
    {
      if(!goingLeft)
      {
        goingLeft = true;
        goingRight = false;
        directionChanges++;
      }
      notMoving = false;
      firstMove = false;
    }
    else if(mVector.x > 0)
    {
      if(!goingRight)
      {
        goingRight =true;
        goingLeft=false;
        directionChanges++;
      }
      notMoving = false;
      firstMove = false;
    }
    else if(mVector.x == 0)
    {
      if(!notMoving && !firstMove)
      {
        if(goingLeft && (pos.x > (currGapPosition + currGapWidth + 25)))
        {
          undershootCount++;
        }
        else if(goingRight && (pos.x < (currGapPosition - currGapWidth - 25)))
        {
          undershootCount++;
        }
      }
      notMoving = true;
    }
  }
  
  public int getDirerctionChanges()
  {
    return directionChanges;
  }
  
  public int getUnderShoots()
  {
    return undershootCount;
  }
  
  public int getOverShoots()
  {
    return overshootCount;
  }
  
  public int getErrors()
  {
    return errors + undershootCount + overshootCount; 
  }
  
  public void setLoggingValuesZero(float gapPos, float halfGapWidth, float startingPosition)
  {
    stopOnBreakPlatform = false;
    firstMove = true;
    directionChanges = 0;
    undershootCount = 0;
    overshootCount=0;
    currGapPosition = gapPos;
    currGapWidth = halfGapWidth;
    currStartPoint = startingPosition;
    errors =0;
    if(currStartPoint < currGapPosition)
    {
      onLeftSide = true;
      onRightSide = false; 
    }
    else
    {
      onLeftSide = false;
      onRightSide = true; 
    }
  }
 
  private void handleEvents() 
  {
    if (eventManager.getEvents(EventType.UP_BUTTON_PRESSED).size() > 0)
      upButtonDown = true;

    if (eventManager.getEvents(EventType.LEFT_BUTTON_PRESSED).size() > 0) 
      leftButtonDown = true; 

    if (eventManager.getEvents(EventType.RIGHT_BUTTON_PRESSED).size() > 0)
      rightButtonDown = true;
 
    if (eventManager.getEvents(EventType.UP_BUTTON_RELEASED).size() > 0) 
      upButtonDown = false;

    if (eventManager.getEvents(EventType.LEFT_BUTTON_RELEASED).size() > 0)
      leftButtonDown = false;
      
    if (eventManager.getEvents(EventType.RIGHT_BUTTON_RELEASED).size() > 0) 
      rightButtonDown = false; 
      
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_COLLISION))
    {
      onPlatform = true;
      onRegPlatform = true;
      IGameObject platform = event.getRequiredGameObjectParameter(collidedPlatformParameterName); 
      playerPlatform = platform;
      gapDirection = determineGapDirection(platform); 
      justJumped = false;
      jumpCount = 0;
      actions = Actions.NORMAL;
    }

    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_EXIT))
    {
      if (!onBreakPlatform)
      {
        onPlatform = false;
      }
      onRegPlatform = false;
      jumpCount = 0;
    }

    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_COLLISION))
    {
      onPlatform = true;
      if(!bonusLevel){
        if (!onBreakPlatform)
          {
            breakTimerStart = System.currentTimeMillis();
            crumbleTimerStart = System.currentTimeMillis();
          }
  
        onBreakPlatform = true;
      }

      IGameObject platform = event.getRequiredGameObjectParameter(collidedBreakPlatformParameterName);
      breakPlatform = platform;
      if (justJumped && (options.getGameOptions().getBreakthroughMode() == BreakthroughMode.CO_CONTRACTION) && breakPlatform.getTranslation().y > gameObject.getTranslation().y)
      {
        jumpCount++;
        justJumped = false;
      }
    }

    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_EXIT))
    {
      if (!onRegPlatform)
      {
        onPlatform = false;
      }
      onBreakPlatform = false;
      breakTimerStart = (long) Double.POSITIVE_INFINITY;
      breakPlatform = null;
    }

    // TODO: confunsing name. This is actually the event thrown when the player successfully "breaks through" a breakthrough platform in the bonus level.
    for (IEvent event: eventManager.getEvents(EventType.PLATFORM_LEVEL_UP))
    {
      if (bonusLevel)
      {
        // force Momo to stay in the middle of break-platform target by zeroing
        // out x-component of velocity that has been accumulated since the
        // event was fired
        IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
        if (component != null)
        {
          RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, rigidBodyComponent.getLinearVelocity().y));
        }
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PORTAL_COLLISION))
    {
      Event bonusGame = new Event(EventType.PUSH_BONUS);
      eventManager.queueEvent(bonusGame);
      
      IGameObject platform = event.getRequiredGameObjectParameter("portal_platform");
      portalPlatform = platform;
      gameStateController.getGameObjectManager().removeGameObject(portalPlatform.getUID());
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_END_PORTAL_COLLISION))
    {
      Event finishBonusGame = new Event(EventType.FINISH_BONUS);
      finishBonusGame.addIntParameter("bonusScore",bsc.getBonusScore());
      finishBonusGame.addIntParameter("bounsCoinsCollected",bsc.getBonusCoins());
      eventManager.queueEvent(finishBonusGame);
      
    }

    for (IEvent event : eventManager.getEvents(EventType.NO_BUTTONS_DOWN))
    {
      leftButtonDown = false;
      rightButtonDown = false;
      upButtonDown = false;
    }
  }

  private String determineGapDirection(IGameObject platform) 
  {
    IGameObject leftWall = gameStateController.getGameObjectManager().getGameObjectsByTag("left_wall").get(0); 
    assert (leftWall != null); 
 
    float wallWidth = leftWall.getScale().x; 
    float playerWidth = gameObject.getScale().x; 
    float platformPositionX = platform.getTranslation().x; 
    float platformWidth = platform.getScale().x; 
 
    String direction = ""; 

    if (platformPositionX <= platformWidth/2.0 + wallWidth + playerWidth)
    {
      // platform extends all the way to left wall (i.e., no gap to the left)
      direction = RIGHT_DIRECTION_LABEL;
    } 
    else 
    { 
      direction = LEFT_DIRECTION_LABEL;
    }
    return direction;
  } 

  private float determineGapDistance(String gapDirection, IGameObject platform)
  {
    float distance = 0;

    if (gapDirection.equals(RIGHT_DIRECTION_LABEL)) {
      if (pc != null)
        distance = (platform.getTranslation().x + platform.getScale().x/2 + pc.getMinGapSize()/2)- gameObject.getTranslation().x;
      else
        distance = (platform.getTranslation().x + platform.getScale().x/2 + 15)- gameObject.getTranslation().x;
    } else {
      if (pc != null)
        distance = gameObject.getTranslation().x - (platform.getTranslation().x - platform.getScale().x/2 - pc.getMinGapSize()/2);
      else
        distance = gameObject.getTranslation().x - (platform.getTranslation().x - platform.getScale().x/2 - 15);
    }

    return distance;
  }

  // TODO since minimumActivationThreshold scaling is now performed in the LibMyoProportional, this method should be renamed to something line `handleJumpDelay()` or removed completly.
  private void smoothControls(PVector moveVector, int deltaTime)
  {
    jumpTime += deltaTime; 
    if (moveVector.y < -0.5  && jumpTime > jumpDelay)  
    { 
      jumpTime = 0; 
    }
    else
    {
      moveVector.y = 0.0f;
    }
  }
}

public class PlatformManagerControllerComponent extends Component
{ 
  private LinkedList<IGameObject> platforms;
  private LinkedList<IGameObject> obstacles;
  private String platformFile;  
  private String breakPlatformFile;
  private String portalPlatformFile;
  private float breakPlatformChance;
  private String slipperyPlatformFile;  
  private float slipperyPlatformChance; 
  private String stickyPlatformFile; 
  private float stickyPlatformChance;
  private float bonusLevelChance;
  private String tag; 
  
  private int maxPlatformLevels;
  
  private float leftSide;
  private float rightSide;
  
  private float platformHeight;
  
  private float disappearHeight;
  private float spawnHeight;

  private int minGapsPerLevel;
  private int maxGapsPerLevel; 
 
  private float minGapSize; 
  private float maxGapSize; 
  private float minDistanceBetweenGaps;
  
  private String obstacleFile;
  private String obstacleTag;
  private float obstacleChance;
  private float obstacleMinWidth;
  private float obstacleMaxWidth;
  private float obstacleMinHeight;
  private float obstacleMaxHeight;
  
  private float minHeightBetweenPlatformLevels;
  private float maxHeightBetweenPlatformLevels; 
  private float nextHeightBetweenPlatformLevels; 

  private String currentRiseSpeedParameterName;
  private float riseSpeed;
  private int inputPlatformCounter;
  
  private boolean firstIteration;
  private boolean rising;
  private int initialHeight;
  private int thresholdHeight;
  private RigidBodyComponent initialPlat;
  private int currentLevel;
  private int currentPlatformLevel;
  
  private float lastPlatformHeight;

  public PlatformManagerControllerComponent(IGameObject _gameObject)
  {
    super (_gameObject);
    obstacles = new LinkedList<IGameObject>();
    platforms = new LinkedList<IGameObject>();
    platformLevels = new ArrayList<ArrayList<Integer>>();
    platformGapPosition = new ArrayList<PVector>();
    currentLevel = 1;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    platformFile = xmlComponent.getString("platformFile");
    breakPlatformFile = xmlComponent.getString("breakPlatformFile");
    breakPlatformChance = xmlComponent.getFloat("breakPlatformChance");
    slipperyPlatformFile = xmlComponent.getString("slipperyPlatformFile");
    slipperyPlatformChance = xmlComponent.getFloat("slipperyPlatformChance");
    stickyPlatformFile = xmlComponent.getString("stickyPlatformFile");
    stickyPlatformChance = xmlComponent.getFloat("stickyPlatformChance");
    bonusLevelChance = xmlComponent.getFloat("bonusLevelChance");
    tag = xmlComponent.getString("tag");
    maxPlatformLevels = xmlComponent.getInt("maxPlatformLevels");
    leftSide = xmlComponent.getFloat("leftSide");
    rightSide = xmlComponent.getFloat("rightSide");
    platformHeight = xmlComponent.getFloat("platformHeight");
    disappearHeight = xmlComponent.getFloat("disappearHeight");
    spawnHeight = xmlComponent.getFloat("spawnHeight");
    portalPlatformFile = xmlComponent.getString("portalPlatformFile");
    if (options.getGameOptions().isFittsLaw() || options.getGameOptions().isStillPlatforms())
    {
      minGapsPerLevel = 1;
      maxGapsPerLevel = 1;
    }
    else
    {
      minGapsPerLevel = xmlComponent.getInt("minGapsPerLevel");
      maxGapsPerLevel = xmlComponent.getInt("maxGapsPerLevel");
    }
    minGapSize = xmlComponent.getFloat("minGapSize");
    maxGapSize = xmlComponent.getFloat("maxGapSize");
    minDistanceBetweenGaps = xmlComponent.getFloat("minDistanceBetweenGaps");
    obstacleFile = xmlComponent.getString("obstacleFile");
    obstacleTag = xmlComponent.getString("obstacleTag");
    obstacleChance = xmlComponent.getFloat("obstacleChance");
    obstacleMinWidth = xmlComponent.getFloat("obstacleMinWidth");
    obstacleMaxWidth = xmlComponent.getFloat("obstacleMaxWidth");
    obstacleMinHeight = xmlComponent.getFloat("obstacleMinHeight");
    obstacleMaxHeight = xmlComponent.getFloat("obstacleMaxHeight");
    minHeightBetweenPlatformLevels = xmlComponent.getFloat("minHeightBetweenPlatformLevels");
    maxHeightBetweenPlatformLevels = xmlComponent.getFloat("maxHeightBetweenPlatformLevels");
    nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    riseSpeed = 0.0f;
    firstIteration = true;
    rising = false;
    isRising = false;
    initialHeight = 0;
    thresholdHeight = 125;
    initialPlat = null;
    currentPlatformLevel = 0;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.PLATFORM_MANAGER_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
    while (!platforms.isEmpty() && ((platforms.getFirst().getTranslation().y < disappearHeight) 
      || ((platforms.getFirst().getTranslation().y == lastPlatformHeight) && !options.getGameOptions().isStillPlatforms())))
    {
      IGameObject platform = platforms.removeFirst();
      gameStateController.getGameObjectManager().removeGameObject(platform.getUID());
    }
   
    if(!platforms.isEmpty())
    {
      lastPlatformHeight = platforms.getFirst().getTranslation().y;
    }
    
    while (!obstacles.isEmpty() && obstacles.getFirst().getTranslation().y < disappearHeight)
    {
      IGameObject obstacle = obstacles.removeFirst();
      gameStateController.getGameObjectManager().removeGameObject(obstacle.getUID());
    }
    
    if ((platforms.isEmpty())
      || (platforms.size() < maxPlatformLevels && ((spawnHeight - platforms.getLast().getTranslation().y) > nextHeightBetweenPlatformLevels)))
    {
        if(!options.getGameOptions().isStillPlatforms())
        {
          if(!((totalRowCountInput <= inputPlatformCounter) && options.getGameOptions().isInputPlatforms()))
          {
            //This used to be able to start at any level
            if(riseSpeed > 0)
            {
              spawnPlatformLevel();
            }
          }
        }
        else
        {
          if(totalRowCountInput > inputPlatformCounter && riseSpeed > 0.0f && firstIteration)
          {
            spawnPlatformLevelNoRiseSpeed();
            incrementPlatforms();
            spawnPlatformLevelNoRiseSpeed();
            incrementPlatforms();
            firstIteration = false;
          }
        }
       
        if(!options.getGameOptions().isStillPlatforms())
        {
          nextHeightBetweenPlatformLevels = random(minHeightBetweenPlatformLevels, maxHeightBetweenPlatformLevels);
        }
        else
        {
          nextHeightBetweenPlatformLevels = 125;
        }
     }


    if (rising)
    {
      if (initialHeight - initialPlat.getPosition().y >= thresholdHeight)
      {
        for (IGameObject platform : platforms)
        {
          IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
          if (component != null)
          {
            RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
            rigidBodyComponent.setLinearVelocity(new PVector(0.0, 0.0));
          }
        }
        rising = false;
        isRising = false;
        if(stillPlatformCounter > 1)
        {
          stillPlatformCounter--;
          Event fittsLawLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
          fittsLawLevelUp.addIntParameter("platformLevel", currentPlatformLevel);
          eventManager.queueEvent(fittsLawLevelUp);
          pc.spawnPlatformLevelNoRiseSpeed();
          pc.incrementPlatforms();
        }
      }
    }
  }
  
  private void spawnPlatformLevel()
  {
    boolean isBreakPlatform = random(0.0, 1.0) < breakPlatformChance ? true : false;
    boolean isPortal = random(0.0, 1.0) < bonusLevelChance ? true: false;
    ArrayList<PVector> platformRanges = new ArrayList<PVector>();
    platformRanges.add(new PVector(leftSide, rightSide));
    ArrayList<Integer> platLevels = new ArrayList<Integer>();
    int gapsInLevel = int(random(minGapsPerLevel, maxGapsPerLevel + 1));
    int rangeSelector;
    PVector range;
    if(options.getGameOptions().isInputPlatforms())
    {
      rangeSelector = int(random(0, platformRanges.size() - 1));
      range = platformRanges.get(rangeSelector);
      
      TableRow row = tableInput.getRow(inputPlatformCounter);
      float gapPosition = row.getFloat("placement")  + 15;
      float halfGapWidth = row.getFloat("halfWidth");
      platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
      range.y = gapPosition - halfGapWidth;
      
     
      if(options.getGameOptions().isFittsLaw() || isBreakPlatform)
      {
        IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
        breakPlatform.setTag("break_platform");
        setPlatformRiseSpeed(breakPlatform);
        platforms.add(breakPlatform);
        platLevels.add(breakPlatform.getUID());
      }
      else if(isPortal)
      {
        IGameObject portalPlatform = gameStateController.getGameObjectManager().addGameObject(portalPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
        portalPlatform.setTag("portal_platform");
        setPlatformRiseSpeed(portalPlatform);
        platforms.add(portalPlatform);
        platLevels.add(portalPlatform.getUID());
      }
      
      inputPlatformCounter++;
    }
    else
    {
      boolean portalLoaded = false;
      for (int i = 0; i < gapsInLevel; ++i)
      {
        rangeSelector = int(random(0, platformRanges.size() - 1));
        range = platformRanges.get(rangeSelector);
        float rangeWidth = range.y - range.x;
        float rangeWidthMinusDistanceBetweenGaps = rangeWidth - minDistanceBetweenGaps;
        if (rangeWidthMinusDistanceBetweenGaps < minGapSize)
        {
          continue;
        }
        float halfGapWidth = random(minGapSize, min(maxGapSize, rangeWidthMinusDistanceBetweenGaps)) / 2.0;
        float gapPosition = random(range.x + minDistanceBetweenGaps + halfGapWidth-5, range.y - minDistanceBetweenGaps - halfGapWidth + 5);
        platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
        range.y = gapPosition - halfGapWidth;
        
        //Have to change to see if we need break platforms
        if(options.getGameOptions().isFittsLaw() || isBreakPlatform)
        {
          IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
         breakPlatform.setTag("break_platform");
         setPlatformRiseSpeed(breakPlatform);
         platforms.add(breakPlatform);
         platLevels.add(breakPlatform.getUID());
        }
        else if(isPortal && !portalLoaded)
        {
          IGameObject portalPlatform = gameStateController.getGameObjectManager().addGameObject(portalPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
          portalPlatform.setTag("portal_platform");
          setPlatformRiseSpeed(portalPlatform);
          platforms.add(portalPlatform);
          platLevels.add(portalPlatform.getUID());
          portalLoaded = true;
        }
      }
    }
    
    for (PVector platformRange : platformRanges)
    {
      float platformPosition = (platformRange.x + platformRange.y) / 2.0f;
      float platformWidth = platformRange.y - platformRange.x;
      IGameObject platform;
      
      if (options.getGameOptions().getPlatformMods())
      {
        if (random(0.0, 1.0) < slipperyPlatformChance)
        {
          platform = gameStateController.getGameObjectManager().addGameObject(slipperyPlatformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
        }
        else if (random(0.0, 1.0) < stickyPlatformChance)
        {
          platform = gameStateController.getGameObjectManager().addGameObject(stickyPlatformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
        }
        else
        {
          platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
        }
      }
      else
      {
        platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, spawnHeight), new PVector(platformWidth, platformHeight));
      }
      
      platform.setTag(tag);
      setPlatformRiseSpeed(platform);
      platforms.add(platform);
      platLevels.add(platform.getUID());
      float obstacleOffset = -100;
      if (options.getGameOptions().getObstacles())
      {
        float generateObstacle = random(0.0, 1);
        if ((generateObstacle < obstacleChance) && platformWidth > 8)
        {
          float obstacleWidth = random(obstacleMinWidth, obstacleMaxWidth);
          float obstacleHeight = obstacleWidth *2.5;
            
          obstacleOffset = random((-platformWidth/2)+obstacleWidth, (platformWidth/2)-obstacleWidth);
          if(obstacleOffset > ((platformWidth/2)-obstacleWidth) || obstacleOffset < ((-platformWidth/2)+obstacleWidth))
          {
            obstacleOffset = 0;
          }
         
          IGameObject obstacle = gameStateController.getGameObjectManager().addGameObject(obstacleFile, new PVector(platformPosition + obstacleOffset, spawnHeight - (platformHeight / 2.0f) - (obstacleHeight / 2.0f)),new PVector(obstacleWidth, obstacleHeight));
          obstacle.setTag(obstacleTag);
          IComponent component = obstacle.getComponent(ComponentType.RIGID_BODY);
            
           if (component != null)
           {
             RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
             rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
           }
           obstacles.add(obstacle);
        }
      }
      
      float coinProbability = currentLevel/10;
      coinProbability = coinProbability/10 + 0.1;
      if(coinProbability < 0.5)
      {
        coinProbability = 0.5; 
      }
      float generateCoin = random(0.0, 1.0);
      if((generateCoin < coinProbability) && platformWidth > 8)
      {
       float coinOffset = random((-platformWidth/2)+7.5, platformWidth/2-7.5);
       if(abs(coinOffset - obstacleOffset) > 15)
       {
         IGameObject coin = gameStateController.getGameObjectManager().addGameObject("xml_data/coin.xml", new PVector(platformPosition+coinOffset,505), new PVector(1.0, 1.0));
         coin.setTag("coin");
         IComponent component = coin.getComponent(ComponentType.RIGID_BODY);
          
         if (component != null)
         {
           RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
           rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
         }
       }
      }
      
    }
    platformLevels.add(platLevels);
  }
  
  public void spawnPlatformLevelNoRiseSpeed()
  {
    boolean isBreakPlatform = random(1.0, 1.0) < breakPlatformChance ? true : false;
    float tempSpawnHeight = spawnHeight;
    ArrayList<PVector> platformRanges = new ArrayList<PVector>();
    platformRanges.add(new PVector(leftSide, rightSide));
    ArrayList<Integer> platLevels = new ArrayList<Integer>();

    int rangeSelector = int(random(0, platformRanges.size() - 1));
    PVector range = platformRanges.get(rangeSelector);
    if(options.getGameOptions().isInputPlatforms())
    {
      if(totalRowCountInput > inputPlatformCounter)
      {
        TableRow row = tableInput.getRow(inputPlatformCounter);
        float gapPosition = row.getFloat("placement") + 15;
        float halfGapWidth = row.getFloat("halfWidth");
        platformGapPosition.add(new PVector(gapPosition,halfGapWidth));
        platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
        range.y = gapPosition - halfGapWidth;

        if(options.getGameOptions().isFittsLaw() || isBreakPlatform)
        {
          IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
          breakPlatform.setTag("break_platform");
          platforms.add(breakPlatform);
          platLevels.add(breakPlatform.getUID());
        }
      }
      else if (totalRowCountInput <= inputPlatformCounter)
      {
        eventManager.queueEvent(new Event(EventType.GAME_OVER));
      }
      inputPlatformCounter++;
    }
    else
    {
      //int gapsInLevel = int(random(minGapsPerLevel, maxGapsPerLevel + 1));
      int gapsInLevel = 1;
      for (int i = 0; i < gapsInLevel; ++i)
      {
        rangeSelector = int(random(0, platformRanges.size() - 1));
        range = platformRanges.get(rangeSelector);
        float rangeWidth = range.y - range.x;
        float rangeWidthMinusDistanceBetweenGaps = rangeWidth - minDistanceBetweenGaps;
        if (rangeWidthMinusDistanceBetweenGaps < minGapSize)
        {
          continue;
        }
        float halfGapWidth = random(minGapSize, min(maxGapSize, rangeWidthMinusDistanceBetweenGaps)) / 2.0;
        float gapPosition = random(range.x + minDistanceBetweenGaps + halfGapWidth, range.y - minDistanceBetweenGaps - halfGapWidth);
        platformGapPosition.add(new PVector(gapPosition,halfGapWidth));
        platformRanges.add(rangeSelector + 1, new PVector(gapPosition + halfGapWidth, range.y));
        range.y = gapPosition - halfGapWidth;
        if(options.getGameOptions().isFittsLaw() || isBreakPlatform)
        {
          IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(gapPosition, spawnHeight), new PVector(halfGapWidth*2, platformHeight));
          breakPlatform.setTag("break_platform");
          platforms.add(breakPlatform);
          platLevels.add(breakPlatform.getUID());
        }
      }
    }

    for (PVector platformRange : platformRanges)
    {
      float platformPosition = (platformRange.x + platformRange.y) / 2.0f;
      float platformWidth = platformRange.y - platformRange.x;

      IGameObject platform;
      platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, tempSpawnHeight), new PVector(platformWidth, platformHeight));
      platform.setTag(tag);
      platforms.add(platform);
      platLevels.add(platform.getUID());
    }
    platformLevels.add(platLevels);
    currentPlatformLevel++;
  }
  
  public void incrementPlatforms()
  {
    if (firstIteration)
    {
      for(IGameObject platform : platforms)
      {
        IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
        if (component != null)
        {
          RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
          rigidBodyComponent.setPlatformPosition(new PVector(0.0, rigidBodyComponent.getPosition().y-125));
        }
      }
    }
    else
    {
      rising = true;
      isRising = true;
      for(IGameObject platform : platforms)
      {
        IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
        if (component != null)
        {
          RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
          if (platform.getUID() == platforms.get(2).getUID())
          {
            initialPlat = rigidBodyComponent;
            initialHeight = (int)rigidBodyComponent.getPosition().y;
          }
          rigidBodyComponent.setLinearVelocity(new PVector(0.0, -50));
        }
      }
    }
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
    {
      riseSpeed = event.getRequiredFloatParameter(currentRiseSpeedParameterName);
      currentLevel = event.getRequiredIntParameter("currentLevel");
      for (IGameObject platform : platforms)
      {
        setPlatformRiseSpeed(platform);
      }
      
      for (IGameObject obstacle : obstacles)
      {
        setPlatformRiseSpeed(obstacle);
      }
    }
  }
  
  private void setPlatformRiseSpeed(IGameObject platform)
  {
    IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setLinearVelocity(new PVector(0.0, -riseSpeed));
    }
  }

  private void setPlatformDescentSpeed(IGameObject platform)
  {
    IComponent component = platform.getComponent(ComponentType.RIGID_BODY);
    if (component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      rigidBodyComponent.setLinearVelocity(new PVector(0.0, 300));
    }
    platforms.remove(platform);
  }

  public float getMinGapSize()
  {
    return minGapSize;
  }
}

public class BonusPlatformManager extends Component
{
  private LinkedList<IGameObject> coins;
  private String platformFile;  
  private String portalPlatformFile;
  private String tag; 
  private String breakPlatformFile;
  private String playerFile;
  
  private float leftSide;
  private float rightSide;
  
  private float platformHeight;
  private long startTime;
  
  private float gapDistance;
  private float gapWidth;
  private ArrayList<ArrayList<Integer>> bonusplatformLevels;;

  public BonusPlatformManager(IGameObject _gameObject)
  {
    super(_gameObject);
    coins = new LinkedList<IGameObject>();
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    platformFile = xmlComponent.getString("platformFile");
    tag = xmlComponent.getString("tag");
    leftSide = xmlComponent.getFloat("leftSide");
    rightSide = xmlComponent.getFloat("rightSide");
    platformHeight = xmlComponent.getFloat("platformHeight");
    portalPlatformFile = xmlComponent.getString("portalPlatformFile");
    breakPlatformFile = xmlComponent.getString("breakPlatformFile");
    playerFile =  xmlComponent.getString("playerFile");
    gapDistance = 0;
    gapWidth = 0;
    bonusplatformLevels = new ArrayList<ArrayList<Integer>>();
    isBonusPractice = false;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.BONUS_PLATFORM_MANAGER;
  }
  
  @Override public void update(int deltaTime)
  { 
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_COLLISION))
    {
      IGameObject platform = event.getRequiredGameObjectParameter("platform");
      if(!bonusplatformLevels.isEmpty())
      {
          if(bonusplatformLevels.get(0).contains(platform.getUID()))
          {
            TableRow newRow = tableFittsStats.addRow(); 
            fsc.startLogLevel(newRow, 7-bonusplatformLevels.size(), bonusInputCounter); 
            bonusplatformLevels.remove(0);
          }
      }
    }
  }
  
  public void spawnBonusPlatformLevels()
  {
    coins.clear();
    startTime = System.currentTimeMillis();
    ArrayList<PVector> platformRanges = new ArrayList<PVector>();
    ArrayList<Integer> platLevels = new ArrayList<Integer>();
    platformRanges.add(new PVector(15, 485));
    float tempSpawnHeight = 50;
    int rangeSelector = int(random(0, platformRanges.size() - 1));
    PVector range = platformRanges.get(rangeSelector);
    tempSpawnHeight = 38;
    TableRow row = tableBonusInput.getRow(bonusInputCounter);
    gapDistance = row.getFloat("distance");
    gapWidth = row.getFloat("width");
    isBonusPractice = row.getString("practice").equalsIgnoreCase("TRUE") ? true : false;
    
    IGameObject player_bonus = gameStateController.getGameObjectManager().addGameObject(playerFile, new PVector(250-(gapDistance/2), 50), new PVector(25, 25));
    player_bonus.setTag("player");
    
    bonusInputCounter++;
    if(bonusInputCounter >= tableBonusInput.getRowCount()){
      bonusInputCounter = 0; 
    }
    
    int numberOfCoins = abs((int)((250-(gapDistance/2)+(gapWidth/2)) - (250+(gapDistance/2)-(gapWidth/2)))/20) + 1;
    
    for(int i = 0; i<6;i++)
    {
      float tempGapPosition = 250+((gapDistance/2) * pow(-1,i));
      platformGapPosition.add(new PVector(tempGapPosition,gapWidth/2));
      platformRanges.add(rangeSelector + 1, new PVector(tempGapPosition + gapWidth/2, range.y));
      range.y = tempGapPosition - gapWidth/2;
      tempSpawnHeight += 76;
      
      if(i == 5)
      {
        IGameObject endPortalPlatform = gameStateController.getGameObjectManager().addGameObject(portalPlatformFile, new PVector(tempGapPosition, tempSpawnHeight+7), new PVector(gapWidth, platformHeight-10));
        endPortalPlatform.setTag("end_portal_platform");
      }

      IGameObject breakPlatform = gameStateController.getGameObjectManager().addGameObject(breakPlatformFile, new PVector(tempGapPosition, tempSpawnHeight), new PVector(gapWidth - 4, platformHeight));
      breakPlatform.setTag("break_platform");
      platLevels.add(breakPlatform.getUID());

      platLevels = new ArrayList<Integer>();
      for (PVector platformRange : platformRanges)
      {
        float platformPosition = (platformRange.x + platformRange.y) / 2.0f;
        float platformWidth = platformRange.y - platformRange.x;
  
        IGameObject platform;
        platform = gameStateController.getGameObjectManager().addGameObject(platformFile, new PVector(platformPosition, tempSpawnHeight), new PVector(platformWidth, platformHeight));
        platform.setTag(tag);
        platLevels.add(platform.getUID());
      }
      bonusplatformLevels.add(platLevels);
      for(int j =0;j<numberOfCoins;j++)
      {
        IGameObject coin;
        if(tempGapPosition < 250){
          coin = gameStateController.getGameObjectManager().addGameObject("xml_data/coin.xml", new PVector(tempGapPosition+(gapWidth/2)+j*20,tempSpawnHeight - 20), new PVector(1.0, 1.0));
        }
        else{
          coin = gameStateController.getGameObjectManager().addGameObject("xml_data/coin.xml", new PVector(tempGapPosition-(gapWidth/2)-j*20,tempSpawnHeight - 20), new PVector(1.0, 1.0));
        }
        coin.setTag("coin");
        coins.add(coin);
      }
      
      platformRanges = new ArrayList<PVector>();
      platformRanges.add(new PVector(leftSide, rightSide));
      rangeSelector = int(random(0, platformRanges.size() - 1));
      range = platformRanges.get(rangeSelector);
   }
  }
}

public class CoinEventHandlerComponent extends Component
{
  private int scoreValue;
  private String coinCollectedCoinParameterName;
  private String scoreValueParameterName;
  
  private float amplitude;
  
  private String destroyCoinCoinParameterName;
  
  private String currentRiseSpeedParameterName;

  public CoinEventHandlerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    for (XML xmlCoinEventComponent : xmlComponent.getChildren())
    {
      if (xmlCoinEventComponent.getName().equals("CoinCollected"))
      {
        scoreValue = xmlCoinEventComponent.getInt("scoreValue");
        coinCollectedCoinParameterName = xmlCoinEventComponent.getString("coinParameterName");
        scoreValueParameterName = xmlCoinEventComponent.getString("scoreValueParameterName");
        amplitude = xmlCoinEventComponent.getFloat("amp");
      }
      else if (xmlCoinEventComponent.getName().equals("DestroyCoin"))
      {
        destroyCoinCoinParameterName = xmlCoinEventComponent.getString("coinParameterName");
      }
      else if (xmlCoinEventComponent.getName().equals("LevelUp"))
      {
        currentRiseSpeedParameterName = xmlCoinEventComponent.getString("currentRiseSpeedParameterName");
      }
    }
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.COIN_EVENT_HANDLER;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.COIN_COLLECTED))
    {
      if (event.getRequiredGameObjectParameter(coinCollectedCoinParameterName).getUID() == gameObject.getUID())
      {
        Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
        updateScoreEvent.addIntParameter(scoreValueParameterName, scoreValue);
        eventManager.queueEvent(updateScoreEvent);
        gameStateController.getGameObjectManager().removeGameObject(gameObject.getUID());
        coinCollectedSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
        coinCollectedSound.play();
      }
    }
    for (IEvent event : eventManager.getEvents(EventType.DESTROY_COIN))
    {
      if (event.getRequiredGameObjectParameter(destroyCoinCoinParameterName).getUID() == gameObject.getUID())
      {
        gameStateController.getGameObjectManager().removeGameObject(gameObject.getUID());
      }
    }
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
    {
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      if (component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        rigidBodyComponent.setLinearVelocity(new PVector(0.0f, -event.getRequiredFloatParameter(currentRiseSpeedParameterName)));
      }
    }
  }
}

public class ScoreTrackerComponent extends Component
{
  private String scoreValueParameterName;
  private String scoreTextPrefix;
  private int totalScore;
  
  public ScoreTrackerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    totalScore = 0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    scoreTextPrefix = xmlComponent.getString("scoreTextPrefix");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.SCORE_TRACKER;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.UPDATE_SCORE))
    {
      totalScore += event.getRequiredIntParameter(scoreValueParameterName);
    
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        RenderComponent.Text text = renderComponent.getTexts().get(0);
        if (text != null)
        {
          text.string = scoreTextPrefix + Integer.toString(totalScore);
        }
      }
    }
  }
}

public class BonusScoreComponent extends Component
{
  private String scoreValueParameterName;
  private String scoreTextPrefix;
  private int totalScore;
  private int coinsCollected;
  
  public BonusScoreComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    coinsCollected = 0;
    totalScore = 0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    scoreTextPrefix = xmlComponent.getString("scoreTextPrefix");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.BONUS_SCORE;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private int getBonusScore()
  {
    return totalScore;
  }
  
  private int getBonusCoins()
  {
    return coinsCollected;
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.UPDATE_SCORE))
    {
      totalScore += event.getRequiredIntParameter(scoreValueParameterName);
    
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        RenderComponent.Text text = renderComponent.getTexts().get(0);
        if (text != null)
        {
          text.string = scoreTextPrefix + Integer.toString(totalScore);
        }
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.COIN_COLLECTED))
    {
      coinsCollected++;
    }
    
  }
}

public class CalibrateWizardComponent extends Component
{
  ArrayList<String> actionsToRegister;
  String currentAction;
  
  public CalibrateWizardComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    actionsToRegister = new ArrayList<String>();
    actionsToRegister.add(LEFT_DIRECTION_LABEL);
    actionsToRegister.add(RIGHT_DIRECTION_LABEL);

    currentAction = actionsToRegister.remove(0);
    updateRenderComponent();
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    // can I read in actionsToRegister from XML?
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.CALIBRATE_WIZARD;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.SPACEBAR_PRESSED))
    {
      // register action
      boolean success = false;
      if (calibrationMode == CalibrationMode.AUTO)
        success = emgManager.registerAction(currentAction);
      else if (currentAction == LEFT_DIRECTION_LABEL)
        success = emgManager.registerAction(currentAction, leftSensor);
      else if (currentAction == RIGHT_DIRECTION_LABEL)
        success = emgManager.registerAction(currentAction, rightSensor);

      if (!success) {
        Event failureEvent = new Event(EventType.CALIBRATE_FAILURE);
        eventManager.queueEvent(failureEvent);
      }

      // increment action
      if (actionsToRegister.size() == 0)
      {
        Event successEvent = new Event(EventType.CALIBRATE_SUCCESS);
        eventManager.queueEvent(successEvent);
      }
      else {
        currentAction = actionsToRegister.remove(0);
      }

      updateRenderComponent();
    }
  }

  private void updateRenderComponent()
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      RenderComponent.Text text = renderComponent.getTexts().get(0);
      RenderComponent.OffsetPImage img = renderComponent.getImages().get(0);
      if (text != null)
      {
        text.string = currentAction;
        if(currentAction.equals("LEFT"))
        {
          if (options.getIOOptions().getForearm() == Forearm.RIGHT)
          {
            img.pimageName = "images/myo_gesture_icons/wave-left.png";
          }
          else if (options.getIOOptions().getForearm() == Forearm.LEFT)
          {
            img.pimageName = "images/myo_gesture_icons/LHwave-left.png";
          }
          else
          {
            println("[ERROR] unrecognized Forearm specified in CalibrateWizard::updateRenderComponent");
          }
        }
        else if(currentAction.equals("RIGHT"))
        {
          if (options.getIOOptions().getForearm() == Forearm.RIGHT)
          {
            img.pimageName = "images/myo_gesture_icons/wave-right.png";
          }
          else if (options.getIOOptions().getForearm() == Forearm.LEFT)
          {
            img.pimageName = "images/myo_gesture_icons/LHwave-right.png";
          }
          else
          {
            println("[ERROR] unrecognized Forearm specified in CalibrateWizard::updateRenderComponent");
          }
        }
      }
    }
  }
}


public class CountdownComponent extends Component 
{
  private int value;
  private int countdownFrom;
  private int sinceLastTick;
  
  public CountdownComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    value = 0;
    countdownFrom = 0;
    sinceLastTick = 0;
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    countdownFrom = xmlComponent.getInt("countdownFrom");
    reset();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.COUNTDOWN;
  }

  @Override public void update(int deltaTime)
  {
    sinceLastTick += deltaTime;
    if (sinceLastTick >= 1000)
    {
      value -= 1;
      sinceLastTick = 0;
      sendEvent();
    }

  }

  public void reset() {
    value = countdownFrom;
    sinceLastTick = 0;
    sendEvent();
  }

  private void sendEvent() {
    Event event = new Event(EventType.COUNTDOWN_UPDATE);
    event.addIntParameter("value", value);
    eventManager.queueEvent(event);
  }
}

public class ButtonComponent extends Component
{
  private int buttonHeight;
  private int buttonWidth;
  
  private boolean mouseOver;
  
  private float amplitude;

  public ButtonComponent(GameObject _gameObject)
  {
    super(_gameObject);

    buttonHeight = 0;
    buttonWidth = 0;
    amplitude = 1;
    mouseOver = false;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    // Multiply the height and width by the scale values to make the button that size
    buttonHeight = xmlComponent.getInt("height") * (int)gameObject.getScale().y;
    buttonWidth = xmlComponent.getInt("width") * (int)gameObject.getScale().x;
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.BUTTON;
  }

  @Override public void update(int deltaTime)
  {
    float widthScale = (width / 500.0f);
    float heightScale = (height / 500.0f);
    
    float xButton = gameObject.getTranslation().x * widthScale;
    float yButton = gameObject.getTranslation().y * heightScale;
    
    float actualButtonWidth = buttonWidth * widthScale;
    float actualButtonHeight = buttonHeight * heightScale;
    
    if (xButton - 0.5 * actualButtonWidth <= mouseX && xButton + 0.5 * actualButtonWidth >= mouseX && yButton - 0.5 * actualButtonHeight <= mouseY && yButton + 0.5 * actualButtonHeight >= mouseY)
    {
      mouseOver = true;
      mouseHand = true;
    }
    else
    {
      mouseOver = false;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.MOUSE_CLICKED))
    {
      if (mouseOver)
      {
        Event buttonEvent = new Event(EventType.BUTTON_CLICKED);
        buttonEvent.addStringParameter("tag",gameObject.getTag());
        eventManager.queueEvent(buttonEvent);
        buttonClickedSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
        buttonClickedSound.play();
      }
    }
  }
}

public class SliderComponent extends Component
{
  private int sliderHeight;
  private int sliderWidth;
  private boolean mouseOver;
  private boolean active;

  public SliderComponent(GameObject _gameObject)
  {
    super(_gameObject);

    sliderHeight = 0;
    sliderWidth = 0;
    mouseOver = false;
    active = false;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    // Multiply the height and width by the scale values to make the button that size
    sliderHeight = xmlComponent.getInt("height") * (int)gameObject.getScale().y;
    sliderWidth = xmlComponent.getInt("width") * (int)gameObject.getScale().x;

    // Adjust ticks on slider
    RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
    renderComponent.getShapes().get(0).translation.x = -(sliderWidth * 0.5);
    renderComponent.getShapes().get(2).translation.x = sliderWidth * 0.5;

    float distBetweenTicks = sliderWidth / 5.0;
    for(int j = 1, i = 3; i < 7; i++, j++)
    {
      renderComponent.getShapes().get(i).translation.x = -(sliderWidth * 0.5) + distBetweenTicks * j;
    }
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.SLIDER;
  }

  @Override public void update(int deltaTime)
  {
    float widthScale = (width / 500.0f);
    float heightScale = (height / 500.0f);
    
    PVector screenTranslation = new PVector(gameObject.getTranslation().x * widthScale, gameObject.getTranslation().y * heightScale);
    
    int actualSliderWidth = (int)(sliderWidth * widthScale);
    int actualSliderHeight = (int)(sliderHeight * heightScale);
    
    // Slider rect boundaries
    int xLeft = (int)(screenTranslation.x - (actualSliderWidth * 0.5));
    int xRight = (int)(screenTranslation.x + (actualSliderWidth * 0.5));
    int yTop = (int)(screenTranslation.y - (actualSliderHeight * 0.5));
    int yBottom = (int)(screenTranslation.y + (actualSliderHeight * 0.5));
    
    if (active || (xLeft <= mouseX && xRight >= mouseX && yTop <= mouseY && yBottom >= mouseY))
    {
      mouseOver = true;
      mouseHand = true;
    }
    else
    {
      mouseOver = false;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.MOUSE_PRESSED))
    {
      if (mouseOver)
      {
        active = true;
      }
    }

    if (active)
    {
      for (IEvent event : eventManager.getEvents(EventType.MOUSE_DRAGGED))
      {
        float xMouse = (float)event.getRequiredIntParameter("mouseX");
        
        if (xMouse < xLeft)
        {
          xMouse = xLeft;
        }
        else if (xMouse > xRight)
        {
          xMouse = xRight;
        }
        
        RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
        renderComponent.getImages().get(0).translation.x = (xMouse - (gameObject.getTranslation().x * widthScale)) / widthScale;
        float sliderPixelVal = xMouse - (xLeft);
        float sliderValue = sliderPixelVal/actualSliderWidth * 100;
        
        IEvent sliderDraggedEvent = new Event(EventType.SLIDER_DRAGGED);
        sliderDraggedEvent.addStringParameter("tag", gameObject.getTag());
        sliderDraggedEvent.addFloatParameter("sliderValue", sliderValue);
        eventManager.queueEvent(sliderDraggedEvent);
      }
      
      for (IEvent event : eventManager.getEvents(EventType.MOUSE_RELEASED))
      {
        float xMouse = (float)event.getRequiredIntParameter("mouseX");
        
        if (xMouse < xLeft)
        {
          xMouse = xLeft;
        }
        else if (xMouse > xRight)
        {
          xMouse = xRight;
        }
        
        RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
        renderComponent.getImages().get(0).translation.x = (xMouse - (gameObject.getTranslation().x * widthScale)) / widthScale;
        float sliderPixelVal = xMouse - (xLeft);
        float sliderValue = sliderPixelVal/actualSliderWidth * 100;
        
        IEvent sliderReleasedEvent = new Event(EventType.SLIDER_RELEASED);
        sliderReleasedEvent.addStringParameter("tag", gameObject.getTag());
        sliderReleasedEvent.addFloatParameter("sliderValue", sliderValue);
        eventManager.queueEvent(sliderReleasedEvent);
        
        active = false;
      }
    }
  }
  
  public void setTabPosition(float x)
  {
    float widthScale = width / 500.0f;
    RenderComponent renderComponent = (RenderComponent) gameObject.getComponent(ComponentType.RENDER);
    renderComponent.getImages().get(0).translation.x = (x - (gameObject.getTranslation().x * widthScale)) / widthScale;
  }
}

public class LevelDisplayComponent extends Component
{
  private String currentLevelParameterName;
  private String levelTextPrefix;
  private String platformLevelPrefix;
  
  public LevelDisplayComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    levelTextPrefix = xmlComponent.getString("levelTextPrefix");
    platformLevelPrefix = xmlComponent.getString("platformLevelPrefix");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LEVEL_DISPLAY;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)  
      {
         RenderComponent renderComponent = (RenderComponent)component;
         RenderComponent.Text text = renderComponent.getTexts().get(0);
         if (text != null)
         { 
           if(!options.getGameOptions().isStillPlatforms())
           {
             text.string = levelTextPrefix + Integer.toString(event.getRequiredIntParameter(currentLevelParameterName));
           }
         }
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLATFORM_LEVEL_UP))
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)  
      {
         RenderComponent renderComponent = (RenderComponent)component;
         RenderComponent.Text text = renderComponent.getTexts().get(0);
         if (text != null)
         { 
           if(options.getGameOptions().isStillPlatforms())
           {
             text.string = platformLevelPrefix + Integer.toString(event.getRequiredIntParameter("platformLevel"));
           }
         }
      }
    }
  }
}

public class CounterIDComponent extends Component
{
  private String countUp;
  private String countDown;
  private int count;
  private ArrayList<Integer> idCounts;
  public CounterIDComponent(GameObject _gameObject)
  {
    super(_gameObject);
    idCounts = new ArrayList<Integer>();
    count = 0;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    countUp = xmlComponent.getString("countup");
    countDown = xmlComponent.getString("countdown");
    idCounts.add(0);
    idCounts.add(0);
    idCounts.add(0);
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.ID_COUNTER;
  }

  @Override public void update(int deltaTime)
  {
    handleEvents();
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      int index = 0;
         
      if(tag.contains(countUp)){
        index = Integer.parseInt(tag.substring(tag.length()-1));
        incrementCounter(index-1,1);
      }
      else if(tag.contains(countDown)){
        index = Integer.parseInt(tag.substring(tag.length()-1));
        incrementCounter(index-1,-1);
      }
    }
  }
  
  private void incrementCounter(int index,int counter)
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    count = idCounts.get(index) + counter;
    if(count > 9)
      count = 0;
    if(count<0)
      count = 9;
      idCounts.set(index, count);
    
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
        if (texts.size() > 0)
        {
           texts.get(index).string = Integer.toString(count);
        }
    }
  }
  
  public String getUserIDNumber()
  {
    String iD = idCounts.get(0).toString() +idCounts.get(1).toString() +idCounts.get(2).toString();
    return iD;
  }
}


public class LevelParametersComponent extends Component
{
  private int currentLevel;
  private int maxLevel;
  private float levelOneRiseSpeed;
  private float riseSpeedChangePerLevel;
  private float currentRiseSpeed;
  private boolean levelUpAtLeastOnce;
  private int levelUpTime;
  private int timePassed;
  private String scoreValueParameterName;
  private String currentLevelParameterName;
  private String currentRiseSpeedParameterName;
  private SoundObject levelUpSound;
  private float amplitude;
  private int platformlevelCount;
  private int totalPlatformLevelCount;
  
  public LevelParametersComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    platformlevelCount = 10;
    totalPlatformLevelCount = 0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevel = options.getGameOptions().getStartingLevel() - 1;
    maxLevel = xmlComponent.getInt("maxLevel");
    levelOneRiseSpeed = xmlComponent.getFloat("levelOneRiseSpeed");
    riseSpeedChangePerLevel = xmlComponent.getFloat("riseSpeedChangePerLevel");
    currentRiseSpeed = levelOneRiseSpeed + (riseSpeedChangePerLevel * (currentLevel - 1));
    levelUpAtLeastOnce = false;
    levelUpTime = xmlComponent.getInt("levelUpTime");
    timePassed = levelUpTime - 1;
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    currentRiseSpeedParameterName = xmlComponent.getString("currentRiseSpeedParameterName");
    levelUpSound = soundManager.loadSoundFile(xmlComponent.getString("levelUpSoundFile"));
    levelUpSound.setPan(xmlComponent.getFloat("pan"));
    amplitude = xmlComponent.getFloat("amp");
    stillPlatformCounter = 0;
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LEVEL_PARAMETERS;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
    if ((options.getGameOptions().getLevelUpOverTime()) || !levelUpAtLeastOnce)
    {
      if (platformlevelCount > (int)(currentLevel/10))
      {
        if (currentLevel < maxLevel)
        {
          platformlevelCount = 0;
          levelUp();
          levelUpAtLeastOnce = true;
        }
      }
    }
  }
  
  private void levelUp()
  {
    currentLevel++;
    currentRiseSpeed += riseSpeedChangePerLevel;
    
    levelUpSound.setVolume(amplitude * options.getIOOptions().getSoundEffectsVolume());
    levelUpSound.play();
    
    Event levelUpEvent = new Event(EventType.LEVEL_UP);
    levelUpEvent.addIntParameter(currentLevelParameterName, currentLevel);
    levelUpEvent.addFloatParameter(currentRiseSpeedParameterName, currentRiseSpeed);
    eventManager.queueEvent(levelUpEvent);
    if(options.getGameOptions().isStillPlatforms())
    {
      Event updatePlatformLevelEvent = new Event(EventType.PLATFORM_LEVEL_UP);
      updatePlatformLevelEvent.addIntParameter("platformLevel", 1);
      eventManager.queueEvent(updatePlatformLevelEvent); 
    }
  }
  
  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_PLATFORM_COLLISION))
    {
      IGameObject platform = event.getRequiredGameObjectParameter("platform");
      if(!platformLevels.isEmpty())
      {
        for(int i = 0; i<platformLevels.size(); i++)
        {
          if(platformLevels.get(i).contains(platform.getUID()))
          {
            for(int j=0; j<i+1; j++)
            {
              platformlevelCount++;
              totalPlatformLevelCount++;
              Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
              updateScoreEvent.addIntParameter(scoreValueParameterName,(j+1)*10);
              eventManager.queueEvent(updateScoreEvent);
              platformLevels.remove(0);
              if(options.getGameOptions().isStillPlatforms() && !options.getGameOptions().isFittsLaw())
              {
                stillPlatformCounter++;
                if(stillPlatformCounter > 1 && !isRising)
                {
                  stillPlatformCounter--;
                  Event platformLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
                  platformLevelUp.addIntParameter("platformLevel", platformlevelCount);
                  eventManager.queueEvent(platformLevelUp);
                  pc.spawnPlatformLevelNoRiseSpeed();
                  pc.incrementPlatforms();
                }
              }
            }
            if(options.getGameOptions().isLogFitts() || bonusLevel)
            {
              TableRow newRow = tableFittsStats.addRow(); 
              fsc.startLogLevel(newRow, totalPlatformLevelCount, totalPlatformLevelCount); 
            }
          }
        }
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_GROUND_COLLISION))
    {
      if(!platformLevels.isEmpty())
      {
        platformlevelCount++;
        totalPlatformLevelCount++;
        Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
        updateScoreEvent.addIntParameter(scoreValueParameterName,10);
        eventManager.queueEvent(updateScoreEvent);
        platformLevels.remove(0);
        if(options.getGameOptions().isStillPlatforms() && !options.getGameOptions().isFittsLaw())
        {
          stillPlatformCounter++;
          if(stillPlatformCounter > 1 && !isRising)
          {
            stillPlatformCounter--;
            Event platformLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
            platformLevelUp.addIntParameter("platformLevel", platformlevelCount);
            eventManager.queueEvent(platformLevelUp);
            pc.spawnPlatformLevelNoRiseSpeed();
            pc.incrementPlatforms();
          }
        }        
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_BREAK_PLATFORM_COLLISION))
    {
      IGameObject platform = event.getRequiredGameObjectParameter("break_platform");
      if(!platformLevels.isEmpty())
      {
        for(int i = 0; i<platformLevels.size(); i++)
        {
          if(platformLevels.get(i).contains(platform.getUID()))
          {
            for(int j=0; j<i +1; j++)
            {
              platformlevelCount++;
              totalPlatformLevelCount++;
              Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
              updateScoreEvent.addIntParameter(scoreValueParameterName, (j+1)*10);
              eventManager.queueEvent(updateScoreEvent);
              platformLevels.remove(0);
              if(options.getGameOptions().isStillPlatforms() && !options.getGameOptions().isFittsLaw())
              {
                stillPlatformCounter++;
                if(stillPlatformCounter > 1 && !isRising)
                {
                  stillPlatformCounter--;
                  Event platformLevelUp = new Event(EventType.PLATFORM_LEVEL_UP);
                  platformLevelUp.addIntParameter("platformLevel", platformlevelCount);
                  eventManager.queueEvent(platformLevelUp);
                  pc.spawnPlatformLevelNoRiseSpeed();
                  pc.incrementPlatforms();
                }
              }
            }
            if(options.getGameOptions().isLogFitts() || bonusLevel)
            {
              TableRow newRow = tableFittsStats.addRow(); 
              fsc.startLogLevel(newRow, totalPlatformLevelCount,totalPlatformLevelCount); 
            }
          }
        }
      }
    }
  }
}

public class MusicPlayerComponent extends Component
{
  SoundObject music;
  float amplitude;
  long totalTime;
  
  public MusicPlayerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    totalTime = 0;
  }
  
  @Override public void destroy()
  {
    music.stop();
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    music = soundManager.loadSoundFile(xmlComponent.getString("musicFile"));
    // pan is not supported in stereo. that's fine, just continue.
    music.setPan(xmlComponent.getFloat("pan"));
    amplitude = xmlComponent.getFloat("amp");
    music.setVolume(amplitude * options.getIOOptions().getMusicVolume());
    music.loop();
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.MUSIC_PLAYER;
  }
  
  @Override public void update(int deltaTime)
  {
    totalTime += deltaTime;
    handleEvents();
    setMusicVolume(options.getIOOptions().getMusicVolume());
  }
  
  public void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.PUSH_BONUS))
    {
      music.stop();
    }
      
    for (IEvent event : eventManager.getEvents(EventType.MUSIC_RESTART))
    {
      music.stop();
      music.loop();
    }
  }
  
  public void setMusicVolume(float volume)
  {
    music.setVolume(amplitude * volume);
  }
}

public class StatsCollectorComponent extends Component
{
  private String currentLevelParameterName;
  private String scoreValueParameterName;
  private String currentSpeedParameterName;
  
  private int levelAchieved;
  private int scoreAchieved;
  private int timePlayed;
  private float speedInstances;
  private float averageSpeed;
  private int coinsCollected;
  
  public StatsCollectorComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    levelAchieved = 0;
    scoreAchieved = 0;
    timePlayed = 0;
    speedInstances = 0.0f;
    averageSpeed = 0.0f;
    coinsCollected = 0;
  }
  
  @Override public void destroy()
  {
    IStats stats = options.getStats();
    ICustomizeOptions custom = options.getCustomizeOptions();
    
    IGameRecord record = stats.createGameRecord();
    record.setLevelAchieved(levelAchieved); 
    record.setScoreAchieved(scoreAchieved);
    record.setTimePlayed(timePlayed);
    record.setAverageSpeed(averageSpeed);
    record.setCoinsCollected(coinsCollected);
    custom.setCoinsCollected(coinsCollected);
    record.setDate(new Date().getTime());
    record.setIsFittsLawMode(options.getGameOptions().isFittsLaw());
    
    stats.addGameRecord(record);
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    currentLevelParameterName = xmlComponent.getString("currentLevelParameterName");
    scoreValueParameterName = xmlComponent.getString("scoreValueParameterName");
    currentSpeedParameterName = xmlComponent.getString("currentSpeedParameterName");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.STATS_COLLECTOR;
  }
  
  @Override public void update(int deltaTime)
  {
    handleEvents();
    timePlayed += deltaTime;
  }
  
  private void handleEvents()
  {
    if(options.getGameOptions().isStillPlatforms())
    {
      for (IEvent event : eventManager.getEvents(EventType.PLATFORM_LEVEL_UP))
      {
        levelAchieved = event.getRequiredIntParameter("platformLevel");
      }
    }
    else
    {
      for (IEvent event : eventManager.getEvents(EventType.LEVEL_UP))
      {
        levelAchieved = event.getRequiredIntParameter(currentLevelParameterName);
      }
    }
    
    for (IEvent event : eventManager.getEvents(EventType.UPDATE_SCORE))
    {
      scoreAchieved += event.getRequiredIntParameter(scoreValueParameterName);
    }
    
    for (IEvent event : eventManager.getEvents(EventType.PLAYER_CURRENT_SPEED))
    {
      float currentSpeed = event.getRequiredFloatParameter(currentSpeedParameterName);
      speedInstances += 1.0f;
      averageSpeed = (((speedInstances - 1.0f) * averageSpeed) + currentSpeed) / speedInstances;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.COIN_COLLECTED))
    {
      coinsCollected++;
    }
    
    for (IEvent event : eventManager.getEvents(EventType.BONUS_COINS_COLLECTED))
    {
      int bonusCoinsCollected = event.getRequiredIntParameter("coinscoleected");
      coinsCollected+= bonusCoinsCollected;
    }
  }
}

public class PostGameControllerComponent extends Component
{
  private IGameRecord lastGameRecord;
  private ICustomizeOptions customizeOptions;
  private boolean textIsSet;
  
  public PostGameControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    
    ArrayList<IGameRecord> records = options.getStats().getGameRecords();
    lastGameRecord = records.get(records.size() - 1);
    customizeOptions = options.getCustomizeOptions();
    textIsSet = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.POST_GAME_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    if (!textIsSet)
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        ArrayList<RenderComponent.Text> textElements = renderComponent.getTexts();
        textElements.get(0).string = Integer.toString(lastGameRecord.getLevelAchieved());
        textElements.get(1).string = Integer.toString(lastGameRecord.getScoreAchieved());
        textElements.get(2).string = Integer.toString((int)(lastGameRecord.getAverageSpeed()));
        textElements.get(3).string = Integer.toString(lastGameRecord.getCoinsCollected());
        textElements.get(4).string = Integer.toString(customizeOptions.getCoinsCollected());
        int milliseconds = lastGameRecord.getTimePlayed();                                                                     
        int seconds = (milliseconds/1000) % 60;                                                                            
        int minutes = milliseconds/60000;  
        textElements.get(5).string = String.format("%3d:%02d", minutes, seconds);
      }
      
      textIsSet = true;
    }
  }
}

public class GameOptionsControllerComponent extends Component
{
  private String sliderTag;
  private float sliderLeftBoundary;
  private float sliderRightBoundary;
  private float yPosition;
  
  private String increaseDifficultyOverTimeTag;
  private String defaultTag;
  private String autoDirectTag;
  private String leftTag;
  private String rightTag;
  private String bothTag;
  private String singleMuscleTag;
  private String autoLeftTag;
  private String autoRightTag;
  private String obstaclesTag;
  private String terrainModsTag;
  private String logRawDataTag;
  private String fittsLawTag;
  private String inputPlatformTag;
  private String logFittsTag;
  private String constraintsFittsTag;
  private String jump3timestag;
  private String wait2secstag;
  private float checkBoxXPosition;
  private float radioButtonXposition;
  private float falseDisplacement;
  
  
  public GameOptionsControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    sliderTag = xmlComponent.getString("sliderTag");
    sliderLeftBoundary = xmlComponent.getFloat("sliderLeftBoundary");
    sliderRightBoundary = xmlComponent.getFloat("sliderRightBoundary");
    yPosition = xmlComponent.getFloat("yPosition");
    
    increaseDifficultyOverTimeTag = xmlComponent.getString("increaseDifficultyOverTimeTag");
    defaultTag = xmlComponent.getString("defaultTag");
    autoDirectTag = xmlComponent.getString("autoDirectTag");
    leftTag = xmlComponent.getString("left");
    rightTag = xmlComponent.getString("right");
    bothTag = xmlComponent.getString("both");
    singleMuscleTag = xmlComponent.getString("singleMuscleTag");
    autoLeftTag = xmlComponent.getString("autoLeftTag");
    autoRightTag = xmlComponent.getString("autoRightTag");
    obstaclesTag = xmlComponent.getString("obstaclesTag");
    terrainModsTag = xmlComponent.getString("terrainModsTag");
    logRawDataTag = xmlComponent.getString("logRawDataTag");
    fittsLawTag = xmlComponent.getString("fittsLawTag");
    inputPlatformTag = xmlComponent.getString("inputPlatformTag");
    logFittsTag = xmlComponent.getString("logFittsTag");
    constraintsFittsTag = xmlComponent.getString("constraintsFittsTag");
    wait2secstag = xmlComponent.getString("wait2secstag");
    jump3timestag = xmlComponent.getString("jump3timestag");
    checkBoxXPosition = xmlComponent.getFloat("checkBoxXPosition");
    radioButtonXposition = xmlComponent.getFloat("radioButtonXposition");
    falseDisplacement = xmlComponent.getFloat("falseDisplacement");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.GAME_OPTIONS_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    IGameOptions gameOptions = options.getGameOptions();
    
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");
      
      if (tag.equals(increaseDifficultyOverTimeTag))
      {
        gameOptions.setLevelUpOverTime(!gameOptions.getLevelUpOverTime());
        if(gameOptions.getLevelUpOverTime())
        {
         gameOptions.setStillPlatforms(false); 
        }
      }
      else if(tag.equals(defaultTag))
      {
        gameOptions.setControlPolicy(ControlPolicy.NORMAL);
      }
      else if (tag.equals(autoDirectTag))
      {
        if (gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST)
        {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
        else
        {
          gameOptions.setControlPolicy(ControlPolicy.DIRECTION_ASSIST);
          gameOptions.setDirectionAssistMode(DirectionAssistMode.LEFT_ONLY);
          gameOptions.setObstacles(false);
          gameOptions.setBreakthroughMode(BreakthroughMode.WAIT_2SEC);

        }
      }
      else if (tag.equals(singleMuscleTag))
      {
        if (gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE) {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
        else
        {
          gameOptions.setControlPolicy(ControlPolicy.SINGLE_MUSCLE);
          gameOptions.setSingleMuscleMode(SingleMuscleMode.AUTO_LEFT);
          gameOptions.setObstacles(false);
          gameOptions.setBreakthroughMode(BreakthroughMode.WAIT_2SEC);
        }
      }
      else if (tag.equals(obstaclesTag))
      {
        gameOptions.setObstacles(!gameOptions.getObstacles());
        if (gameOptions.getObstacles())
        {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
      }
      else if (tag.equals(terrainModsTag))
      {
        gameOptions.setPlatformMods(!gameOptions.getPlatformMods());
      }
      else if(tag.equals(logRawDataTag))
      {
        gameOptions.setLogRawData(!gameOptions.isLogRawData());
      }
      else if (tag.equals(fittsLawTag))
      {
        gameOptions.setFittsLaw(!gameOptions.isFittsLaw());
        if(gameOptions.isFittsLaw())
        {
          gameOptions.setInputPlatforms(true);
          gameOptions.setLogFitts(true);
          gameOptions.setStillPlatforms(true);
          gameOptions.setLevelUpOverTime(false);
          gameOptions.setObstacles(false);
          gameOptions.setPlatformMods(false);
        }
        else
        {
          gameOptions.setInputPlatforms(false);
          gameOptions.setLogFitts(false);
          gameOptions.setStillPlatforms(false);
        }
      }
      else if (tag.equals(inputPlatformTag))
      {
        gameOptions.setInputPlatforms(!gameOptions.isInputPlatforms());
      }
      else if (tag.equals(logFittsTag))
      {
        gameOptions.setLogFitts(!gameOptions.isLogFitts());
      }
      else if (tag.equals(constraintsFittsTag))
      {
        gameOptions.setStillPlatforms(!gameOptions.isStillPlatforms());
        if(gameOptions.isStillPlatforms())
        {
          gameOptions.setLevelUpOverTime(false);
        }
      }
      

      if(tag.equals(wait2secstag))
      {
        gameOptions.setBreakthroughMode(BreakthroughMode.WAIT_2SEC);
      }
      else if(tag.equals(jump3timestag))
      {
        gameOptions.setBreakthroughMode(BreakthroughMode.CO_CONTRACTION);
        if(!(gameOptions.getControlPolicy() == ControlPolicy.NORMAL))
        {
          gameOptions.setControlPolicy(ControlPolicy.NORMAL);
        }
      }
       
      if(gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST)
      {
        if (tag.equals(leftTag))
        {
          gameOptions.setDirectionAssistMode(DirectionAssistMode.LEFT_ONLY);
        }
        else if (tag.equals(rightTag))
        {
          gameOptions.setDirectionAssistMode(DirectionAssistMode.RIGHT_ONLY);
        }
          else if (tag.equals(bothTag))
        {
          gameOptions.setDirectionAssistMode(DirectionAssistMode.BOTH);
        } 
      }

      if(gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE)
      {
        if (tag.equals(autoLeftTag))
          gameOptions.setSingleMuscleMode(SingleMuscleMode.AUTO_LEFT);
        else if (tag.equals(autoRightTag))
          gameOptions.setSingleMuscleMode(SingleMuscleMode.AUTO_RIGHT);
      }
    }
    
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
      if (texts.size() > 0)
      {
        RenderComponent.Text sliderText = texts.get(0);
        
        int startingLevel = options.getGameOptions().getStartingLevel();
        sliderText.string = Integer.toString(startingLevel);
        sliderText.translation.x = ((startingLevel / 100.0f) * (sliderRightBoundary - sliderLeftBoundary)) + sliderLeftBoundary;
        sliderText.translation.y = yPosition;
        
        ArrayList<IGameObject> sliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(sliderTag);
        if (sliderList.size() > 0)
        {
          IGameObject slider = sliderList.get(0);
          component = slider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0) * sliderText.translation.x);
          }
        }
      }
      
      ArrayList<RenderComponent.OffsetPShape> shapes = renderComponent.getShapes();
      ArrayList<RenderComponent.OffsetPImage> images = renderComponent.getImages();
      if (shapes.size() > 3)
      {
        RenderComponent.OffsetPImage levelUpOverTimeCheckBox = images.get(0);
        RenderComponent.OffsetPImage obstaclesCheckBox = images.get(1);
        RenderComponent.OffsetPImage terrainModsCheckBox = images.get(2);
         RenderComponent.OffsetPImage logRawDataCheckBox = images.get(3);
        RenderComponent.OffsetPImage fittsLawCheckBox = images.get(4);
       
        
        RenderComponent.OffsetPImage inputPlatformsCheckBox = images.get(5);
        RenderComponent.OffsetPImage logFittsCheckBox = images.get(6);
        RenderComponent.OffsetPImage contraintsFittsCheckBox = images.get(7);

        
        //Ellipses for Auto-DirectMode
        RenderComponent.OffsetPShape deafultControlCheckBox = shapes.get(0);
        RenderComponent.OffsetPShape autoDirectCheckBox = shapes.get(1);
        RenderComponent.OffsetPShape leftCheckbox = shapes.get(2);
        RenderComponent.OffsetPShape rightCheckbox = shapes.get(3);
        RenderComponent.OffsetPShape bothCheckbox = shapes.get(4);

        RenderComponent.OffsetPShape singleMuscleCheckBox = shapes.get(5);
        RenderComponent.OffsetPShape autoLeftCheckBox = shapes.get(6);
        RenderComponent.OffsetPShape autoRightCheckBox = shapes.get(7);
        
        RenderComponent.OffsetPShape jump3timeCheckbox = shapes.get(8);
        RenderComponent.OffsetPShape wait2secCheckbox = shapes.get(9);
        
        levelUpOverTimeCheckBox.translation.x = checkBoxXPosition + (gameOptions.getLevelUpOverTime() ? 0.0f : falseDisplacement);
        
        deafultControlCheckBox.translation.x = radioButtonXposition + (gameOptions.getControlPolicy() == ControlPolicy.NORMAL ? 0.0f : falseDisplacement);
        
        autoDirectCheckBox.translation.x = radioButtonXposition + (gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST ? 0.0f : falseDisplacement);
        leftCheckbox.translation.x = 75 + ((gameOptions.getDirectionAssistMode() == DirectionAssistMode.LEFT_ONLY && gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST) ? 0.0f : falseDisplacement);
        rightCheckbox.translation.x = 150 + ((gameOptions.getDirectionAssistMode() == DirectionAssistMode.RIGHT_ONLY && gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST) ? 0.0f : falseDisplacement);
        bothCheckbox.translation.x = 230 + ((gameOptions.getDirectionAssistMode() == DirectionAssistMode.BOTH && gameOptions.getControlPolicy() == ControlPolicy.DIRECTION_ASSIST) ? 0.0f : falseDisplacement);
        
        singleMuscleCheckBox.translation.x = radioButtonXposition + (gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE ? 0.0f : falseDisplacement);
        autoLeftCheckBox.translation.x = 75 + ((gameOptions.getSingleMuscleMode() == SingleMuscleMode.AUTO_LEFT && gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE) ? 0.0f : falseDisplacement);
        autoRightCheckBox.translation.x = 200 + ((gameOptions.getSingleMuscleMode() == SingleMuscleMode.AUTO_RIGHT && gameOptions.getControlPolicy() == ControlPolicy.SINGLE_MUSCLE) ? 0.0f : falseDisplacement);
        
        obstaclesCheckBox.translation.x = checkBoxXPosition + (gameOptions.getObstacles() ? 0.0f : falseDisplacement);
        terrainModsCheckBox.translation.x = checkBoxXPosition + (gameOptions.getPlatformMods() ? 0.0f : falseDisplacement);
        logRawDataCheckBox.translation.x = checkBoxXPosition + (gameOptions.isLogRawData() ? 0.0f : falseDisplacement);
        
        fittsLawCheckBox.translation.x = checkBoxXPosition + (gameOptions.isFittsLaw() ? 0.0f : falseDisplacement);
        inputPlatformsCheckBox.translation.x = 60 + (gameOptions.isInputPlatforms() ? 0.0f : falseDisplacement);
        logFittsCheckBox.translation.x = 60 + (gameOptions.isLogFitts() ? 0.0f : falseDisplacement);
        contraintsFittsCheckBox.translation.x = 60 + (gameOptions.isStillPlatforms() ? 0.0f : falseDisplacement);
        
        jump3timeCheckbox.translation.x = 315 + ((gameOptions.getBreakthroughMode() == BreakthroughMode.CO_CONTRACTION) ? 0.0f : falseDisplacement);
        wait2secCheckbox.translation.x = 315 + ((gameOptions.getBreakthroughMode() == BreakthroughMode.WAIT_2SEC) ? 0.0f : falseDisplacement);
      }
    }
  }
}

public class IOOptionsControllerComponent extends Component
{
  private String musicSliderTag;
  private float musicSliderLeftBoundary;
  private float musicSliderRightBoundary;
  private float musicSliderYPosition;
  
  private String soundEffectsSliderTag;
  private float soundEffectsSliderLeftBoundary;
  private float soundEffectsSliderRightBoundary;
  private float soundEffectsSliderYPosition;

  public IOOptionsControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
    musicSliderTag = xmlComponent.getString("musicSliderTag");
    musicSliderLeftBoundary = xmlComponent.getFloat("musicSliderLeftBoundary");
    musicSliderRightBoundary = xmlComponent.getFloat("musicSliderRightBoundary");
    musicSliderYPosition = xmlComponent.getFloat("musicSliderYPosition");
    
    soundEffectsSliderTag = xmlComponent.getString("soundEffectsSliderTag");
    soundEffectsSliderLeftBoundary = xmlComponent.getFloat("soundEffectsSliderLeftBoundary");
    soundEffectsSliderRightBoundary = xmlComponent.getFloat("soundEffectsSliderRightBoundary");
    soundEffectsSliderYPosition = xmlComponent.getFloat("soundEffectsSliderYPosition");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.IO_OPTIONS_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
      if (texts.size() > 1)
      {
        RenderComponent.Text musicSliderText = texts.get(0);
        RenderComponent.Text soundEffectsSliderText = texts.get(1);
        
        float musicVolume = options.getIOOptions().getMusicVolume();
        float soundEffectsVolume = options.getIOOptions().getSoundEffectsVolume();

        musicSliderText.string = Integer.toString((int)(musicVolume * 100.0f));
        musicSliderText.translation.x = (musicVolume * (musicSliderRightBoundary - musicSliderLeftBoundary)) + musicSliderLeftBoundary;
        musicSliderText.translation.y = musicSliderYPosition;
        
        soundEffectsSliderText.string = Integer.toString((int)(soundEffectsVolume * 100.0f));
        soundEffectsSliderText.translation.x = (soundEffectsVolume * (soundEffectsSliderRightBoundary - soundEffectsSliderLeftBoundary)) + soundEffectsSliderLeftBoundary;
        soundEffectsSliderText.translation.y = soundEffectsSliderYPosition;

        ArrayList<IGameObject> musicSliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(musicSliderTag);
        if (musicSliderList.size() > 0)
        {
          IGameObject musicSlider = musicSliderList.get(0);
          component = musicSlider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0f) * musicSliderText.translation.x);
          }
        }
        
        ArrayList<IGameObject> soundEffectsSliderList = gameStateController.getGameObjectManager().getGameObjectsByTag(soundEffectsSliderTag);
        if (soundEffectsSliderList.size() > 0)
        {
          IGameObject soundEffectsSlider = soundEffectsSliderList.get(0);
          component = soundEffectsSlider.getComponent(ComponentType.SLIDER);
          if (component != null)
          {
            SliderComponent sliderComponent = (SliderComponent)component;
            sliderComponent.setTabPosition((width / 500.0f) * soundEffectsSliderText.translation.x);
          }
        }
      }
    }
  }
}

public class AnimationControllerComponent extends Component
{
 
  public float[] right;
  public float[] left;
  public float[] still = {0,0,0};
  public boolean isRight;
  
  public AnimationControllerComponent(IGameObject _gameObject)
  {
    super(_gameObject);
     right = new float[3];
     left = new float[3];
     isRight = false;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
     right[0] = xmlComponent.getInt("rightStart");
     right[1] = xmlComponent.getInt("rightEnd");
     left[0] = xmlComponent.getInt("leftStart");
     left[1] = xmlComponent.getInt("leftEnd");
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.ANIMATION_CONTROLLER;
  }
  
  @Override public void update(int deltaTime)
  {  
  }
  
  public float[] getDirection()
  {
    IComponent componentRigid = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
    PlayerControllerComponent playComp = (PlayerControllerComponent)componentRigid;
    float vectorX = playComp.getLatestMoveVector().x;
    float magnitude = playComp.getLatestMoveVector().mag();
    //to normalize the frequency the max magnitude is 1.41212
    if(magnitude !=0)
    {
      magnitude = abs(1.5-magnitude);
    }
    
    if(vectorX > 0)
    {
      isRight = true;
      right[2] = magnitude;
      return right;
    }
    else if(vectorX < 0)
    {
     isRight = false;
     left[2]= magnitude;
     return left; 
    }
    else
    {
      if(isRight)
      {
        right[2] = (magnitude);
        return right;
      }
      else
      {
        left[2] = (magnitude);
        return left;
      } 
    }
  }
}

public class FittsStatsComponent extends Component
{ 
  private int levelCount;
  private long startTime;
  private long endTime;
  private int errors;
  private float gapPos;
  private float gapWidth;
  private float optimalPath;
  private float fittsDistance;
  private float distance;
  private float distanceTravelled;
  private int undershoots;
  private int overshoots;
  private int directionChanges;
  private boolean firstFall = true;
  public FittsStatsComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    levelCount = 0;
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.FITTS_STATS;
  }
  
  @Override public void update(int deltaTime)
  {

  }
  
  private int getCurrentLevel()
  {
    return levelCount;
  }
  
  private void startLogLevel(TableRow newRow, int levelC,int trialNum)
  {
    startTime = System.currentTimeMillis();
    
    IComponent componentPlayerComp = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
    PlayerControllerComponent playComp = (PlayerControllerComponent)componentPlayerComp;
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    PVector pos = new PVector();
    if(component != null)
    {
      RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
      pos = rigidBodyComponent.getPosition();
    }


    int index = (tableFittsStats.getRowCount()-1) % platformGapPosition.size();
    gapPos = platformGapPosition.get(index).x;
    gapWidth = platformGapPosition.get(index).y;
    
    if (pos.x <= gapPos + gapWidth && pos.x >= gapPos - gapWidth)
    {
      optimalPath = 0;
    }
    else if (gapPos > pos.x)
    {
      optimalPath = round(abs(pos.x - (gapPos - gapWidth)));
    }
    else
    {
      optimalPath = round(abs(pos.x - (gapPos + gapWidth)));
    }

    fittsDistance = round(abs(pos.x - gapPos));
    
    playComp.setLoggingValuesZero(gapPos, gapWidth, pos.x);
    String iD = options.getUserInformation().getUserID();
    levelCount = levelC;
    if(iD == null)
      iD ="-1";
    newRow.setLong("tod", System.currentTimeMillis());  
    newRow.setString("username", iD);
    newRow.setInt("block", trialNum);
    newRow.setInt("trial", levelCount);
    newRow.setString("condition", "Simple");
    newRow.setFloat("start_point_x", pos.x);
    newRow.setLong("start_time", startTime);
    newRow.setFloat("optimal_path", optimalPath);
    newRow.setFloat("fitts_distance", fittsDistance);
    newRow.setString("selection", "DWELL");
    newRow.setString("practice", Boolean.toString(isBonusPractice));
    if  (firstFall)
    {
      distance = abs(pos.x - gapPos);
      firstFall = false;
    }
    else
    {
      float prevGap = platformGapPosition.get((tableFittsStats.getRowCount()-2) % platformGapPosition.size()).x;
      distance = abs(prevGap - gapPos);
    }
    newRow.setFloat("amplitude", distance);
    fittsLawRecorded = true;
  }
  
  private void endLogLevel()
  {
    endTime = System.currentTimeMillis();
    if(options.getGameOptions().isFittsLaw())
    {
      Event updateScoreEvent = new Event(EventType.UPDATE_SCORE);
      int timeValue = (int)((10000-(endTime - startTime))*0.001);
      if(timeValue < 0)
        timeValue = 0;
      updateScoreEvent.addIntParameter("scoreValue", timeValue);
      eventManager.queueEvent(updateScoreEvent);
    }
          
      TableRow newRow = tableFittsStats.getRow(tableFittsStats.getRowCount() - 1);
      IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
      PVector pos = new PVector();
      if(component != null)
      {
        RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
        pos = rigidBodyComponent.getPosition();
      }
      IComponent componentRigid = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
      PlayerControllerComponent playComp = (PlayerControllerComponent)componentRigid;
      if (playComp.distanceTravelled < optimalPath) {
        distanceTravelled = optimalPath;
      }
      else {
        distanceTravelled = round(playComp.distanceTravelled);
      }
      playComp.distanceTravelled = 0;
      playComp.lastXPos = gapPos;
      directionChanges = playComp.getDirerctionChanges();
      overshoots =  playComp.getOverShoots();
      undershoots = playComp.getUnderShoots();
      errors = playComp.getErrors();
      newRow.setFloat("end_point_x", pos.x);
      newRow.setLong("end_time", endTime);
      newRow.setFloat("width", gapWidth*2);
      newRow.setFloat("distance_travelled", distanceTravelled);
      newRow.setInt("errors", errors);
      newRow.setInt("undershoots", undershoots);
      newRow.setInt("overshoots", overshoots);
      newRow.setInt("direction_changes", directionChanges);
      if (options.getGameOptions().getBreakthroughMode() == BreakthroughMode.WAIT_2SEC){
        newRow.setLong("elapsedTimeMillis",endTime - startTime - (options.getGameOptions().getDwellTime()*1000));
      }
      else { // TODO somehow subtract the time spent jumping as well ??
        newRow.setLong("elapsedTimeMillis",endTime - startTime);
      }
  }
}


public class LogRawDataComponent extends Component
{ 
  private String userID;
  private int platLevel;
  private String playingWith;
  private String inputType;
  private String mode;
  private boolean movingLeft;
  private boolean movingRight;
  private boolean isJumping;
  
  private long totalTime;
  private long nextLogTime;
  private EmgSamplingPolicy sampPolicy;
  private ControlPolicy contPolicy;
  
  public LogRawDataComponent(IGameObject _gameObject)
  {
    super(_gameObject);
    userID = options.getUserInformation().getUserID();
    if(userID == null)
      userID ="-1";  
    
    sampPolicy = options.getIOOptions().getEmgSamplingPolicy();
    if(sampPolicy == EmgSamplingPolicy.DIFFERENCE)
      inputType = "diff";
    else if(sampPolicy == EmgSamplingPolicy.MAX)
      inputType = "max";
    else
      inputType = "first-over";
      
    contPolicy = options.getGameOptions().getControlPolicy();
    if(ControlPolicy.SINGLE_MUSCLE == contPolicy)
    {
      mode = "Single Muscle - " + options.getGameOptions().getSingleMuscleMode();
    }
    else if(ControlPolicy.DIRECTION_ASSIST == contPolicy)
    {
      mode = "Direction Assist - " + options.getGameOptions().getDirectionAssistMode();
    }
    else
    {
      mode = "Normal"; 
    }
    
  }
  
  @Override public void destroy()
  {
  }
  
  @Override public void fromXML(XML xmlComponent)
  {
  }
  
  @Override public ComponentType getComponentType()
  {
    return ComponentType.LOG_RAW_DATA;
  }
  
  @Override public void update(int deltaTime)
  {
    totalTime += deltaTime;
    if((gameStateController.getCurrentState() instanceof GameState_InGame) && options.getGameOptions().isLogRawData() && (totalTime - nextLogTime) > 100)
    {
      nextLogTime = totalTime;
      TableRow newRow = tableRawData.addRow(); 
      logRawData(newRow);
    }
  }
  
  private void logRawData(TableRow newRow)
  {
    if(emgManager.isCalibrated())
      playingWith = "Myo Armband";
    else
      playingWith = "Keyboard";
      
    IComponent componentFittsStats = gameObject.getComponent(ComponentType.FITTS_STATS);
    FittsStatsComponent FittsStatComp = (FittsStatsComponent)componentFittsStats;
    platLevel = FittsStatComp.getCurrentLevel();
    IComponent componentPlayerComp = gameObject.getComponent(ComponentType.PLAYER_CONTROLLER);
    PlayerControllerComponent playComp = (PlayerControllerComponent)componentPlayerComp;
    HashMap<String, Float> input = playComp.getRawInput();
    IComponent component = gameObject.getComponent(ComponentType.RIGID_BODY);
    RigidBodyComponent rigidBodyComponent = (RigidBodyComponent)component;
    PVector vel = rigidBodyComponent.getLinearVelocity();
    if(vel.x<0)
    {
      movingLeft = true;
      movingRight= false;
    }
    else if(vel.x>0)
    {
      movingLeft = false;
      movingRight= true;
    }
    else
    {
      movingLeft = false;
      movingRight= false;
    }
    
    if(vel.y<0)
    {
      isJumping = true;
    }
    else
    {
      isJumping = false;
    }
    
    newRow.setLong("timestamp", System.currentTimeMillis());
    newRow.setString("user_id", userID);
    newRow.setString("playing_with", playingWith);
    newRow.setInt("level", platLevel);
    newRow.setFloat("sensor_left", input.get(LEFT_DIRECTION_LABEL));
    newRow.setFloat("sensor_right", input.get(RIGHT_DIRECTION_LABEL));
    newRow.setFloat("sensor_jump", input.get(JUMP_DIRECTION_LABEL));
    newRow.setString("input_type", inputType);
    newRow.setString("mode", mode);
    newRow.setString("moving_left", movingLeft ? "1" : "0");
    newRow.setString("moving_right", movingRight ? "1" : "0");
    newRow.setInt("moving_up", isJumping ? 1 : 0);
  }
}

public class ModalComponent extends Component
{
  private int modalHeight;
  private int modalWidth;

  private boolean mouseOver;

  public ModalComponent(GameObject _gameObject)
  {
    super(_gameObject);

    modalHeight = 0;
    modalWidth = 0;

    mouseOver = false;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    // Multiply the height and width by the scale values to make the button that size
    modalHeight = xmlComponent.getInt("height") * (int)gameObject.getScale().y;
    modalWidth = xmlComponent.getInt("width") * (int)gameObject.getScale().x;
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.MODAL;
  }

  @Override public void update(int deltaTime)
  {
    float widthScale = (width / 500.0f);
    float heightScale = (height / 500.0f);

    float xModal = gameObject.getTranslation().x * widthScale;
    float yModal = gameObject.getTranslation().y * heightScale;

    float actualModalWidth = modalWidth * widthScale;
    float actualModalHeight = modalHeight * heightScale;
    if (xModal - 0.5 * actualModalWidth <= mouseX && xModal + 0.5 * actualModalWidth >= mouseX && yModal - 0.5 * actualModalHeight <= mouseY && yModal + 0.5 * actualModalHeight >= mouseY)
    {
      mouseOver = true;
      Event modalEvent = new Event(EventType.MODAL_HOVER);
      modalEvent.addStringParameter("tag", gameObject.getTag());
      eventManager.queueEvent(modalEvent);
    }
    else
    {
      mouseOver = false;
      Event modalEvent = new Event(EventType.MODAL_OFF);
      modalEvent.addStringParameter("tag", gameObject.getTag());
      eventManager.queueEvent(modalEvent);
    }
  }
}

public class CalibrationDisplayComponent extends Component
{
  private PlayerControllerComponent pcc;
  private boolean showCalibrationDisplay;
  private boolean showGraphDisplay = false;
  private int left;
  private int right;
  

  public CalibrationDisplayComponent(IGameObject _gameObject)
  {
    super(_gameObject);

    showCalibrationDisplay = false;
    
    left = 0;
    right = 0;
    
    
  }

  @Override public void fromXML(XML xmlComponent)
  {

  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.CALIBRATION_DISPLAY;
  }

  @Override public void update(int deltaTime)
  {
    if (pcc == null && gameStateController.getGameObjectManager().getGameObjectsByTag("player").size() > 0)
    {
      IGameObject playerObj = gameStateController.getGameObjectManager().getGameObjectsByTag("player").get(0);
      pcc = (PlayerControllerComponent) playerObj.getComponent(ComponentType.PLAYER_CONTROLLER);
    }

    if (pcc != null)
    {
      IComponent component = gameObject.getComponent(ComponentType.RENDER);
      if (component != null)
      {
        RenderComponent renderComponent = (RenderComponent)component;
        RenderComponent.Text text = renderComponent.getTexts().get(0);
        //println(text.string);
        if (text != null && pcc.rawInput != null)
        {
          HashMap<String, Float> emgInput = (HashMap<String, Float>) rawReadings.clone();
          
          //the min of 150f only allows the bar to go up to 200% so it does not go outside rectangle  
          float rightRectVal = min((emgInput.get(RIGHT_DIRECTION_LABEL) * 75.0f),150.0f);
          int xPoint = floor(rightRectVal/4 + 425);
          renderComponent.getShapes().get(2).translation.x = ((500-xPoint)*(-1));
           
          //the min 0.5 makes it so the the bar does not go outside rectangle  
          renderComponent.getShapes().get(2).scale.x = min((emgInput.get(RIGHT_DIRECTION_LABEL)/4),0.5);
          
           //the min of 150f only allows the bar to go up to 200% so it does not go outside rectangle  
          float leftRectVal = min((emgInput.get(LEFT_DIRECTION_LABEL) * 75.0f),150.0f);
          xPoint = floor(leftRectVal/4 + 350);
          renderComponent.getShapes().get(3).translation.x = -75-(abs(-150-((500-xPoint)*(-1))));
          
          //the min 0.5 makes it so the the bar does not go outside rectangle  
          renderComponent.getShapes().get(3).scale.x = min((emgInput.get(LEFT_DIRECTION_LABEL)/4),0.5);
          
          
          left = (int)(emgInput.get(LEFT_DIRECTION_LABEL)*100);
          right = (int)(emgInput.get(RIGHT_DIRECTION_LABEL)*100);
          text.string = "Left: " + nf(left, 3) + "%, Right: " + nf(right, 3) + "%";
        }
      }
    }

    //handle toggle of calibration display (shows small label at bottom of game)
    for (IEvent event : eventManager.getEvents(EventType.TOGGLE_CALIBRATION_DISPLAY)) {
      if (showCalibrationDisplay) {
        hideCalibrationDisplay();
        showCalibrationDisplay = !showCalibrationDisplay;
      } else {
        showCalibrationDisplay();
        showCalibrationDisplay = !showCalibrationDisplay;
      }
    }
    
    
    //handle toggle of graph display (shows second window with graphs)
    for (IEvent event : eventManager.getEvents(EventType.TOGGLE_GRAPH_DISPLAY)) {

      if (showGraphDisplay) {
        hideGraphDisplay();
        showGraphDisplay = !showGraphDisplay;
      } else {
        showGraphDisplay();
        showGraphDisplay = !showGraphDisplay;
      }
    }    
  }
  
  public void hideGraphDisplay() {
    sa.getSurface().setVisible(false);
    sa.noLoop();
    sa.giveFocusToParentFrame();
  }

  public void showGraphDisplay() {
    Frame parentFrame = ((processing.awt.PSurfaceAWT.SmoothCanvas) getSurface().getNative()).getFrame();
    if (sa == null){
      String[] args = {"Sensor Graph", "--display=2", "--location=0,0"};
      sa = new SensorGraphApplet(parentFrame);
            
      PApplet.runSketch(args, sa);
      sa.getSurface().setLocation(0,0);
      sa.removeExitEvent();      
      
    }
    else
    {
      sa.getSurface().setVisible(true);
      sa.loop();
    }
        
  }

  public void hideCalibrationDisplay() {
    IComponent component = gameObject.getComponent(ComponentType.CALIBRATION_DISPLAY);
    component.getGameObject().setTranslation(new PVector(1000.0, 485.0));
  }

  public void showCalibrationDisplay() {
    IComponent component = gameObject.getComponent(ComponentType.CALIBRATION_DISPLAY);
    component.getGameObject().setTranslation(new PVector(485.0, 485.0));
  }
}

public class CounterComponent extends Component
{
  private String countUp;
  private String countDown;
  private int count;
  private ArrayList<Integer> idCounts;
  private int min;
  private int max;
  private boolean isTextValSet;

  public CounterComponent(GameObject _gameObject)
  {
    super(_gameObject);
    idCounts = new ArrayList<Integer>();
    isTextValSet = false;
  }

  @Override public void destroy()
  {
  }

  @Override public void fromXML(XML xmlComponent)
  {
    countUp = xmlComponent.getString("countup");
    countDown = xmlComponent.getString("countdown");
    min = xmlComponent.getInt("min");
    max = xmlComponent.getInt("max");

    // TODO: set this elsewhere
    if (gameObject.getTag().equals("counterDwellTime"))
    {
      idCounts.add(options.getGameOptions().getDwellTime());
    }
    else if (gameObject.getTag().equals("counterSensorLeft") || gameObject.getTag().equals("counterSensorRight"))
    {
      idCounts.add(0);
      leftSensor = 0;
      rightSensor = 0;
    }
  }

  @Override public ComponentType getComponentType()
  {
    return ComponentType.SINGLE_COUNTER;
  }

  @Override public void update(int deltaTime)
  {
    if (!isTextValSet)
    {
      isTextValSet = setTextVal();
    }
    handleEvents();
  }

  private void handleEvents()
  {
    for (IEvent event : eventManager.getEvents(EventType.BUTTON_CLICKED))
    {
      String tag = event.getRequiredStringParameter("tag");

      if(tag.contains(countUp))
      {
        adjustCounter(1);
      }
      else if(tag.contains(countDown))
      {
        adjustCounter(-1);
      }
    }
  }

  private void adjustCounter(int adjustment)
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);
    count = idCounts.get(0) + adjustment;
    if(count > max)
      count = min;
    else if(count < min)
      count = max;
    idCounts.set(0, count);
    options.getGameOptions().setDwellTime(count);

    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
      if (texts.size() > 0)
      {
         texts.get(0).string = Integer.toString(count);
      }
    }
  }

  private boolean setTextVal()
  {
    IComponent component = gameObject.getComponent(ComponentType.RENDER);

    if (component != null)
    {
      RenderComponent renderComponent = (RenderComponent)component;
      ArrayList<RenderComponent.Text> texts = renderComponent.getTexts();
      if (texts.size() > 0)
      {
        texts.get(0).string = Integer.toString(idCounts.get(0));
        return true;
      }
    }

    return false;
  }

  public int getCount()
  {
    return count;
  }
}

IComponent componentFactory(GameObject gameObject, XML xmlComponent)
{
  IComponent component = null;
  String componentName = xmlComponent.getName();
  
  if (componentName.equals("Render"))
  {
    component = new RenderComponent(gameObject);
  }
  else if (componentName.equals("RigidBody"))
  {
    component = new RigidBodyComponent(gameObject);
  }
  else if (componentName.equals("PlayerController"))
  {
    component = new PlayerControllerComponent(gameObject);
  }
  else if (componentName.equals("PlatformManagerController"))
  {
    component = new PlatformManagerControllerComponent(gameObject);
    pc = (PlatformManagerControllerComponent) component;
  }
  else if (componentName.equals("CoinEventHandler"))
  {
    component = new CoinEventHandlerComponent(gameObject);
  }
  else if (componentName.equals("ScoreTracker"))
  {
    component = new ScoreTrackerComponent(gameObject);
  }
  else if (componentName.equals("CalibrateWizard"))
  {
    component = new CalibrateWizardComponent(gameObject);
  }
  else if (componentName.equals("Countdown"))
  {
    component = new CountdownComponent(gameObject);
  }
  else if (componentName.equals("LevelDisplay"))
  {
    component = new LevelDisplayComponent(gameObject);
  }
  else if (componentName.equals("LevelParameters"))
  {
    component = new LevelParametersComponent(gameObject);
  }
  else if (componentName.equals("Button"))
  {
    component = new ButtonComponent(gameObject);
  }
  else if (componentName.equals("MusicPlayer"))
  {
    component = new MusicPlayerComponent(gameObject);
  }
  else if (componentName.equals("Slider"))
  {
    component = new SliderComponent(gameObject);
  }
  else if (componentName.equals("StatsCollector"))
  {
    component = new StatsCollectorComponent(gameObject);
  }
  else if (componentName.equals("PostGameController"))
  {
    component = new PostGameControllerComponent(gameObject);
  }
  else if (componentName.equals("GameOptionsController"))
  {
    component = new GameOptionsControllerComponent(gameObject);
  }
  else if (componentName.equals("IOOptionsController"))
  {
    component = new IOOptionsControllerComponent(gameObject);
  }
  else if (componentName.equals("AnimationController"))
  {
    component = new AnimationControllerComponent(gameObject);
  }
  else if(componentName.equals("CounterID"))
  {
    component = new CounterIDComponent(gameObject);
  }
  else if (componentName.equals("Modal"))
  {
    component = new ModalComponent(gameObject);
  }
  else if (componentName.equals("CalibrationDisplay"))
  {
    component = new CalibrationDisplayComponent(gameObject);
  }
  else if(componentName.equals("FittsStatsComponent"))
  {
   component = new FittsStatsComponent(gameObject);
   fsc = (FittsStatsComponent) component;
  }
  else if(componentName.equals("LogRawDataComponent"))
  {
   component = new LogRawDataComponent(gameObject); 
  }
  else if(componentName.equals("Counter"))
  {
    if (gameObject.getTag().equals(xmlComponent.getString("tag"))) {
      component = new CounterComponent(gameObject);
    }
  }
  else if(componentName.equals("BonusPlatformManager"))
  {
   component = new BonusPlatformManager(gameObject);
   bpc = (BonusPlatformManager) component;
  }
  else if(componentName.equals("BonusScoreComponent"))
  {
    component = new BonusScoreComponent(gameObject);
    bsc = (BonusScoreComponent) component;
  }
  
  if (component != null)
  {
    component.fromXML(xmlComponent);
  }
  
  return component;
}
