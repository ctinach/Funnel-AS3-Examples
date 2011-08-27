﻿package {	import flash.display.Sprite;	import flash.events.Event;	import flash.geom.Vector3D;	import funnel.*;	import funnel.i2c.ADXL345;			/*	 * Test class for ADXL 3 axis accelHandlererometer	 * Using Sparkfun breakout board: http://www.sparkfun.com/products/9836	 * and Arduino FIO: http://www.sparkfun.com/products/9712	 * 	 * Connection:	 * 	 * ADXL345	->	Arduino FIO (or other 3.3v Arduino variant)	 * gnd 		->	gnd		 * vcc		->	3.3v	 * cs		->	3.3v	 * int1	(NC)	 * int2 (NC)	 * sdo		->	gnd	 * sda		->	A4	 * scl		->	A5	 *	 */	 	public class ADXL345Example extends Sprite {					private var arduino:Arduino;		private var accel:ADXL345;				// create a variable to reference the Accelerometer Handler		private var accelHandler:AccelerometerHandler;				private var box:Box;				public function ADXL345Example() {					var config:Configuration = Arduino.FIRMATA;			arduino = new Arduino(config);				arduino.addEventListener(FunnelEvent.READY, onReady);				}												private function onReady(evt:FunnelEvent):void {			arduino.removeEventListener(FunnelEvent.READY, onReady);						accel = new ADXL345(arduino, false, ADXL345.DEVICE_ID, ADXL345.RANGE_4G);			accel.addEventListener(Event.CHANGE, onAcclUpdate);						// calibrate according to your sensor			accel.setAxisOffset(-2, -2, 4);						accelHandler = new AccelerometerHandler();						// create an instance of the box object in the library			box = new Box();			box.x = stage.stageWidth/2;			box.y = stage.stageHeight/2;			this.addChild(box);						// start continuous reading of the accelHandlereromter			// devault interval is 33ms			accel.startReading();			}						private function onAcclUpdate(evt:Event):void {						// get the accelHandlereromter values in units of gravity			var xVal:Number = evt.currentTarget.x;			var yVal:Number = evt.currentTarget.y;			var zVal:Number = evt.currentTarget.z;						//trace("x = " + xVal.toFixed(3) + "\ty = " + yVal.toFixed(3) + "\tz = " + zVal.toFixed(3));							// update the accelHandlererometer handler			accelHandler.update(xVal, yVal, zVal);						// create a Vector3D object to hold the 3 values			var orientation:Vector3D = accelHandler.orientation;						// use pitch and roll to rotate box on screen			// orientation.y = pitch			// orientation.x = roll			// due to difference between sensor and screen orientations, need to swap z with x and x with y			box.rotationZ = orientation.x * -1;			box.rotationX = orientation.y - 90;	// offset by -90 degrees because the box was drawn vertically						}	}}