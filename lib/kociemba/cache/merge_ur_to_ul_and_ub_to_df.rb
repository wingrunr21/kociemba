# frozen_string_literal: true

require 'kociemba/edge'

module Kociemba
  module Cache
    # Table to merge the coordinates of the UR,UF,UL and UB,DR,DF edges at the beginning of phase2
    class MergeUrToUlAndUbToDf < BaseCache
      MERGE_SIZE = 336

      def self.cache_name
        'merge_ur_to_ul_and_ub_to_df'.freeze
      end

      # FIXME: this produces all of the same output
      # not sure if this is actually broken or not
      def self.dump
        merge_ur_to_ul_and_ub_to_df = Array.new(MERGE_SIZE) {Array.new(MERGE_SIZE, 0)}

        MERGE_SIZE.times do |ur_to_ul|
          MERGE_SIZE.times do |ub_to_df|
            merge_ur_to_ul_and_ub_to_df[ur_to_ul][ub_to_df] = get_ur_to_df(ur_to_ul, ub_to_df)
          end
        end

        File.open(filename, 'w') {|f| Marshal.dump(merge_ur_to_ul_and_ub_to_df, f)}
        merge_ur_to_ul_and_ub_to_df
      end

      # Permutation of the six edges UR,UF,UL,UB,DR,DF
      def self.get_ur_to_df(idx1, idx2)
        a = CubieCube.new
        b = CubieCube.new

        a.ur_to_ul = idx1
        b.ub_to_df = idx2

        8.times do |i|
          if a.edge_permutation[i] != Kociemba::Edge::BR
            if b.edge_permutation[i] != Kociemba::Edge::BR # collision
              return -1
            else
              b.edge_permutation[i] = a.edge_permutation[i]
            end
          end
        end

        b.ur_to_df
      end
    end

    def self.merge_ur_to_ul_and_ub_to_df
      @merge_ur_to_ul_and_ub_to_df ||= MergeUrToUlAndUbToDf.load.freeze
    end
  end
end
