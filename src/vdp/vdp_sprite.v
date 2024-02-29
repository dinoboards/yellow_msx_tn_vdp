// File src/vdp/vdp_sprite.vhd translated with vhd2vl 3.0 VHDL to Verilog RTL translator
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
//  vdp_sprite.vhd
//    Sprite module.
//
//  Copyright (C) 2004-2006 Kunihiko Ohnaka
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
//---------------------------------------------------------------------------
// Memo
//   Japanese comment lines are starts with "JP:".
//   JP: 日本語のコメント行は JP:を頭に付ける事にする
//
//---------------------------------------------------------------------------
// Revision History
//
// 29th,October,2006 modified by Kunihiko Ohnaka
//   - Insert the license text.
//   - Add the document part below.
//
// 26th,August,2006 modified by Kunihiko Ohnaka
//   - latch the base addresses every eight dot cycle
//     (DRAM RAS/CAS access emulation)
//
// 20th,August,2006 modified by Kunihiko Ohnaka
//   - Change the drawing algorithm.
//   - Add sprite collision checking function.
//   - Add sprite over-mapped checking function.
//   - Many bugs are fixed, and it works fine.
//   - (first release virsion)
//
// 17th,August,2004 created by Kunihiko Ohnaka
//   - Start new sprite module implementing.
//     * This module uses Block RAMs so that shrink the
//       circuit size.
//     * Separate sprite module from vdp.vhd.
//
//---------------------------------------------------------------------------
// Document
//
// JP: この実装ではBLOCKRAMを使い、消費するSLICEを節約するのが狙い。
// JP: この実装を使わない状態での vdp.vhdをコンパイルした時の
// JP: SLICE使用数は1900前後。
// JP: 2006/8/16。このスプライトを使わない最新版(Cyclone)では、
// JP:            2726LCだった.
// JP: 2006/8/19。このスプライトを使ったところ、2278LCまで減少。
// JP:
// JP: [用語]
// JP: ・ローカルプレーン番号
// JP:   あるライン上に並んでいるスプライト(プレーン)だけを抜き出して
// JP:   スプライトプレーン番号順に並べた時の順位。
// JP:   例えばあるラインにスプライトプレーン#1,#4,#5が存在する場合、
// JP:   それぞれのスプライトのローカルプレーン番号は#0,#1,#2となる。
// JP:   スプライトモード2でも横一列に最大8枚しか並ばないので、
// JP:   ローカルプレーン番号は最大で#7となる。
// JP:
// JP: ・画面描画帯域
// JP:    VDPの実機は8ドット(32クロック)で連続アドレス上のデータ4バイト
// JP:    (GRAPHIC6,7ではRAMのインターリーブアクセスによりバイト)
// JP:    のリードに加え、ランダムアドレスへの2サイクル(2バイト)の
// JP:    アクセスが加納
// JP:    それらのDRAMアクセスサイクルに以下のように名前を付ける。
// JP:     * 画面描画リードサイクル
// JP:     * スプライトY座標検査サイクル
// JP:     * ランダムアクセスサイクル
// JP:
// JP: ○似非VDPでのVRAMアクセスサイクル
// JP:    似非VDPでは旧式のDRAMではなくより高速なメモリを使用している。
// JP:    そのため、４クロックに1回確実にランダムアクセスを実行できる
// JP:    メモリを持っている事を前提としてコーディングします。
// JP:    また、Cyclone版似非MSXでは、16ビット幅のSDRAMを用いている
// JP:    ため、一回のアクセスで連続する16ビットのデータを読む事も可能
// JP:    です。
// JP:    似非VDPでは、D0～D7の下位8ビットをVRAMの前半64Kバイト、
// JP:    D8～D15の上位8ビットを後半64Kバイトにマッピングしています。
// JP:    このような変則的な割り当てをするのは、実機のVDPのメモリ
// JP:    マップをまねるためです。実際、4クロックで2バイトのメモリを
// JP:    読み出す帯域が必要になるのはGRAPHIC6,7のモードだけです。
// JP:    実機のVDPは、GRAPHIC6,7ではメモリのインターリーブを用い、
// JP:    (GRAPHIC7における)偶数ドットをVRAMの前半64Kバイトに
// JP:    わりあて、奇数ドットを後半64Kバイトに割り当てています。
// JP:    そのため、似非VDPでも前半64Kと後半64Kの同一アドレス上の
// JP:    データを１サイクル(4クロック)で読み出せる必要があるので
// JP:    このようなマッピングになっています。
// JP:    単純に言えば、SDRAMの16ビットアクセスを、実機のDRAMの
// JP:    インターリーブアクセスに見立てているということです。
// JP:
// JP:    いろいろな現象から、VDPの内部は8ドットサイクルで動いていると
// JP:    推測されています。8ドット、つまり32クロックのどうさをメモリ
// JP:    の帯域から推測すると、以下のようになります。
// JP:
// JP:   　　ドット　：<=0=><=1=><=2=><=3=><=4=><=5=><=6=><=7=>
// JP:   通常アクセス： A0   A1   A2   A3   A4  (A5)  A6  (A7)
// JP: インターリーブ： B0   B1   B2   B3
// JP:
// JP:    - 描画中
// JP:   　　・A0～A3 (B0～B3)
// JP:        画面描画のために使用。B0～B3はインターリーブで同時に
// JP:        読み出せるデータで、GRAPHIC6,7でしか使わない。
// JP:   　　・A4     スプライトY座標検査
// JP:   　　・A6     VRAM R/W or VDPコマンド (2回に一回ずつ、交互に割り当てる)
// JP:
// JP:     - 非描画中(スプライト準備中)
// JP:    　　・A0     スプライトX座標リード
// JP:    　　・A1     スプライトパターン番号リード
// JP:    　　・A2     スプライトパターン左リード
// JP:    　　・A3     スプライトパターン右リード
// JP:    　　・A4     スプライトカラーリード
// JP:    　　・A6     VRAM R/W or VDPコマンド (2回に一回ずつ、交互に割り当てる)
// JP:
// JP:   A5とA7のスロットは実際には使用することもできるのですが、
// JP:   これを使ってしまうと実機よりも帯域が増えてしまうので、
// JP:   あえて使わずに残しています。
// JP:   また、非描画中のサイクルは、実機とは異なります。実機では
// JP:   64クロックで 2つのスプライトをまとめて処理する事で、DRAMの
// JP:   ページモードサイクルを有効利用できるようにしています。
// JP:   また、その64クロックの中にはVRAMやVDPコマンドに割くための
// JP:   スロットが無いので、64クロックサイクルの隙間にVRAMアク
// JP:   セスのための隙間を空けているのかもしれません。（未確認）
// JP:   似非VDPでもその動作を完全に真似する事は可能ですが、
// JP:   ソースが必要以上に複雑に見えてしまうのと、2のn乗サイクル
// JP:   からずれてしまうのがちょっぴり嫌だったので、上記のような
// JP:   きれいなサイクルにしています。
// JP:   どうしても実機と同じタイミングにしたいという方は
// JP:   チャレンジしてみてください。
// JP:
//
// no timescale needed

