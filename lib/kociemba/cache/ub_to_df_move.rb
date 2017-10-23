module Kociemba
  module Cache
    class UbToDfMove < BaseCache
      N_UB_TO_DF = 1320 # 12!/(12-3)! permutation of UB,DR,DF edges

      def self.cache_name
        'ub_to_df_move'.freeze
      end

      def self.dump
        ub_to_df_move = Array.new(N_UB_TO_DF) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_UB_TO_DF.times do |i|
          a.ub_to_df = i
          6.times do |j|
            3.times do |k|
              a.edge_multiply(MoveCube[j])
              ub_to_df_move[i][3 * j + k] = a.ub_to_df
            end
            a.edge_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| Marshal.dump(ub_to_df_move, f)}
        ub_to_df_move
      end
    end

    def self.ub_to_df_move
      @ub_to_df_move ||= UbToDfMove.load.freeze
    end
  end
end
