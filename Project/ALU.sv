module ALU (
    input  logic [7:0] rs1, rs2,
    input  logic [2:0] opcode,
    output logic [7:0] rd,
    output logic is_zero
);
    assign is_zero = !(|rs1);
    logic [7:0] lut [0:7];
    always_comb begin
            lut[2] = rs1 + rs2; // 010
            lut[3] = rs1 & rs2; //011
            lut[4] = rs1 ^ rs2; //100
            rd = lut[opcode];
        end
    end
endmodule