module VDP_SPRITE (
    input wire CLK21M,
    input wire RESET,
    input wire [1:0] DOTSTATE,
    input wire [2:0] EIGHTDOTSTATE,
    input wire [8:0] DOTCOUNTERX,
    input wire [8:0] DOTCOUNTERYP,
    input wire BWINDOW_Y,
    output reg PVDPS0SPCOLLISIONINCIDENCE,
    output wire PVDPS0SPOVERMAPPED,
    output wire [4:0] PVDPS0SPOVERMAPPEDNUM,
    output reg [8:0] PVDPS3S4SPCOLLISIONX,
    output reg [8:0] PVDPS5S6SPCOLLISIONY,
    input wire PVDPS0RESETREQ,
    output wire PVDPS0RESETACK,
    input wire PVDPS5RESETREQ,
    output wire PVDPS5RESETACK,
    input wire REG_R1_SP_SIZE,
    input wire REG_R1_SP_ZOOM,
    input wire [9:0] REG_R11R5_SP_ATR_ADDR,
    input wire [5:0] REG_R6_SP_GEN_ADDR,
    input wire REG_R8_COL0_ON,
    input wire REG_R8_SP_OFF,
    input wire [7:0] REG_R23_VSTART_LINE,
    input wire [2:0] REG_R27_H_SCROLL,
    input wire SPMODE2,
    input wire VRAMINTERLEAVEMODE,
    output reg SPVRAMACCESSING,
    input wire [7:0] PRAMDAT,
    output wire [16:0] PRAMADR,
    output reg SPCOLOROUT,
    output reg [3:0] SPCOLORCODE,
    input wire REG_R9_Y_DOTS,
    input wire SPMAXSPR
);

  // VDP CLOCK ... 21.477MHZ
  // VDP STATUS REGISTERS OF SPRITE
  // VDP REGISTERS
  // JP: スプライトを描画した時に'1'になる。カラーコード0で
  // JP: 描画する事もできるので、このビットが必要
  // OUTPUT COLOR



  reg FF_SP_EN;
  reg [8:0] FF_CUR_Y;
  reg [8:0] FF_PREV_CUR_Y;
  wire SPLIT_SCRN;
  reg FF_VDPS0RESETACK;
  reg FF_VDPS5RESETACK;  // FOR SPINFORAM
  wire [2:0] SPINFORAMADDR;
  reg SPINFORAMWE;
  wire [31:0] SPINFORAMDATA_IN;
  wire [31:0] SPINFORAMDATA_OUT;
  reg [8:0] SPINFORAMX_IN;
  reg [15:0] SPINFORAMPATTERN_IN;
  reg [3:0] SPINFORAMCOLOR_IN;
  reg SPINFORAMCC_IN;
  reg SPINFORAMIC_IN;
  wire [8:0] SPINFORAMX_OUT;
  wire [15:0] SPINFORAMPATTERN_OUT;
  wire [3:0] SPINFORAMCOLOR_OUT;
  wire SPINFORAMCC_OUT;
  wire SPINFORAMIC_OUT;
  parameter [1:0] SPSTATE_IDLE = 0, SPSTATE_YTEST_DRAW = 1, SPSTATE_PREPARE = 2;

  reg [1:0] SPSTATE;  // JP: スプライトプレーン番号×横方向表示枚数の配列

  reg [4:0] SPRENDERPLANES[0:7];
  wire [16:0] IRAMADR;
  reg [16:0] FF_Y_TEST_VRAM_ADDR;
  reg [16:0] IRAMADRPREPARE;
  reg [10-1:0] SPATTRTBLBASEADDR;
  reg [10-1:0] SPPTNGENETBLBASEADDR;
  wire [16:2] SPATTRIB_ADDR;
  wire [16:0] READVRAMADDRCREAD;
  wire [16:0] READVRAMADDRPTREAD;  // JP: Y座標検査中のプレーン番号
  reg [4:0] FF_Y_TEST_SP_NUM;
  reg [3:0] FF_Y_TEST_LISTUP_ADDR;  // 0 - 8
  reg FF_Y_TEST_EN;  // JP: 下書きデータ準備中のローカルプレーン番号
  reg [2:0] SPPREPARELOCALPLANENUM;  // JP: 下書きデータ準備中のプレーン番号
  reg [4:0] SPPREPAREPLANENUM;  // JP: 下書きデータ準備中のスプライトのYライン番号(スプライトのどの部分を描画するか)
  reg [3:0] SPPREPARELINENUM;  // JP: 下書きデータ準備中のスプライトのX位置。0の時左8ドット。1の時右8ドット。(16X16モードのみで使用)
  wire SPPREPAREXPOS;
  reg [7:0] SPPREPAREPATTERNNUM;  // JP: 下書データの準備が終了した
  reg SPPREPAREEND;
  wire SPCCD;  // JP: 下書きをしているスプライトのローカルプレーン番号
  reg [2:0] SPPREDRAWLOCALPLANENUM;  // 0 - 7
  reg SPPREDRAWEND;  // JP: ラインバッファへの描画用
  reg [8:0] SPDRAWX;  // -32 - 287 (=256+31)
  reg [15:0] SPDRAWPATTERN;
  reg [3:0] SPDRAWCOLOR;  // JP: スプライト描画ラインバッファの制御信号
  wire [7:0] SPLINEBUFADDR_E;
  wire [7:0] SPLINEBUFADDR_O;
  wire SPLINEBUFWE_E;
  wire SPLINEBUFWE_O;
  wire [7:0] SPLINEBUFDATA_IN_E;
  wire [7:0] SPLINEBUFDATA_IN_O;
  wire [7:0] SPLINEBUFDATA_OUT_E;
  wire [7:0] SPLINEBUFDATA_OUT_O;
  reg SPLINEBUFDISPWE;
  reg SPLINEBUFDRAWWE;
  reg [7:0] SPLINEBUFDISPX;
  reg [7:0] SPLINEBUFDRAWX;
  reg [7:0] SPLINEBUFDRAWCOLOR;
  wire [7:0] SPLINEBUFDISPDATA_OUT;
  wire [7:0] SPLINEBUFDRAWDATA_OUT;
  reg SPWINDOWX;
  reg FF_SP_OVERMAP;
  reg [4:0] FF_SP_OVERMAP_NUM;
  wire [7:0] W_SPLISTUPY;
  wire W_TARGET_SP_EN;
  wire W_SP_OFF;
  wire W_SP_OVERMAP;
  wire W_ACTIVE;
  reg SPWINDOW_Y;

  assign PVDPS0RESETACK = FF_VDPS0RESETACK;
  assign PVDPS5RESETACK = FF_VDPS5RESETACK;
  assign PVDPS0SPOVERMAPPED = FF_SP_OVERMAP;
  assign PVDPS0SPOVERMAPPEDNUM = FF_SP_OVERMAP_NUM;
  //---------------------------------------------------------------------------
  // スプライトを表示するか否かを示す信号
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_SP_EN <= 1'b0;
    end else begin
      if ((DOTSTATE == 2'b01 && DOTCOUNTERX == 0)) begin
        FF_SP_EN <= (~REG_R8_SP_OFF) & W_ACTIVE;
      end
    end
  end

  //---------------------------------------------------------------------------
  // SPRITE INFORMATION ARRAY
  // 実際に表示するスプライトの情報を集めて記録しておくRAM
  //---------------------------------------------------------------------------
  VDP_SPINFORAM ISPINFORAM (
      .ADDRESS(SPINFORAMADDR),
      .INCLOCK(CLK21M),
      .WE(SPINFORAMWE),
      .DATA(SPINFORAMDATA_IN),
      .Q(SPINFORAMDATA_OUT)
  );

  assign SPINFORAMDATA_IN = {
    1'b0, SPINFORAMX_IN, SPINFORAMPATTERN_IN, SPINFORAMCOLOR_IN, SPINFORAMCC_IN, SPINFORAMIC_IN
  };
  assign SPINFORAMX_OUT = SPINFORAMDATA_OUT[30:22];
  assign SPINFORAMPATTERN_OUT = SPINFORAMDATA_OUT[21:6];
  assign SPINFORAMCOLOR_OUT = SPINFORAMDATA_OUT[5:2];
  assign SPINFORAMCC_OUT = SPINFORAMDATA_OUT[1];
  assign SPINFORAMIC_OUT = SPINFORAMDATA_OUT[0];
  assign SPINFORAMADDR = (SPSTATE == SPSTATE_PREPARE) ? SPPREPARELOCALPLANENUM : SPPREDRAWLOCALPLANENUM;
  //---------------------------------------------------------------------------
  // SPRITE LINE BUFFER
  //---------------------------------------------------------------------------
  assign SPLINEBUFADDR_E = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDISPX : SPLINEBUFDRAWX;
  assign SPLINEBUFDATA_IN_E = (DOTCOUNTERYP[0] == 1'b0) ? 8'b00000000 : SPLINEBUFDRAWCOLOR;
  assign SPLINEBUFWE_E = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDISPWE : SPLINEBUFDRAWWE;
  assign SPLINEBUFDISPDATA_OUT = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDATA_OUT_E : SPLINEBUFDATA_OUT_O;
  RAM U_EVEN_LINE_BUF (
      .ADR(SPLINEBUFADDR_E),
      .CLK(CLK21M),
      .WE (SPLINEBUFWE_E),
      .DBO(SPLINEBUFDATA_IN_E),
      .DBI(SPLINEBUFDATA_OUT_E)
  );

  assign SPLINEBUFADDR_O = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDRAWX : SPLINEBUFDISPX;
  assign SPLINEBUFDATA_IN_O = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDRAWCOLOR : 8'b00000000;
  assign SPLINEBUFWE_O = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDRAWWE : SPLINEBUFDISPWE;
  assign SPLINEBUFDRAWDATA_OUT = (DOTCOUNTERYP[0] == 1'b0) ? SPLINEBUFDATA_OUT_O : SPLINEBUFDATA_OUT_E;
  RAM U_ODD_LINE_BUF (
      .ADR(SPLINEBUFADDR_O),
      .CLK(CLK21M),
      .WE (SPLINEBUFWE_O),
      .DBO(SPLINEBUFDATA_IN_O),
      .DBI(SPLINEBUFDATA_OUT_O)
  );

  //---------------------------------------------------------------------------
  assign SPPREPAREXPOS = (EIGHTDOTSTATE == 3'b100) ? 1'b1 : 1'b0;
  // JP: VRAMアクセスアドレスの出力
  assign IRAMADR = (SPSTATE == SPSTATE_YTEST_DRAW) ? FF_Y_TEST_VRAM_ADDR : IRAMADRPREPARE;
  assign PRAMADR = (VRAMINTERLEAVEMODE == 1'b0) ? IRAMADR[16:0] : {IRAMADR[0], IRAMADR[16:1]};
  //---------------------------------------------------------------------------
  // STATE MACHINE
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPSTATE <= SPSTATE_IDLE;
    end else begin
      if ((DOTSTATE == 2'b10)) begin
        case (SPSTATE)
          SPSTATE_IDLE: begin
            if ((DOTCOUNTERX == 0)) begin
              SPSTATE <= SPSTATE_YTEST_DRAW;
            end
          end
          SPSTATE_YTEST_DRAW: begin
            if ((DOTCOUNTERX == (256 + 8))) begin
              SPSTATE <= SPSTATE_PREPARE;
            end
          end
          SPSTATE_PREPARE: begin
            if ((SPPREPAREEND == 1'b1)) begin
              SPSTATE <= SPSTATE_IDLE;
            end
          end
          default: begin
            SPSTATE <= SPSTATE_IDLE;
          end
        endcase
      end
    end
  end

  //---------------------------------------------------------------------------
  // 現ラインのライン番号
  //---------------------------------------------------------------------------
  always @(posedge CLK21M) begin
    if (((DOTSTATE == 2'b01) && (DOTCOUNTERX == 0))) begin
      //   +1 SHOULD BE NEEDED. BECAUSE IT WILL BE DRAWN IN THE NEXT LINE.
      FF_CUR_Y <= DOTCOUNTERYP + ({1'b0, REG_R23_VSTART_LINE}) + 1;
    end
  end

  always @(posedge CLK21M) begin
    if (((DOTSTATE == 2'b01) && (DOTCOUNTERX == 0))) begin
      FF_PREV_CUR_Y <= FF_CUR_Y;
    end
  end

  // detect a split screen
  assign SPLIT_SCRN = (FF_CUR_Y == (FF_PREV_CUR_Y + 1)) ? 1'b0 : 1'b1;
  //---------------------------------------------------------------------------
  // VRAM ADDRESS GENERATOR
  //---------------------------------------------------------------------------
  always @(posedge CLK21M) begin
    // LATCHING ADDRESS SIGNALS
    if (((DOTSTATE == 2'b01) && (DOTCOUNTERX == 0))) begin
      SPPTNGENETBLBASEADDR <= REG_R6_SP_GEN_ADDR;
      if ((SPMODE2 == 1'b0)) begin
        SPATTRTBLBASEADDR <= REG_R11R5_SP_ATR_ADDR[9:0];
      end else begin
        SPATTRTBLBASEADDR <= {REG_R11R5_SP_ATR_ADDR[9:2], 2'b00};
      end
    end
  end

  //---------------------------------------------------------------------------
  // VRAM ACCESS MASK
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPVRAMACCESSING <= 1'b0;
    end else begin
      if ((DOTSTATE == 2'b10)) begin
        case (SPSTATE)
          SPSTATE_IDLE: begin
            if ((DOTCOUNTERX == 0)) begin
              SPVRAMACCESSING <= (~REG_R8_SP_OFF) & W_ACTIVE;
            end
          end
          SPSTATE_YTEST_DRAW: begin
            if ((DOTCOUNTERX == (256 + 8))) begin
              SPVRAMACCESSING <= FF_SP_EN;
            end
          end
          SPSTATE_PREPARE: begin
            if ((SPPREPAREEND == 1'b1)) begin
              SPVRAMACCESSING <= 1'b0;
            end
          end
          default: begin
          end
        endcase
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]Yテスト用の信号
  //---------------------------------------------------------------------------
  assign W_SPLISTUPY = FF_CUR_Y[7:0] - PRAMDAT;
  // [Y_TEST]着目スプライトを現ラインに表示するかどうかの信号
  assign W_TARGET_SP_EN = (((W_SPLISTUPY[7:3] == 5'b00000) && (REG_R1_SP_SIZE == 1'b0) && (REG_R1_SP_ZOOM == 1'b0)) || ((W_SPLISTUPY[7:4] == 4'b0000) && (REG_R1_SP_SIZE == 1'b1) && (REG_R1_SP_ZOOM == 1'b0)) || ((W_SPLISTUPY[7:4] == 4'b0000) && (REG_R1_SP_SIZE == 1'b0) && (REG_R1_SP_ZOOM == 1'b1)) || ((W_SPLISTUPY[7:5] == 3'b000) && (REG_R1_SP_SIZE == 1'b1) && (REG_R1_SP_ZOOM == 1'b1))) ? 1'b1 : 1'b0;
  // [Y_TEST]これ以降のスプライトは表示禁止かどうかの信号
  assign W_SP_OFF = (PRAMDAT == ({4'b1101, SPMODE2, 3'b000})) ? 1'b1 : 1'b0;
  // [Y_TEST]４つ（８つ）のスプライトが並んでいるかどうかの信号
  assign W_SP_OVERMAP = ((FF_Y_TEST_LISTUP_ADDR[2] == 1'b1 && SPMODE2 == 1'b0 && SPMAXSPR == 1'b0) || FF_Y_TEST_LISTUP_ADDR[3] == 1'b1) ? 1'b1 : 1'b0;
  // [Y_TEST]表示中のラインか否か
  assign W_ACTIVE = BWINDOW_Y;
  //---------------------------------------------------------------------------
  // [SPWINDOW_Y]
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPWINDOW_Y <= 1'b0;
    end else begin
      if ((DOTCOUNTERYP == 0)) begin
        SPWINDOW_Y <= 1'b1;
      end
      else if(((REG_R9_Y_DOTS == 1'b0 && DOTCOUNTERYP == 192) || (REG_R9_Y_DOTS == 1'b1 && DOTCOUNTERYP == 212))) begin
        SPWINDOW_Y <= 1'b0;
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]Yテストステートでないことを示す信号
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_Y_TEST_EN <= 1'b0;
    end else begin
      if ((DOTSTATE == 2'b01)) begin
        if ((DOTCOUNTERX == 0)) begin
          FF_Y_TEST_EN <= FF_SP_EN;
        end else if ((EIGHTDOTSTATE == 3'b110)) begin
          if((W_SP_OFF == 1'b1 || (W_SP_OVERMAP & W_TARGET_SP_EN) == 1'b1 || FF_Y_TEST_SP_NUM == 5'b11111)) begin
            FF_Y_TEST_EN <= 1'b0;
          end
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]テスト対象のスプライト番号 (0～31)
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_Y_TEST_SP_NUM <= {5{1'b0}};
    end else begin
      if ((DOTSTATE == 2'b01)) begin
        if ((DOTCOUNTERX == 0)) begin
          FF_Y_TEST_SP_NUM <= {5{1'b0}};
        end else if ((EIGHTDOTSTATE == 3'b110)) begin
          if ((FF_Y_TEST_EN == 1'b1 && FF_Y_TEST_SP_NUM != 5'b11111)) begin
            FF_Y_TEST_SP_NUM <= FF_Y_TEST_SP_NUM + 1;
          end
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]表示するスプライトをリストアップするためのリストアップメモリアドレス 0～8
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_Y_TEST_LISTUP_ADDR <= {4{1'b0}};
    end else begin
      if ((DOTSTATE == 2'b01)) begin
        if ((DOTCOUNTERX == 0)) begin
          // INITIALIZE
          FF_Y_TEST_LISTUP_ADDR <= {4{1'b0}};
        end else if ((EIGHTDOTSTATE == 3'b110)) begin
          // NEXT SPRITE [リストアップメモリが満杯になるまでインクリメント]
          if((FF_Y_TEST_EN == 1'b1 && W_TARGET_SP_EN == 1'b1 && W_SP_OVERMAP == 1'b0 && W_SP_OFF == 1'b0)) begin
            FF_Y_TEST_LISTUP_ADDR <= FF_Y_TEST_LISTUP_ADDR + 1;
          end
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]表示するスプライトをリストアップするためのリストアップメモリへの書き込み
  //---------------------------------------------------------------------------
  always @(posedge CLK21M) begin
    if ((DOTSTATE == 2'b01)) begin
      if ((DOTCOUNTERX == 0)) begin
        // INITIALIZE
      end else if ((EIGHTDOTSTATE == 3'b110)) begin
        // NEXT SPRITE
        if((FF_Y_TEST_EN == 1'b1 && W_TARGET_SP_EN == 1'b1 && W_SP_OVERMAP == 1'b0 && W_SP_OFF == 1'b0)) begin
          SPRENDERPLANES[FF_Y_TEST_LISTUP_ADDR] <= FF_Y_TEST_SP_NUM;
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]４つ目（８つ目）のスプライトが並んだかどうかの信号
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_SP_OVERMAP <= 1'b0;
    end else begin
      if ((PVDPS0RESETREQ == (~FF_VDPS0RESETACK))) begin
        // S#0が読み込まれるまでクリアしない
        FF_SP_OVERMAP <= 1'b0;
      end else if ((DOTSTATE == 2'b01)) begin
        if ((DOTCOUNTERX == 0)) begin
          // INITIALIZE
        end else if ((EIGHTDOTSTATE == 3'b110)) begin
          if((SPWINDOW_Y == 1'b1 && FF_Y_TEST_EN == 1'b1 && W_TARGET_SP_EN == 1'b1 && W_SP_OVERMAP == 1'b1 && W_SP_OFF == 1'b0)) begin
            FF_SP_OVERMAP <= 1'b1;
          end
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // [Y_TEST]処理をあきらめたスプライト信号
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_SP_OVERMAP_NUM <= {5{1'b1}};
    end else begin
      if ((PVDPS0RESETREQ == (~FF_VDPS0RESETACK))) begin
        FF_SP_OVERMAP_NUM <= {5{1'b1}};
      end else if ((DOTSTATE == 2'b01)) begin
        if ((DOTCOUNTERX == 0)) begin
          // INITIALIZE
        end else if ((EIGHTDOTSTATE == 3'b110)) begin
          // JP: 調査をあきらめたスプライト番号が格納される。OVERMAPとは限らない。
          // JP: しかし、すでに OVERMAP で値が確定している場合は更新しない。
          if((SPWINDOW_Y == 1'b1 && FF_Y_TEST_EN == 1'b1 && W_TARGET_SP_EN == 1'b1 && W_SP_OVERMAP == 1'b1 && W_SP_OFF == 1'b0 && FF_SP_OVERMAP == 1'b0)) begin
            FF_SP_OVERMAP_NUM <= FF_Y_TEST_SP_NUM;
          end
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // Yテスト用の VRAM読み出しアドレス
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      FF_Y_TEST_VRAM_ADDR <= {17{1'b0}};
    end else begin
      if ((DOTSTATE == 2'b11)) begin
        FF_Y_TEST_VRAM_ADDR <= {SPATTRTBLBASEADDR, FF_Y_TEST_SP_NUM, 2'b00};
      end
    end
  end

  //---------------------------------------------------------------------------
  // PREPARE SPRITE
  //
  // JP: 画面描画中           : 8ドット描画する間に1プレーン、スプライトのY座標を検査し、
  // JP:                        表示すべきスプライトをリストアップする。
  // JP: 画面非描画中         : リストアップしたスプライトの情報を集め、inforamに格納
  // JP: 次の画面描画中       : inforamに格納された情報を元に、ラインバッファに描画
  // JP: 次の次の画面描画中   : ラインバッファに描画された絵を出力し、画面描画に混ぜる
  //---------------------------------------------------------------------------
  // READ TIMING OF SPRITE ATTRIBUTE TABLE
  assign SPATTRIB_ADDR = {SPATTRTBLBASEADDR, SPPREPAREPLANENUM};
  assign READVRAMADDRPTREAD = (REG_R1_SP_SIZE == 1'b0) ? {SPPTNGENETBLBASEADDR,SPPREPAREPATTERNNUM[7:0],SPPREPARELINENUM[2:0]} : {SPPTNGENETBLBASEADDR,SPPREPAREPATTERNNUM[7:2],SPPREPAREXPOS,SPPREPARELINENUM[3:0]};
  // 16X16 MODE
  assign READVRAMADDRCREAD = (SPMODE2 == 1'b0) ? {SPATTRIB_ADDR,2'b11} : {SPATTRTBLBASEADDR[9:3], ~SPATTRTBLBASEADDR[2],SPPREPAREPLANENUM,SPPREPARELINENUM};
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      IRAMADRPREPARE <= {17{1'b0}};
    end else begin
      // PREPAREING
      if ((DOTSTATE == 2'b11)) begin
        case (EIGHTDOTSTATE)
          3'b000: begin
            // Y READ
            IRAMADRPREPARE <= {SPATTRIB_ADDR, 2'b00};
          end
          3'b001: begin
            // X READ
            IRAMADRPREPARE <= {SPATTRIB_ADDR, 2'b01};
          end
          3'b010: begin
            // PATTERN NUM READ
            IRAMADRPREPARE <= {SPATTRIB_ADDR, 2'b10};
          end
          3'b011, 3'b100: begin
            // PATTERN READ
            IRAMADRPREPARE <= READVRAMADDRPTREAD;
          end
          3'b101: begin
            // COLOR READ
            IRAMADRPREPARE <= READVRAMADDRCREAD;
          end
          default: begin
          end
        endcase
      end
    end
  end

  always @(posedge CLK21M) begin
    case (DOTSTATE)
      2'b11: begin
        SPINFORAMWE <= 1'b0;
      end
      2'b01: begin
        if ((SPSTATE == SPSTATE_PREPARE)) begin
          if ((EIGHTDOTSTATE == 3'b110)) begin
            SPINFORAMWE <= 1'b1;
          end
        end else begin
          SPINFORAMWE <= 1'b0;
        end
      end
      default: begin
      end
    endcase
  end

  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPPREPARELOCALPLANENUM <= {3{1'b0}};
      SPPREPAREEND <= 1'b0;
    end else begin
      // PREPAREING
      case (DOTSTATE)
        2'b01: begin
          if ((SPSTATE == SPSTATE_PREPARE)) begin
            case (EIGHTDOTSTATE)
              3'b001: begin
                // Y READ
                // JP: スプライトの何行目が該当したか覚えておく
                if ((REG_R1_SP_ZOOM == 1'b0)) begin
                  SPPREPARELINENUM <= W_SPLISTUPY[3:0];
                end else begin
                  SPPREPARELINENUM <= W_SPLISTUPY[4:1];
                end
              end
              3'b010: begin
                // X READ
                SPINFORAMX_IN <= {1'b0, PRAMDAT};
              end
              3'b011: begin
                // PATTERN NUM READ
                SPPREPAREPATTERNNUM <= PRAMDAT;
              end
              3'b100: begin
                // PATTERN READ LEFT
                SPINFORAMPATTERN_IN[15:8] <= PRAMDAT;
              end
              3'b101: begin
                // PATTERN READ RIGHT
                if ((REG_R1_SP_SIZE == 1'b0)) begin
                  // 8X8 MODE
                  SPINFORAMPATTERN_IN[7:0] <= {8{1'b0}};
                end else begin
                  // 16X16 MODE
                  SPINFORAMPATTERN_IN[7:0] <= PRAMDAT;
                end
              end
              3'b110: begin
                // COLOR READ
                // COLOR
                SPINFORAMCOLOR_IN <= PRAMDAT[3:0];
                // CC   優先順位ビット (1: 優先順位無し, 0: 優先順位あり)
                if ((SPMODE2 == 1'b1)) begin
                  SPINFORAMCC_IN <= PRAMDAT[6];
                end else begin
                  SPINFORAMCC_IN <= 1'b0;
                end
                // IC   衝突検知ビット (1: 検知しない, 0: 検知する)
                SPINFORAMIC_IN <= PRAMDAT[5] & SPMODE2;
                // EC   32ドット左シフト (1: する, 0: しない)
                if ((PRAMDAT[7] == 1'b1)) begin
                  SPINFORAMX_IN <= SPINFORAMX_IN - 32;
                end
                // IF ALL OF THE SPRITES LIST-UPED ARE READED,
                // THE SPRITES LEFT SHOULD NOT BE DRAWN.
                if ((SPPREPARELOCALPLANENUM >= FF_Y_TEST_LISTUP_ADDR)) begin
                  SPINFORAMPATTERN_IN <= {16{1'b0}};
                end
              end
              3'b111: begin
                SPPREPARELOCALPLANENUM <= SPPREPARELOCALPLANENUM + 1;
                if(((SPPREPARELOCALPLANENUM == 7) || (SPMAXSPR == 1'b0 && (SPPREPARELOCALPLANENUM == 3 && SPMODE2 == 1'b0)))) begin
                  SPPREPAREEND <= 1'b1;
                end
              end
              default: begin
              end
            endcase
          end else begin
            SPPREPARELOCALPLANENUM <= {3{1'b0}};
            SPPREPAREEND <= 1'b0;
          end
        end
        default: begin
        end
      endcase
    end
  end

  always @(posedge CLK21M) begin
    if ((DOTSTATE == 2'b01)) begin
      if ((SPSTATE == SPSTATE_PREPARE)) begin
        if ((EIGHTDOTSTATE == 3'b111)) begin
          SPPREPAREPLANENUM <= SPRENDERPLANES[SPPREPARELOCALPLANENUM+1];
        end
      end else begin
        SPPREPAREPLANENUM <= SPRENDERPLANES[0];
      end
    end
  end

  //---------------------------------------------------------------------------
  // DRAWING TO LINE BUFFER.
  //
  // DOTCOUNTERX( 4 DOWNTO 0 )
  //   0... 31    DRAW LOCAL PLANE#0 TO LINE BUFFER
  //  32... 63    DRAW LOCAL PLANE#1 TO LINE BUFFER
  //     :                         :
  // 224...255    DRAW LOCAL PLANE#7 TO LINE BUFFER
  //---------------------------------------------------------------------------
  always @(posedge CLK21M, posedge RESET) begin : P1
    reg SPCC0FOUNDV;
    reg [2:0] LASTCC0LOCALPLANENUMV;
    reg [8:0] SPDRAWXV;
    // -32 - 287 (=256+31)
    reg VDPS0SPCOLLISIONINCIDENCEV;
    reg [8:0] VDPS3S4SPCOLLISIONXV;
    reg [8:0] VDPS5S6SPCOLLISIONYV;

    if ((RESET == 1'b1)) begin
      SPLINEBUFDRAWWE <= 1'b0;
      // JP: ラインバッファへの書き込みイネーブラ
      SPPREDRAWEND <= 1'b0;
      SPDRAWPATTERN <= {16{1'b0}};
      SPLINEBUFDRAWCOLOR <= {8{1'b0}};
      SPLINEBUFDRAWX <= {8{1'b0}};
      SPDRAWCOLOR <= {4{1'b0}};
      VDPS0SPCOLLISIONINCIDENCEV = 1'b0;
      // JP: スプライトが衝突したかどうかを示すフラグ
      VDPS3S4SPCOLLISIONXV = {1{1'b0}};
      VDPS5S6SPCOLLISIONYV = {1{1'b0}};
      SPCC0FOUNDV = 1'b0;
      LASTCC0LOCALPLANENUMV = {1{1'b0}};
    end else begin
      if ((SPSTATE == SPSTATE_YTEST_DRAW)) begin
        case (DOTSTATE)
          2'b10: begin
            // JP: 処理単位の始まり
            SPLINEBUFDRAWWE <= 1'b0;
          end
          2'b00: begin
            // JP:
            if ((DOTCOUNTERX[4:0] == 1)) begin
              SPDRAWPATTERN <= SPINFORAMPATTERN_OUT;
              SPDRAWXV = SPINFORAMX_OUT;
            end else begin
              if (((REG_R1_SP_ZOOM == 1'b0) || (DOTCOUNTERX[0] == 1'b1))) begin
                SPDRAWPATTERN <= {SPDRAWPATTERN[14:0], 1'b0};
              end
              SPDRAWXV = SPDRAWX + 1;
            end
            SPDRAWX <= SPDRAWXV;
            SPLINEBUFDRAWX <= SPDRAWXV[7:0];
          end
          2'b01: begin
            SPDRAWCOLOR <= SPINFORAMCOLOR_OUT;
          end
          2'b11: begin
            if ((SPINFORAMCC_OUT == 1'b0)) begin
              LASTCC0LOCALPLANENUMV = SPPREDRAWLOCALPLANENUM;
              SPCC0FOUNDV = 1'b1;
            end
            if(((SPDRAWPATTERN[15] == 1'b1) && (SPDRAWX[8] == 1'b0) && (SPPREDRAWEND == 1'b0) && ((REG_R8_COL0_ON == 1'b1) || (SPDRAWCOLOR != 0)))) begin
              // JP: スプライトのドットを描画
              // JP: ラインバッファの7ビット目は、何らかの色を描画した時に'1'になる。
              // JP: ラインバッファの6-4ビット目はそこに描画されているドットのローカルプレーン番号
              // JP: (色合成されているときは親となるCC='0'のスプライトのローカルプレーン番号)が入る。
              // JP: つまり、LASTCC0LOCALPLANENUMVがこの番号と等しいときはOR合成してよい事になる。
              if (((SPLINEBUFDRAWDATA_OUT[7] == 1'b0) && (SPCC0FOUNDV == 1'b1))) begin
                // JP: 何も描かれていない(ビット7が'0')とき、このドットに初めての
                // JP: スプライトが描画される。ただし、CC='0'のスプライトが同一ライン上にまだ
                // JP: 現れていない時は描画しない
                SPLINEBUFDRAWCOLOR <= {1'b1, LASTCC0LOCALPLANENUMV, SPDRAWCOLOR};
                SPLINEBUFDRAWWE <= 1'b1;
              end
            else if(((SPLINEBUFDRAWDATA_OUT[7] == 1'b1) && (SPINFORAMCC_OUT == 1'b1) && (SPLINEBUFDRAWDATA_OUT[6:4] == LASTCC0LOCALPLANENUMV))) begin
                // JP: 既に絵が描かれているが、CCが'1'でかつこのドットに描かれているスプライトの
                // JP: LOCALPLANENUMが LASTCC0LOCALPLANENUMVと等しい時は、ラインバッファから
                // JP: 下地データを読み、書きたい色と論理和を取リ、書き戻す。
                SPLINEBUFDRAWCOLOR <= SPLINEBUFDRAWDATA_OUT | ({4'b0000, SPDRAWCOLOR});
                SPLINEBUFDRAWWE <= 1'b1;
              end else if (((SPLINEBUFDRAWDATA_OUT[7] == 1'b1) && (SPINFORAMIC_OUT == 1'b0))) begin
                SPLINEBUFDRAWCOLOR <= SPLINEBUFDRAWDATA_OUT;
                // JP: スプライトが衝突。
                // SPRITE COLISION OCCURED
                VDPS0SPCOLLISIONINCIDENCEV = 1'b1;
                VDPS3S4SPCOLLISIONXV = SPDRAWX + 12;
                // NOTE: DRAWING LINE IS PREVIOUS LINE.
                VDPS5S6SPCOLLISIONYV = FF_CUR_Y + 7;
              end
            end
            //
            if ((DOTCOUNTERX == 0)) begin
              SPPREDRAWLOCALPLANENUM <= {3{1'b0}};
              SPPREDRAWEND <= SPLIT_SCRN | REG_R8_SP_OFF;
              LASTCC0LOCALPLANENUMV = {1{1'b0}};
              SPCC0FOUNDV = 1'b0;
            end else if ((DOTCOUNTERX[4:0] == 0)) begin
              SPPREDRAWLOCALPLANENUM <= SPPREDRAWLOCALPLANENUM + 1;
              if(((SPPREDRAWLOCALPLANENUM == 7) || (SPMAXSPR == 1'b0 && (SPPREDRAWLOCALPLANENUM == 3 && SPMODE2 == 1'b0)))) begin
                SPPREDRAWEND <= 1'b1;
              end
            end
          end
          default: begin
          end
        endcase
      end
      // STATUS REGISTER
      if ((PVDPS0RESETREQ != FF_VDPS0RESETACK)) begin
        FF_VDPS0RESETACK <= PVDPS0RESETREQ;
        VDPS0SPCOLLISIONINCIDENCEV = 1'b0;
      end
      if ((PVDPS5RESETREQ != FF_VDPS5RESETACK)) begin
        FF_VDPS5RESETACK <= PVDPS5RESETREQ;
        VDPS3S4SPCOLLISIONXV = {1{1'b0}};
        VDPS5S6SPCOLLISIONYV = {1{1'b0}};
      end
      PVDPS0SPCOLLISIONINCIDENCE <= VDPS0SPCOLLISIONINCIDENCEV;
      PVDPS3S4SPCOLLISIONX <= VDPS3S4SPCOLLISIONXV;
      PVDPS5S6SPCOLLISIONY <= VDPS5S6SPCOLLISIONYV;
    end
  end

  //---------------------------------------------------------------------------
  // JP: 画面へのレンダリング。VDPエンティティがDOTSTATE="11"の時に値を取得できるように、
  // JP: "01"のタイミングで出力する。
  //---------------------------------------------------------------------------
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPLINEBUFDISPX <= {8{1'b0}};
    end else begin
      if ((DOTSTATE == 2'b10)) begin
        // JP: DOTCOUNTERと実際の表示(カラーコードの出力)は8ドットずれている
        if ((DOTCOUNTERX == 8)) begin
          SPLINEBUFDISPX <= {5'b00000, REG_R27_H_SCROLL};
        end else begin
          SPLINEBUFDISPX <= SPLINEBUFDISPX + 1;
        end
      end
    end
  end

  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPWINDOWX <= 1'b0;
    end else begin
      if ((DOTSTATE == 2'b10)) begin
        // JP: DOTCOUNTERと実際の表示(カラーコードの出力)は8ドットずれている
        if ((DOTCOUNTERX == 8)) begin
          SPWINDOWX <= 1'b1;
        end else if ((SPLINEBUFDISPX == 8'hFF)) begin
          SPWINDOWX <= 1'b0;
        end
      end
    end
  end

  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPLINEBUFDISPWE <= 1'b0;
    end else begin
      if ((DOTSTATE == 2'b10)) begin
        SPLINEBUFDISPWE <= 1'b0;
      end else if ((DOTSTATE == 2'b11 && SPWINDOWX == 1'b1)) begin
        // CLEAR DISPLAYED DOT
        SPLINEBUFDISPWE <= 1'b1;
      end
    end
  end

  // JP: ウィンドウで表示をカットする
  always @(posedge RESET, posedge CLK21M) begin
    if ((RESET == 1'b1)) begin
      SPCOLOROUT  <= 1'b0;
      // JP:  0=透明, 1=スプライトドット
      SPCOLORCODE <= {4{1'b0}};
      // JP:  SPCOLOROUT=1 の時のスプライトドット色番号
    end else begin
      if ((DOTSTATE == 2'b01)) begin
        if ((SPWINDOWX == 1'b1)) begin
          SPCOLOROUT  <= SPLINEBUFDISPDATA_OUT[7];
          SPCOLORCODE <= SPLINEBUFDISPDATA_OUT[3:0];
        end else begin
          SPCOLOROUT  <= 1'b0;
          SPCOLORCODE <= {4{1'b0}};
        end
      end
    end
  end


endmodule
