require 'spec_helper'
require 'weakref'

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
    weak = WeakRef.new(instance)

    GC.start

    instance.value.should == 12
    weak.value.should == 12

    instance = nil
    GC.start

    expect do
      weak.value
    end.to raise_error(WeakRef::RefError)
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
    value = WeakRef.new(value)

    instance.value.should == "hello"

    instance_id = instance.object_id

    instance.recycle!
    instance.value.should be_nil

    instance = nil

    GC.start

    expect do
      value.to_s
    end.to raise_error(WeakRef::RefError)
  end
end
