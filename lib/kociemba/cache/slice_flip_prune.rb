module Kociemba
  module Cache
    class SliceFlipPrune < BasePrune
      def self.cache_name
        'slice_flip_prune'.freeze
      end

      def self.dump
        size = N_SLICE1 * FlipMove::N_FLIP
        slice_flip_prune = Array.new(size / 2, -1)

        depth = 0
        set_pruning(slice_flip_prune, 0, 0)
        done = 1

        puts size
        while done != size
          puts depth
          size.times do |i|
            flip = i / N_SLICE1
            slice = i % N_SLICE1

            if (get_pruning(slice_flip_prune, i) == depth)
              18.times do |j|
                new_slice = Cache.fr_to_br_move[slice * 24][j] # 24
                new_flip = Cache.flip_move[flip][j]

                new_size = N_SLICE1 * new_flip + new_slice # FIXME: no idea if this variable name is right

                if get_pruning(slice_flip_prune, new_size) == 0x0f
                  set_pruning(slice_flip_prune, new_size, (depth + 1) & 0xff)
                  done += 1
                end
              end
            end
          end
          depth += 1
        end

        File.open(filename, 'w') {|f| Marshal.dump(slice_flip_prune, f)}
        slice_flip_prune
      end
    end

    def self.slice_flip_prune
      @slice_flip_prune ||= SliceFlipPrune.load.freeze
    end
  end
end
