class Tracer{
  int lifeSpan;
  PVector position = new PVector(0,0);
  PVector velocity = new PVector(2.5,5);
  PVector desired = new PVector(0,0);
  PVector acceleration = new PVector(0,0);
  float maxSpeed = 20;
  float maxForce = 20;

  void setup(){
  position = new PVector(0, 0);
  
  }
  
  void draw(){
   fill(255,0,0, 200);
    ellipse(position.x, position.y, 10, 10);
  }
  
  
  public void setPosition(PVector value ){
    position = value;
    draw();
  }
  
  
    private void seek(PVector value ){
    desired = PVector.sub(value, position);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer = PVector.sub(desired, velocity);
    position = value;
    draw();
  }
  
  
    public void applyForce(PVector value ){
    seek(value);
    // position.add(velocity);
    //draw();
  }
   
  
}
