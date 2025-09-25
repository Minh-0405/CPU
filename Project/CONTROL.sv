module CONTROL (
        input logic [2:0] opcode,
        input logic clk, rst,
        input logic is_zero,
        output logic pc_load, pc_en, halt,
        output logic accumulator_load, accumulator_control,
        output logic memIns_en, memDa_en, memDa_we,
        output logic jmp
);
    typedef enum logic [3:0] {
        s0 = 4'b0000,
        s1 = 4'b0001, // fetch
        s2 = 4'b0010, // decode
        s3 = 4'b0100, // execute
        s4 = 4'b1000  // writeback
    } statetype_e;

    statetype_e state, nextstate;

    always_comb begin
    if (!halt) begin
        case (state)
            s0: nextstate = s1;
            s1: nextstate = s2;
            s2: nextstate = s3;
            s3: nextstate = s4;
            s4: nextstate = s1;
            default: nextstate = s0;
        endcase
    end else begin
        nextstate = state; // giữ nguyên khi halt
    end
end
    

    
    logic ACC_LOAD, ACC_MEM, STO, HALT, JMP, SKZ ;
    always_comb
    begin
        ACC_LOAD = (opcode == 2 | opcode == 3 | opcode == 4 | opcode == 5) ;
        ACC_MEM = (opcode == 5) ;
        STO = (opcode == 6) ;
        HALT = (opcode == 0) ;
        JMP = (opcode == 7) ;
        SKZ = (opcode == 2) ;
    end
    
    always_ff @(posedge clk or posedge rst) begin
    if (rst)
        state <= s0;      // reset về FETCH
    else
        state <= nextstate;
    end
    
    always_comb begin
    if (rst) begin
        pc_load = 0; pc_en = 0; halt = 0; jmp = 0;
        accumulator_control = 0; accumulator_load = 0;
        memIns_en = 0; memDa_en = 0; memDa_we = 0;
    end else begin
        case (state)
            s1: begin // FETCH
					 pc_load = (opcode === 3'bxxx) ? 0 : (JMP | (SKZ & is_zero));
                pc_en = 1; halt = 0; jmp = JMP;
                accumulator_control = 0; accumulator_load = 0;
                memIns_en = 1; memDa_en = 0; memDa_we = 0;
            end
            s2: begin // DECODE
                pc_load = 0; pc_en = 0; halt = 0; jmp = JMP;
                accumulator_control = 0; accumulator_load = 0;
                memIns_en = 0; memDa_en = 1; memDa_we = 0;
            end
            s3: begin // EXECUTE
                pc_load = 0; pc_en = 0; halt = HALT; jmp = JMP;
                accumulator_control = 0; accumulator_load = 0;
                memIns_en = 0; memDa_en = 0; memDa_we = 0;
            end
            s4: begin // WRITEBACK
                pc_load = 0; pc_en = 0; halt = HALT; jmp = JMP;
                pc_load = 0; pc_en = 0; halt = HALT; jmp = JMP;
                accumulator_control = ACC_MEM;
                accumulator_load = ACC_LOAD;
                memIns_en = 0; memDa_en = 1; memDa_we = STO;
            end
            default: begin
                pc_load = 0; pc_en = 0; halt = 0; jmp = 0;
                accumulator_control = 0; accumulator_load = 0;
                memIns_en = 0; memDa_en = 0; memDa_we = 0;
            end
        endcase
    end
end
endmodule
