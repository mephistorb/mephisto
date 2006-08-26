module CodeRay
module Scanners
    
  # Pretty much all of the predefined words here were borrowed(stolen) from the 
  # Javascript bundle in TextMate
  class Javascript < Scanner
    
    register_for :javascript, :ecma
    
    RESERVED_WORDS = %w[
      boolean type char class double enum float function int interface 
      long short var void const export extends final implements native private 
      protected public static throws break case catch continue default do else 
      finally for goto if import package return switch throw try while
    ]
    
    KEYWORD_OPERATOR = %w[delete in instanceof new typeof with]
    
    PREDEFINED_CONSTANT = %w[false null super this true undefined]
    
    KLASS= %w[
      Anchor Applet Area Array Boolean Button Checkbox Date document event 
      FileUpload Form Frame Function Hidden History Image JavaArray JavaClass 
      JavaObject JavaPackage java Layer Link Location Math MimeType Number 
      navigator netscape Object Option Packages Password Plugin Radio RegExp 
      Reset Select String Style Submit screen sun Text Textarea window XMLHttpRequest
    ]
    
    FUNCTION = %w[
      abort abs acos alert anchor apply asin atan atan2 atob attachEvent back 
      big blink bold borderWidths btoa call captureEvents ceil charAt charCodeAt 
      clear clearInterval clearTimeout compile concat confirm contextual cos 
      createEventObject createPopup createStyleSheet detachEvent disableExternalCapture 
      dump elementFromPoint enableExternalCapture escape eval exec execCommand execScript 
      exp fileCreatedDate fileModifiedDate fileSize fileUpdatedDate find fixed floor 
      fontcolor fontsize fromCharCode forward getAllResponseHeaders getAttention getDate 
      getDay getFullYear getHours getMilliseconds getMinutes getMonth getResponseHeader 
      getSeconds getSelection getTime getTimezoneOffset getUTCDate getUTCDay getUTCFullYear 
      getUTCHours getUTCMilliseconds getUTCMinutes getUTCMonth getUTCSeconds getYear go 
      handleEvent home indexOf isFinite isNaN italics javaEnabled join lastIndexOf link 
      load log margins match max mergeAttributes min moveAbove moveBelow moveBy moveTo 
      moveToAbsolute navigate paddings parse parseFloat parseInt plugins.refresh pop pow 
      preference print prompt push queryCommandEnabled queryCommandIndeterm queryCommandState 
      queryCommandValue random recalc releaseCapture releaseEvents reload replace resizeBy 
      resizeTo returnValue reverse round routeEvents savePreferences scroll scrollBy scrollByLines 
      scrollByPages scrollTo scrollX scrollY search send setDate setFullYear setActive setCursor 
      setHotKeys setHours setInterval setMilliseconds setMinutes setMonth setResizable 
      setRequestHeader setSeconds setTime setTimeout setUTCDate setUTCFullYear setUTCHours 
      setUTCMilliseconds setUTCMinutes setUTCMonth setUTCSeconds setYear setZOptions shift 
      showHelp showModalDialog showModelessDialog sidebar sin signText sizeToContent slice 
      small sort splice split sqrt strike stop sub substr substring sup taint taintEnabled 
      tan test toGMTString toLocaleString toLowerCase toSource toString toUpperCase toUTCString 
      UTC unescape unshift untaint updateCommands unwatch valueOf watch
    ]
    
    SUPPORT_EVENT_HANDLER = %w[
      onAbort onActivate onAfterprint onAfterupdate onBeforeactivate onBeforecut onBeforedeactivate 
      onBeforeeditfocus onBeforepaste onBeforeprint onBeforeunload onBeforeupdate onBlur onCellchange 
      onChange onClick onClose onContextmenu onControlselect onCut onDataavailable onDatasetchanged 
      onDatasetcomplete onDblclick onDeactivate onDrag onDragdrop onDragend onDragenter onDragleave 
      onDragover onDragstart onDrop onError onErrorupdate onFocus onHelp onHover onKeydown onKeypress 
      onKeyup onLoad onMousedown onMousemove onMouseout onMouseover onMouseup onPaste onPropertychange 
      onReadystatechange onReset onResize onResizeend onResizestart onRowenter onRowexit onRowsdelete 
      onRowsinserted onScroll onSelect onSelectionchange onSelectstart onStop onSubmit onUnload
    ]
    
    PLAIN_STRING_CONTENT = {
      "'" => /[^'\n]+/,
      '"' => /[^"\n]+/,
    }

    
    IDENT_KIND = WordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(KEYWORD_OPERATOR, :operator).
      add(PREDEFINED_CONSTANT, :pre_constant).
      add(KLASS, :pre_type).
      add(FUNCTION, :function).
      add(SUPPORT_EVENT_HANDLER, :event)

    private
    
    def setup
      @state = :initial
      @plain_string_content = nil
    end
    
    def scan_tokens tokens, options
      
      state = @state
      plain_string_content = @plain_string_content
      
      until eos?
        match = nil
        kind  = nil
        
      case state
        
        when :initial
          
          if scan(/\s+/x)
            kind = :space
            
          elsif scan(%r! // [^\n\\]* (?: \\. [^\n\\]* )* | /\* (?: .*? \*/ | .* ) !mx)
            kind = :comment
            
          elsif scan(/ [-+*\/=<>?:;,!&^|()\[\]{}~%]+ | \.(?!\d) /x)
            kind = :operator
            
          elsif match = scan(/[A-Za-z_][A-Za-z_0-9]*/x)
            kind = IDENT_KIND[match]
            
          elsif match = scan(/["']/)
            tokens << [:open, :string]
            state = :string
            plain_string_content = PLAIN_STRING_CONTENT[match]
            kind = :delimiter
            
          else
            kind = :plain
            getch
          end
          
        when :string
          if scan(plain_string_content)
            kind = :content
          elsif scan(/['"]/)
            tokens << [matched, :delimiter]
            tokens << [:close, :string]
            state = :initial
            next
          elsif scan(/ \\ | $ /x)
            tokens << [:close, :string]
            kind = :error
            state = :initial
          end
          
        else
          raise_inspect "else case \" reached; %p not handled." % peek(1), tokens
        end
                      
        
        match ||= matched
        if $DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens
        end
        raise_inspect 'Empty token', tokens unless match

        tokens << [match, kind]
        
      end
        
      tokens
    end
    
    
    
  end
end
end