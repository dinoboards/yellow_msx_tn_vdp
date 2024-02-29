// File src/vdp/vdp_ntsc_pal.vhd translated with vhd2vl 3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001-2023 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2023 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//
//  VDP_NTSC.vhd
//   VDP_NTSC sync signal generator.
//
//  Copyright (C) 2006 Kunihiko Ohnaka
//  All rights reserved.
//                                     http://www.ohnaka.jp/ese-vdp/
//
//  本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
//  満たす場合に限り、再頒布および使用が許可されます。
//
//  1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
//    免責条項をそのままの形で保持すること。
//  2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
//    著作権表示、本条件一覧、および下記免責条項を含めること。
//  3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
//    に使用しないこと。
//
//  本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
//  特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
//  的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
//  発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
//  その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
//  されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
//  ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
//  れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
//  たは結果損害について、一切責任を負わないものとします。
//
//  Note that above Japanese version license is the formal document.
//  The following translation is only for reference.
//
//  Redistribution and use of this software or any derivative works,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above
//     copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials
//     provided with the distribution.
//  3. Redistributions may not be sold, nor may they be used in a
//     commercial product or activity without specific prior written
//     permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//-----------------------------------------------------------------------------
// Memo
//   Japanese comment lines are starts with "JP:".
//   JP: 日本語のコメント行は JP:を頭に付ける事にする
//
//-----------------------------------------------------------------------------
// Revision History
//
// 13th,October,2003 created by Kunihiko Ohnaka
// JP: VDPのコアの実装と表示デバイスへの出力を別ソースにした．
//
// ??th,August,2006 modified by Kunihiko Ohnaka
//   - Move the equalization pulse generator from
//     vdp.vhd.
//
// 29th,October,2006 modified by Kunihiko Ohnaka
//   - Insert the license text.
//   - Add the document part below.
//
// 23rd,March,2008 modified by t.hara
// JP: リファクタリング, NTSC と PAL のタイミング生成回路を統合
//
//-----------------------------------------------------------------------------
// Document
//
// JP: ESE-VDPコア(vdp.vhd)が生成したビデオ信号を、NTSC/PALの
// JP: タイミングに合った同期信号および映像信号に変換します。
// JP: ESE-VDPコアはNTSCモード時は NTSC/PALのタイミングで映像
// JP: 信号や垂直同期信号を生成するため、本モジュールでは
// JP: 水平同期信号に等価パルスを挿入する処理だけを行って
// JP: います。
// Translation:
//   Converts the video signal generated by the ESE-VDP core (vdp.vhd) into
//   a sync signal and video signal that matches the timing of NTSC/PAL.
//   The ESE-VDP core generates video signals and vertical sync signals at
//   the timing of NTSC/PAL during NTSC mode, so this module only performs
//   the process of inserting equivalent pulses into the horizontal sync
//   signal.
// no timescale needed

module VDP_NTSC_PAL(
input wire CLK21M,
input wire RESET,
input wire PALMODE,
input wire INTERLACEMODE,
input wire [5:0] VIDEORIN,
input wire [5:0] VIDEOGIN,
input wire [5:0] VIDEOBIN,
input wire VIDEOVSIN_N,
input wire [10:0] HCOUNTERIN,
input wire [10:0] VCOUNTERIN,
output wire [5:0] VIDEOROUT,
output wire [5:0] VIDEOGOUT,
output wire [5:0] VIDEOBOUT,
output wire VIDEOHSOUT_N,
output wire VIDEOVSOUT_N
);

// MODE
// VIDEO INPUT
// VIDEO OUTPUT



parameter [1:0]
  SSTATE_A = 0,
  SSTATE_B = 1,
  SSTATE_C = 2,
  SSTATE_D = 3;

