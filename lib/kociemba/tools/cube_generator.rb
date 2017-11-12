require 'kociemba/cubie_cube'

module Kociemba
  module Tools
    class CubeGenerator
      CORNER_PERMUTATIONS = 40_320 # 8!
      EDGE_PERMUTATIONS = 479_001_600 # 12!

      class << self
        def random_cube
          cc = CubieCube.new
          cc.flip = rand(Cache::FlipMove::N_FLIP - 1)
          cc.twist = rand(Cache::TwistMove::N_TWIST - 1)

          loop do
            cc.urf_to_dlb = rand(CORNER_PERMUTATIONS)
            cc.ur_to_br = rand(EDGE_PERMUTATIONS)

            break if cc.edge_parity ^ cc.corner_parity == 0
          end

          cc.to_face_cube.to_s
        end

        def random_last_layer_cube
        end
      end
    end
  end
end
