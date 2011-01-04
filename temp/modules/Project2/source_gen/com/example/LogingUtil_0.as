package com.example{
  
  import flash.net.XMLSocket;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.utils.setTimeout;
  import flash.utils.getTimer;
  
  public class LogingUtil_0 {
    private static var socket : XMLSocket ;
    private static var messages : Array = new Array() ;
    private static var scopes : Array = new Array(["Main", 0]) ;
    private static const PORT : Number = 6125 ;
    private static var hasError : Boolean = false ;
    public function LogingUtil_0(  ){
      
    }
    private static function initSocket (  ) : void {
      if ( socket ) {
        socket.close();
      }
      try {
        socket = new XMLSocket("localhost", PORT);
        socket.addEventListener(Event.CONNECT, onConnect, false, 0, true);
        socket.addEventListener(IOErrorEvent.IO_ERROR,         function (  ) : void {
          hasError = true;
        }, false, 0, true);
        socket.addEventListener(IOErrorEvent.NETWORK_ERROR,         function (  ) : void {
          hasError = true;
        }, false, 0, true);
      } catch ( e : Error ) {
        hasError = true;
      }
    }
    private static function onConnect ( event : Event ) : void {
      flush();
    }
    private static function onClose ( event : Event ) : void {
      var delay : Number = Math.random() * 1000 + 1000;
      setTimeout(      function (  ) : void {
        initSocket();
      }, delay);
    }
    private static function flush (  ) : void {
      if ( socket == null ) {
        initSocket();
        return  ;
      }
      if ( socket.connected ) {
        for each ( var e : XML in messages ) {
          socket.send(e);
        }
        messages = new Array();
      }
    }
    public static function enterLogScope ( scope : String, scopeId : String ) : void {
      if ( hasError ) {
        return  ;
      }
      scopes.push([scope, scopeId]);
    }
    public static function exitLogScope ( scope : String, scopeId : String ) : void {
      if ( hasError ) {
        return  ;
      }
      var oldScopes : Array = scopes.concat([]);
      scopes = new Array();
      for each ( var e : Array in oldScopes ) {
        if ( !((e[0] == scope && e[1] == scopeId)) ) {
          scopes.push(e);
        }
      }
    }
    public static function log ( severity : String, nodeId : String, modelId : String, rootFQN : String, message : String, exception : Error = null ) : void {
      if ( hasError ) {
        return  ;
      }
      var xmlMessage : XML =       <logMessage>
        <source nodeId={nodeId} modelReference={modelId}  />
        <message severity={severity}  >{message}</message>
        <root>{rootFQN}</root>
        <timestamp>{getTimer()}</timestamp>
        <scopes/>
</logMessage>;
      
      for each ( var scope : Array in scopes ) {
        xmlMessage.scopes.appendChild(<scope id={scope[1]}  >{scope[0]}</scope>);
      }
      
      messages.push(xmlMessage);
      
      flush();
    }
  }
}
