// Section 1: Declaration of input/output ports
program testbench(input reg clk, router_interface router_if);
    // Section 2: TB Variables
    typedef struct {
        logic [7:0] sa;        // Source address
        logic [7:0] da;        // Destination address
        logic [31:0] len;      // Packet length
        logic [31:0] crc;      // CRC
        logic [7:0] payload[]; // Dynamic array for payload
    } packet;

    bit [7:0] inp_stream[$]; // Queue to hold the packed input stream
    bit [7:0] outp_stream[$]; // Queue to hold the packed output stream
    bit [31:0] pkt_count = 0;
    packet stimulus_pkt, q_inp[$], q_outp[$], dut_pkt; // Packets for stimulus and DUT output

    // Section 3: Methods (functions/tasks) definitions related to Verification Environment
    task apply_reset();
        $display("[TB Reset] Applying reset to DUT...");
        router_if.reset <= 1;
        repeat (2) @(router_if.cb);
        router_if.reset <= 0;
        $display("[TB Reset] Reset completed.");
    endtask

    // Function to print packet details
    function void print(input packet pkt);
        $display("[TB Packet] Sa = %0h Da = %0h Len = %0h Crc = %0h", pkt.sa, pkt.da, pkt.len, pkt.crc);
        foreach (pkt.payload[k])
            $display("[TB Packet] Payload[%0d] = %0h", k, pkt.payload[k]);
    endfunction

    // Function to generate random stimulus
    function automatic void generate_stimulus(ref packet pkt);
        pkt.sa = $urandom_range(1, 8); // Random source address
        pkt.da = $urandom_range(1, 8); // Random destination address
        pkt.payload = new[$urandom_range(2, 10)]; // Random payload size
        foreach (pkt.payload[i]) pkt.payload[i] = $urandom; // Fill payload with random values
        pkt.len = pkt.payload.size() + 4 + 4 + 1 + 1; // Total packet length
        pkt.crc = pkt.payload.sum(); // CRC is sum of payload bytes
        $display("[TB Generate] Packet generated: sa=%0h, da=%0h, len=%0d, crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.crc);
    endfunction

    // Function to pack the stimulus into a stream using streaming operator
    function automatic void pack(ref bit [7:0] q_inp[$], input packet pkt);
    // Pack sa, da, len, crc with explicit bit-widths
    q_inp = {<< 8{pkt.payload, pkt.crc, pkt.len, pkt.da, pkt.sa}};
    $display("[TB Pack] Stream packed with %0d bytes", q_inp.size());
    $display("[TB Pack] Stream packed with %p", q_inp);
    endfunction

    // Function to unpack the collected output stream into a packet
    function automatic void unpack(ref bit [7:0] stream_out[$], output packet pkt);
        {<< 8 {pkt.payload, pkt.crc, pkt.len, pkt.da, pkt.sa}} = stream_out;
        $display("[TB Unpack] Packet unpacked: sa=%0h, da=%0h, len=%0d, crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.crc);
        $display("[TB Unpack] Packet unpacked: %0p", pkt.payload);
    endfunction
    // Task to drive the stimulus into DUT
    task drive(const ref bit [7:0] inp_stream[$]);
        wait (router_if.cb.busy == 0); // Wait for DUT to be ready
        @(router_if.cb);
        $display("[TB Drive] Driving stream into DUT at time=%0t", $time);

        router_if.cb.inp_valid <= 1; // Assert inp_valid
        foreach (inp_stream[i]) begin
            router_if.cb.dut_inp <= inp_stream[i]; // Drive each byte of the stream
            @(router_if.cb);
        end
        router_if.cb.inp_valid <= 0; // De-assert inp_valid
        $display("[TB Drive] Stream driving completed at time=%0t", $time);
    endtask

    // Function to compare input packet and dut_pkt
    function bit compare(packet ref_pkt, packet dut_pkt);
        if(ref_pkt.sa != dut_pkt.sa) return 0;
        if(ref_pkt.da != dut_pkt.da) return 0;
        if(ref_pkt.len != dut_pkt.len) return 0;
        if(ref_pkt.crc != dut_pkt.crc) return 0;
        if(ref_pkt.payload != dut_pkt.payload) return 0;
        return 1; // Return 1 for success
    endfunction

    function void result();
        bit[31:0] matched, mis_matched;
        if(q_inp.size() == 0) begin
            $display("[TB Error] There are no Input packets in q_inp");
            $finish;
        end
        
        if(q_outp.size() == 0) begin
            $display("[TB Error] There are no Ouput packets in q_outp");
            $finish;
        end

        foreach(q_inp[i]) begin
            if(compare(q_inp[i], q_outp[i]))
                matched++;
            else begin
                mis_matched++;
                $display("[Error] Packet %0d MisMatched\n", i);
            end
        end
        
        if(mis_matched == 0 && matched == pkt_count) begin
            $display("\n\n******************************************************");
            $display("[INFO]****************** TEST PASSED *****************");
            $display("[INFO] Matched = %0d MisMatched=%0d", matched, mis_matched);
            $display("******************************************************");
        end
        else begin
            $display("\n\n******************************************************");
            $display("[INFO]*************** TEST FAILED ********************");
            $display("[INFO] Matched = %0d MisMatched=%0d", matched, mis_matched);
            $display("******************************************************");
        end
    endfunction

    // Section 6: Verification Flow
    initial begin
        for (int i = 0; i < 1; i++) begin
            apply_reset(); // Apply reset
            generate_stimulus(stimulus_pkt); // Generate a random packet
            pack(inp_stream, stimulus_pkt); // Pack the stimulus into a stream
            q_inp.push_back(stimulus_pkt);
            drive(inp_stream); // Drive the stream into DUT
            repeat(5) @(router_if.cb); // Wait for some clock cycles
            wait(router_if.cb.busy == 0); // Wait for DUT to finish processing
            repeat (10) @(router_if.cb); // Additional wait for observation
            inp_stream.delete();
            pkt_count++;
        end
        result();
        $finish; // End simulation
    end

    // Section 8: Collect DUT output
    initial begin
        forever begin
            @(posedge router_if.outp_valid); // Wait for start of packet
            $display("[TB Output] Start of packet detected at time=%0t", $time);
            while (router_if.outp_valid) begin
                @(router_if.cb); // Wait for the next clock edge
                if (router_if.dut_outp !== 'z) begin // Only collect valid data
                    outp_stream.push_back(router_if.dut_outp);
                    // $display("[TB Output] Collected byte: %0h at time=%0t", dut_outp, $time);
                end
            end
            $display("[TB Output] End of packet detected at time=%0t", $time);
            unpack(outp_stream, dut_pkt); // Unpack the collected output
            q_outp.push_back(dut_pkt);
            outp_stream.delete(); // Clear the output stream for the next packet
        end
    end

endprogram
