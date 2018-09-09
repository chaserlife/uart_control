module uart_rx(
    input       rst_n,
    input       mosi,
    input       clk,
    output      ok,
    output[7:0] data
);
reg[4:0] cnt,next_cnt;
reg      rx_ok,next_rx_ok;
reg[3:0] state,next_state;
reg[7:0] rx,next_rx;
assign data = rx;
assign ok  = rx_ok;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state <= 0;
        cnt   <= next_cnt;
        rx    <= 0;
        rx_ok <= 0;
    end
    else begin
        state <= next_state;
        rx_ok <= next_rx_ok;
        cnt   <= next_cnt;
        rx    <= next_rx;
    end
end
parameter idle     = 0;
parameter rec_data = 1;
parameter done     = 2;
parameter wait_dmy = 3;
always@(*)begin
    next_state = state;
    next_rx_ok = rx_ok;
    next_cnt   = cnt - |cnt;
    next_rx    = rx;
    case(state)
        idle:begin
            next_rx_ok = 1'b0;
            if(!mosi)begin
                next_state = rec_data;
                next_cnt   = 8;
            end
        end
        rec_data:begin
            if(|cnt)begin
                next_rx = {mosi,rx[7:1]};
            end
            else if(mosi)begin
                next_state = idle;
                next_rx_ok = 1'b1;
            end
            else begin//overtime
                next_state = wait_dmy;
                next_cnt   = 8;
            end
        end
        wait_dmy:begin
            if(|cnt) next_state = idle;
        end        
    endcase
end
endmodule
