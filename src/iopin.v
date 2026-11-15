`default_nettype wire
`timescale 1ns / 1ps
module iopin (input clk, input rst_n
    ,input pin_in, output reg pin_out, output reg tri_out
    ,output pin_sampled

    ,input enable_in_pos
    ,input enable_in_neg

    ,input cmd_vld,input [9:0] global_time

    ,input [9:0] cmd_time
    ,input cmd_value
    ,input cmd_catch_change
    ,input cmd_catch_time
    ,input cmd_tri_now
    ,input cmd_tri_future
    ,input cmd_force_now
    ,input cmd_force_future


    ,output reg [11:0] event_data
    ,output reg event_vld
    ,input clear_event
);

wire catch_event;
wire pin_event;






synchronizer_level synch0 (.clk(clk),.rst_n(rst_n),.din(pin_in),.dout(pin_sampled));
reg was_sampled;
always @(posedge clk) begin
    was_sampled <= pin_sampled;
end
wire pos_event =  (!was_sampled && pin_sampled) && enable_in_pos;
wire neg_event =  (was_sampled && !pin_sampled) && enable_in_neg;
assign pin_event = pos_event || neg_event;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        event_data <= 0;
        event_vld  <= 0;
    end  else if (clear_event) begin
        event_data <= 0;
        event_vld  <= 0;
    end else if (pin_event || catch_event) begin
        event_data <= pin_event ? {global_time,pos_event,1'b0} : catch_event ? {global_time,was_sampled,1'b1} : 0;
        event_vld  <= 1;
    end
end

reg catch_in_time; reg [9:0] catch_time;
assign catch_event = catch_in_time && (catch_time == global_time);
reg [9:0] catch_delay;
reg catch_repeat;
wire cmd_repeat = 0; //for now
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        catch_in_time <= 0;
        catch_time <= 0;
        catch_delay <= 0;
        catch_repeat <= 0;
    end else begin
        if (cmd_vld && cmd_catch_time) begin
            catch_in_time <= 1;
            catch_time <= cmd_time;
            catch_repeat <= 0;
        end else if  (cmd_vld && cmd_catch_time && cmd_repeat) begin
            catch_in_time <= 1;
            catch_time <= cmd_time;
            catch_repeat <= 1;
            catch_delay <= cmd_time;
        end else if (catch_event) begin
            if (catch_repeat) begin
                catch_in_time <= 1;
                catch_time <= catch_delay;
            end else begin 
                catch_in_time <= 0;
            end
        end
    end
end

reg [9:0] backup_time;
reg backup_value ;
reg backup_catch_change ;
reg backup_catch_time ;
reg backup_tri_now ;
reg backup_tri_future ;
reg backup_force_now ;
reg backup_force_future ;

reg backup_command_armed;
reg armed;
reg future_value;
reg future_tri;
reg [9:0] future_time;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pin_out <= 0;
        tri_out <= 1;
        armed <= 0;
        future_value <= 0;
        future_tri <= 1;
        future_time <= 0;
        backup_command_armed <= 0;
        backup_value <= 0;
        backup_catch_change <= 0;
        backup_catch_time <= 0;
        backup_tri_now <= 0;
        backup_tri_future <= 0;
        backup_force_now <= 0;
        backup_force_future <= 0;
        backup_time <= 0;
    end else begin
        if (cmd_vld && cmd_force_now) begin
            pin_out <= cmd_value;
        end if (cmd_vld && cmd_tri_now && !armed) begin
            future_value <= 0;
            future_tri <= 1;
            future_time <=  cmd_time;
            armed <= 1;
        end else if (cmd_vld && cmd_force_future && !armed) begin
            future_value <= cmd_value;
            future_tri <= 0;
            future_time <=  cmd_time;
            armed <= 1;
        end else if (cmd_vld && cmd_tri_future && !armed) begin
            future_value <= 0;
            future_tri <= 1;
            future_time <=  cmd_time;
            armed <= 1;
        end else if (cmd_vld && armed) begin
            backup_command_armed <= 1;
            backup_value <= cmd_value;
            backup_catch_change <= cmd_catch_change;
            backup_catch_time <= cmd_catch_time;
            backup_tri_now <= cmd_tri_now;
            backup_tri_future <= cmd_tri_future;
            backup_force_now <= cmd_force_now;
            backup_force_future <= cmd_force_future;
            backup_time <= cmd_time;
        end            

        if (armed && (future_time == global_time)) begin
            pin_out <= future_value;
            tri_out <= future_tri;
            if (backup_command_armed) begin
                backup_command_armed <= 0;
                future_time <=  backup_time;
                if (backup_force_now) begin
                    pin_out <= cmd_value;
                    armed <= 0;
                end if (backup_tri_now) begin
                    future_value <= 0;
                    future_tri <= 1;
                    future_time <=  backup_time;
                    armed <= 0;
                end else if (backup_force_future) begin
                    future_value <= backup_value;
                    future_tri <= 0;
                    future_time <=  backup_time;
                    armed <= 1;
                end else if (backup_tri_future) begin
                    future_value <= 0;
                    future_tri <= 1;
                    future_time <=  backup_time;
                    armed <= 1;
                end else armed<=0;
            end else armed<=0;
        end
    end
end

wire panic0 = !clk && armed && backup_command_armed && cmd_vld;
wire dbg0 = (future_time == global_time);
wire dbg1 = armed && dbg0;



wire [63:0]  sign_version = 64'hc60c655e94151126 ;
endmodule
// FROMFILE c60c6 55e94 :: /Users/iliagreenblat/projects/fplp/verila/src/iopin.v


