# frozen_string_literal: true

module Kociemba
  module Cache
    class TwistMove < BaseCache
      N_TWIST = 2187 # 3^7 possible corner orientations

      def self.cache_name
        'twist_move'.freeze
      end

      def self.dump
        twist_move = Array.new(N_TWIST) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_TWIST.times do |i|
          a.twist = i
          6.times do |j|
            3.times do |k|
              a.corner_multiply(MoveCube[j])
              twist_move[i][3 * j + k] = a.twist
            end
            a.corner_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| JSON.dump(twist_move, f)}
        twist_move
      end
    end

    def self.twist_move
      @twist_move ||= TwistMove.load.freeze
    end
  end
end
