
#include <ESP8266WiFi.h>

#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"



// Enter WiFi Details
#define WLAN_SSID       ""
#define WLAN_PASS       ""


// Enter Adafruit Cloud details
#define AIO_SERVER      "io.adafruit.com"
#define AIO_SERVERPORT  1883                   
#define AIO_USERNAME    ""
#define AIO_KEY         ""

WiFiClient client;

Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);




Adafruit_MQTT_Publish photocell = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/power");

Adafruit_MQTT_Publish changestate = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/onoff");

Adafruit_MQTT_Subscribe onoffbutton = Adafruit_MQTT_Subscribe(&mqtt, AIO_USERNAME "/feeds/onoff");

Adafruit_MQTT_Subscribe threshold = Adafruit_MQTT_Subscribe(&mqtt, AIO_USERNAME "/feeds/threshold");

   

  


void MQTT_connect();
int ext;
 int value ;
 String v;
 float consumption;
float voltage;
float current;
float  power;
float total_power;
float prev_power = 0;

float avg =0;
int count =0;
const float vpp = 0.00488758553274689;
int relayInput = D2;

void setup() {
  Serial.begin(9600);
 // s.begin(9600);
  delay(10);
  
  pinMode(relayInput , OUTPUT);

  Serial.println(F("Adafruit MQTT demo"));

  // Connect to WiFi access point.
  Serial.println(); Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WLAN_SSID);

  WiFi.begin(WLAN_SSID, WLAN_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  Serial.println("WiFi connected");
  Serial.println("IP address: "); Serial.println(WiFi.localIP());

  // Setup MQTT subscription for onoff feed.
  mqtt.subscribe(&onoffbutton);
  mqtt.subscribe(&threshold);
}



void loop() {


  MQTT_connect();


  Adafruit_MQTT_Subscribe *subscription;
  while ((subscription = mqtt.readSubscription(5000))) {
    if (subscription == &onoffbutton )  {
      Serial.print(F("Got: "));
      Serial.println((char *)onoffbutton.lastread);}
      
      if(subscription == &threshold){
        Serial.print(F("Got: :: thrsh ::  "));
        v= (char *)threshold.lastread;
      Serial.println(v.toInt());}
 Serial.println("check if else of on off");
 String sr = (char *)onoffbutton.lastread;
 Serial.println(sr);

       if(sr == "on")
  {
     digitalWrite(relayInput ,HIGH);
     Serial.println("I am On");
  }
  else
     digitalWrite(relayInput ,LOW);
      //Serial.println("I am Off");
      
    
    }


     

 
  value= analogRead(A0);
  Serial.println(value);

  value = value - 543;
  

 

  
 voltage = value * vpp *(-1) ;
 
 current = voltage/0.066;
 
  power = current * 5*0.00277778 ;


 if(count <=60)
 {
  avg = avg +power;
  count = count +1;
  
 }
 
 avg = avg /60;
 total_power = total_power + avg;
 
  Serial.println(total_power,5);
  

  Serial.println(count);
if(count == 5){
                            power = 0;
                                 avg =0;

            
           if ( abs(prev_power) <= v.toInt())// threshold or user in built off;
                              {
                                Serial.println("in the relay on loop");
                                prev_power = prev_power+ total_power;
                                
                              
                              }
            if(abs(total_power) >= v.toInt() || ((char *)onoffbutton.lastread)=="off")
            {
              Serial.println("in the relay off loop");
               prev_power = prev_power+ total_power;
                          
                    total_power = 0;
                                
                    digitalWrite(relayInput, LOW);
                    changestate.publish("off");
                    

                    ext = 0;
                               
              
            }
                                 
                                
                                 
                        
        
          if (! photocell.publish(prev_power))
          {
                  Serial.println(F("Failed"));
                            
          }
          else
                  {
                    Serial.println(F("OK!"));
                  }
          
          count =0;
}

 
  
 delay(10);
 


}


void MQTT_connect() {
  int8_t ret;

  // Stop if already connected.
  if (mqtt.connected()) {
    return;
  }

  Serial.print("Connecting to MQTT... ");

  uint8_t retries = 3;
   while ((ret = mqtt.connect()) != 0) { // connect will return 0 for connected
       Serial.println(mqtt.connectErrorString(ret));
       Serial.println("Retrying MQTT connection in 5 seconds...");
       mqtt.disconnect();
       delay(5000);  
       retries--;
       if (retries == 0) {
         // basically die and wait for WDT to reset me
         while (1);
       }
  }
  Serial.println("MQTT Connected!");
}
