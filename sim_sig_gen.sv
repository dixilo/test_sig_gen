`timescale 1ns / 1ps

module sim_accum();
    
    localparam STEP_SYS = 40;


    logic [19:0] pinc;
    logic [19:0] poff;
    logic        resync;
    logic        valid_in;

    // M_AXIS
    logic         m_axis_aclk;
    logic         m_axis_aresetn;
    logic [127:0] m_axis_tdata;
    logic         m_axis_tvalid;
    logic         m_axis_tready;

    test_sig_gen tsg_inst(.*);
    logic clk;
    assign m_axis_aclk = clk

    task clk_gen();
        clk = 0;
        forever #(STEP_SYS/2) clk = ~clk;
    endtask
    
    task rst_gen();
        pinc = 1;
        poff = 0;
        m_axis_tready = 1'b0;
        m_axis_aresetn = 1'b1;
        @(posedge clk);
        m_axis_aresetn = 1'b0;
        repeat(10) @(posedge clk);
        m_axis_aresetn = 1'b1;
        m_axis_tready = 1'b1
    endtask

    initial begin
        fork
            clk_gen();
            rst_gen();
        join_none
        repeat(100) @(posedge clk);
        $finish;
    end
endmodule
