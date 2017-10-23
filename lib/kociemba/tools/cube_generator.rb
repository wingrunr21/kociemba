require 'kociemba/cubie_cube'

module Kociemba
  module Tools
    class CubeGenerator
      class << self
        def random_cube
          cube = CubieCube.new
          cube.setFlip()
          cube.setTwist(rand(26))

          cube.to_s
        end

        def random_last_layer_cube
        end
      end
    end
  end
end