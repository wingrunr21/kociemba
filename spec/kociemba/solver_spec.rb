require 'benchmark'
require 'spec_helper'

describe Kociemba::Solver do
  subject(:solver) { described_class.new }

  SCRAMBLES = {
    'LBLBULBURUFBFRDURUDFBUFRRBLFUFDDUDFBFLRBLLRRUDRDLBDLDF' => "U R2 U2 F2 L2 B' R' D' R' U2 L D' F2 B2 U' L2 B2 R2 D' F2",
    'BUDRUDULDLFRLRLDRBLBFRFFUDLFLBBDFFDRRDBFLURRLFBUUBUDBU' => "U2 F' U2 L' U' B2 U B2 U2 R B' L2 D R2 B2 D' R2 U' B2 R2 D'",
    'BRFRUUDBUBFDLRLUBLLRRDFUDLLRDFUDLFDULFFDLRRBBRUDFBFBBU' => "U' R U2 R2 F2 R B2 U B2 D R2 B D2 B2 U' R2 U B2 L2 U B2",
    'RFBDUUFLFLLDLRBLRBUFURFBRDDDRFDDUBUUBFRDLBLLFLRDUBBRFU' => "D' B' L2 U2 R B D F' D2 F R' D' F2 U' R2 F2 D' F2 R2 L2 D2",
    'LDRBUULFRDFURRDLRRDDFLFBURUBFBUDUUUDFLBFLDLBRFRDBBLBLF' => "U2 L2 U2 L D F' D2 L' U2 F2 B' U2 L2 U R2 D L2 U2 D' R2 D",
    'UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB' => "R L U2 R L' B2 U2 R2 F2 L2 D2 L2 F2"
  }

  before do
    solver.reset
  end

  SCRAMBLES.each do |cube, solution|
    it "solves the cube represented by #{cube}" do
      result = solver.solve(cube)
      expect(result).to eq solution
    end
  end
end
