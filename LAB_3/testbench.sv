module testbench;

// Section 1: Define variables for DUT port connections
reg clk, reset;
reg [7:0] dut_inp;
reg inp_valid;
wire [7:0] dut_outp;
wire outp_valid;
wire busy;
wire [3:0] error;

// Section 2: Router DUT instantiation
router_dut dut_inst (
    .clk(clk),
    .reset(reset),
    .dut_inp(dut_inp),
    .inp_valid(inp_valid),
    .dut_outp(dut_outp),
    .outp_valid(outp_valid),
    .busy(busy),
    .error(error)
);

// Section 3: Clock initialization and Generation
initial clk = 0;
always #5 clk = ~clk; // 10ns clock period

// Section 4: TB Variables declarations
typedef struct {
    logic [7:0] sa;        // Source address
    logic [7:0] da;        // Destination address
    logic [31:0] len;      // Packet length
    logic [31:0] crc;      // CRC
    logic [7:0] payload[]; // Dynamic array for payload
} packet;

bit [7:0] inp_stream[$]; // Queue to hold the packed input stream
bit [7:0] outp_stream[$]; // Queue to hold the packed output stream
packet stimulus_pkt, dut_pkt; // Packets for stimulus and DUT output

// Section 5: Methods (functions/tasks) definitions related to Verification Environment

task apply_reset();
    $display("[TB Reset] Applying reset to DUT...");
    reset <= 1;
    repeat (2) @(posedge clk);
    reset <= 0;
    $display("[TB Reset] Reset completed.");
endtask

// Function to generate random stimulus
function automatic void generate_stimulus(ref packet pkt);
    pkt.sa = 4; // Random source address
    pkt.da = 8; // Random destination address
    pkt.payload = new[$urandom_range(10, 20)]; // Random payload size
    foreach (pkt.payload[i]) pkt.payload[i] = $urandom; // Fill payload with random values
    pkt.len = pkt.payload.size() + 4 + 4 + 1 + 1; // Total packet length
    pkt.crc = pkt.payload.sum(); // CRC is sum of payload bytes
    $display("[TB Generate] Packet generated: sa=%0h, da=%0h, len=%0d, crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.crc);
endfunction

// Function to pack the stimulus into a stream using streaming operator
function automatic void pack(ref bit [7:0] q_imp[$], packet pkt);
    bit [7:0] temp_stream[$];
    // Pack sa, da, len, crc with explicit bit-widths
    temp_stream = {>>8{
        pkt.sa,         // 8 bits
        pkt.da,         // 8 bits
        pkt.len[31:24], // 8 bits (MSB of len)
        pkt.len[23:16], // 8 bits
        pkt.len[15:8],  // 8 bits
        pkt.len[7:0],   // 8 bits (LSB of len)
        pkt.crc[31:24], // 8 bits (MSB of crc)
        pkt.crc[23:16], // 8 bits
        pkt.crc[15:8],  // 8 bits
        pkt.crc[7:0]    // 8 bits (LSB of crc)
    }};
    // Append payload to the stream
    foreach (pkt.payload[i])
        temp_stream.push_back(pkt.payload[i]);

    // Assign the packed stream to the output queue
    q_imp = temp_stream;
    $display("[TB Pack] Stream packed with %0d bytes", q_imp.size());
endfunction

// Task to drive the stimulus into DUT
task drive(const ref bit [7:0] inp_stream[$]);
    wait (busy == 0); // Wait for DUT to be ready
    @(posedge clk);
    $display("[TB Drive] Driving stream into DUT at time=%0t", $time);

    inp_valid <= 1; // Assert inp_valid
    foreach (inp_stream[i]) begin
        dut_inp <= inp_stream[i]; // Drive each byte of the stream
        @(posedge clk);
    end
    inp_valid <= 0; // De-assert inp_valid
    $display("[TB Drive] Stream driving completed at time=%0t", $time);
endtask

// Function to unpack the collected output stream into a packet
function automatic void unpack(ref bit [7:0] q[$], output packet pkt);
    pkt.sa = q[0]; // Source address
    pkt.da = q[1]; // Destination address
    pkt.len = {q[2], q[3], q[4], q[5]}; // Packet length
    pkt.crc = {q[6], q[7], q[8], q[9]}; // CRC
    pkt.payload = new[pkt.len - 10]; // Allocate payload array
    for (int i = 10; i < q.size(); i++) begin
        pkt.payload[i - 10] = q[i]; // Fill payload
    end
    $display("[TB Unpack] Packet unpacked: sa=%0h, da=%0h, len=%0d, crc=%0d", pkt.sa, pkt.da, pkt.len, pkt.crc);
endfunction

// Function to print packet details
function void print(input packet pkt);
    $display("[TB Packet] Sa = %0h Da = %0h Len = %0h Crc = %0h", pkt.sa, pkt.da, pkt.len, pkt.crc);
    foreach (pkt.payload[k])
        $display("[TB Packet] Payload[%0d] = %0h", k, pkt.payload[k]);
endfunction

// Section 6: Verification Flow
initial begin
    apply_reset(); // Apply reset
    generate_stimulus(stimulus_pkt); // Generate a random packet
    print(stimulus_pkt); // Print packet details
    pack(inp_stream, stimulus_pkt); // Pack the stimulus into a stream
    drive(inp_stream); // Drive the stream into DUT
    repeat(5) @(posedge clk); // Wait for some clock cycles
    wait (busy == 0); // Wait for DUT to finish processing
    repeat (10) @(posedge clk); // Additional wait for observation
    $finish; // End simulation
end

// Section 7: Dumping Waveform
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
end

// Section 8: Collect DUT output
initial begin
    forever begin
        @(posedge outp_valid); // Wait for start of packet
        $display("[TB Output] Start of packet detected at time=%0t", $time);
        while (outp_valid) begin
            @(posedge clk); // Wait for the next clock edge
            if (dut_outp !== 'z) begin // Only collect valid data
                outp_stream.push_back(dut_outp);
                $display("[TB Output] Collected byte: %0h at time=%0t", dut_outp, $time);
            end
        end
        $display("[TB Output] End of packet detected at time=%0t", $time);
        unpack(outp_stream, dut_pkt); // Unpack the collected output
        outp_stream.delete(); // Clear the output stream for the next packet
    end
end

// Section 9: Error handling
always @(error) begin
    case (error)
        1: $display("[TB Error] Protocol Violation. Packet driven while Router is busy");
        2: $display("[TB Error] Packet Dropped due to CRC mismatch");
        3: $display("[TB Error] Packet Dropped due to Minimum packet size mismatch");
        4: $display("[TB Error] Packet Dropped due to Maximum packet size mismatch");
        5: begin
            $display("[TB Error] Packet Corrupted. Packet dropped due to packet length mismatch");
            $display("[TB Error] Step 1: Check value of len field of packet driven from TB");
            $display("[TB Error] Step 2: Check total number of bytes received in DUT in the waveform (Check dut_inp)");
            $display("[TB Error] Check value of Step 1 matching with Step 2 or not");
        end
    endcase
end

endmodule