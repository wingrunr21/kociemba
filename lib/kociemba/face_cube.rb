require 'kociemba/color'
require 'kociemba/facelet'

module Kociemba
  # Cube on the Facelet level
  class FaceCube
    include Corner
    include Edge

    DEFAULT_CUBE = 'UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB'
    CORNER_COLORS = CORNERS.map do |value|
      value.to_s.scan(/./).map {|c| Color.new(c)}
    end
    EDGE_COLORS = EDGES.map do |value|
      value.to_s.scan(/./).map {|c| Color.new(c)}
    end

    attr_reader :colors

    def initialize(cube = DEFAULT_CUBE)
      @cube = cube
      @colors = cube.upcase.scan(/./).map do |facelet|
        Color.new(facelet.to_sym)
      end
    end

    def to_s
      @cube
    end

    def to_cubie_cube
      cube = CubieCube.new

      # Invalidate corners
      8.times do |i|
        cube.corner_permutation[i] = -1
      end

      # Invalidate edges
      12.times do |i|
        cube.edge_permutation[i] = UR
      end

      CORNERS.length.times do |i|
        # get the colors of the cubie at corner i, starting with U/D
        # FIXME this is kinda bla
        ori = nil
        CORNER_SIZE.times do |j|
          ori = j
          ord = Facelet.for(i, j, type: :corner).ord
          break if colors[ord] == Color::U || colors[ord] == Color::D
        end

        color_1 = colors[Facelet.for(i, (ori + 1) % 3, type: :corner).ord]
        color_2 = colors[Facelet.for(i, (ori + 2) % 3, type: :corner).ord]

        CORNERS.length.times do |j|
          if color_1 == corner_color(j, 1) && color_2 == corner_color(j, 2)
            cube.corner_permutation[i] = j
            cube.corner_orientation[i] = ori % 3
            break
          end
        end
      end

      EDGES.length.times do |i|
        EDGES.length.times do |j|
          if colors[Facelet.for(i, 0, type: :edge).ord] == edge_color(j, 0) && colors[Facelet.for(i, 1, type: :edge).ord] == edge_color(j, 1)
            cube.edge_permutation[i] = j
            cube.edge_orientation[i] = 0
            break
          end

          if colors[Facelet.for(i, 0, type: :edge).ord] == edge_color(j, 1) && colors[Facelet.for(i, 1, type: :edge).ord] == edge_color(j, 0)
            cube.edge_permutation[i] = j
            cube.edge_orientation[i] = 1
            break
          end
        end
      end

      cube
    end

    private

    def corner_color(i, j)
      CORNER_COLORS[i][j]
    end

    def edge_color(i, j)
      EDGE_COLORS[i][j]
    end
  end
end
