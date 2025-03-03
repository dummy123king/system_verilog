class packet;
    bit[7:0] sa;
    bit[7:0] da;
    bit[31:0] len;
    bit[31:0] crc;
    bit[7:0] payload;
    bit[7:0] inp_stream[$];
    bit[7:0] outp_stream[$];
        
    function void pack(ref bit[7:0] q_inp[$]);
        q_inp = { << 8 {this.payload, this.crc, this.len, this.da, this.sa}};
    endfunction

    function void unpack(ref bit[7:0] q_inp[$]);
        { << 8 {this.payload, this.crc, this.len, this.da, this.sa}} = q_inp;
    endfunction

    function void print();
        $write("[Packet print] Sa=%d Da=%0d Len=%0d Crc=%d", sa, da, len, crc);
        $write("Payload");
        foreach(payload[i])
            $write(%0h, payload[i]);
        $display("\n");
    endfunction

endclass //packet