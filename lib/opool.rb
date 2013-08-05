require "opool/version"

module OPool
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def new(*args, &blk)
      object = _opool.pop || allocate
      object.send(:initialize, *args, &blk)
      object
    end

    def _opool
      @_opool ||= []
    end
  end

  def recycle!
    self.class._opool << self
    instance_variables.each do |ivar|
      remove_instance_variable(ivar)
    end
  end
end
