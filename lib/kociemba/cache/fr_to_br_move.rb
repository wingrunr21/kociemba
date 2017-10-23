module Kociemba
  module Cache
    class FrToBrMove < BaseCache
      N_FR_TO_BR = 11880 # 12!/(12-4)! permutation of FR,FL,BL,BR edges

      def self.cache_name
        'fr_to_br_move'.freeze
      end

      def self.dump
        fr_to_br_move = Array.new(N_FR_TO_BR) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_FR_TO_BR.times do |i|
          a.fr_to_br = i
          6.times do |j|
            3.times do |k|
              a.edge_multiply(MoveCube[j])
              fr_to_br_move[i][3 * j + k] = a.fr_to_br
            end
            a.edge_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| Marshal.dump(fr_to_br_move, f)}
        fr_to_br_move
      end
    end

    def self.fr_to_br_move
      @fr_to_br_move ||= FrToBrMove.load.freeze
    end
  end
end
