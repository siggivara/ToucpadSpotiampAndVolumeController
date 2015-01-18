#include "PS2Mouse.h"

#define MDATA 5 // touchpad ps/2 data pin
#define MCLK 6 // touchpad ps/2 clock pin
#define SENSITIVITY 5 // amount of movement needed to get a reaction
#define SWIPE_SENSITIVITY 100
#define HORIZONTAL_SENSITIVITY 15

#define NOGEST 0
#define DOUBLETAP 3
#define SWIPE2 8
#define SWIPE3 -2
#define SWIPE5 4
#define SWIPE6 2
#define SWIPE7 7
#define SWIPE9 -2
#define SWIPE10 5
#define SWIPE12 1
#define CLOCKWISE 10
#define COUNTER_CLOCKWISE 11
#define START_SEQ 0xff


#define NO_DIR  0
#define CLOCKW_DIR 1
#define COUNTERCW_DIR 2


PS2Mouse mouse_one(MCLK, MDATA, REMOTE);

int prevStatByte, prevX, prevY, lastGesture;
int value, prev_val_clockw, prev_val_counter, clockw_eightcount, counter_eightcount, dir;

void setup() 
{ 
  
  clockw_eightcount = 0;
  dir = NO_DIR;
  
   prevStatByte = prevX = prevY = lastGesture = -1;
   Serial.begin(115200);   
   mouse_one.initialize();  
   mouse_one.set_scaling_1_1();
   
   pinMode(13, OUTPUT);
}

void loop() {
  int data[2];
  
  mouse_one.report(data);
  /*
  if (dir == NO_DIR || dir == CLOCKW_DIR)
  {  
   // Check clockwise
    if(checkClockwise((byte)data[0])) 
    {
      Serial.println("Clockwise detected!!");
      //Serial.write(START_SEQ);
      // Serial.write(0x01);
    } 
  } 
  
  if (dir == NO_DIR || dir == COUNTERCW_DIR)
  {
    if(checkCounterclockwise((byte)data[0])) 
    {
      Serial.println("Counterclockwise detected!!");
      //Serial.write(START_SEQ);
      //Serial.write(0x02);
    }  
  }
  
  */
  // Check for doubletap
  if(data[0] == 9)
    if(prevStatByte == 9)
    {
       //Serial.println("Got Doubletap!!");
       Serial.write(START_SEQ);
       Serial.write(DOUBLETAP);
       lastGesture = DOUBLETAP;
    } 
  
  // Check for 2 o'clock
  if (lastGesture != SWIPE2 && lastGesture != SWIPE12)
    if (data[1] > HORIZONTAL_SENSITIVITY)    // X-val is positive and greater than the SENSITIVITY threshold
      if (data[2] > HORIZONTAL_SENSITIVITY)  // Y-val is positive greater than SENSITIVITY
      {
        //Serial.println("Got 2 o'clock swipe");
        Serial.write(START_SEQ);
        Serial.write(SWIPE2);
        lastGesture = SWIPE2; 
      }
  
 
  // Check for 5 o'clock
  if (lastGesture != SWIPE5 && dir == NO_DIR && lastGesture != SWIPE6)
    if (data[1] > HORIZONTAL_SENSITIVITY)    // X-val is positive and grater than the SENSITIVITY threshold
      if (data[2] < -HORIZONTAL_SENSITIVITY)  // Y-val is negative and lesser than negative SENSITIVITY
      {
        //Serial.println("Got 5 o'clock swipe");
        Serial.write(START_SEQ);
        Serial.write(SWIPE5);
        lastGesture = SWIPE5;
      }
  
  // Check for 7 o'clock
  if (lastGesture != SWIPE7 && lastGesture != SWIPE6)
    if (data[1] < -HORIZONTAL_SENSITIVITY)    // X-val is negative and lesser than the negative SENSITIVITY threshold
      if (data[2] < -HORIZONTAL_SENSITIVITY)  // Y-val is negative and lesser than negative SENSITIVITY
      {
        //Serial.println("Got 7 o'clock swipe");
        Serial.write(START_SEQ);
        Serial.write(SWIPE7);
        lastGesture = SWIPE7; 
      }
  
  // Check for 10 o'clock
  if (lastGesture != SWIPE10 && lastGesture != SWIPE12)
    if (data[1] < -HORIZONTAL_SENSITIVITY)  // X-val is less than the negative SENSITIVITY threshold
      if (data[2] > HORIZONTAL_SENSITIVITY) // Y-val is positive larger than SENSITIVITY
      {
        //Serial.println("Got 10 o'clock swipe");
        Serial.write(START_SEQ);
        Serial.write(SWIPE10);
        lastGesture = SWIPE10;
      }
      
  // Check for 6 o'clock swipe
  if ((data[0] == 0x28 || data[0] == 0x08) && abs(data[1]) < HORIZONTAL_SENSITIVITY && data[2] < 0)
  {
    //Serial.println("Got 6 o'clock swipe");
    Serial.write(START_SEQ);
    Serial.write(SWIPE6);
    lastGesture = SWIPE6;
  }
  
  // Check for 12 o'clock swipe
  if ((data[0] == 0x28 || data[0] == 0x18 || data[0] == 0x08) && abs(data[1]) < HORIZONTAL_SENSITIVITY && data[2] > 0)
  {
    if (lastGesture == SWIPE12)
    {
      //Serial.println("Got 12 o'clock swipe");
      Serial.write(START_SEQ);
      Serial.write(SWIPE12);
    }
    lastGesture = SWIPE12;
  }
    
    
  // Nothins happening
 if (data[0] == 8 && data[1] == 0 && data[2] == 0)
  {
     lastGesture = NOGEST; 
  }

  /*
  if(data[0] != 8 || data[1] != 0 || data[2] != 0)
  {
    Serial.print(data[0], HEX);
    Serial.print(": ");
    Serial.print(data[1], DEC);
    Serial.print(":");
    Serial.println(data[2], DEC);  
  } 
  */
  prevStatByte = data[0];
  prevX = data[1];
  prevY = data[2];
  
  delay(175);
}


