module Kociemba
  module Cache
    class UrToDfMove < BaseCache
      N_UR_TO_DF = 20160 # 8!/(8-6)! permutation of UR,UF,UL,UB,DR,DF edges in phase2

      def self.cache_name
        'ur_to_df_move'.freeze
      end

      def self.dump
        ur_to_df_move = Array.new(N_UR_TO_DF) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_UR_TO_DF.times do |i|
          a.ur_to_df = i
          6.times do |j|
            3.times do |k|
              a.edge_multiply(MoveCube[j])
              ur_to_df_move[i][3 * j + k] = a.ur_to_df
            end
            a.edge_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| Marshal.dump(ur_to_df_move, f)}
        ur_to_df_move
      end
    end

    def self.ur_to_df_move
      @ur_to_df_move ||= UrToDfMove.load.freeze
    end
  end
end
