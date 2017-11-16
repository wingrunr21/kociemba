# frozen_string_literal: true

module Kociemba
  module Cache
    class UrToUlMove < BaseCache
      N_UR_TO_UL = 1320 # 12!/(12-3)! permutation of UR,UF,UL edges

      def self.cache_name
        'ur_to_ul_move'.freeze
      end

      def self.dump
        ur_to_ul_move = Array.new(N_UR_TO_UL) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_UR_TO_UL.times do |i|
          a.ur_to_ul = i
          6.times do |j|
            3.times do |k|
              a.edge_multiply(MoveCube[j])
              ur_to_ul_move[i][3 * j + k] = a.ur_to_ul
            end
            a.edge_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| Marshal.dump(ur_to_ul_move, f)}
        ur_to_ul_move
      end
    end

    def self.ur_to_ul_move
      @ur_to_ul_move ||= UrToUlMove.load.freeze
    end
  end
end
