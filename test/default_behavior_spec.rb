include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior" do 
  describe "'internal:createText'" do 
    it "should be possible to invoke from Ioke with a regular String" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[internal:createText("foo")])).data.text.should == "foo"
    end
  end

  describe "'derive'" do 
    it "should be able to derive from Origin" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Origin derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Origin'
      result.should_not == ioke.origin
    end

    it "should be able to derive from Ground" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Ground derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Ground'
      result.should_not == ioke.ground
    end

    it "should be able to derive from Text" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Text derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Text'
      result.should_not == ioke.text
    end
  end
  
  describe "'break'" do 
    it "should raise a control flow exception" do 
      ioke = IokeRuntime.get_runtime()
      proc do 
        ioke.evaluate_stream(StringReader.new(%q[break]))
      end.should raise_error(NativeException)
    end

    it "should have nil as value by default" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_stream(StringReader.new(%q[break]))
        false.should == true
      rescue NativeException => e
        e.cause.value.should == ioke.nil
      end
    end

    it "should take a return value" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_stream(StringReader.new(%q[break(42)]))
        false.should == true
      rescue NativeException => e
        e.cause.value.data.as_java_integer.should == 42
      end
    end
  end
  
  describe "'until'" do 
    it "should not do anything if initial argument is true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; until(true, x=43)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 42
    end
    
    it "should loop until the argument becomes true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; until(x==45, x++)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
    
    it "should return the last statement value" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[x=42; until(x==43, x++; "blurg")]))
      result.data.text.should == "blurg"
    end
    
    it "should be interrupted by break" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; until(x==50, x++; if(x==45, break))]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
    
    it "should return nil if no arguments provided" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[until()])).should == ioke.nil
    end
  end

  describe "'while'" do 
    it "should not do anything if initial argument is false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; while(false, x=43)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 42
    end
    
    it "should loop until the argument becomes false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; while(x<45, x++)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
    
    it "should return the last statement value" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[x=42; while(x<43, x++; "blurg")]))
      result.data.text.should == "blurg"
    end
    
    it "should be interrupted by break" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; while(x<50, x++; if(x==45, break))]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end

    it "should return nil if no arguments provided" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[while()])).should == ioke.nil
    end
  end
  
  describe "'loop'" do 
    it "should loop until interrupted by break" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; loop(x++; if(x==45, break))]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
  end

  describe "'if'" do 
    it "should evaluate it's first element once" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42; if(x++)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 43
    end
    
    it "should return it's second argument if the first element evaluates to true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(true, 42, 43)])).data.as_java_integer.should == 42
    end

    it "should return it's third argument if the first element evaluates to false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(false, 42, 43)])).data.as_java_integer.should == 43
    end
    
    it "should return the result of evaluating the first argument if there are no more arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(44)])).data.as_java_integer.should == 44
    end
    
    it "should return the result of evaluating the first argument if it is false and there are only two arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(false)])).should == ioke.false
      ioke.evaluate_stream(StringReader.new(%q[if(nil)])).should == ioke.nil
    end
  end

  describe "'asText'" do 
    it "should call toString and return the text from that" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[Origin mimic asText])).data.text.should match(/^#<Origin:[0-9A-F]+>$/)
    end
  end

  describe "'representation'" do 
    it "should call representation and return the text from that" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[Origin mimic representation])).data.text.
        should match(/^#<#<Origin:[0-9A-F]+>: mimics=\[#<Origin:[0-9A-F]+>\] cells=\{\}>$/)
    end
  end

  describe "'do'" do 
    it "should execute a piece of code inside an object" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do(
  y = 42
  z = "str"
)
CODE
      ioke.ground.find_cell(nil,nil, 'y').should == ioke.nul
      ioke.ground.find_cell(nil,nil, 'x').find_cell(nil,nil, 'y').data.as_java_integer.should == 42
      ioke.ground.find_cell(nil,nil, 'x').find_cell(nil,nil, 'z').data.text.should == "str"
    end
  end
  
  describe "'nil?'" do 
    it "should return true for nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("nil nil?")).should == ioke.true
    end

    it "should return false for false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("false nil?")).should == ioke.false
    end
    
    it "should return false for true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("true nil?")).should == ioke.false
    end
    
    it "should return false for a Number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123 nil?")).should == ioke.false
    end
    
    it "should return false for a Text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("\"flurg\" nil?")).should == ioke.false
    end
  end

  describe "'true?'" do 
    it "should return false for nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("nil true?")).should == ioke.false
    end

    it "should return false for false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("false true?")).should == ioke.false
    end
    
    it "should return true for true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("true true?")).should == ioke.true
    end
    
    it "should return true for a Number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123 true?")).should == ioke.true
    end
    
    it "should return true for a Text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("\"flurg\" true?")).should == ioke.true
    end
  end

  describe "'false?'" do 
    it "should return true for nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("nil false?")).should == ioke.true
    end

    it "should return true for false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("false false?")).should == ioke.true
    end
    
    it "should return false for true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("true false?")).should == ioke.false
    end
    
    it "should return false for a Number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123 false?")).should == ioke.false
    end
    
    it "should return false for a Text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("\"flurg\" false?")).should == ioke.false
    end
  end

  describe "kind?" do 
    # This will have to wait until we can remove cells from objects
    it "should return false if the object doesn't have a kind at all"

    it "should return false if the kind doesn't match" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("Text kind?(\"nil\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("Text kind?(\"Number\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"nil\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Number\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"System\")")).should == ioke.false
    end

    it "should return true if the current object has the kind" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("Text kind?(\"Text\")")).should == ioke.true
    end
    
    it "should return true if the main mimic has the kind" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Text\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"DefaultBehavior\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Base\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Ground\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Origin\")")).should == ioke.true
    end

    it "should return true if another mimic has the kind" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("123 kind?(\"Mixins Comparing\")")).should == ioke.true
    end

    it "should handle a cycle of mimics correctly" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("f = Origin mimic; f mimic!(f); f kind?(\"Origin\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("f = Origin mimic; Origin mimic!(f); f kind?(\"Origin\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("f = Origin mimic; Origin mimic!(f); f kind?(\"DefaultBehavior\")")).should == ioke.true
    end
  end
  
  describe "mimics?" do 
    it "should return false if the object doesn't mimic anyone"
    it "should return false if the object doesn't mimic the argument"
    it "should return true if the object is the same as the argument"
    it "should return true if any of the mimics are the argument"
    it "should handle a cycle of mimics correctly"
  end

  describe "mimic!" do 
    it "should add a new mimic to the list of mimics" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("f = Origin mimic; g = Origin mimic; f mimic!(g)"))
      ioke.ground.find_cell(nil, nil, "f").get_mimics.size.should == 2
      ioke.ground.find_cell(nil, nil, "f").get_mimics.get(0).should == ioke.origin
      ioke.ground.find_cell(nil, nil, "f").get_mimics.get(1).should == ioke.ground.find_cell(nil, nil, "g")
    end

    it "should not add a mimic that's already in the list"
    it "should not be able to mimic nil"
    it "should not be able to mimic true"
    it "should not be able to mimic false"
    it "should not be able to mimic symbols"
    it "should return the receiving object"
  end
end
