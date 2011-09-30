﻿package {		import flash.display.Sprite;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.events.TimerEvent;	import flash.utils.Timer;		import funnel.*;	import funnel.Configuration;	import funnel.FunnelEvent;	import funnel.i2c.*;			public class IMUExample extends Sprite {				//private static const GRAVITY:Number = 9.812865328;	// /m/s/s		private static const GRAVITY:Number = 1;	// /m/s/s		private static const UPDATE_INTERVAL:Number = 100;		// 100ms		private static const FILTER_RATE:Number = .1;				private var fio:Fio;		private var accl:ADXL345;		private var gyro:GyroITG3200;				private var gyroTick:Timer;		private var acclTick:Timer;		private var imuFilterTick:Timer;				private var imuFilter:IMUFilter;				private var gotGyro:Boolean = false;		private var gotAccl:Boolean = false;				private var box:Box;				public function IMUExample() {						var config:Configuration = Fio.FIRMATA;			fio = new Fio([1], config);							initGyro();						initAccl();						imuFilter = new IMUFilter(FILTER_RATE, 0.3);						// set update interval to 100 ms			gyroTick = new Timer(UPDATE_INTERVAL, 0);			acclTick = new Timer(UPDATE_INTERVAL, 0);			imuFilterTick = new Timer(UPDATE_INTERVAL, 0);						gyroTick.addEventListener(TimerEvent.TIMER, onGyroTick);			acclTick.addEventListener(TimerEvent.TIMER, onAcclTick);			imuFilterTick.addEventListener(TimerEvent.TIMER, onImuFilterTick);								gyroTick.start();			acclTick.start();			imuFilterTick.start();						box = new Box();			this.addChild(box);			box.x = stage.stageWidth/2;			box.y = stage.stageHeight/2;						stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);					}				private function onGyroTick(evt:TimerEvent):void {			gyro.update();		}				private function onAcclTick(evt:TimerEvent):void {			accl.update();		}				private function onImuFilterTick(evt:TimerEvent):void {			var pitch:Number;			var roll:Number;			var yaw:Number;						if (gotGyro && gotAccl) {				// swap accl x and y values due to sensor orientation				imuFilter.updateFilter(toRadians(gyro.x), toRadians(gyro.y), toRadians(gyro.z), (accl.y * GRAVITY), (accl.x * GRAVITY), (accl.z * GRAVITY));				imuFilter.computeEuler();								pitch =  toDegrees(imuFilter.getPitch());				roll =  toDegrees(imuFilter.getRoll());				yaw =  toDegrees(imuFilter.getYaw());								//trace("pitch = " + pitch);				//trace("roll = " + roll);				//trace("yaw = " + yaw);								// use pitch, roll, and yaw to rotate box on screen				// rotate the onscreen object on the z axis using the accelerometer y axis				box.rotationX = (roll - 90) * -1;				// need to swap Y and Z do to difference between screen and sensor orientations				box.rotationY = yaw * -1;	// offset by -90 degrees because the box was drawn vertically				box.rotationZ = pitch * -1;			}		}						private function initGyro():void {			gyro = new GyroITG3200(fio.ioModule(1), false);						// manual calibration			gyro.setOffsets(-.75, 3.3, -5.5);						gyro.addEventListener(Event.CHANGE, onGyroUpdate);		}				private function initAccl():void {			accl = new ADXL345(fio.ioModule(1), false, ADXL345.DEVICE_ID, ADXL345.RANGE_4G);			accl.addEventListener(Event.CHANGE, onAcclUpdate);						accl.setAxisOffset(-2, -2, 4);		}				private function onAcclUpdate(evt:Event):void {			var xVal:Number = evt.currentTarget.x.toFixed(3);			var yVal:Number = evt.currentTarget.y.toFixed(3);			var zVal:Number = evt.currentTarget.z.toFixed(3);						trace("x = " + xVal + "\ty = " + yVal + "\tz = " + zVal);						gotAccl = true;		}				private function onGyroUpdate(evt:Event):void {						var xVal:Number = evt.currentTarget.x;			var yVal:Number = evt.currentTarget.y;			var zVal:Number = evt.currentTarget.z;						xVal = Math.floor(xVal);			yVal = Math.floor(yVal);			zVal = Math.floor(zVal);						trace("x = " + xVal + "\ty = " + yVal + "\tz = " + zVal);						gotGyro = true;		}				private function toRadians(decimalVal:Number):Number {			return Math.floor(decimalVal) * Math.PI/180;		}				private function toDegrees(radianVal:Number):Number {			return radianVal * (180/Math.PI);		}				private function onKeyPress(e:KeyboardEvent):void {			//trace(e.keyCode);			switch (e.keyCode) {				case 82:	// 'r'					imuFilter.reset();					break;			}		}						}}