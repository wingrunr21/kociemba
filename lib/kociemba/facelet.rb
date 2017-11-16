# frozen_string_literal: true

module Kociemba
  class Facelet
    CUBE_SIZE = 3
    FACELETS_SIZE = CUBE_SIZE**2
    FACES = %i(U R F D L B)
    ORDINALS = {}.tap do |h|
      FACES.each_with_index do |face, i|
        FACELETS_SIZE.times do |j|
          h["#{face}#{j + 1}".to_sym] = (i * FACELETS_SIZE) + j
        end
      end
    end

    CORNERS = [
      %i(U9 R1 F3),
      %i(U7 F1 L3),
      %i(U1 L1 B3),
      %i(U3 B1 R3),
      %i(D3 F9 R7),
      %i(D1 L9 F7),
      %i(D7 B9 L7),
      %i(D9 R9 B7)
    ]

    EDGES = [
      %i(U6 R2),
      %i(U8 F2),
      %i(U4 L2),
      %i(U2 B2),
      %i(D6 R8),
      %i(D2 F8),
      %i(D4 L8),
      %i(D8 B8),
      %i(F6 R4),
      %i(F4 L6),
      %i(B6 L4),
      %i(B4 R6)
    ]

    def self.for(i, j, type:)
      case type
      when :corner
        new CORNERS[i][j]
      when :edge
        new EDGES[i][j]
      end
    end

    attr_reader :facelet, :face, :color

    def initialize(facelet)
      @facelet = facelet
      @face = ord / FACELETS_SIZE
      @color = Color.new(FACES[@face])
    end

    def ord
      ORDINALS[@facelet]
    end
  end
end
