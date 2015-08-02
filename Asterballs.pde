import java.util.Iterator;
import java.util.Random;
ArrayList <ParticleSystem> systems;
PImage image;
Random generator = new Random();
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
int hsIdx;
String highscores[];
Boolean enteringName = false;
String name = "";

void setup(){
  size(800, 600, P2D);
  blendMode(ADD);
  systems = new ArrayList<ParticleSystem>();
  m = new Mover();
  angleVect = new PVector(1, 0);
  alevel = new AsteroidsLevel(level, m);
  titleFont = createFont("Hyperspace Bold", 100);
  bullets = new ArrayList<Bullet>();
  highscores = loadStrings("highscores.txt");
  image = loadImage("ball.png");
  image.resize(6,6);
  println(highscores[0]);
}

void draw(){
  //System.out.println(mouseX + ", " + mouseY);
  if(!started){
    background(0);
    titleScreen();
  }
  else if(collided){
    if(enteringName){
      showName();
    }
    else if(hsIdx >= 0){
      showHighscores();
    }
  }  
  else{
     background(0);
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
      PVector loc = m.location.get();
      PVector ang = angleVect.get();
      ang.mult(10);
      loc.sub(ang);
      ParticleSystem newest = systems.get(systems.size()-1);
      newest.location = loc;
      newest.addParticle();
      newest.addParticle();
    }
    for(int i = 0; i<systems.size(); i++){
      ParticleSystem cur = systems.get(i);
      cur.run();
      if(cur.deadParticles == cur.numParticles){
        systems.remove(i);
      }
    }
    alevel.updateLevel(m);
    showState(score);
    if(collided){
      gameOver();
    }
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
  if(enteringName){
    if(key == BACKSPACE){
      if(name.length() > 0){
        name = name.substring(0, name.length()-1);
      }
    }
    else if(key == ENTER || key == RETURN){
      saveScore();
      enteringName = false;  
    }
    else if(name.length()<2) name = name + key;
  }
 
  else if(keyCode == LEFT){
    buttonDirection = -1;
  }
  else if(keyCode == RIGHT){
    buttonDirection = 1;
  }
  else if(key == 'z'){
    m.applyForce(angleVect);
    m.boostActivated = true;
    systems.add(new ParticleSystem(m.location.get()));
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

void showHighscores(){
  background(0);
  textAlign(CENTER);
  textSize(80);
  text("LEADERBOARD", width/2, 100);
  textSize(65);
  textAlign(LEFT);
  for(int i = 0; i < 5; i++){
    text(highscores[i], 100, 200+90*i);
  }
}

void showName(){
      noStroke();
      fill(0);
      rect(width/2-300, height/2 + 160, 800, 500);
      textAlign(LEFT);
      fill(255);
      textSize(60);
      text(name, width/2-50, height/2 + 250);
      rect(width/2-55, height/2 +254, 37, 4);
      rect(width/2-16, height/2 +254, 37, 4);
}

void titleScreen(){
  textFont(titleFont);
  textAlign(CENTER);
  text("Asterballs", width/2, height/2-height/4);
  textSize(40);
  text("Press ENTER to play", width/2, height/2+height/4);
}

void showState(int score){
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
  hsIdx = checkHighscore();
  if(hsIdx < 0){
    text("Press 'r' to restart", width/2, height/2+120);
  }
  else{
    textSize(20);
    text("You have reached the leaderboard! \nEnter your initials to save highscore", width/2, height/2+120);
    enteringName = true;
  }
}

void saveScore(){
  String temp = highscores[hsIdx];
  for(int i = hsIdx+1; i<5; i++){
    highscores[i] = temp;
    if(i+1 < 5){
      temp = highscores[i+1];
    }
  }
  if(score < 10){
    highscores[hsIdx] = name + " " + "0" + Integer.toString(score);
  }
  else{
    highscores[hsIdx] = name + " " + Integer.toString(score);
  }
  saveStrings("C:/Users/suraj/Dropbox/Processing Projects/Asterballs/data/highscores.txt", highscores);
}

int checkHighscore(){
  for(int i = 0; i < 5; i++){
    int curVal = Integer.parseInt(highscores[i].substring(3));
    System.out.println(curVal);
    if(score > curVal){
      return i;
    }
    else if(score == curVal && i < 4){
      return i+1;
    }
  }
  return -1;
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
       if(al.roids[i] == null){
         continue;
       }
       PVector distance = PVector.sub(location, al.roids[i].location);
       if(distance.mag() <= al.roids[i].diameter/2){
         if(al.roids[i].size == 0){
           al.roids[i].shot = true;
           al.roids[i].explode();
           al.remainingAlive--;
         }
         else{
           al.roids[i].explode();
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
    diameter = 40+20*size;
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
    diameter = 40;
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
  
  void explode(){
    if(size == 1){
      fill(255);
    }
    else{
      fill(156, 42, 0);
    }
    ellipse(location.x, location.y, diameter, diameter);

  
    
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

public class ParticleSystem{
  ArrayList<Particle> particles;
  PVector location;
  int numParticles = 50;
  int deadParticles = 0;
  
  ParticleSystem(PVector loc){
    particles = new ArrayList<Particle>(0);
    location = loc;
  }
  
  void run(){
    Iterator<Particle> iter = particles.iterator();
    while(iter.hasNext()){
      Particle prt = iter.next();
      prt.update();
      prt.display();
      if(prt.isDead()){
        iter.remove();
        deadParticles++;
      }
    }
  }
  
  void addParticle(){
    particles.add(new Particle(new PVector(location.x, location.y)));
  }
  
  void applyForce(PVector force){
    for(Particle p : particles){
      p.applyForce(force);
    }
  }
}

public class Particle{
  PVector location;
  PVector acceleration;
  PVector velocity;
  //PVector angVelocity;
  int decay;
  float mass;
  
  Particle(PVector loc){
    location = loc;
    acceleration = new PVector(0, 0);
    velocity = new PVector(1, 0);
    velocity.rotate(m.angle - PI);
    velocity.x = velocity.x + (float)generator.nextGaussian()*0.3;
    velocity.y = velocity.y + (float) generator.nextGaussian()*0.3;
    //angVelocity = new PVector(0, 0);
    decay = 100;
    mass = 0.5;
  }
  
  void applyForce(PVector f){
    PVector force = f.get();
    force.div(mass);
    acceleration.add(force);
  }
  
  void update(){
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    decay -= 1;
  }
  
  void display(){
    //fill(0, decay);
    //ellipse(location.x,location.y, 7, 7);
    imageMode(CENTER);
    tint(146, 42, 0, map(decay, 0, 100, 0, 255));
    image(image, location.x, location.y);
  }
  
  boolean isDead(){
    return decay < 0;
  }
}
