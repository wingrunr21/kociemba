require 'kociemba/cache'

module Kociemba
  class CoordCube
    attr_accessor :twist, :flip, :parity
    attr_accessor :fr_to_br, :ur_to_ul, :ub_to_df, :ur_to_df
    attr_accessor :urf_to_dlf

    def initialize(cubie_cube)
      @twist = cubie_cube.twist
      @flip = cubie_cube.flip
      @parity = cubie_cube.corner_parity
      @fr_to_br = cubie_cube.fr_to_br
      @ur_to_ul = cubie_cube.ur_to_ul
      @ub_to_df = cubie_cube.ub_to_df
      @ur_to_df = cubie_cube.ur_to_df
      @urf_to_dlf = cubie_cube.urf_to_dlf
    end

    # A move on the coordinate level
    def move(move)
      twist = Cache.twist_move[twist][move]
      flip = Cache.flip_move[flip][move]
      parity = Cache.parity_move[parity][move]
      fr_to_br = Cache.fr_to_br_move[fr_to_br][move]
      urf_to_dlf = Cache.urf_to_dlf_move[urf_to_dlf][move]
      ur_to_ul = Cache.ur_to_ul_move[ur_to_ul][move]
      ub_to_df = Cache.ub_to_df_move[ub_to_df][move]
      ur_to_df = Cache.merge_ur_to_ul_and_ub_to_df[ur_to_ul][ub_to_df] if (ur_to_ul < 336 && ub_to_df < 336)
    end
  end
end
