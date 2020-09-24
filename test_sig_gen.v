`timescale 1 ns / 1 ps

module test_sig_gen #
(
    input wire m_axis_aclk,
    input wire m_axis_aresetn,

    input wire [19:0] pinc,
    input wire [19:0] poff,
    input wire resync,
    input wire valid_in,

    // M_AXIS
    output wire [127:0] m_axis_tdata,
    output wire         m_axis_tvalid,
    input  wire         m_axis_tready
);

    reg [19:0] pinc_buf;
    reg [19:0] poff_buf;
    reg valid_in_buf;
    reg resync_buf;

    always @(posedge m_axis_aclk) begin
        if (~m_axis_aresetn) begin
            pinc_buf <= 20'b0;
            poff_buf <= 20'b0;
            valid_in_buf <= 1'b0;
            resync_buf <= 1'b0;
        end else begin
            pinc_buf <= pinc;
            pinc_buf <= poff;
            valid_in_buf <= valid_in;
            resync_buf <= resync;
        end
    end

    wire [19:0] pinc_x2 = {pinc_buf[18:0], 1'b0};
    wire [19:0] pinc_x3 = pinc_buf + pinc_x2;
    wire [19:0] pinc_x4 = {pinc_buf[17:0], 2'b0};

    wire [19:0] poff_0;
    wire [19:0] poff_1;
    wire [19:0] poff_2;
    wire [19:0] poff_3;

    // phase adder
    adder_phase add_0(
        .clk(m_axis_aclk),
        .a(poff_buf),
        .b(20'b0),
        .s(poff_0)
    );

    adder_phase add_1(
        .clk(m_axis_aclk),
        .a(poff_buf),
        .b(pinc_buf),
        .s(poff_1)
    );

    adder_phase add_2(
        .clk(m_axis_aclk),
        .a(poff_buf),
        .b(pinc_x2),
        .s(poff_2)
    );

    adder_phase add_3(
        .clk(m_axis_aclk),
        .a(poff_buf),
        .b(pinc_x3),
        .s(poff_3)
    );

    wire [31:0] dds_out_0;
    wire [31:0] dds_out_1;
    wire [31:0] dds_out_2;
    wire [31:0] dds_out_3;

    wire m_valid_0;
    wire m_valid_1;
    wire m_valid_2;
    wire m_valid_3;

    dds dds_inst_0(
        .aclk(m_axis_aclk),
        .s_axis_phase_tvalid(valid_in_buf),
        .s_axis_phase_tdata({resync_buf, 4'b0, poff_0, 4'b0, pinc_x4}),
        .m_axis_data_tvalid(m_valid_0),
        .m_axis_data_tdata(dds_out_0)
    );

    dds dds_inst_1(
        .aclk(m_axis_aclk),
        .s_axis_phase_tvalid(valid_in_buf),
        .s_axis_phase_tdata({resync_buf, 4'b0, poff_1, 4'b0, pinc_x4}),
        .m_axis_data_tvalid(m_valid_1),
        .m_axis_data_tdata(dds_out_1)
    );

    dds dds_inst_2(
        .aclk(m_axis_aclk),
        .s_axis_phase_tvalid(valid_in_buf),
        .s_axis_phase_tdata({resync_buf, 4'b0, poff_2, 4'b0, pinc_x4}),
        .m_axis_data_tvalid(m_valid_2),
        .m_axis_data_tdata(dds_out_2)
    );

    dds dds_inst_3(
        .aclk(m_axis_aclk),
        .s_axis_phase_tvalid(valid_in_buf),
        .s_axis_phase_tdata({resync_buf, 4'b0, poff_3, 4'b0, pinc_x4}),
        .m_axis_data_tvalid(m_valid_3),
        .m_axis_data_tdata(dds_out_3)
    );

    assign m_axis_tdata = {dds_out_3, dds_out_2, dds_out_1, dds_out_0};
    assign m_axis_tvalid = m_valid_0 & m_valid_1 & m_valid_2 & m_valid_3;

endmodule