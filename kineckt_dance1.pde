/*
This code imports everything from SimpleOpenNI library and declares 
a variable of the type SimpleOpenNI named context.
*/
import SimpleOpenNI.*; 
 
SimpleOpenNI  context; 
PImage img;
//...add more declarations here...
PFont _font;
// The font must be located in the sketch's 
// "data" directory to load successfully
float bodyPos;
PVector projLHand;
PVector projRHand;

//-- the hand tracers

Tracer leftTracer = new Tracer();
Tracer rightTracer = new Tracer();

// The vehicle tracer
Vehicle _vehicle1;
int swarm1Size = 30;

Vehicle[] vehicleArray1 = new Vehicle[swarm1Size];

 
/* 
Sets the size of application window and creates a new SimpleOpenNI context, 
that can be used to communicate with the Kinect device.
*/
void setup(){
  //set size of the application window
  size(640, 480); 
 
  //initialize context variable
  context = new SimpleOpenNI(this);
 
  //asks OpenNI to initialize and start receiving depth sensor's data
  context.enableDepth(); 
 
  //asks OpenNI to initialize and start receiving User data
  context.enableUser(); 
 
  //enable mirroring - flips the sensor's data horizontally
  context.setMirror(true); 
 
  //... add more variable initialization code here...
 
  img=createImage(640,480,RGB);
  img.loadPixels();
  //-- now the tracers
  _vehicle1 = new Vehicle(0,0);
       createSwarm();

}
 
/*
Clears the screen, gets new data from Kinect and draw a depthmap to the 
screen.
*/
void draw(){
  //clears the screen with the black color, this is usually a good idea 
  //to avoid color artefacts from previous draw iterations
  background(255);

  //asks kinect to send new data
  context.update();
 
  //retrieves depth image
  PImage depthImage=context.depthImage();
  depthImage.loadPixels();
 
  //get user pixels - array of the same size as depthImage.pixels, that gives information about the users in the depth image:
  // if upix[i]=0, there is no user at that pixel position
  // if upix[i] > 0, upix[i] indicates which userid is at that position
  int[] upix=context.userMap();
 
  //colorize users
  for(int i=0; i < upix.length; i++){
    if(upix[i] > 0){
      //there is a user on that position
      //NOTE: if you need to distinguish between users, check the value of the upix[i]
      img.pixels[i]=color(0,0,255);
    }else{
      //add depth data to the image
     img.pixels[i]=depthImage.pixels[i];
    }
  }
  img.updatePixels();
 
  //draws the depth map data as an image to the screen 
  //at position 0(left),0(top) corner
  // --------------- 
  image(img,0,0);
 
  //draw significant points of users
 
  //get array of IDs of all users present 
  int[] users=context.getUsers();
 
  ellipseMode(CENTER);
 
  //iterate through users
  for(int i=0; i < users.length; i++){
    int uid=users[i];
    
    //draw center of mass of the user (simple mean across position of all user pixels that corresponds to the given user)
    PVector realCoM=new PVector();
    
    //get the CoM in realworld (3D) coordinates
    context.getCoM(uid,realCoM);
    PVector projCoM=new PVector();
    
    //convert realworld coordinates to projective (those that we can use to draw to our canvas)
    context.convertRealWorldToProjective(realCoM, projCoM);
    fill(255,0,0);
    
        _font = loadFont("ApexSansBookT-48.vlw");
        textFont(_font, 32);
        text("Body", projCoM.x,projCoM.y);
        
        
    ellipse(projCoM.x,projCoM.y,6,6);
    //check if user has a skeleton
    if(context.isTrackingSkeleton(uid)){
      //draw head
      PVector realHead=new PVector();
      
      //get realworld coordinates of the given joint of the user (in this case Head -> SimpleOpenNI.SKEL_HEAD)
      context.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_HEAD,realHead);
      PVector projHead=new PVector();
      context.convertRealWorldToProjective(realHead, projHead);
      fill(0,255,0);
      ellipse(projHead.x,projHead.y,10,10);
        _font = loadFont("ApexSansBookT-48.vlw");
        textFont(_font, 32);
        text("Head", projHead.x,projHead.y);
        
        updateVehicle(_vehicle1, projHead);
        updateSwarm(projHead);

 
      //draw left hand
      PVector realLHand=new PVector();
      context.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_LEFT_HAND,realLHand);
      projLHand=new PVector();
      context.convertRealWorldToProjective(realLHand, projLHand);
      fill(255,255,0);
      ellipse(projLHand.x,projLHand.y,30,30);
      
      //draw right hand
      PVector realRHand=new PVector();
      context.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_RIGHT_HAND,realRHand);
      projRHand=new PVector();
      context.convertRealWorldToProjective(realRHand, projRHand);
      fill(0,255,0);
      ellipse(projRHand.x,projRHand.y,30,30);

       setTracers();
    }
  }
 
}

void setTracers(){
  leftTracer.applyForce(projLHand);
}

void updateVehicle(Vehicle vehicle, PVector target){
  vehicle.seek(target);
  vehicle.update();
  vehicle.display();
}

void updateSwarm(PVector target){
  for(int i=0;i<vehicleArray1.length; i++){
    updateVehicle(vehicleArray1[i], target);
  }
}

//creates a swarm of vehicles

void createSwarm(){
  for(int i=0; i<swarm1Size; i++){
      vehicleArray1[i] = new Vehicle(random(100), random(300));
  }
}


 
//is called everytime a new user appears
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  //asks OpenNI to start tracking a skeleton data for this user 
  //NOTE: you cannot request more than 2 skeletons at the same time due to the perfomance limitation
  //      so some user logic is necessary (e.g. only the closest user will have a skeleton)
  curContext.startTrackingSkeleton(userId);
}
 
//is called everytime a user disappears
void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void addType(){
  
}



