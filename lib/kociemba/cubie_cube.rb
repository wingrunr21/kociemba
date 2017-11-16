# frozen_string_literal: true

require 'kociemba/corner'
require 'kociemba/edge'

module Kociemba
  class CubieCube
    include Edge
    include Corner

    DEFAULT_CP = [URF, UFL, ULB, UBR, DFR, DLF, DBL, DRB]
    DEFAULT_CO = [0, 0, 0, 0, 0, 0, 0, 0]
    DEFAULT_EP = [UR, UF, UL, UB, DR, DF, DL, DB, FR, FL, BL, BR]
    DEFAULT_EO = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    attr_reader :corner_permutation, :corner_orientation
    attr_reader :edge_permutation, :edge_orientation

    def initialize(corner_permutation: DEFAULT_CP,
                   corner_orientation: DEFAULT_CO,
                   edge_permutation: DEFAULT_EP,
                   edge_orientation: DEFAULT_EO)
      @corner_permutation = corner_permutation
      @corner_orientation = corner_orientation
      @edge_permutation = edge_permutation
      @edge_orientation = edge_orientation
    end

    def to_s
    end

    # Return the cube facelet representation
    def to_face_cube
      fc = FaceCube.new

      CORNERS.length.times do |i|
        j = corner_permutation[i]
        ori = corner_orientation[i]

        CORNER_SIZE.times do |n|
          ord = Facelet.for(i, (n + ori) % 3, type: :corner).ord
          fc.colors[ord] = FaceCube::CORNER_COLORS[j][n]
        end
      end

      EDGES.length.times do |i|
        j = edge_permutation[i]
        ori = edge_orientation[i]
        EDGE_SIZE.times do |n|
          ord = Facelet.for(i, (n + ori) % 2, type: :edge).ord
          fc.colors[ord] = FaceCube::EDGE_COLORS[j][n]
        end
      end

      fc
    end

    # TODO more ruby
    def corner_multiply(b)
      c_perm = []
      c_ori = []

      CORNERS.length.times do |i|
        c_perm << corner_permutation[b.corner_permutation[i]].dup # FIXME: dup needed?

        ori_a = corner_orientation[b.corner_permutation[i]]
        ori_b = b.corner_orientation[i]
        ori = 0

        if (ori_a < 3 && ori_b < 3)
          ori = (ori_a + ori_b) & 0xff
          ori -= 3 if ori >= 3 # FIXME: can this be clamped better (also see others below)
        elsif ori_a < 3 && ori_b >= 3 # need symmetry support for this
          ori = (ori_a + ori_b) & 0xff
          ori -= 3 if ori >= 6
        elsif ori_a >= 3 && ori_b < 3 # need symmetry support for this
          ori = (ori_a - ori_b) & 0xff
          ori += 3 if ori < 3
        elsif ori_a >= 3 && ori_b >= 3 # need symmetry support for this
          ori = (ori_a - ori_b) & 0xff
          ori += 3 if ori < 0
        end

        c_ori << ori
      end

      # FIXME: we don't have to do an O(n) copy here...
      CORNERS.length.times do |i|
        corner_permutation[i] = c_perm[i]
        corner_orientation[i] = c_ori[i]
      end
    end

    # Multiply this CubieCube with another cubiecube b, restricted to the edges.
    # TODO: more ruby
    def edge_multiply(b)
      e_perm = []
      e_ori = []

      EDGES.length.times do |i|
        ep = b.edge_permutation[i]
        e_perm << edge_permutation[ep].dup # FIXME: this may not be correct? dup needed?
        e_ori << (((b.edge_orientation[i] + edge_orientation[ep]) % 2) & 0xff)
      end

      # FIXME: we don't have to do an O(n) copy here...
      EDGES.length.times do |i|
        edge_permutation[i] = e_perm[i]
        edge_orientation[i] = e_ori[i]
      end
    end

    def multiply(b)
      corner_multiply(b)
      edge_multiply(b)
    end

    # TODO: this can be WAY optimized
    def invert_cubie_cube(c)
      EDGES.length.times do |i|
        c.edge_permutation[edge_permutation[i]] = i
      end
      EDGES.length.times do |i|
        c.edge_orientation[edge_orientation[i]] = i
      end
      CORNERS.length.times do |i|
        c.corner_permutation[corner_permutation[i]] = i
      end
      CORNERS.length.times do |i|
        ori = corner_orientation[c.corner_permutation[i]]
        if ori >= 3 # mirrored cube case
          c.corner_orientation[i] = ori
        else # standard case
          c.corner_orientation[i] = -ori
          c.corner_orientation[i] += 3 if c.corner_orientation[i] < 0
        end
      end
    end

    def twist
      # better implementation?
      # CORNERS.length.times.reduce(0) {|sum, i| (CORNER_SIZE * sum + corner_orientation[i]) & 0xffff}
      ret = 0
      (URF...DRB).each do |i|
        ret = (CORNER_SIZE * ret + corner_orientation[i]) & 0xffff
      end

      ret
    end

    # FIXME: make better. probably use reduce here
    def twist=(new_twist)
      twist_parity = 0
      (DRB - 1).downto(URF).each do |i|
        corner_orientation[i] = (new_twist % CORNER_SIZE) & 0xff
        twist_parity += corner_orientation[i]
        new_twist /= CORNER_SIZE
      end

      # Highest corner index
      edge_orientation[DRB] = ((CORNER_SIZE - twist_parity % CORNER_SIZE) % CORNER_SIZE) & 0xff
    end

    def flip
      # EDGES.length.times.reduce(0) {|sum, i| (EDGE_SIZE * sum + edge_orientation[i]) & 0xffff}
      ret = 0
      (UR...BR).each do |i|
        ret = (EDGE_SIZE * ret + edge_orientation[i]) & 0xffff
      end
      ret
    end

    # FIXME: make better. probably use reduce here
    def flip=(new_flip)
      flip_parity = 0
      (BR - 1).downto(UR).each do |i|
        edge_orientation[i] = (new_flip % EDGE_SIZE) & 0xff
        flip_parity += edge_orientation[i]
        new_flip /= EDGE_SIZE
      end

      # Highest edge index
      edge_orientation[BR] = ((EDGE_SIZE - flip_parity % EDGE_SIZE) % EDGE_SIZE) & 0xff
    end

    def corner_parity
      s = 0
      DRB.downto(URF + 1).each do |i|
        (i - 1).downto(URF).each do |j|
          s += 1 if corner_permutation[j] > corner_permutation[i]
        end
      end
      (s % 2) & 0xffff
    end

    def edge_parity
      s = 0
      BR.downto(UR + 1).each do |i|
        (i - 1).downto(UR).each do |j|
          s += 1 if edge_permutation[j] > edge_permutation[i]
        end
      end
      (s % 2) & 0xffff
    end

    # permutation of the UD-slice edges FR,FL,BL and BR
    # TODO make this more Ruby
    def fr_to_br
      a = 0
      x = 0
      edge4 = [nil] * 4

      BR.downto(UR).each do |j|
        ep = edge_permutation[j]
        if FR <= ep && ep <= BR # use range? faster?
          a += n_choose_k(11 - j, x + 1)
          edge4[3 - x] = edge_permutation[j] # CORNER_SIZE?
          x += 1
        end
      end

      b = 0
      3.downto(1).each do |j| # range? CORNER_SIZE?
        k = 0
        while edge4[j] != (j + 8) # ????
          edge4 = rotateLeft(edge4, 0, j) # BLAAAAA
          k += 1
        end
        b = (j + 1) * b + k
      end

      (24 * a + b) & 0xffff # where does 24 come from?
    end

    # TODO more ruby
    def fr_to_br=(idx)
      slice_edge = [FR, FL, BL, BR]
      other_edge = [UR, UF, UL, UB, DR, DF, DL, DB]
      b = idx % 24
      a = idx / 24

      # use UR to invalidate all edges
      EDGES.length.times {|i| edge_permutation[i] = DB}

      (1...4).each do |j|
        k = b % (j + 1)
        b /= j + 1

        while k > 0
          k -= 1
          slice_edge = rotateRight(slice_edge, 0, j)
        end
      end
      x = 3 # generate combination and set slice edges
      (UR..BR).each do |j|
        if a - n_choose_k(11 - j, x + 1) >= 0
          edge_permutation[j] = slice_edge[3 - x]
          a -= n_choose_k(11 - j, x + 1)
          x -= 1
        end
      end
      x = 0 # set the remaining edges UR..DB
      (UR..BR).each do |j|
        if edge_permutation[j] == DB
          edge_permutation[j] = other_edge[x]
          x += 1
        end
      end
    end

    # Permutation of all corners except DBL and DRB
    # TODO more ruby
    def urf_to_dlf
      a = 0
      x = 0
      corner6 = []

      (URF..DRB).each do |j|
        if corner_permutation[j] <= DLF
          a += n_choose_k(j, x + 1)
          corner6 << corner_permutation[j]
          x += 1
        end
      end

      b = 0
      5.downto(1).each do |j|
        k = 0
        while corner6[j] != j
          binding.pry if k >= 50
          corner6 = rotateLeft(corner6, 0, j)
          k += 1
        end
        b = (j + 1) * b + k
      end

      (720 * a + b) & 0xffff
    end

    # TODO more ruby
    def urf_to_dlf=(idx)
      corner6 = [URF, UFL, ULB, UBR, DFR, DLF]
      other_corner = [DBL, DRB]
      b = idx % 720
      a = idx / 720

      # Use DRB to invalidate all corners
      # this can be better
      CORNERS.length.times do |i|
        corner_permutation[i] = DRB
      end

      (1...6).each do |j|
        k = b % (j + 1)
        b /= j + 1
        while k > 0
          k -= 1
          corner6 = rotateRight(corner6, 0, j)
        end
      end

      x = 5
      # generate combination and set corners
      DRB.downto(0).each do |j|
        nck = n_choose_k(j, x + 1)
        if (a - nck) >= 0
          corner_permutation[j] = corner6[x]
          a -= nck
          x -= 1
        end
      end

      x = 0
      (URF..DRB).each do |j|
        if corner_permutation[j] == DRB
          corner_permutation[j] = other_corner[x]
          x += 1
        end
      end
    end

    # Permutation of the six edges UR,UF,UL,UB,DR,DF
    # TODO more ruby
    def ur_to_df
      a = 0
      x = 0
      edge6 = []
      (UR..BR).each do |j|
        if edge_permutation[j] <= DF
          a += n_choose_k(j, x + 1)
          edge6 << edge_permutation[j]
          x += 1
        end
      end

      b = 0
      5.downto(1).each do |j|
        k = 0
        while edge6[j] != j
          edge6 = rotateLeft(edge6, 0, j)
          k += 1
        end
        b = (j + 1) * b + k
      end
      720 * a + b
    end

    # TODO more ruby
    def ur_to_df=(idx)
      edge6 = [UR, UF, UL, UB, DR, DF]
      other_edge = [DL, DB, FR, FL, BL, BR]
      b = idx % 720  # Permutation
      a = idx / 720  # Combination

      # edge_permutation = [BR] * EDGES.length
      EDGES.length.times {|i| edge_permutation[i] = BR}

      (1...6).each do |j|
        k = b % (j + 1)
        b /= j + 1
        while k > 0
          k -= 1
          edge6 = rotateRight(edge6, 0, j)
        end
      end

      x = 5
      BR.downto(0).each do |j|
        nck = n_choose_k(j, x + 1)
        if a - nck >= 0
          edge_permutation[j] = edge6[x]
          a -= nck
          x -= 1
        end
      end

      x = 0
      (UR..BR).each do |j|
        if edge_permutation[j] == BR
          edge_permutation[j] = other_edge[x]
          x += 1
        end
      end
    end

    # Permutation of the three edges UR,UF,UL
    # TODO more ruby
    def ur_to_ul
      a = 0
      x = 0
      edge3 = []

      # compute the index a < (12 choose 3) and the edge permutation
      (UR..BR).each do |j|
        if edge_permutation[j] <= UL
          a += n_choose_k(j, x + 1)
          edge3 << edge_permutation[j]
          x += 1
        end
      end

      # compute the index b < 3! for the permutation in edge3
      b = 0
      2.downto(1).each do |j|
        k = 0
        while edge3[j] != j
          edge3 = rotateLeft(edge3, 0, j)
          k += 1
        end
        b = (j + 1) * b + k
      end

      (6 * a + b) & 0xffff
    end

    # TODO more ruby
    def ur_to_ul=(idx)
      edge3 = [UR, UF, UL]
      b = idx % 6    # Permutation
      a = idx / 6    # Combination

      # Use BR to invalidate edges
      EDGES.length.times {|i| edge_permutation[i] = BR}

      (1...3).each do |j|
        k = b % (j + 1)
        b /= j + 1
        while k > 0
          k -= 1
          edge3 = rotateRight(edge3, 0, j)
        end
      end

      x = 2 # generate combination and set edges
      BR.downto(0).each do |j|
        nck = n_choose_k(j, x + 1)
        if a - nck >= 0
          edge_permutation[j] = edge3[x]
          a -= nck
          x -= 1
        end
      end
    end

    # Permutation of the three edges UB,DR,DF
    # TODO more ruby
    def ub_to_df
      a = 0
      x = 0
      edge3 = []

      (UR..BR).each do |j|
        ep = edge_permutation[j]
        if UB <= ep && ep <= DF # TODO use range?
          a += n_choose_k(j, x + 1)
          edge3 << ep
          x += 1
        end
      end

      b = 0
      2.downto(1).each do |j|
        k = 0
        while edge3[j] != (UB + j)
          edge3 = rotateLeft(edge3, 0, j)
          k += 1
        end
        b = (j + 1) * b + k
      end

      (6 * a + b) & 0xffff
    end

    # TODO more ruby
    def ub_to_df=(idx)
      edge3 = [UB, DR, DF]
      b = idx % 6    # Permutation
      a = idx / 6    # Combination

      # Use BR to invalidate edges
      EDGES.length.times {|i| edge_permutation[i] = BR}
      # edge_permutation = [BR] * EDGES.length

      (1...3).each do |j|
        k = b % (j + 1)
        b /= j + 1
        while k > 0
          k -= 1
          edge3 = rotateRight(edge3, 0, j)
        end
      end

      x = 2 # generate combination and set edges
      BR.downto(0).each do |j|
        nck = n_choose_k(j, x + 1)
        if a - nck >= 0
          edge_permutation[j] = edge3[x]
          a -= nck
          x -= 1
        end
      end
    end

    # TODO more ruby
    def urf_to_dlb
      perm = corner_permutation.dup
      b = 0
      # compute the index b < 8! for the permutation in perm
      7.downto(1).each do |j|
        k = 0
        while perm[j] != j
          perm = rotateLeft(perm, 0, j)
          k += 1
        end
        b = (j + 1) * b + k
      end

      b
    end

    # TODO more ruby
    def urf_to_dlb=(idx)
      perm = [URF, UFL, ULB, UBR, DFR, DLF, DBL, DRB]
      (1...8).each do |j|
        k = idx % (j + 1)
        idx /= j + 1
        while k > 0
          k -= 1
          perm = rotateRight(perm, 0, j)
        end
      end

      x = 7
      7.downto(0).each do |j|
        corner_permutation[j] = perm[x]
        x -= 1
      end
    end

    # TODO more ruby
    def ur_to_br
      perm = edge_permutation.dup
      b = 0
      11.downto(0).each do |j|
        k = 0
        while perm[j] != j
          perm = rotateLeft(perm, 0, j)
          k += 1
        end

        b = (j + 1) * b + k
      end

      b
    end

    # TODO more ruby
    def ur_to_br=(idx)
      perm = [UR, UF, UL, UB, DR, DF, DL, DB, FR, FL, BL, BR]
      (1...12).each do |j|
        k = idx % (j + 1)
        idx /= j + 1
        while k > 0
          k -= 1
          perm = rotateRight(perm, 0, j)
        end
      end

      # set edges
      x = 11
      11.downto(0).each do |j|
        edge_permutation[j] = perm[x]
        x -= 1
      end
    end

    # TODO more ruby
    def verify
    end

    private

    # https://stackoverflow.com/questions/37301649/faster-n-choose-k-for-combination-of-array-ruby
    def n_choose_k(n, k)
      return 0 if k > n
      result = 1
      1.upto(k) do |d|
        result *= n
        result /= d
        n -= 1
      end
      result
    end

    # Left rotation of all array elements between l and r
    # TODO RUBY!
    def rotateLeft(a, l, r)
      arr = a.dup
      temp = arr[l]
      (l...r).each do |i|
        arr[i] = arr[i + 1]
      end
      arr[r] = temp
      arr
    end

    # Right rotation of all array elements between l and r
    # TODO RUBY!
    def rotateRight(a, l, r)
      arr = a.dup
      temp = arr[r]
      r.downto(l + 1).each do |i|
        arr[i] = arr[i - 1]
      end
      arr[l] = temp
      arr
    end
  end
end
