import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean overLogo = false; //check where mouse is
boolean locked = false; //if the logo is currently locked
float xOffset = 0;
float yOffset = 0; //offsets of logo

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(0);
  //text(mouseX, width/2, height/2);
  //text(mouseY, width/2, height/2 + 20);
  if (userDone == false){
    fill(0,255,50);
    noStroke();
    rect(width/2, 100, inchToPix(1f), inchToPix(1f));
    fill(0);
    text("submit", width/2, 100);
  }

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center of the logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  if(checkForSuccess()) {
    fill(0, 255, 0);
  } else {
    fill(60, 60, 192, 192);
  }
  
  rect(0, 0, logoZ, logoZ);
  popMatrix();
  
  // Test if the cursor is over the box 
  if (mouseX > logoX-logoZ/2 && mouseX < logoX+logoZ/2 && 
      mouseY > logoY-logoZ/2 && mouseY < logoY+logoZ/2) {
         //text("true", width/2, height/2 + 40);
    overLogo = true;
    cursor(HAND);
    if(!locked) { 
      stroke(255); 
    } 
  } else {
    cursor(ARROW);
    stroke(153);
    overLogo = false;
  }
  
  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  scaffoldControlLogic(); //you are going to want to replace this!
} // end draw

void decreaseSize() {
  logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
}

void increaseSize() {
  logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  noFill();
  stroke(255);
  
  
  // rotate counter-clockwise
  float posXCCW = logoX - (logoZ / 3 + 15);
  float posYCCW = logoY - (logoZ / 3 + 15);
  circle(posXCCW, posYCCW, 20);
  text("<", posXCCW, posYCCW + 6);
  if (mousePressed && dist(posXCCW,posYCCW, mouseX, mouseY)<inchToPix(.2f))
    logoRotation--;

  // rotate clockwise
  float posXCW = logoX + (logoZ / 3 + 15);
  float posYCW = logoY - (logoZ / 3 + 15);
  circle(posXCW, posYCW, 20);
  text(">", posXCW, posYCW + 6);
  if (mousePressed && dist(posXCW,posYCW, mouseX, mouseY)<inchToPix(.2f))
    logoRotation++;

  // decrease Z
  float posXMinus = logoX - (logoZ / 3 + 15);
  float posYMinus = logoY + (logoZ / 3 + 15);
  circle(posXMinus, posYMinus, 20);
  text("-", posXMinus, posYMinus + 6);
  if (mousePressed && dist(posXMinus,posYMinus, mouseX, mouseY)<inchToPix(.2f)){
    decreaseSize();
    mouseX = (int)posXMinus;
    mouseY = (int)posYMinus;
  }

  // increase Z
  float posXPlus = logoX + (logoZ / 3 + 15);
  float posYPlus = logoY + (logoZ / 3 + 15);
  //translate(logoX, logoY);
  //rotate(radians(logoRotation));
  circle(posXPlus, posYPlus, 20);
  text("+", posXPlus, posYPlus + 6);
  if (mousePressed && dist(posXPlus, posYPlus, mouseX, mouseY)<inchToPix(.2f)){
    text("true", 0, 0);
    increaseSize();
    mouseX = (int)posXPlus;
    mouseY = (int)posYPlus;
  }
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if(overLogo) { 
    locked = true; 
    fill(255, 255, 255);
  } else {
    locked = false;
  }
  xOffset = mouseX-logoX; 
  yOffset = mouseY-logoY; 
}

void mouseDragged() {
  if(locked) {
    logoX = mouseX-xOffset; 
    logoY = mouseY-yOffset; 
  }
}

void mouseReleased()
{
  locked = false;
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (dist(width/2, 100, mouseX, mouseY)<inchToPix(0.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
