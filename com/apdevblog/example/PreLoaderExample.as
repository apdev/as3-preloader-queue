/**
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
package com.apdevblog.example 
{
	import com.apdevblog.load.PreLoader;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * Example implementation.
	 *
	 * @package    com.apdevblog.example.PreLoaderExample
	 * @author     Aron Woost / aron[at]apdevblog.com
	 * @copyright  2009 apdevblog.com
	 * @version    SVN: $Id$
	 */
	[SWF(backgroundColor="#AAAAAAA", frameRate="30", width="550", height="400")]
	public class PreLoaderExample extends MovieClip 
	{
		private var folder:String = "http://apdevblog.com/examples/apdev_preloader/img/";
		private var images:Array = ["img01.png", "img02.png", "img03.png", "img04.png"];
		private var _txt1 : TextField;
		private var _txt2 : TextField;

		public function PreLoaderExample()
		{
			for (var i : int = 0; i < images.length; i++) 
			{
				var img:PreLoader = new PreLoader();
				img.addEventListener(ProgressEvent.PROGRESS, _onProgress, false, 0, true);
				img.addEventListener(Event.COMPLETE, _onImgLoaded, false, 0, true);
				img.load(folder + images[i]);
				img.x = i * 50;
				addChild(img);
			}
			
			_txt1 = new TextField();
			_txt1.autoSize = TextFieldAutoSize.LEFT;
			_txt1.x = 5;
			_txt1.y = 320;
			addChild(_txt1);
			
			_txt2 = new TextField();
			_txt2.autoSize = TextFieldAutoSize.LEFT;
			_txt2.x = 5;
			_txt2.y = 340;
			addChild(_txt2);
		}

		private function _onProgress(event : ProgressEvent) : void
		{
			_txt1.text = (event.bytesLoaded / event.bytesTotal).toString();
		}

		private function _onImgLoaded(event : Event) : void
		{
			var preLoader:PreLoader = event.target as PreLoader;
			_txt2.text = preLoader.url + " loaded";
		}
	}
}