reg [1:0] FF_SSTATE;
reg FF_HSYNC_N;
wire [1:0] W_MODE;
reg [10:0] W_STATE_A1_FULL;
reg [10:0] W_STATE_A2_FULL;
reg [10:0] W_STATE_B_FULL;
reg [10:0] W_STATE_C_FULL;

  // MODE
  assign W_MODE = {PALMODE,INTERLACEMODE};
  always @(*) begin
    case(W_MODE)
      2'b00 : W_STATE_A1_FULL <= 11'b01000001100;
  // 524
      2'b01 : W_STATE_A1_FULL <= 11'b01000001101;
  // 525
      2'b10 : W_STATE_A1_FULL <= 11'b01001110010;
  // 626
      2'b11 : W_STATE_A1_FULL <= 11'b01001110001;
  // 625
      default : W_STATE_A1_FULL <= {11{1'bX}};
    endcase
  end

  always @(*) begin
    case(W_MODE)
      2'b00 : W_STATE_A2_FULL <= 11'b01000011000;
  // 524+12
      2'b01 : W_STATE_A2_FULL <= 11'b01000011001;
  // 525+12
      2'b10 : W_STATE_A2_FULL <= 11'b01001111110;
  // 626+12
      2'b11 : W_STATE_A2_FULL <= 11'b01001111101;
  // 625+12
      default : W_STATE_A2_FULL <= {11{1'bX}};
    endcase
  end

  always @(*) begin
    case(W_MODE)
      2'b00 : W_STATE_B_FULL <= 11'b01000010010;
  // 524+6
      2'b01 : W_STATE_B_FULL <= 11'b01000010011;
  // 525+6
      2'b10 : W_STATE_B_FULL <= 11'b01001111000;
  // 626+6
      2'b11 : W_STATE_B_FULL <= 11'b01001110111;
  // 625+6
      default : W_STATE_B_FULL <= {11{1'bX}};
    endcase
  end

  always @(*) begin
    case(W_MODE)
      2'b00 : W_STATE_C_FULL <= 11'b01000011110;
  // 524+18
      2'b01 : W_STATE_C_FULL <= 11'b01000011111;
  // 525+18
      2'b10 : W_STATE_C_FULL <= 11'b01010000100;
  // 626+18
      2'b11 : W_STATE_C_FULL <= 11'b01010000011;
  // 625+18
      default : W_STATE_C_FULL <= {11{1'bX}};
    endcase
  end

  // STATE
  always @(posedge RESET, posedge CLK21M) begin
    if((RESET == 1'b1)) begin
      FF_SSTATE <= SSTATE_A;
    end else begin
      if(((VCOUNTERIN == 0) || (VCOUNTERIN == 12) || (VCOUNTERIN == W_STATE_A1_FULL) || (VCOUNTERIN == W_STATE_A2_FULL))) begin
        FF_SSTATE <= SSTATE_A;
      end
      else if(((VCOUNTERIN == 6) || (VCOUNTERIN == W_STATE_B_FULL))) begin
        FF_SSTATE <= SSTATE_B;
      end
      else if(((VCOUNTERIN == 18) || (VCOUNTERIN == W_STATE_C_FULL))) begin
        FF_SSTATE <= SSTATE_C;
      end
    end
  end

  // GENERATE H SYNC PULSE
  always @(posedge RESET, posedge CLK21M) begin
    if((RESET == 1'b1)) begin
      FF_HSYNC_N <= 1'b0;
    end else begin
      if((FF_SSTATE == SSTATE_A)) begin
        if(((HCOUNTERIN == 1) || (HCOUNTERIN == (`CLOCKS_PER_HALF_LINE + 1)))) begin
          FF_HSYNC_N <= 1'b0;
          // PULSE ON
        end
        else if(((HCOUNTERIN == 51) || (HCOUNTERIN == (`CLOCKS_PER_HALF_LINE + 51)))) begin
          FF_HSYNC_N <= 1'b1;
          // PULSE OFF
        end
      end
      else if((FF_SSTATE == SSTATE_B)) begin
        if(((HCOUNTERIN == (`CLOCKS_PER_LINE - 100 + 1)) || (HCOUNTERIN == (`CLOCKS_PER_HALF_LINE - 100 + 1)))) begin
          FF_HSYNC_N <= 1'b0;
          // PULSE ON
        end
        else if(((HCOUNTERIN == 1) || (HCOUNTERIN == (`CLOCKS_PER_HALF_LINE + 1)))) begin
          FF_HSYNC_N <= 1'b1;
          // PULSE OFF
        end
      end
      else if((FF_SSTATE == SSTATE_C)) begin
        if((HCOUNTERIN == 1)) begin
          FF_HSYNC_N <= 1'b0;
          // PULSE ON
        end
        else if((HCOUNTERIN == 101)) begin
          FF_HSYNC_N <= 1'b1;
          // PULSE OFF
        end
      end
    end
  end

  assign VIDEOHSOUT_N = FF_HSYNC_N;
  assign VIDEOVSOUT_N = VIDEOVSIN_N;
  assign VIDEOROUT = VIDEORIN;
  assign VIDEOGOUT = VIDEOGIN;
  assign VIDEOBOUT = VIDEOBIN;

endmodule