/* My functions */

/* Checks if a clockwise gesture was made */
boolean checkClockwise(byte state) 
{
     // Check for clockwise turn
  if(state == 0x08) 
  {
    //Serial.println(state, HEX);
    clockw_eightcount++;
    if(clockw_eightcount > 8)
    {
      prev_val_clockw = state;     // Start over
      clockw_eightcount = 0;
      dir = NO_DIR;
    }
  }
  
  if((prev_val_clockw == 0x08 || prev_val_clockw == 0x28) && state == 0x28)
  {
    prev_val_clockw = 0x28;
    dir = CLOCKW_DIR;
  }
  
  if((prev_val_clockw == 0x28 || prev_val_clockw == 0x38) && state == 0x38)
  {
    prev_val_clockw = 0x38;
    dir = CLOCKW_DIR;
  }
    
  if((prev_val_clockw == 0x38 || prev_val_clockw == 0x18) && state == 0x18)
  {
    prev_val_clockw = 0x08;          // Circle complete
    dir = NO_DIR;
    return true;
  }
  return false;
}

/* Checks if a counterclockwise gesture was made */
boolean checkCounterclockwise(byte state) 
{
  // Check for counterclockwise turn
  if(state == 0x08) 
  {
    //Serial.println(state, HEX);
    counter_eightcount++;
    if(counter_eightcount > 8)
    {
      prev_val_counter = state;     // Start over
      counter_eightcount = 0;
      dir = NO_DIR;
    }
  }
  if((prev_val_counter == 0x08 || prev_val_counter == 0x18) && state == 0x18) 
  {
   // Serial.println(state, HEX);
    prev_val_counter = 0x18;
    dir = COUNTERCW_DIR;
  }
  if((prev_val_counter == 0x18 || prev_val_counter == 0x38) && state == 0x38)
  {
    //Serial.println(state, HEX);
    prev_val_counter = 0x38;
    dir = COUNTERCW_DIR;
  }
  if((prev_val_counter == 0x38 || prev_val_counter == 0x28) && state == 0x28)
  {
    //Serial.println(state, HEX);
    prev_val_counter = 0x08;          // Circle complete
    dir = NO_DIR;
    return true;
  }
  return false;
}


