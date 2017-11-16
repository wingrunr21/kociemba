# frozen_string_literal: true

module Kociemba
  module MoveCube
    include Corner
    include Edge

    def self.[](i)
      MOVE_CUBES[i]
    end

    CPU = [UBR, URF, UFL, ULB, DFR, DLF, DBL, DRB]
    COU = [0, 0, 0, 0, 0, 0, 0, 0]
    EPU = [UB, UR, UF, UL, DR, DF, DL, DB, FR, FL, BL, BR]
    EOU = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    CPR = [DFR, UFL, ULB, URF, DRB, DLF, DBL, UBR]
    COR = [2, 0, 0, 1, 1, 0, 0, 2]
    EPR = [FR, UF, UL, UB, BR, DF, DL, DB, DR, FL, BL, UR]
    EOR = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    CPF = [UFL, DLF, ULB, UBR, URF, DFR, DBL, DRB]
    COF = [1, 2, 0, 0, 2, 1, 0, 0]
    EPF = [UR, FL, UL, UB, DR, FR, DL, DB, UF, DF, BL, BR]
    EOF = [0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0]

    CPD = [URF, UFL, ULB, UBR, DLF, DBL, DRB, DFR]
    COD = [0, 0, 0, 0, 0, 0, 0, 0]
    EPD = [UR, UF, UL, UB, DF, DL, DB, DR, FR, FL, BL, BR]
    EOD = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    CPL = [URF, ULB, DBL, UBR, DFR, UFL, DLF, DRB]
    COL = [0, 1, 2, 0, 0, 2, 1, 0]
    EPL = [UR, UF, BL, UB, DR, DF, FL, DB, FR, UL, DL, BR]
    EOL = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    CPB = [URF, UFL, UBR, DRB, DFR, DLF, ULB, DBL]
    COB = [0, 0, 1, 2, 0, 0, 2, 1]
    EPB = [UR, UF, UL, BR, DR, DF, DL, BL, FR, FL, UB, DB]
    EOB = [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1]

    MOVE_CUBES = [
      CubieCube.new(corner_permutation: CPU,
                    corner_orientation: COU,
                    edge_permutation: EPU,
                    edge_orientation: EOU),
      CubieCube.new(corner_permutation: CPR,
                    corner_orientation: COR,
                    edge_permutation: EPR,
                    edge_orientation: EOR),
      CubieCube.new(corner_permutation: CPF,
                    corner_orientation: COF,
                    edge_permutation: EPF,
                    edge_orientation: EOF),
      CubieCube.new(corner_permutation: CPD,
                    corner_orientation: COD,
                    edge_permutation: EPD,
                    edge_orientation: EOD),
      CubieCube.new(corner_permutation: CPL,
                    corner_orientation: COL,
                    edge_permutation: EPL,
                    edge_orientation: EOL),
      CubieCube.new(corner_permutation: CPB,
                    corner_orientation: COB,
                    edge_permutation: EPB,
                    edge_orientation: EOB),
    ]

    private_constant :MOVE_CUBES

  end
end
