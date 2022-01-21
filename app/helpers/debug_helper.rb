# frozen_string_literal: true

# DebugHelper
#
module DebugHelper
  # Setup mixin for class methods
  #
  # === Parameters:
  #
  # * <tt>:base</tt>
  #
  def self.included(base)
    base.extend(ClassMethods)
  end

  # holder of class methods
  #
  module ClassMethods
    # prints name-value pairs for debugging
    #
    # === Parameters:
    #
    # * <tt>:name</tt>
    # * <tt>:value</tt>
    # * <tt>:name2</tt> optional
    # * <tt>:value2</tt> optional
    # * <tt>:name3</tt> optional
    # * <tt>:value3</tt> optional
    #
    def xpp(name, value, name2 = nil, value2 = nil, name3 = nil, value3 = nil)
      # puts "XX#{name}=#{value}" if name2.nil?
      # puts "XX#{name}=#{value} #{name2}=#{value2}" if !name2.nil? && name3.nil?
      # puts "XX#{name}=#{value} #{name2}=#{value2} #{name3}=#{value3}" unless name3.nil?
    end
  end

  private

  def xpp(name, value, name2 = nil, value2 = nil, name3 = nil, value3 = nil)
    self.class.xpp(name, value, name2, value2, name3, value3)
  end
end
