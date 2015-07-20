Mover m;
PFont titleFont;
PVector angleVect;
AsteroidsLevel alevel;
int level = 0;
Boolean collided = false;
int score = 0;
int levelChangeFrame;
int buttonDirection = 0; //set to -1 if left arrow key and 1 if right arrow key
Boolean started = false;
ArrayList<Bullet> bullets;


void setup(){
  size(800, 600);
  m = new Mover();
  angleVect = new PVector(1, 0);
  alevel = new AsteroidsLevel(level, m);
  titleFont = createFont("Hyperspace Bold", 100);
  bullets = new ArrayList<Bullet>();
}

void draw(){
  background(0);
  if(!started){
    titleScreen();
  }
  else{
    if(frameCount <= levelChangeFrame + 100){
      textSize(100);
      fill(255,0,0,100);
      textAlign(CENTER);
      text("LEVEL " + Integer.toString(level+1), width/2, height/2);
    }
    if(alevel.remainingAlive == 0){
      level++;
      alevel = new AsteroidsLevel(level, m);
      levelChangeFrame = frameCount;
    }
    if(buttonDirection != 0){
      m.angle += radians(5*buttonDirection);
      angleVect.rotate(buttonDirection*radians(5));
    }
    for(int i = 0; i<bullets.size(); i++){
      if(!bullets.get(i).update()){
        bullets.remove(i);
        i--;
        continue;
      }
      bullets.get(i).checkEdges();
      if(bullets.get(i).checkCollisions(alevel, m)){
        bullets.remove(i);
        i--;
        score++;
        continue;
      }
      bullets.get(i).display();
    }
    m.update();
    m.checkEdges();
    m.display();
    if(m.boostActivated){
      m.drawFlames();
    }
    alevel.updateLevel(m);
    showScore(score);
    if(collided){
      gameOver();
    }
    System.out.println(bullets.size());
  }
}

void keyReleased(){
  if(key == CODED){
    buttonDirection = 0;
  }
  else if(key == 'z'){
    m.boostActivated = false;
  }
  else if(key == ' '){
    Bullet b = new Bullet(m.angle - PI/2, m.location);
    bullets.add(b);
  }
}

void keyPressed(){
  float leastDistance = 1000;
  int idx = -1;
  if(keyCode == LEFT){
    buttonDirection = -1;
  }
  else if(keyCode == RIGHT){
    buttonDirection = 1;
  }
  else if(key == 'z'){
    m.applyForce(angleVect);
    m.boostActivated = true;
  }
  else if(key == 'r'){
    m.reset();
    alevel = new AsteroidsLevel(0, m);
    collided = false;
    score = 0;
  }
  else if(keyCode == ENTER){
    if(!started){
      started = true;
    }
  }
}
  

void titleScreen(){
  textFont(titleFont);
  textAlign(CENTER);
  text("Asterballs", width/2, height/2-height/4);
  textSize(40);
  text("Press ENTER to play", width/2, height/2+height/4);
}

void showScore(int score){
  textSize(16);
  fill(255);
  textAlign(LEFT);
  text(Integer.toString(score), 5, 20);
  text("Level: " + Integer.toString(level+1), width - 80, 20);
}

void gameOver(){
  background(0);
  textSize(100);
  fill(255);
  textAlign(CENTER);
  text("GAME OVER", width/2, height/2);
  textSize(40);
  fill(200, 0, 0);
  text("Score: " + Integer.toString(score),width/2, height/2 + 70);
  fill(200);
  text("Press 'r' to restart", width/2, height/2+120);
}


class Bullet{
  PVector velocity;
  PVector location;
  int decayCount;
  int decayPoint;
   
   public Bullet(float _angle, PVector _location) {
     velocity = new PVector(0,1);
     velocity.rotate(_angle);
     velocity.setMag(8);
     location = _location.get();
     decayCount = 0;
     decayPoint = 50;
   }
   
   void checkEdges(){
     if(location.x > width){
       location.x = 0;
     }
     else if(location.x < 0){
       location.x = width;
     }
     if(location.y > height){
       location.y = 0;
     }
     else if(location.y < 0){
       location.y = height;
     }
   }
   
   boolean checkCollisions(AsteroidsLevel al, Mover m){
     for(int i = 0; i<al.numAsteroids; i++){
       if(al.roids[i] == null || cos(m.angle) > 0 && al.roids[i].location.x < m.location.x || cos(m.angle) < 0 && al.roids[i].location.x > m.location.x){
         continue;
       }
       PVector distance = PVector.sub(location, al.roids[i].location);
       if(distance.mag() < al.roids[i].diameter/2){
         if(al.roids[i].size == 0){
           al.roids[i].shot = true;
           al.remainingAlive--;
         }
         else{
           al.roids[i].shrink();
           al.roids[i].velocity.setMag(4);
           al.roids[i+1] = new Asteroid(0, m);
           al.roids[i+1].location = al.roids[i].location.get();
         }
         return true;
       }
     }
     return false;
   }
   
   boolean update(){ // returns true if sucessfully updated, false if the bullet needs to be removed
     location.add(velocity);
     decayCount++;
     if(decayCount > decayPoint){
       return false;
     }
     else return true;
   }
   
