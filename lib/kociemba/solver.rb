# frozen_string_literal: true

module Kociemba
  class Solver
    SIZE = 31

    attr_accessor :move_axis, :move_power
    # phase 1
    attr_accessor :flip, :twist, :slice
    # phase 2
    attr_accessor :parity, :urf_to_dlf, :fr_to_br, :ur_to_ul, :ub_to_df, :ur_to_df
    # distances
    attr_accessor :min_dist_phase1, :min_dist_phase2

    # FIXME: this can probably be better
    def initialize
      reset
    end

    def reset
      @move_axis = Array.new(SIZE, 0)
      @move_power = Array.new(SIZE, 0)
      @flip = Array.new(SIZE, 0)
      @twist = Array.new(SIZE, 0)
      @slice = Array.new(SIZE, 0)
      @parity = Array.new(SIZE, 0)
      @urf_to_dlf = Array.new(SIZE, 0)
      @fr_to_br = Array.new(SIZE, 0)
      @ur_to_ul = Array.new(SIZE, 0)
      @ub_to_df = Array.new(SIZE, 0)
      @ur_to_df = Array.new(SIZE, 0)
      @min_dist_phase1 = Array.new(SIZE, 0)
      @min_dist_phase2 = Array.new(SIZE, 0)
      self
    end

    # FIXME: make more better
    def to_solution_string(length)
      ax_to_s = ['U', 'R', 'F', 'D', 'L', 'B']
      po_to_s = ['', ' ', '2 ', "' "]
      s = ''
      length.times do |i|
        s += ax_to_s[move_axis[i]]
        s += po_to_s[move_power[i]]
      end

      s.strip
    end

    def solve(cube, max_depth: 21, time_out: 120)
      fc = FaceCube.new(cube)
      cc = fc.to_cubie_cube

      # TODO: verify the cube here

      c = CoordCube.new(cc)

      # FIXME: this can be made better
      # Initialization
      move_power[0] = 0
      move_axis[0] = 0
      flip[0] = c.flip
      twist[0] = c.twist
      parity[0] = c.parity
      slice[0] = c.fr_to_br / 24 # why 24?
      urf_to_dlf[0] = c.urf_to_dlf
      fr_to_br[0] = c.fr_to_br
      ur_to_ul[0] = c.ur_to_ul
      ub_to_df[0] = c.ub_to_df

      min_dist_phase1[1] = 1 # else failure for depth=1, n=0. TODO understand this

      mv = 0
      n = 0
      busy = false
      depth_phase1 = 1

      t_start = Time.now

      # FIXME: make more better
      while true
        while true
          if depth_phase1 - n > min_dist_phase1[n + 1] && !busy
            # Initialize next move
            if move_axis[n] == 0 || move_axis[n] == 3
              n += 1
              move_axis[n] = 1
            else
              n += 1
              move_axis[n] = 0
            end
            move_power[n] = 1
          else
            move_power[n] += 1
            if move_power[n] > 3
              while true
                move_axis[n] += 1
                if move_axis[n] > 5
                  return "Error 8" if Time.now - t_start > time_out

                  if n == 0
                    if depth_phase1 >= max_depth
                      return "Error 7"
                    else
                      depth_phase1 += 1
                      move_axis[n] = 0
                      move_power[n] = 1
                      busy = false
                      break
                    end
                  else
                    n -= 1
                    busy = true
                    break
                  end
                else
                  move_power[n] = 1
                  busy = false
                end

                break unless n != 0 && (move_axis[n - 1] == move_axis[n] || move_axis[n - 1] - 3 == move_axis[n])
              end
            else
              busy = false
            end
          end
          break unless busy
        end

        # Compute new coordinates and new min_dist_phase1
        mv = 3 * move_axis[n] + move_power[n] - 1
        begin
          flip[n + 1] = Cache.flip_move[flip[n]][mv]
          twist[n + 1] = Cache.twist_move[twist[n]][mv]
          slice[n + 1] = Cache.fr_to_br_move[slice[n] * 24][mv] / 24
        rescue
          binding.pry
        end

        min_dist_phase1[n + 1] = [
         Cache::BasePrune.get_pruning(Cache.slice_flip_prune, Cache::BaseCache::N_SLICE1 * flip[n + 1] + slice[n + 1]),
         Cache::BasePrune.get_pruning(Cache.slice_twist_prune, Cache::BaseCache::N_SLICE1 * twist[n + 1] + slice[n + 1])
        ].max
        #####

        if min_dist_phase1[n + 1] == 0 && n >= depth_phase1 - 5
          min_dist_phase1[n + 1] = 10 # any value > 5 can be used here. why?
          if n == depth_phase1 - 1
            s = total_depth(depth_phase1, max_depth)
            if (s >= 0)
              if (s == depth_phase1 ||
                  (move_axis[depth_phase1 - 1] != move_axis[depth_phase1] && move_axis[depth_phase1 - 1] != move_axis[depth_phase1] + 3))
                return to_solution_string(s)
              end
            end
          end
        end
      end
    end

    # Apply phase2 of algorithm and return the combined phase1 and phase2 depth. In phase2, only the moves
    # U,D,R2,F2,L2 and B2 are allowed.
    def total_depth(depth_phase1, max_depth)
      mv = 0
      d1 = 0
      d2 = 0
      max_depth_phase2 = [10, max_depth - depth_phase1].min # max 10 moves in phase 2
      depth_phase1.times do |i|
        mv = 3 * move_axis[i] + move_power[i] - 1
        urf_to_dlf[i + 1] = Cache.urf_to_dlf_move[urf_to_dlf[i]][mv]
        fr_to_br[i + 1] = Cache.fr_to_br_move[fr_to_br[i]][mv]
        parity[i + 1] = Cache.parity_move[parity[i]][mv]
      end

      d1 = Cache::BasePrune.get_pruning(
        Cache.slice_urf_to_dlf_parity_prune,
        (Cache::BaseCache::N_SLICE2 * urf_to_dlf[depth_phase1] + fr_to_br[depth_phase1]) * 2 + parity[depth_phase1]
      )
      return -1 if d1 > max_depth_phase2

      depth_phase1.times do |i|
        mv = 3 * move_axis[i] + move_power[i] - 1
        ur_to_ul[i + 1] = Cache.ur_to_ul_move[ur_to_ul[i]][mv]
        ub_to_df[i + 1] = Cache.ub_to_df_move[ub_to_df[i]][mv]
      end

      ur_to_df[depth_phase1] = Cache.merge_ur_to_ul_and_ub_to_df[ur_to_ul[depth_phase1]][ub_to_df[depth_phase1]]

      d2 = Cache::BasePrune.get_pruning(
        Cache.slice_ur_to_df_parity_prune,
        (Cache::BaseCache::N_SLICE2 * ur_to_df[depth_phase1] + fr_to_br[depth_phase1]) * 2 + parity[depth_phase1]
      )
      return -1 if d2 > max_depth_phase2

      min_dist_phase2[depth_phase1] = [d1, d2].max
      return depth_phase1 if min_dist_phase2[depth_phase1] == 0 #already solved

      # set up search
      depth_phase2 = 1
      n = depth_phase1
      busy = false
      move_power[depth_phase1] = 0
      move_axis[depth_phase1] = 0
      min_dist_phase2[n + 1] = 1 # else failure for depth_phase2=1, n=0
      ####

      while true
        while true
          if depth_phase1 + depth_phase2 - n > min_dist_phase2[n + 1] and !busy
            if move_axis[n] == 0 || move_axis[n] == 3
              n += 1
              move_axis[n] = 1
              move_power[n] = 2
            else
              n += 1
              move_axis[n] = 0
              move_power[n] = 1
            end
          else
            if move_axis[n] == 0 || move_axis[n] == 3
              move_power[n] += 1
            else
              move_power[n] += 2
            end

            if move_power[n] > 3
              while true
                # increment axis
                move_axis[n] += 1
                if move_axis[n] > 5
                  if n == depth_phase1
                    if depth_phase2 >= max_depth_phase2
                      return -1
                    else
                      depth_phase2 += 1
                      move_axis[n] = 0
                      move_power[n] = 1
                      busy = false
                      break
                    end
                  else
                    n -= 1
                    busy = true
                    break
                  end
                else
                  if move_axis[n] == 0 || move_axis[n] == 3
                    move_power[n] = 1
                  else
                    move_power[n] = 2
                  end

                  busy = false
                end

                break unless n != depth_phase1 && (move_axis[n - 1] == move_axis[n] || move_axis[n - 1] - 3 == move_axis[n])
              end
            else
              busy = false
            end
          end

          break unless busy
        end

        # compute new coordinates and new minDist
        mv = 3 * move_axis[n] + move_power[n] - 1
        urf_to_dlf[n + 1] = Cache.urf_to_dlf_move[urf_to_dlf[n]][mv]
        fr_to_br[n + 1] = Cache.fr_to_br_move[fr_to_br[n]][mv]
        parity[n + 1] = Cache.parity_move[parity[n]][mv]
        ur_to_df[n + 1] = Cache.ur_to_df_move[ur_to_df[n]][mv]

        min_dist_phase2[n + 1] = [
          Cache::BasePrune.get_pruning(
            Cache.slice_ur_to_df_parity_prune,
            (Cache::BaseCache::N_SLICE2 * ur_to_df[n + 1] + fr_to_br[n + 1]) * 2 + parity[n + 1]
          ),
          Cache::BasePrune.get_pruning(
            Cache.slice_urf_to_dlf_parity_prune,
            (Cache::BaseCache::N_SLICE2 * urf_to_dlf[n + 1] + fr_to_br[n + 1]) * 2 + parity[n + 1]
          )
        ].max

        break if min_dist_phase2[n + 1] == 0
      end

      depth_phase1 + depth_phase2
    end
  end
end
