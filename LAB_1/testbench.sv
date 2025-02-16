module testbench;

//Section 1: Define variables for DUT port connections
reg clk,reset;
reg [7:0] dut_inp;
reg inp_valid;
wire [7:0] dut_outp;
wire outp_valid;
wire busy;
wire [3:0] error;

//Section 2: Router DUT instantiation
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

	//Section 3: Clock initiliazation and Generation
	initial clk = 0;
	always #5 clk = ~clk; // 10ns clock period


	//Section 4: TB Variables declarations. 
	//Variables required for various testbench related activities . ex: stimulus generation,packing ....
	typedef struct {
	logic [7:0] sa;        // Source address
	logic [7:0] da;        // Destination address
	logic [31:0] len;      // Packet length
	logic [31:0] crc;      // CRC
	logic [7:0] payload[]; // Dynamic array for payload
	} packet;

	//Section 5: Methods (functions/tasks) definitions related to Verification Environment 

	task apply_reset();
		$display("[TB Reset] Applying reset to DUT...");
		reset <= 1;
		repeat (2) @(posedge clk);
		reset <= 0;
		$display("[TB Reset] Reset completed.");
	endtask

	// Section 5: Methods (generate_stimulus)
	function automatic void generate_stimulus(ref packet pkt);
		pkt.sa = $random; // Random source address
		pkt.da = $random; // Random destination address
		pkt.payload = new[10]; // Random payload size
		foreach (pkt.payload[i]) pkt.payload[i] = $random;
		// $display("---------------------->>>pkt.payload size = %0d", pkt.payload.size());
		pkt.len = 10 + pkt.payload.size(); // Total packet length
		// $display("---------------------->>>pkt.payload size = %0d", pkt.len);
		pkt.crc = pkt.payload.sum(); // CRC is sum of payload bytes
		// $display("---------------------->>>pkt.payload size = %0d", pkt.len);
		// print(pkt);
	endfunction

	// Section 5: Methods (drive)
	task drive(input packet pkt);
		wait (busy == 0);		// Wait for DUT to be ready
		@(posedge clk);
		$display("[TB Drive] Driving of packet started at time=%0t",$time);

		inp_valid <= 1; // Start of packet
		dut_inp <= pkt.sa;
		@(posedge clk);
		dut_inp <= pkt.da;
		@(posedge clk);
		dut_inp <= pkt.len[31:24];
		@(posedge clk);
		dut_inp <= pkt.len[23:16];
		@(posedge clk);
		dut_inp <= pkt.len[15:8];
		@(posedge clk);
		dut_inp <= pkt.len[7:0];
		@(posedge clk);
		dut_inp <= pkt.crc[31:24];
		@(posedge clk);
		dut_inp <= pkt.crc[23:16];
		@(posedge clk);
		dut_inp <= pkt.crc[15:8];
		@(posedge clk);
		dut_inp <= pkt.crc[7:0];
		// Send data to DUT
		foreach (pkt.payload[i]) begin
			@(posedge clk);
			dut_inp <= pkt.payload[i];
		end
		@(posedge clk);
		inp_valid <= 0; // End of packet
	endtask

	function void print(input packet pkt);
		$display("[TB Packet] Sa = %0h Da = %0h Len = %0h Crc = %0h", pkt.sa, pkt.da, pkt.len, pkt.crc);
		foreach(pkt.payload[k])
			$display("[TB Packet] Payload[%0d] = %0h", k, pkt.payload[k]);
	endfunction
	//--------End of Section 5 ----------------  

	//Section 6: Verification Flow
	packet stimulus_pkt;
	initial begin
		apply_reset(); // Apply reset
		generate_stimulus(stimulus_pkt); // Generate a random packet
		print(stimulus_pkt);
		drive(stimulus_pkt); // Drive packet into DUT
		repeat(5) @(posedge clk);
		wait (busy == 0); // Wait for DUT to finish processing
		repeat (10) @(posedge clk);
		$finish;
	end
	//Wait for dut to process the packet and to drive on output
	//--------End of Section 6 ---------------- 

	//Section 7: Dumping Waveform
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, testbench);
	end

	//--------End of Section 7 ---------------- 

	//Section 8: Collect DUT output
	always @(posedge clk) begin
		if (outp_valid) begin
			$display("[TB Output] DUT output valid. Data: %0h", dut_outp);
		end
	end
	//--------End of Section 8---------------- 

	always@(error) begin
		case(error)
			1:$display("[TB Error] Protocol Violation. Packet driven while Router is busy");
			2:$display("[TB Error] Packet Dropped due to CRC mismatch");
			3:$display("[TB Error] Packet Dropped due to Minimum packet size mismatch");
			4:$display("[TB Error] Packet Dropped due to Maximum packet size mismatch");
			5:begin
				$display("[TB Error] Packet Corrupted.Packet dropped due to packet length mismatch");
				$display("[TB Error] Step 1: Check value of len filed of packet driven from TB");
				$display("[TB Error] Step 2: Check total number of bytes received in DUT in the waveform (Check dut_inp)");
				$display("[TB Error] Check value of Step 1 matching with Step 2 or not");
			end
		endcase
	end
	endmodule
