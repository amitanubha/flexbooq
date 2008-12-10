/*
Copyright 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
package qs.containers
{
	import fcat.events.BookEvent;

	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import mx.core.UIComponent;
	import mx.core.UIComponentCachePolicy;

	import qs.controls.LayoutAnimator;
	import qs.controls.LayoutTarget;

	[Style(name="paddingLeft", type="Number", inherit="no")]
	[Style(name="paddingTop", type="Number", inherit="no")]
	[Style(name="paddingRight", type="Number", inherit="no")]
	[Style(name="paddingBottom", type="Number", inherit="no")]
	[Style(name="zoomLimit", type="String", inherit="no")]

	[Event(name="pageZoomComplete",type="fcat.events.BookEvent")]

	[DefaultProperty("children")]
	public class Landscape extends UIComponent
	{
		// all children are placed inside the pane.  We can then adjust the pane's transform to
		// get the correct pan and zoom.
		private var _contentPane:ContentPane;
		// the mask is applied to the pane to make sure it gets clipped correctly.
		private var _mask:Shape;
		// our trusty layout animator, which allows us to get animated layout without having to write
		// any real animation code.
		private var _animator:LayoutAnimator;

		// the array of currently selected ancestors
		private var _selection:Array = [];

		//our scale and translation state.
		private var _tSX:Number = 1;
		private var _tSY:Number = 1;
		private var _tTX:Number = 0;
		private var _tTY:Number = 0;


		// a flag to indicate that we should skip animation and jump right to our target.
		private var _needImmediateUpdate:Boolean = true;

		// Constructor
		public function Landscape()
		{
			super();

			// setup our pane to hold all of our children.
			_contentPane = new ContentPane();
			_contentPane.landscape=this;
			_contentPane.cachePolicy = UIComponentCachePolicy.ON;

			// and the mask that will guarantee it stays within our bounds.
			_mask = new Shape();
			addChild(_mask);
			addChild(_contentPane);
			_contentPane.mask = _mask;

			// initialize the animated layout engine.
			_animator = new LayoutAnimator();
			_animator.layoutFunction = generateLayout;
			_animator.completeFunction = completeLayout;
			_animator.initializeFunction = initPaneTarget;
		}

		public function set clipContent(value:Boolean):void
		{
			_mask.visible = (value)? true:false;
			_contentPane.mask = (value)? _mask:null;
		}
		public function get clipContent():Boolean
		{
			return (_contentPane.mask != null);
		}

		override public function set cachePolicy(value:String):void
		{
			_contentPane.cachePolicy = value;
		}
		override public function get cachePolicy():String
		{
			return _contentPane.cachePolicy;
		}
		// to allow developers to declarative set our children, like they do with standard Flex containers,
		// we're going to declare a children array property. We'll go ahead and add all of these children
		// directly to the pane. We should really override the getChild/setChild functions too,
		// as a facade down to the pane. But I'll leave that as an exercise for the reader.
		private var _children:Array = [];
		public function set children(value:Array):void
		{
			var i:int;

			// adding and removing a child can be expensive. It's probably common for someone to
			// grab the children, add a new item to the end of the array, and reassign it, which
			// means most of our children wouldn't really be changing.  So to avoid removing everything
			// then adding everything, we'll use a dictionary to track what children get added.
			// We can then iterate over all of our children, and whichever weren't added, get removed.

			// we could maybe be a little more clever here by tracking as we add children whether or not
			// the numChildren changes. But I'll leave that as an exercise for the reader ;)
			var d:Dictionary = new Dictionary();
			for(i = 0;i<value.length;i++)
			{
				d[value[i]] = true;
				_contentPane.addChild(value[i]);
			}
			for(i = _contentPane.numChildren-1;i>=0;i--)
			{
				if(d[_contentPane.getChildAt(i)] == undefined)
					_contentPane.removeChildAt(i);
			}
			_children = value.concat();
		}
		public function get children():Array
		{
			return _children.concat();
		}

		// we facade this property up on the assumption that different uses might want different speeds.
		public function set animationSpeed(value:Number):void
		{
			_animator.animationSpeed = value;
		}
		public function get animationSpeed():Number
		{
			return _animator.animationSpeed;
		}

		// sets the selection, but skips the animation and jumps directly to the final display parameters.
		public function jumpToSelection(value:Array):void
		{
			selection = value;
			_needImmediateUpdate = true;
			invalidateDisplayList();
		}

		// Sets the selection. This property can be assigned an array of arbitrary descendents
		// of the Landscape component.  All the values in this array _must_ be descendents.
		// the landscape will calculate the scale/translation needed to display all the children
		// in the array, and animate towards it.
		public function set selection(value:Array):void
		{
			_selection = (value as Array);

			calculateMatrixForDescendants(_selection);
			_animator.invalidateLayout();
		}

		public function get selection():Array
		{
			return _selection;
		}

		// Rost: flag added to allow switching from high-scaled state back to normal
		// in the calculateMatrixForDescendants method.
		private var isZoomedIn: Boolean = false;

		// given an array of descendants, calculate the scale and translation factors for the content pane
		// that will display those children as large as possible, centered.
		private function calculateMatrixForDescendants(selections:Array, switchScaledState: Boolean = true, moveWithMouse: Boolean = false):void
		{
			if(selections == null || selections.length == 0)
			{
				_tSX = 1;
				_tSY = 1;
				_tTX = _tTY = 0;
				isZoomedIn = false;
			}
			else
			{
				// Before we get started, we'll zero out the contentPane's transformMatrix.
				// We don't want previous transforms screwing up our calculations.
				var m:Matrix = _contentPane.transform.matrix;
				_contentPane.transform.matrix = new Matrix();

				// If the developer has set padding, we'll inset our view rect by those values.
				// The inset rectangle is the target area we'll try and display the selections in.
				var targetLeft:Number = getStyle("paddingLeft");
				if(isNaN(targetLeft))
					targetLeft = 0;
				var targetTop:Number = getStyle("paddingTop");
				if(isNaN(targetTop))
					targetTop = 0;
				var targetRight:Number = getStyle("paddingRight");
				if(isNaN(targetRight))
					targetRight = 0;
				var targetBottom:Number = getStyle("paddingBottom");
				if(isNaN(targetBottom))
					targetBottom = 0;

				var targetWidth:Number = unscaledWidth - targetLeft - targetRight;
				var targetHeight:Number = unscaledHeight - targetTop - targetBottom;

				var globalBounds:Rectangle;

				var items:Array = [];
				for(var i:int = 0;i<selections.length;i++)
				{
					// for each child, convert its bounds into global coordinates
					var target:Object = selections[i];
					var context:UIComponent;
					var tl:Point;
					var br:Point;
					if(target is UIComponent)
					{
						context = target as UIComponent;
						tl = context.localToGlobal(new Point(0,0));
						br = context.localToGlobal(new Point(context.width/context.scaleX,context.height/context.scaleY));
					}
					else if (target is Rectangle)
					{
						context = _contentPane;
						tl = context.localToGlobal(target.topLeft);
						br = context.localToGlobal(target.bottomRight);
					}
					else
					{
						context = target.context;
						tl = context.localToGlobal(target.bounds.topLeft);
						br = context.localToGlobal(target.bounds.bottomRight);
					}
					items.push(context);

					// union that rect into a running bounding box for all selections.
					if(i == 0)
					{
						globalBounds = new Rectangle(tl.x,tl.y,br.x - tl.x,br.y - tl.y);
					}
					else
					{
						globalBounds = globalBounds.union(new Rectangle(tl.x,tl.y,br.x - tl.x,br.y - tl.y));
					}
				}
				// now convert that global bounding box back into the Landscape component's coordinates.
				tl = globalToLocal(globalBounds.topLeft);
				br = globalToLocal(globalBounds.bottomRight);

				// figure out the scale/translation factors to display that bounding box
				// in the available viewable area
				var w:Number = br.x - tl.x;
				var h:Number = br.y - tl.y;
				var sX:Number = targetWidth/ w;
				var sY:Number = targetHeight/ h;

				// We want to preserve the content scale when moved with mouse and change only its x & y
				if(moveWithMouse)
				{
					sX = m.a;
					sY = m.d;
				}

				// we want to choose the smaller of the two scales to guarantee everything is visible.
				// lastly, we don't want to zoom in past full size. This probably should be optional...
				// it's entirely possible that the selections we're focused on are scaled down,
				// so even if the contentPane is zoomed up larger, the selections might not be scaled at full.
				// Probably should be an option... don't go past 1, don't let the computed
				// scale of any focused child go past 1, or just scale as big as we can.
				var scale:Number  = Math.min(sX,sY);
				var zoomLimit:String = getStyle("zoomLimit");
				switch(zoomLimit)
				{
					case "none":
						break;
					case "100%":
					default:
						//scale = Math.min(scale,1);
						if(isZoomedIn)
						{
							Math.min(scale,1);
						}
						else
						{
							scale = parseInt(zoomLimit);
						}

				}
				//trace("SScale to: " + scale + ", is scaled=" + isZoomedIn);
				if(	switchScaledState == true )
				{
					isZoomedIn = !isZoomedIn;
				}

				// To update object coordinates according to mouse position
				var mX:int = 0;
				var mY:int = 0;
				if(moveWithMouse)
				{
					mX = (targetWidth/2 - mouseX) * sX / 2.5;
					mY = (targetHeight/2 - mouseY) * sY / 1.5;
				}

				_tSX = _tSY =  scale;
				_tTX = -(tl.x + w/2)*scale + targetLeft + targetWidth/2 + mX;
				_tTY = -(tl.y + h/2)*scale + targetTop + targetHeight/2 + mY;

				_contentPane.transform.matrix = m;
			}
		}

		// We measure like Canvas does... by default, we just take the bounding box
		// of all of our children at their measured sizes, and return that as our measured bounds.
		override protected function measure():void
		{
			var maxW:Number = 0;
			var maxH:Number = 0;
			for(var i:int = 0;i<_contentPane.numChildren;i++)
			{
				var child:UIComponent = UIComponent(_contentPane.getChildAt(i));
				if (isNaN(child.percentHeight))
					maxW = Math.max(maxW, child.x + child.getExplicitOrMeasuredWidth());
				if (isNaN(child.percentHeight))
					maxH = Math.max(maxH,child.y+child.getExplicitOrMeasuredHeight());

			}
			measuredWidth = maxW;
			measuredHeight = maxH;
			measuredMinWidth = 0;
			measuredMinHeight = 0;
			invalidateDisplayList();
		}

		private function initPaneTarget(target:LayoutTarget):void
		{
		}

		// Layout the animation targets. In this component we only animate a single target...
		// the contentPane, so this function is simple.
		private function generateLayout():void
		{
			var target:LayoutTarget = _animator.targetFor(_contentPane);

			//trace("layout is " + _tSX + "," + _tSY + " : " + _tTX + "," + _tTY + ",mX=" + mouseX + ",mY=" + mouseY );

			target.scaleX = _tSX;
			target.scaleY = _tSY;
			target.x = _tTX;
			target.y = _tTY;
		}

		// Layout the children. We're currently using a subset of the canvas layout...
		// We just leave every child where it is, and let each child size to it's measured or explicit size.
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRect(0,0,unscaledWidth,unscaledHeight);

			var childWidth:Number;
			var childHeight:Number;

			for(var i:int = 0;i<_contentPane.numChildren;i++)
			{
				var child:UIComponent = UIComponent(_contentPane.getChildAt(i));
				if(isNaN(child.percentWidth))
					childWidth = child.getExplicitOrMeasuredWidth();
				else
					childWidth = child.percentWidth/100 * unscaledWidth;

				if(isNaN(child.percentHeight))
					childHeight = child.getExplicitOrMeasuredHeight();
				else
					childHeight = child.percentHeight/100 * unscaledHeight;

				//trace("child size is " + childWidth +","+childHeight);
				child.setActualSize(childWidth, childHeight);
			}
			calculateMatrixForDescendants(_selection);

			// If someone wanted us to skip animation, we now are guaranteed to know
			// what our viewable area is, so jump to the target values now.
			if(_needImmediateUpdate)
			{
				_needImmediateUpdate = false;
				_animator.updateLayoutWithoutAnimation();
			}
			else
			{
				_animator.invalidateLayout();
			}
		}

		// Rost: called by Animator when animation is finished
		private function completeLayout():void
		{
			switchPanning();
			trace("Animation is finished. Book is zoomed in: " + isZoomedIn);

			var event: BookEvent = new BookEvent(BookEvent.PAGE_ZOOM_COMPLETE, true);
			event.isZoomedIn = isZoomedIn;

			dispatchEvent(event);
		}

		// Rost: we want Landscape to be able to pan childrens too
		private function switchPanning():void
		{
			if(isZoomedIn)
			{
				if(!systemManager.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					systemManager.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				}
			}
			else
			{
				if(systemManager.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					systemManager.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
				}
			}
		}

		private function mouseMoveHandler(event: MouseEvent):void
		{
			if(isZoomedIn)
			{
				calculateMatrixForDescendants(_selection, false, true);
				_animator.invalidateLayout();

				//trace("Move content: " + newx + ", " + event.stageX);
			}
			else
			{
				//trace("Content is static: " + newx + ", " + event.stageX);
			}
		}
	}
}
	import mx.core.UIComponent;
	import qs.containers.Landscape;


class ContentPane extends UIComponent
{
	public var landscape:Landscape

	override protected function measure():void
	{
		landscape.invalidateDisplayList();
	}
}
