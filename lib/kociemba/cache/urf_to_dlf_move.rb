# frozen_string_literal: true

module Kociemba
  module Cache
    class UrfToDlfMove < BaseCache
      N_URF_TO_DLF = 20160 # 8!/(8-6)! permutation of URF,UFL,ULB,UBR,DFR,DLF corners

      def self.cache_name
        'urf_to_dlf_move'.freeze
      end

      def self.dump
        urf_to_dlf_move = Array.new(N_URF_TO_DLF) {Array.new(N_MOVE, 0)}
        a = CubieCube.new
        N_URF_TO_DLF.times do |i|
          a.urf_to_dlf = i
          6.times do |j|
            3.times do |k|
              a.corner_multiply(MoveCube[j])
              urf_to_dlf_move[i][3 * j + k] = a.urf_to_dlf
            end
            a.corner_multiply(MoveCube[j])
          end
        end

        File.open(filename, 'w') {|f| Marshal.dump(urf_to_dlf_move, f)}
        urf_to_dlf_move
      end
    end

    def self.urf_to_dlf_move
      @urf_to_dlf_move ||= UrfToDlfMove.load.freeze
    end
  end
end
