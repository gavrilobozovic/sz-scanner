import processing.video.*;
import com.cage.zxing4p3.*;
import de.bezier.data.sql.mapper.*;
import de.bezier.data.sql.*;
import ddf.minim.*;

Capture           video;

ZXING4P           zxing4p;
int tw;

String            decodedText="";
String            latestDecodedText = "";
MySQL             mainSQL;
String            dbHost;
String            dbUser;
String            dbPass;
String            dbName;
boolean           debug = true;    // if set to true, will use test database

Minim             minim;
AudioPlayer       sound;


void setup() {
  size(640, 480, P2D);
  
  if(debug == true) {
    dbHost    = "89.216.104.119:3306";
    dbUser    = "sz_prod";
    dbPass    = "sUsh!-Z3n@_1";
    dbName    = "sushizen";
  } else {
    dbHost    = "80.74.128.84:3306";
    dbUser    = "zen_printer";
    dbPass    = "Wj4o7*p5";
    dbName    = "zen_shop_db";
  } 
  
  mainSQL    = new MySQL(this, dbHost, dbName, dbUser, dbPass);
  println("MAIN connection ok");
  
  // CREATE CAPTURE
  video = new Capture(this, 640, 480);
  // START CAPTURING
  video.start();  
  println("video started");
  
  zxing4p = new ZXING4P();  // initiate the qr code scanner
  println("qr code scanner started");
  
  minim = new Minim(this);
  sound = minim.loadFile("beep.mp3");
  
  frameRate(60);
}

void draw()
{ 
  background(0);

  // DISPLAY VIDEO CAPTURE
  set(0, 0, video);

  // DISPLAY LATEST DECODED TEXT
  if (!latestDecodedText.equals(""))
  {
    // LAYOUT
    textAlign(CENTER);
    textSize(30);
    String displayText = "dernière commande préparée : " + latestDecodedText;
    tw = int(textWidth(displayText));
    fill(0, 150);
    rect((width>>1)-(tw>>1)-5, 15, tw+10, 36);
    fill(255);
    text(displayText, width>>1, 43);
  }

  try
  {  
    decodedText = zxing4p.decodeImage(false, video);
  }
  catch (Exception e)
  {  
    println("Zxing4processing exception: "+e);
    decodedText = "";
  }

  if (!decodedText.equals(""))
  { // FOUND A QRCODE!
    if (latestDecodedText.equals("") || (!latestDecodedText.equals(decodedText))) {
      println("Ticket scanned: "+decodedText);
      sound.rewind();
      sound.play();
      mainSQL.connect();
      mainSQL.execute("UPDATE orders SET status_3=1 WHERE id=" + decodedText);
      mainSQL.close();
      latestDecodedText = decodedText;
    }
  }
} // draw()

void captureEvent(Capture c) {
  c.read();
}