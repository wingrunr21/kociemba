# frozen_string_literal: true

module Kociemba
  module Cache
    class FlipMove < BaseCache
      N_FLIP = 2048 # 2^11 possible edge flips

      def self.cache_name
        'flip_move'.freeze
      end

      def self.dump
        flip_move = Array.new(N_FLIP) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_FLIP.times do |i|
          a.flip = i
          6.times do |j|
            # FIXME: can the edge_multiply be done once?
            3.times do |k|
              a.edge_multiply(MoveCube[j])
              flip_move[i][3 * j + k] = a.flip
            end
            a.edge_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| JSON.dump(flip_move, f)}
        flip_move
      end
    end

    def self.flip_move
      @flip_move ||= FlipMove.load.freeze
    end
  end
end
