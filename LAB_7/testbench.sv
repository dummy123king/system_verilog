program testbench(input reg clk, router_interface router_if);
    // Section 2: TB Variables
    typedef struct {
        logic [7:0] sa;
        logic [7:0] da;
        logic [31:0] len;
        logic [31:0] crc;
        logic [7:0] payload[];
    } packet;

    bit [7:0] inp_stream[$];
    bit [7:0] outp_stream[$];
    packet stimulus_pkt, dut_pkt;
    bit result;

    // Section 3: Apply Reset
    task apply_reset();
        $display("[TB Reset] Applying reset to DUT...");
        router_if.reset <= 1;
        repeat (2) @(posedge clk);
        router_if.reset <= 0;
        $display("[TB Reset] Reset completed.");
    endtask

    // Generate Stimulus
    function automatic void generate_stimulus(ref packet pkt);
        pkt.sa = 4;
        pkt.da = 8;
        pkt.payload = new[$urandom_range(10, 20)];
        foreach (pkt.payload[i]) pkt.payload[i] = $urandom;
        pkt.len = pkt.payload.size() + 10;
        pkt.crc = pkt.payload.sum();
        $display("[TB Generate] Packet generated: sa=%0h, da=%0h, len=%0d, crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.crc);
    endfunction

    // Pack Stream
    function automatic void pack(ref bit [7:0] q_imp[$], packet pkt);
        bit [7:0] temp_stream[$];
        temp_stream = {>>8{ pkt.sa, pkt.da, pkt.len[31:24], pkt.len[23:16], pkt.len[15:8], pkt.len[7:0], pkt.crc[31:24], pkt.crc[23:16], pkt.crc[15:8], pkt.crc[7:0] }};
        foreach (pkt.payload[i]) temp_stream.push_back(pkt.payload[i]);
        q_imp = temp_stream;
        $display("[TB Pack] Stream packed with %0d bytes", q_imp.size());
    endfunction

    // Drive Data into DUT
    task drive(const ref bit [7:0] inp_stream[$]);
        wait (router_if.busy == 0);
        @(posedge clk);
        $display("[TB Drive] Driving stream into DUT at time=%0t", $time);
        router_if.inp_valid <= 1;
        foreach (inp_stream[i]) begin
            router_if.dut_inp <= inp_stream[i];
            @(posedge clk);
        end
        router_if.inp_valid <= 0;
        $display("[TB Drive] Stream driving completed at time=%0t", $time);
    endtask

    // Unpack Data
    function automatic void unpack(ref bit [7:0] q[$], output packet pkt);
        pkt.sa = q[0];
        pkt.da = q[1];
        pkt.len = {q[2], q[3], q[4], q[5]};
        pkt.crc = {q[6], q[7], q[8], q[9]};
        pkt.payload = new[pkt.len - 10];
        for (int i = 10; i < q.size(); i++) pkt.payload[i - 10] = q[i];
        $display("[TB Unpack] Packet unpacked: sa=%0h, da=%0h, len=%0d, crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.crc);
    endfunction

    // Compare Streams
    function bit compare_streams(ref bit [7:0] inp_stream[$], ref bit [7:0] outp_stream[$]);
        if (inp_stream.size() != outp_stream.size()) begin
            $display("[TB Compare] Test Failed: Size mismatch.");
            return 0;
        end
        for (int i = 0; i < inp_stream.size(); i++) begin
            if (inp_stream[i] !== outp_stream[i]) begin
                $display("[TB Compare] Mismatch at byte %0d. Input: %0h, Output: %0h", i, inp_stream[i], outp_stream[i]);
                return 0;
            end
        end
        $display("[TB Compare] Test Passed.");
        return 1;
    endfunction

    // Section 4: Verification Flow
    initial begin
        apply_reset();
        generate_stimulus(stimulus_pkt);
        pack(inp_stream, stimulus_pkt);
        drive(inp_stream);
        repeat(5) @(posedge clk);
        wait (router_if.busy == 0);
        repeat (10) @(posedge clk);
        result = compare_streams(inp_stream, outp_stream);
        if (result == 1) begin
            $display("******************************************************");
            $display("****************** TEST PASSED ***********************");
            $display("******************************************************");
        end else begin
            $display("******************************************************");
            $display("****************** TEST FAILED ***********************");
            $display("******************************************************");
        end
        $finish;
    end

    // Section 5: Collect DUT Output
    initial begin
        forever begin
            @(posedge router_if.outp_valid);
            while (router_if.outp_valid) begin
                @(posedge clk);
                if (router_if.dut_outp !== 'z) outp_stream.push_back(router_if.dut_outp);
            end
            unpack(outp_stream, dut_pkt);
        end
    end
endprogram