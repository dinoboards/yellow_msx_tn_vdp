//  converted from vdp_vga.vhd
//   VGA up-scan converter.
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
// By using the line doubler, produces a signal at the VGA/DVI freequency of 31.5kHz

`include "vdp_constants.vh"

module VDP_VGA (
    input wire CLK21M,
    input wire RESET,
    input wire [5:0] VIDEORIN,
    input wire [5:0] VIDEOGIN,
    input wire [5:0] VIDEOBIN,
    input wire VIDEOVSIN_N,
    input wire [10:0] HCOUNTERIN,
    input wire [9:0] VCOUNTERIN,
    input wire PALMODE,
    input wire INTERLACEMODE,
    output wire [5:0] VIDEOROUT,
    output wire [5:0] VIDEOGOUT,
    output wire [5:0] VIDEOBOUT,
    input wire [2:0] RATIOMODE
);

  import custom_timings::*;

  // VIDEO OUTPUT ENABLE
  reg VIDEOOUTX;

  // DOUBLE BUFFER SIGNAL
  wire [9:0] XPOSITIONW;
  reg [9:0] XPOSITIONR;
  wire EVENODD;
  wire [5:0] DATAROUT;
  wire [5:0] DATAGOUT;
  wire [5:0] DATABOUT;

  assign VIDEOROUT = (VIDEOOUTX == 1'b1) ? DATAROUT : 0;
  assign VIDEOGOUT = (VIDEOOUTX == 1'b1) ? DATAGOUT : 0;
  assign VIDEOBOUT = (VIDEOOUTX == 1'b1) ? DATABOUT : 0;

  VDP_DOUBLEBUF DBUF (
      .CLK(CLK21M),
      .XPOSITIONW(XPOSITIONW),
      .XPOSITIONR(XPOSITIONR),
      .EVENODD(EVENODD),
      .WE(1),
      .DATARIN(VIDEORIN),
      .DATAGIN(VIDEOGIN),
      .DATABIN(VIDEOBIN),
      .DATAROUT(DATAROUT),
      .DATAGOUT(DATAGOUT),
      .DATABOUT(DATABOUT)
  );

  assign XPOSITIONW = HCOUNTERIN[10:1];
  assign EVENODD = VCOUNTERIN[1];

  // GENERATE DATA READ TIMING
  always_ff @(posedge RESET, posedge CLK21M) begin
    if (RESET) begin
      XPOSITIONR <= 0;
    end else begin
      if (((HCOUNTERIN == 0) || (HCOUNTERIN == (CLOCKS_PER_HALF_LINE(PALMODE))))) begin
        XPOSITIONR <= 0;
      end else begin
        XPOSITIONR <= 10'(XPOSITIONR + 1);
      end
    end
  end

  // GENERATE VIDEO OUTPUT TIMING
  always_ff @(posedge RESET, posedge CLK21M) begin
    if (RESET) begin
      VIDEOOUTX <= 1'b0;
    end else begin
      VIDEOOUTX <= 1'b1;
    end
  end

endmodule
