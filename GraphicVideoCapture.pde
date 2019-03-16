import java.lang.*;
import processing.video.*;
import cvimage.*;
import org.opencv.core.*;

Capture cam;
CVImage img11, img12, img21, img22;
int dimension, thresholdSquareSize, xThreshold, yThreshold;
int red, green, blue;
boolean mainScreen = true;

void setup() {
  size(1280, 720);

  cam = new Capture(this, width / 2, height / 2);
  cam.start();
  dimension = cam.width * cam.height;
  thresholdSquareSize = 150;
  xThreshold = yThreshold = red = green = blue = 0;

  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);

  img11 = new CVImage(cam.width, cam.height);
  img12 = new CVImage(cam.width, cam.height);
  img21 = new CVImage(cam.width, cam.height);
  img22 = new CVImage(cam.width, cam.height);
}

void draw() {
  if (!mainScreen) {
    if (cam.available()) {
      background(0);
      cam.read();

      img11.copy(cam, 0, 0, cam.width, cam.height, 
        0, 0, img11.width, img11.height);
      img11.copyTo();

      img21.copy(cam, 0, 0, cam.width, cam.height, 
        0, 0, img21.width, img21.height);
      img21.copyTo();

      img22.copy(cam, 0, 0, cam.width, cam.height, 
        0, 0, img21.width, img21.height);
      img22.copyTo();

      Mat gris = img11.getGrey();

      cpMat2CVImage(gris, img12);

      applyThreshold(img21);
      applyColor(img22);

      image(img11, 0, 0, width / 2, height / 2);
      image(img12, width / 2, 0, width / 2, height / 2);
      image(img21, 0, height / 2, width / 2, height / 2);
      image(img22, width / 2, height / 2, width / 2, height / 2);

      gris.release();
    }
  } else
    mainScreen();

  if (keyPressed) {
    if (key == 'd' || key == 'D')
      if (xThreshold + thresholdSquareSize < 640) xThreshold += 5;      
    if (key == 'a' || key == 'A')
      if (xThreshold > 0) xThreshold -= 5;     
    if (key == 's' || key == 'S')
      if (yThreshold + thresholdSquareSize < 360) yThreshold += 5;      
    if (key == 'w' || key == 'W')
      if (yThreshold > 0) yThreshold -= 5;     

    if (key == 'j' || key == 'J')
      if (red > 0) red -= 2;
    if (key == 'u' || key == 'U')
      if (red < 255) red += 2;      
    if (key == 'k' || key == 'K')
      if (green > 0) green -= 2;
    if (key == 'i' || key == 'I')
      if (green < 255) green += 2;      
    if (key == 'l' || key == 'L')
      if (blue > 0) blue -= 2;
    if (key == 'o' || key == 'O')
      if (blue < 255) blue += 2;
  }
}

void applyColor(CVImage img) {
  img.loadPixels();
  for (int i = 0; i < dimension; i++) {
    float sum = red(img.pixels[i]) + green(img.pixels[i]) + blue(img.pixels[i]);

    if (sum > 255 && sum < 255 * 2) 
      img.pixels[i]=color(red, green, blue);
    cam.updatePixels();
  }
}

void applyThreshold(CVImage img) {
  img.loadPixels();
  for (int i = yThreshold; i < yThreshold + thresholdSquareSize; i++) {
    for (int j = xThreshold; j < xThreshold + thresholdSquareSize; j++) {
      int pixel_1Dimension = j + (i * cam.width);

      float sum = red(img.pixels[pixel_1Dimension]) +
        green(img.pixels[pixel_1Dimension]) +
        blue(img.pixels[pixel_1Dimension]);

      if (sum < 255 * 1.5) 
        img.pixels[pixel_1Dimension]=color(0, 0, 0);
      else
        img.pixels[pixel_1Dimension]=color(255, 255, 255);
    }
  }
  img.updatePixels();
}

void cpMat2CVImage(Mat in_mat, CVImage out_img) {    
  byte[] data8 = new byte[cam.width * cam.height];
  out_img.loadPixels();
  in_mat.get(0, 0, data8);

  for (int x = 0; x < cam.width; x++) {
    for (int y = 0; y < cam.height; y++) {
      int loc = x + y * cam.width;
      int val = data8[loc] & 0xFF;
      out_img.pixels[loc] = color(val);
    }
  }
  out_img.updatePixels();
}

void keyReleased() {
  if (key == 'H' || key == 'h')
    mainScreen = !mainScreen;
}

void mainScreen() {
  background(0);
  textSize(40);
  text("Graphic Video Capture", width / 2 - 220, 100);
  textSize(30);
  text("Top left image is the original", width / 2 - 500, 200);
  text("Top right image is black and white", width / 2 - 500, 250);
  text("Bottom left image has a filter", width / 2 - 500, 300);
  text("To move it press w/s (up/down) a/d (left/right) ", width / 2 - 400, 350);
  text("Bottom right image has color a filter", width / 2 - 500, 400);
  text("Change color pressing u/j (red), i/k (green) and o/l (blue)", width / 2 - 400, 450);
  text("Press H to return to main screen", width / 2 - 500, 500);
  textSize(20);
  text("Press H to continue", width / 2 - 100, height / 2 + 300);
}
