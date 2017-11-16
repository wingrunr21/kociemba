# frozen_string_literal: true

module Kociemba
  class Color
    COLORS = %i(U R F D L B).map.with_index { |c, i| [c, i] }.to_h

    attr_reader :color

    def initialize(color)
      @color = color.to_sym
    end

    def ord
      COLORS[color]
    end

    def to_s
      color.to_s
    end

    def ==(other)
      other.instance_of?(self.class) && color == other.color
    end
    alias_method :eql?, :==

    def hash
      color.hash
    end

    def self.const_missing(name)
      if COLORS.include?(name)
        const_set name, new(name)
      else
        super
      end
    end
  end
end
