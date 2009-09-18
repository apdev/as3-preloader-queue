﻿/**
 * Copyright (c) 2009 apdevblog.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.apdevblog.load 
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	/**
	 * Manages the loading queue.
	 * 
	 * <p>You don't have direct access to the queue (except the log for testing purposes). Why that? Read the <a href="http://code.google.com/p/apdev-preloader-queue/wiki/TypicalScenario" target="_blank">typical scenario</a>.</p>
	 * 
	 * @playerversion Flash 9
 	 * @langversion 3.0
	 *
	 * @package    com.apdevblog.load.PreLoader
	 * @author     Aron Woost / aron[at]apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * 	 
	 * @see com.apdevblog.load.PreLoader PreLoader
	 */
	public class PreloadProxy 
	{
		private static var __instance:PreloadProxy = null;
		//
		private var __preloadArray:Array;
		private var __preloading:Boolean;
		
		/**
		 * @private
		 */
		public static function getInstance():PreloadProxy 
		{
			if(__instance == null) __instance = new PreloadProxy(new SingletonBlocker());
			return __instance;
		}
		
		/**
		 * @private
		 */
		public static function init():void
		{
			getInstance();
		}
		
		/**
		 * @private
		 */
		public static function add(pldr:PreLoader):void
		{
			getInstance()._add(pldr);
		}
		
		/**
		 * @private
		 */		
		public static function addNext(pldr:PreLoader):void
		{
			getInstance()._addNext(pldr);
		}
		
		/**
		 * @private
		 */		
		public static function addImmediately(pldr:PreLoader):void
		{
			getInstance()._addImmediately(pldr);
		}
		
		/**
		 * @private
		 */		
		public static function addAfter(pldr:PreLoader, afterUrlReq:URLRequest):void
		{
			getInstance()._addAfter(pldr, afterUrlReq);
		}			
		
		/**
		 * @private
		 */		
		public static function closeLoad(pldr:PreLoader):void
		{
			getInstance()._closeLoad(pldr);
		}
		
		/**
		 * @private
		 */		
		public static function currentLoader():PreLoader
		{
			return getInstance()._currentLoader();
		}

		/**
		 * Traces the queue. Only for testing purposes.
		 */		
		public static function logQueue():void
		{
			getInstance()._logQueue();
		}
		
		/**
		 * @private
		 */		
		public function PreloadProxy(s:SingletonBlocker)
		{
			if(s == null) throw new Error("Error: Instantiation failed: Use VEventDispatcher.getInstance() instead of new.");
			if(__instance != null) throw new Error("Error: Instantiation failed: Only one VEventDispatcher object allowed.");
			_init();
		}		
		
		/**
		 * private functions
		 */
		private function _init():void
		{
			__preloadArray = new Array();
		}
	
		private function _add(pldr:PreLoader):void
		{
			__preloadArray.push(pldr);
			
			_startPreload();		
		}
		
		private function _addNext(pldr:PreLoader):void
		{
			if(__preloadArray.length == 0)
			{
				__preloadArray.push(pldr);
			}
			else
			{
				__preloadArray.splice(1, 0, pldr);
			}
			
			_startPreload();					
		}
		
		private function _addImmediately(pldr:PreLoader):void
		{
			if(__preloading)
			{
				var oldPldr:PreLoader = __preloadArray[0] as PreLoader;
				try 
				{ 
					oldPldr.loader.close();
				}
				catch(e:*)
				{
				
				}
				
				_removeLoadListener(oldPldr);
				__preloadArray.splice(0, 0, pldr);
			else
			{
				__preloadArray.push(pldr);
			}
			
			__preloading = false;
			_startPreload();
		}
		
		private function _addAfter(pldr:PreLoader, afterUrlReq:URLRequest):void
		{
			if(__preloadArray.length == 0)
			{
				__preloadArray.push(pldr);
			}
			else
			{
				var inserted:Boolean = false;
				
				for (var i : Number = 0; i < __preloadArray.length; i++) 
				{
					var checkPldr:PreLoader = __preloadArray[i] as PreLoader;
					
					if(checkPldr.urlRequest.url == afterUrlReq.url)
					{
						__preloadArray.splice(i+1, 0, pldr);
					}
					
					inserted = true;
				}
				
				if(inserted == false) __preloadArray.splice(1, 0, pldr);
			}
			
			_startPreload();
		}
		
		private function _closeLoad(pldr:PreLoader):void
		{
			if(__preloadArray.length == 0) return;
			
			var checkPldr:PreLoader = __preloadArray[0] as PreLoader;
			
			if(checkPldr == pldr)
			{
				try { checkPldr.loader.close(); } catch (e:*) {}
				
				_removeLoadListener(checkPldr);
				__preloadArray.splice(0, 1);
				__preloading = false;
				_startPreload();
			}
			else
			{
				for (var i : Number = 0; i < __preloadArray.length; i++) 
				{
					checkPldr = __preloadArray[i] as PreLoader;
					
					if(checkPldr == pldr)
					{
						__preloadArray.splice(i, 1);
					}
				}
			}
			
		}
		
		private function _currentLoader():PreLoader
		{
			if(__preloadArray == null || __preloadArray.length == 0)
			{
				return null;
			}
			return __preloadArray[0] as PreLoader;
		}

		private function _preload():void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			
			_addLoadListener(pldr);
			
			pldr.loader.load(pldr.urlRequest);
			
			__preloading = true;
		}
		
		private function _startPreload():void
		{
			if(__preloading || __preloadArray.length == 0)
			{
				return;
			}
			
			_preload();
		}
		
		private function _nextPreload():void
		{
			__preloadArray.splice(0, 1);
			
			if(__preloadArray.length == 0)
			{
				__preloading = false;
			}
			else
			{
				_preload();
			}
		}
		
		private function _logQueue():void
		{
			var s:String = "";
			for (var i : Number = 0; i < __preloadArray.length; i++) 
			{
				var pldr:PreLoader = __preloadArray[i] as PreLoader;
				s += pldr.urlRequest.url+" - ";
			}
			trace(s);
		}
		
		private function _addLoadListener(pldr:PreLoader):void
		{
			pldr.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoadComplete, false, 0, true);
			pldr.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, _onHttpStatus, false, 0, true);
			pldr.loader.contentLoaderInfo.addEventListener(Event.INIT, _onLoadInit, false, 0, true);
			pldr.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onLoadError, false, 0, true);
			pldr.loader.contentLoaderInfo.addEventListener(Event.OPEN, _onLoadOpen, false, 0, true);
			pldr.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress, false, 0, true);
			pldr.loader.contentLoaderInfo.addEventListener(Event.UNLOAD, _onUnload, false, 0, true);
		}
		
		private function _removeLoadListener(pldr:PreLoader):void
		{
			pldr.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onLoadComplete);
			pldr.loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, _onHttpStatus);
			pldr.loader.contentLoaderInfo.removeEventListener(Event.INIT, _onLoadInit);
			pldr.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onLoadError);
			pldr.loader.contentLoaderInfo.removeEventListener(Event.OPEN, _onLoadOpen);
			pldr.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			pldr.loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, _onUnload);			
		}
		
		private function _onLoadOpen(e:Event):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onLoadOpen(e);
		}		
		private function _onLoadComplete(e:Event):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onLoadComplete(e);
			
			_nextPreload();
		}
		private function _onLoadInit(e:Event):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onLoadInit(e);
		}		
		private function _onLoadProgress(e:ProgressEvent):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onLoadProgress(e);
		}		
		private function _onLoadError(e:IOErrorEvent):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onLoadError(e);
			
			_nextPreload();				
		}
		private function _onHttpStatus(e:HTTPStatusEvent):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onHttpStatus(e);	
		}
		private function _onUnload(e:Event):void
		{
			var pldr:PreLoader = __preloadArray[0] as PreLoader;
			pldr.onUnload(e);
		}
	}
}

internal class SingletonBlocker {}