   void display(){
     pushMatrix();
     fill(255);
     noStroke();
     translate(location.x, location.y);
     rotate(velocity.heading() - PI/2);
     rect(0,-2,4,8);
     popMatrix();
   }
}
   
           
       
   

class AsteroidsLevel{
  int level;
  int remainingAlive;
  int numAsteroids;
  Asteroid[] roids;
  
  AsteroidsLevel(int _level, Mover m){
    level = _level;
    numAsteroids = (5 + 5*level)*2;
    remainingAlive = numAsteroids;
    roids = new Asteroid[numAsteroids];
    for(int i = 0; i<numAsteroids; i+=2){
      roids[i] = new Asteroid(1, m);
    }
  }
  
  void updateLevel(Mover m){
    for(int i = 0; i<numAsteroids; i++){
      if(roids[i] != null){
        roids[i].update();
        roids[i].checkEdges();
        roids[i].display();
        if(!roids[i].shot && abs(roids[i].location.x-m.location.x)<= 40){ //don't need to check all asteroids
          if(roids[i].colliding(m.location)){
            collided = true;
            break;
          }
        }
      }
    }
  }
}

class Asteroid{
  PVector location;
  PVector velocity;
  int size;
  int diameter;
  Boolean shot;
  
  Asteroid(int _size, Mover m){
    size = _size;
    if(int(random(2))==0){
      location = new PVector(random(0,m.location.x-30), random(0, 600)); // asteroid spawns to the left of Mover
    }
    else{
      location = new PVector(random(m.location.x+50, 800), random(0, 600));
    }
    if(size == 0){
      velocity = new PVector(random(-1, 1), random(-1, 1));
      velocity.setMag(4);
    }
    else if(size == 1){
      velocity = new PVector(random(-1, 1), random(-1, 1));
      velocity.setMag(2);
    }
    shot = false;
    diameter = 20+20*size;
  }
  
  Boolean colliding(PVector mlocation){
    float distance = (location.x - mlocation.x)*(location.x - mlocation.x)+(location.y - mlocation.y)*(location.y - mlocation.y);
    if(distance <= ((diameter/2)+10)*((diameter/2)+10)){
      return true;
    }
    else return false;
  }
  
  void shrink(){
    size = 0;
    diameter = 20;
  }
    
  void update(){
    location.add(velocity);
  }
  
  void checkEdges() {
    if (location.x > width) {
      location.x = 0;
    } else if (location.x < 0) {
      location.x = width;
    }

    if (location.y > height) {
      location.y = 0;
    }
    else if(location.y < 0){
      location.y = height;
    }
  }
  
  void display(){
    if(!shot){
      stroke(255);
      fill(0);
      pushMatrix();
      translate(location.x, location.y);
      ellipse(0,0, diameter, diameter);
      popMatrix();
    }
  }
  
  Boolean checkHit(Mover m){
    PVector d = angleVect.get();
    d.setMag(1); // 
    PVector f = PVector.sub(m.location, location);
    float r = (20+20*size)/2; //radius of circle
    // find discriminant of equation P=E+x*d (where E is the location of the ship)
    float a = d.dot(d);
    float b = 2*f.dot(d);
    float c = f.dot(f)-r*r;
    float discriminant = b*b - 4*a*c;
    //System.out.println(discriminant);
    if(discriminant >= -40){
      //shot = true;
      return true;
    }
    else {
      return false;
    }
  }
}
    

class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  float angVel;
  float angAcc;
  float angle;
  Boolean boostActivated;
  
  Mover() {
    mass = 1;
    location = new PVector(width/2,height/2);
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    angVel = 0;
    angAcc = 0;
    angle = 0;
    boostActivated = false;
  }
  
  void shoot(){
    pushMatrix();
    translate(location.x,location.y);
    line(0,0,angleVect.x * 800, angleVect.y * 800);
    popMatrix();
  }
  
  void drawFlames(){
    //noStroke();
    pushMatrix();
    translate(location.x, location.y);
    rotate(angle);
    fill(226,88,34);
    triangle(-12, -7, -12, 7, -24, 0);
    fill(255,255,51);
    triangle(-12, -4, -12, 4, -20, 0);
    popMatrix();
  }
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
    //acceleration.limit(0.5);
  }
  
  void reset(){
    location.x = width/2;
    location.y = height/2;
    velocity.mult(0);
    acceleration.mult(0);
  }
  
  void update() {
    velocity.add(acceleration);
    velocity.limit(5);
    location.add(velocity);
    //angAcc = acceleration.x;
    //angVel += angAcc;
    //angVel = constrain(angVel, -.1, .1);
    //angle += angVel;
    acceleration.mult(0);
  }

  void display() {
    //rectMode(CENTER);
    stroke(0);
    fill(175);
    pushMatrix();
    translate(location.x, location.y);
    rotate(angle);
    triangle(10,0 ,-10, -7.5, -10, 7.5);
    popMatrix();
  }
  
  void checkEdges() {
    if (location.x > width) {
      location.x = 0;
    } else if (location.x < 0) {
      location.x = width;
    }

    if (location.y > height) {
      location.y = 0;
    }
    else if(location.y < 0){
      location.y = height;
    }
  }
}
