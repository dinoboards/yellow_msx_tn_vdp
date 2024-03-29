`define DISPLAYED_PIXEL_WIDTH 720
`define DISPLAYED_PIXEL_HEIGHT PIXEL_HEIGHT(pal_mode)

module vdp_super_high_res (
    input bit reset,
    input bit clk,
    input bit vdp_super,
    input bit super_color,
    input bit super_mid,
    input bit super_res,
    input bit [10:0] cx,
    input bit [9:0] cy,
    input bit pal_mode,

    input bit [31:0] vrm_32,

    output bit [16:0] high_res_vram_addr,
    output bit [ 7:0] high_res_red,
    output bit [ 7:0] high_res_green,
    output bit [ 7:0] high_res_blue
);

  import custom_timings::*;

  bit super_high_res;
  bit [31:0] high_res_data;
  bit [31:0] next_rgb;
  bit super_high_res_visible_x;
  bit super_high_res_visible_y;
  bit last_line;
  bit active_line;  // true if line is drawn from sdram, false if drawn from line buffer

  bit [31:0] line_buffer[`MAX_PIXEL_WIDTH];
  bit [7:0] line_buffer_index;

  assign super_high_res = (vdp_super & super_color) | (vdp_super & super_mid);

  // pixel format for super_mid: GGGG GGRR RRRB BBBB
  // green <= data[15:10]; red <= data[9:5]; blue <= data[4:0]

  bit [15:0] high_mid_pixel;
  bit [ 5:0] high_mid_pixel_green;
  bit [ 4:0] high_mid_pixel_red;
  bit [ 4:0] high_mid_pixel_blue;

  assign high_mid_pixel = cx[1:0] == 2'b10 || cx[1:0] == 2'b01 ? high_res_data[15:0] : high_res_data[31:16];
  assign high_mid_pixel_green = high_mid_pixel[15:10];
  assign high_mid_pixel_red = high_mid_pixel[9:5];
  assign high_mid_pixel_blue = high_mid_pixel[4:0];

  assign high_res_red = super_color ? high_res_data[23:16] : {high_mid_pixel_red, 3'b0};
  assign high_res_green = super_color ? high_res_data[15:8] : {high_mid_pixel_green, 2'b0};
  assign high_res_blue = super_color ? high_res_data[7:0] : {high_mid_pixel_blue, 3'b0};

  assign super_high_res_visible = super_high_res_visible_x & super_high_res_visible_y;

  assign last_line = cy == (FRAME_HEIGHT(pal_mode) - 1);

  always_ff @(posedge reset or posedge clk) begin
    if (reset | ~super_high_res) begin
      super_high_res_visible_x <= 0;
    end else begin
      if (cx == FRAME_WIDTH(pal_mode) - 1) super_high_res_visible_x <= 1;
      else if (cx == `DISPLAYED_PIXEL_WIDTH - 1) super_high_res_visible_x <= 0;
    end
  end

  always_ff @(posedge reset or posedge clk) begin
    if (reset | ~super_high_res) begin
      super_high_res_visible_y <= 0;
    end else begin
      if (cx == (FRAME_WIDTH(pal_mode) - 1) && last_line) super_high_res_visible_y <= 1;
      else if (cy == (`DISPLAYED_PIXEL_HEIGHT - 1) && cx == (`DISPLAYED_PIXEL_WIDTH)) super_high_res_visible_y <= 0;
    end
  end

  assign active_line = (super_color && cy[1:0] == 2'b00) || (super_mid && cy[0] == 0);

  always_ff @(posedge reset or posedge clk) begin
    if (reset | ~super_high_res) begin
      high_res_vram_addr <= 0;
      next_rgb <= '{default: 0};
      high_res_data <= '{default: 0};
      line_buffer_index <= 0;

    end else begin
      case (cx)
        722: begin  //(AP)
          if (last_line) begin
            high_res_vram_addr <= 0;
          end
          line_buffer_index <= 0;
        end

        //723 (FS) read initiated
        //724 (DL) data loading

        725: begin  //(DR)
          if (last_line) begin
            next_rgb <= vrm_32;
            high_res_vram_addr <= 17'(high_res_vram_addr + 2);
          end
        end

        726: begin  //(AP)
        end

        default begin
          if (~super_high_res_visible) begin
            high_res_data <= {8'd0, 8'd0, 8'd255, 8'd0};

          end else begin
            case (cx[1:0])
              0: begin  // (DL)
                if (active_line) begin
                  line_buffer[line_buffer_index] <= next_rgb;
                  high_res_data <= next_rgb;

                end else begin
                  high_res_data <= line_buffer[line_buffer_index];
                end

                line_buffer_index <= 8'(line_buffer_index + 1);
              end

              1: begin  // (DR)
                if (active_line) begin
                  next_rgb <= vrm_32;
                  high_res_vram_addr <= 17'(high_res_vram_addr + 2);
                end
              end

              2: begin  // (AP)
              end

              3: begin  // (FS)
              end
            endcase
          end
        end
      endcase
    end
  end

endmodule
