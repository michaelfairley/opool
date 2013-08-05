require 'spec_helper'
require 'ref'

describe OPool do
  klass = Class.new do
    include OPool

    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  it "will be garbage collected if completely deferenced" do
    instance = klass.new(12)
    weak = Ref::WeakReference.new(instance)

    GC.start

    instance.value.should == 12
    weak.object.value.should == 12

    instance = nil
    GC.start

    weak.object.should be_nil
  end

  it "is recyclable" do
    instance = klass.new(12)
    instance.value.should == 12

    instance_id = instance.object_id

    instance.recycle!

    instance = nil

    instance2 = klass.new(13)
    instance2.value.should == 13

    instance2.object_id.should == instance_id
  end

  it "clears out instance variables on recycled objects" do
    value = "hello"

    instance = klass.new(value)
    value = Ref::WeakReference.new(value)

    instance.value.should == "hello"

    instance_id = instance.object_id

    instance.recycle!
    instance.value.should be_nil

    instance = nil

    GC.start

    value.object.should be_nil
  end
end
