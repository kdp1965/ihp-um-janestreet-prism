module CFGMEM_IHP_LEFT16 (BYP,
    EN0,
    WE0,
    VPWR,
    VGND,
    A0,
    Di0,
    Do0,
    WROW);
 input BYP;
 input EN0;
 input WE0;
 inout VPWR;
 inout VGND;
 input [3:0] A0;
 input [31:0] Di0;
 output [31:0] Do0;
 input [15:0] WROW;

 wire \A0BUF[0].X ;
 wire \A0BUF[1].X ;
 wire \A0BUF[2].X ;
 wire \A0BUF[3].X ;
 wire \BYPBUF.X ;
 wire \DEC0.D.SEL[0] ;
 wire \DEC0.D.SEL[1] ;
 wire \DEC0.D0.A_N[0] ;
 wire \DEC0.D0.A_N[1] ;
 wire \DEC0.D0.A_N[2] ;
 wire \DEC0.D0.A_buf[0] ;
 wire \DEC0.D0.A_buf[1] ;
 wire \DEC0.D0.A_buf[2] ;
 wire \DEC0.D0.EN_buf ;
 wire \DEC0.D0.SEL[0] ;
 wire \DEC0.D0.SEL[1] ;
 wire \DEC0.D0.SEL[2] ;
 wire \DEC0.D0.SEL[3] ;
 wire \DEC0.D0.SEL[4] ;
 wire \DEC0.D0.SEL[5] ;
 wire \DEC0.D0.SEL[6] ;
 wire \DEC0.D0.SEL[7] ;
 wire \DEC0.D1.A_N[0] ;
 wire \DEC0.D1.A_N[1] ;
 wire \DEC0.D1.A_N[2] ;
 wire \DEC0.D1.A_buf[0] ;
 wire \DEC0.D1.A_buf[1] ;
 wire \DEC0.D1.A_buf[2] ;
 wire \DEC0.D1.EN_buf ;
 wire \DEC0.D1.SEL[0] ;
 wire \DEC0.D1.SEL[1] ;
 wire \DEC0.D1.SEL[2] ;
 wire \DEC0.D1.SEL[3] ;
 wire \DEC0.D1.SEL[4] ;
 wire \DEC0.D1.SEL[5] ;
 wire \DEC0.D1.SEL[6] ;
 wire \DEC0.D1.SEL[7] ;
 wire \Di0_in[10][0] ;
 wire \Di0_in[10][10] ;
 wire \Di0_in[10][11] ;
 wire \Di0_in[10][12] ;
 wire \Di0_in[10][13] ;
 wire \Di0_in[10][14] ;
 wire \Di0_in[10][15] ;
 wire \Di0_in[10][16] ;
 wire \Di0_in[10][17] ;
 wire \Di0_in[10][18] ;
 wire \Di0_in[10][19] ;
 wire \Di0_in[10][1] ;
 wire \Di0_in[10][20] ;
 wire \Di0_in[10][21] ;
 wire \Di0_in[10][22] ;
 wire \Di0_in[10][23] ;
 wire \Di0_in[10][24] ;
 wire \Di0_in[10][25] ;
 wire \Di0_in[10][26] ;
 wire \Di0_in[10][27] ;
 wire \Di0_in[10][28] ;
 wire \Di0_in[10][29] ;
 wire \Di0_in[10][2] ;
 wire \Di0_in[10][30] ;
 wire \Di0_in[10][31] ;
 wire \Di0_in[10][3] ;
 wire \Di0_in[10][4] ;
 wire \Di0_in[10][5] ;
 wire \Di0_in[10][6] ;
 wire \Di0_in[10][7] ;
 wire \Di0_in[10][8] ;
 wire \Di0_in[10][9] ;
 wire \Di0_in[11][0] ;
 wire \Di0_in[11][10] ;
 wire \Di0_in[11][11] ;
 wire \Di0_in[11][12] ;
 wire \Di0_in[11][13] ;
 wire \Di0_in[11][14] ;
 wire \Di0_in[11][15] ;
 wire \Di0_in[11][16] ;
 wire \Di0_in[11][17] ;
 wire \Di0_in[11][18] ;
 wire \Di0_in[11][19] ;
 wire \Di0_in[11][1] ;
 wire \Di0_in[11][20] ;
 wire \Di0_in[11][21] ;
 wire \Di0_in[11][22] ;
 wire \Di0_in[11][23] ;
 wire \Di0_in[11][24] ;
 wire \Di0_in[11][25] ;
 wire \Di0_in[11][26] ;
 wire \Di0_in[11][27] ;
 wire \Di0_in[11][28] ;
 wire \Di0_in[11][29] ;
 wire \Di0_in[11][2] ;
 wire \Di0_in[11][30] ;
 wire \Di0_in[11][31] ;
 wire \Di0_in[11][3] ;
 wire \Di0_in[11][4] ;
 wire \Di0_in[11][5] ;
 wire \Di0_in[11][6] ;
 wire \Di0_in[11][7] ;
 wire \Di0_in[11][8] ;
 wire \Di0_in[11][9] ;
 wire \Di0_in[12][0] ;
 wire \Di0_in[12][10] ;
 wire \Di0_in[12][11] ;
 wire \Di0_in[12][12] ;
 wire \Di0_in[12][13] ;
 wire \Di0_in[12][14] ;
 wire \Di0_in[12][15] ;
 wire \Di0_in[12][16] ;
 wire \Di0_in[12][17] ;
 wire \Di0_in[12][18] ;
 wire \Di0_in[12][19] ;
 wire \Di0_in[12][1] ;
 wire \Di0_in[12][20] ;
 wire \Di0_in[12][21] ;
 wire \Di0_in[12][22] ;
 wire \Di0_in[12][23] ;
 wire \Di0_in[12][24] ;
 wire \Di0_in[12][25] ;
 wire \Di0_in[12][26] ;
 wire \Di0_in[12][27] ;
 wire \Di0_in[12][28] ;
 wire \Di0_in[12][29] ;
 wire \Di0_in[12][2] ;
 wire \Di0_in[12][30] ;
 wire \Di0_in[12][31] ;
 wire \Di0_in[12][3] ;
 wire \Di0_in[12][4] ;
 wire \Di0_in[12][5] ;
 wire \Di0_in[12][6] ;
 wire \Di0_in[12][7] ;
 wire \Di0_in[12][8] ;
 wire \Di0_in[12][9] ;
 wire \Di0_in[13][0] ;
 wire \Di0_in[13][10] ;
 wire \Di0_in[13][11] ;
 wire \Di0_in[13][12] ;
 wire \Di0_in[13][13] ;
 wire \Di0_in[13][14] ;
 wire \Di0_in[13][15] ;
 wire \Di0_in[13][16] ;
 wire \Di0_in[13][17] ;
 wire \Di0_in[13][18] ;
 wire \Di0_in[13][19] ;
 wire \Di0_in[13][1] ;
 wire \Di0_in[13][20] ;
 wire \Di0_in[13][21] ;
 wire \Di0_in[13][22] ;
 wire \Di0_in[13][23] ;
 wire \Di0_in[13][24] ;
 wire \Di0_in[13][25] ;
 wire \Di0_in[13][26] ;
 wire \Di0_in[13][27] ;
 wire \Di0_in[13][28] ;
 wire \Di0_in[13][29] ;
 wire \Di0_in[13][2] ;
 wire \Di0_in[13][30] ;
 wire \Di0_in[13][31] ;
 wire \Di0_in[13][3] ;
 wire \Di0_in[13][4] ;
 wire \Di0_in[13][5] ;
 wire \Di0_in[13][6] ;
 wire \Di0_in[13][7] ;
 wire \Di0_in[13][8] ;
 wire \Di0_in[13][9] ;
 wire \Di0_in[14][0] ;
 wire \Di0_in[14][10] ;
 wire \Di0_in[14][11] ;
 wire \Di0_in[14][12] ;
 wire \Di0_in[14][13] ;
 wire \Di0_in[14][14] ;
 wire \Di0_in[14][15] ;
 wire \Di0_in[14][16] ;
 wire \Di0_in[14][17] ;
 wire \Di0_in[14][18] ;
 wire \Di0_in[14][19] ;
 wire \Di0_in[14][1] ;
 wire \Di0_in[14][20] ;
 wire \Di0_in[14][21] ;
 wire \Di0_in[14][22] ;
 wire \Di0_in[14][23] ;
 wire \Di0_in[14][24] ;
 wire \Di0_in[14][25] ;
 wire \Di0_in[14][26] ;
 wire \Di0_in[14][27] ;
 wire \Di0_in[14][28] ;
 wire \Di0_in[14][29] ;
 wire \Di0_in[14][2] ;
 wire \Di0_in[14][30] ;
 wire \Di0_in[14][31] ;
 wire \Di0_in[14][3] ;
 wire \Di0_in[14][4] ;
 wire \Di0_in[14][5] ;
 wire \Di0_in[14][6] ;
 wire \Di0_in[14][7] ;
 wire \Di0_in[14][8] ;
 wire \Di0_in[14][9] ;
 wire \Di0_in[15][0] ;
 wire \Di0_in[15][10] ;
 wire \Di0_in[15][11] ;
 wire \Di0_in[15][12] ;
 wire \Di0_in[15][13] ;
 wire \Di0_in[15][14] ;
 wire \Di0_in[15][15] ;
 wire \Di0_in[15][16] ;
 wire \Di0_in[15][17] ;
 wire \Di0_in[15][18] ;
 wire \Di0_in[15][19] ;
 wire \Di0_in[15][1] ;
 wire \Di0_in[15][20] ;
 wire \Di0_in[15][21] ;
 wire \Di0_in[15][22] ;
 wire \Di0_in[15][23] ;
 wire \Di0_in[15][24] ;
 wire \Di0_in[15][25] ;
 wire \Di0_in[15][26] ;
 wire \Di0_in[15][27] ;
 wire \Di0_in[15][28] ;
 wire \Di0_in[15][29] ;
 wire \Di0_in[15][2] ;
 wire \Di0_in[15][30] ;
 wire \Di0_in[15][31] ;
 wire \Di0_in[15][3] ;
 wire \Di0_in[15][4] ;
 wire \Di0_in[15][5] ;
 wire \Di0_in[15][6] ;
 wire \Di0_in[15][7] ;
 wire \Di0_in[15][8] ;
 wire \Di0_in[15][9] ;
 wire \Di0_in[1][0] ;
 wire \Di0_in[1][10] ;
 wire \Di0_in[1][11] ;
 wire \Di0_in[1][12] ;
 wire \Di0_in[1][13] ;
 wire \Di0_in[1][14] ;
 wire \Di0_in[1][15] ;
 wire \Di0_in[1][16] ;
 wire \Di0_in[1][17] ;
 wire \Di0_in[1][18] ;
 wire \Di0_in[1][19] ;
 wire \Di0_in[1][1] ;
 wire \Di0_in[1][20] ;
 wire \Di0_in[1][21] ;
 wire \Di0_in[1][22] ;
 wire \Di0_in[1][23] ;
 wire \Di0_in[1][24] ;
 wire \Di0_in[1][25] ;
 wire \Di0_in[1][26] ;
 wire \Di0_in[1][27] ;
 wire \Di0_in[1][28] ;
 wire \Di0_in[1][29] ;
 wire \Di0_in[1][2] ;
 wire \Di0_in[1][30] ;
 wire \Di0_in[1][31] ;
 wire \Di0_in[1][3] ;
 wire \Di0_in[1][4] ;
 wire \Di0_in[1][5] ;
 wire \Di0_in[1][6] ;
 wire \Di0_in[1][7] ;
 wire \Di0_in[1][8] ;
 wire \Di0_in[1][9] ;
 wire \Di0_in[2][0] ;
 wire \Di0_in[2][10] ;
 wire \Di0_in[2][11] ;
 wire \Di0_in[2][12] ;
 wire \Di0_in[2][13] ;
 wire \Di0_in[2][14] ;
 wire \Di0_in[2][15] ;
 wire \Di0_in[2][16] ;
 wire \Di0_in[2][17] ;
 wire \Di0_in[2][18] ;
 wire \Di0_in[2][19] ;
 wire \Di0_in[2][1] ;
 wire \Di0_in[2][20] ;
 wire \Di0_in[2][21] ;
 wire \Di0_in[2][22] ;
 wire \Di0_in[2][23] ;
 wire \Di0_in[2][24] ;
 wire \Di0_in[2][25] ;
 wire \Di0_in[2][26] ;
 wire \Di0_in[2][27] ;
 wire \Di0_in[2][28] ;
 wire \Di0_in[2][29] ;
 wire \Di0_in[2][2] ;
 wire \Di0_in[2][30] ;
 wire \Di0_in[2][31] ;
 wire \Di0_in[2][3] ;
 wire \Di0_in[2][4] ;
 wire \Di0_in[2][5] ;
 wire \Di0_in[2][6] ;
 wire \Di0_in[2][7] ;
 wire \Di0_in[2][8] ;
 wire \Di0_in[2][9] ;
 wire \Di0_in[3][0] ;
 wire \Di0_in[3][10] ;
 wire \Di0_in[3][11] ;
 wire \Di0_in[3][12] ;
 wire \Di0_in[3][13] ;
 wire \Di0_in[3][14] ;
 wire \Di0_in[3][15] ;
 wire \Di0_in[3][16] ;
 wire \Di0_in[3][17] ;
 wire \Di0_in[3][18] ;
 wire \Di0_in[3][19] ;
 wire \Di0_in[3][1] ;
 wire \Di0_in[3][20] ;
 wire \Di0_in[3][21] ;
 wire \Di0_in[3][22] ;
 wire \Di0_in[3][23] ;
 wire \Di0_in[3][24] ;
 wire \Di0_in[3][25] ;
 wire \Di0_in[3][26] ;
 wire \Di0_in[3][27] ;
 wire \Di0_in[3][28] ;
 wire \Di0_in[3][29] ;
 wire \Di0_in[3][2] ;
 wire \Di0_in[3][30] ;
 wire \Di0_in[3][31] ;
 wire \Di0_in[3][3] ;
 wire \Di0_in[3][4] ;
 wire \Di0_in[3][5] ;
 wire \Di0_in[3][6] ;
 wire \Di0_in[3][7] ;
 wire \Di0_in[3][8] ;
 wire \Di0_in[3][9] ;
 wire \Di0_in[4][0] ;
 wire \Di0_in[4][10] ;
 wire \Di0_in[4][11] ;
 wire \Di0_in[4][12] ;
 wire \Di0_in[4][13] ;
 wire \Di0_in[4][14] ;
 wire \Di0_in[4][15] ;
 wire \Di0_in[4][16] ;
 wire \Di0_in[4][17] ;
 wire \Di0_in[4][18] ;
 wire \Di0_in[4][19] ;
 wire \Di0_in[4][1] ;
 wire \Di0_in[4][20] ;
 wire \Di0_in[4][21] ;
 wire \Di0_in[4][22] ;
 wire \Di0_in[4][23] ;
 wire \Di0_in[4][24] ;
 wire \Di0_in[4][25] ;
 wire \Di0_in[4][26] ;
 wire \Di0_in[4][27] ;
 wire \Di0_in[4][28] ;
 wire \Di0_in[4][29] ;
 wire \Di0_in[4][2] ;
 wire \Di0_in[4][30] ;
 wire \Di0_in[4][31] ;
 wire \Di0_in[4][3] ;
 wire \Di0_in[4][4] ;
 wire \Di0_in[4][5] ;
 wire \Di0_in[4][6] ;
 wire \Di0_in[4][7] ;
 wire \Di0_in[4][8] ;
 wire \Di0_in[4][9] ;
 wire \Di0_in[5][0] ;
 wire \Di0_in[5][10] ;
 wire \Di0_in[5][11] ;
 wire \Di0_in[5][12] ;
 wire \Di0_in[5][13] ;
 wire \Di0_in[5][14] ;
 wire \Di0_in[5][15] ;
 wire \Di0_in[5][16] ;
 wire \Di0_in[5][17] ;
 wire \Di0_in[5][18] ;
 wire \Di0_in[5][19] ;
 wire \Di0_in[5][1] ;
 wire \Di0_in[5][20] ;
 wire \Di0_in[5][21] ;
 wire \Di0_in[5][22] ;
 wire \Di0_in[5][23] ;
 wire \Di0_in[5][24] ;
 wire \Di0_in[5][25] ;
 wire \Di0_in[5][26] ;
 wire \Di0_in[5][27] ;
 wire \Di0_in[5][28] ;
 wire \Di0_in[5][29] ;
 wire \Di0_in[5][2] ;
 wire \Di0_in[5][30] ;
 wire \Di0_in[5][31] ;
 wire \Di0_in[5][3] ;
 wire \Di0_in[5][4] ;
 wire \Di0_in[5][5] ;
 wire \Di0_in[5][6] ;
 wire \Di0_in[5][7] ;
 wire \Di0_in[5][8] ;
 wire \Di0_in[5][9] ;
 wire \Di0_in[6][0] ;
 wire \Di0_in[6][10] ;
 wire \Di0_in[6][11] ;
 wire \Di0_in[6][12] ;
 wire \Di0_in[6][13] ;
 wire \Di0_in[6][14] ;
 wire \Di0_in[6][15] ;
 wire \Di0_in[6][16] ;
 wire \Di0_in[6][17] ;
 wire \Di0_in[6][18] ;
 wire \Di0_in[6][19] ;
 wire \Di0_in[6][1] ;
 wire \Di0_in[6][20] ;
 wire \Di0_in[6][21] ;
 wire \Di0_in[6][22] ;
 wire \Di0_in[6][23] ;
 wire \Di0_in[6][24] ;
 wire \Di0_in[6][25] ;
 wire \Di0_in[6][26] ;
 wire \Di0_in[6][27] ;
 wire \Di0_in[6][28] ;
 wire \Di0_in[6][29] ;
 wire \Di0_in[6][2] ;
 wire \Di0_in[6][30] ;
 wire \Di0_in[6][31] ;
 wire \Di0_in[6][3] ;
 wire \Di0_in[6][4] ;
 wire \Di0_in[6][5] ;
 wire \Di0_in[6][6] ;
 wire \Di0_in[6][7] ;
 wire \Di0_in[6][8] ;
 wire \Di0_in[6][9] ;
 wire \Di0_in[7][0] ;
 wire \Di0_in[7][10] ;
 wire \Di0_in[7][11] ;
 wire \Di0_in[7][12] ;
 wire \Di0_in[7][13] ;
 wire \Di0_in[7][14] ;
 wire \Di0_in[7][15] ;
 wire \Di0_in[7][16] ;
 wire \Di0_in[7][17] ;
 wire \Di0_in[7][18] ;
 wire \Di0_in[7][19] ;
 wire \Di0_in[7][1] ;
 wire \Di0_in[7][20] ;
 wire \Di0_in[7][21] ;
 wire \Di0_in[7][22] ;
 wire \Di0_in[7][23] ;
 wire \Di0_in[7][24] ;
 wire \Di0_in[7][25] ;
 wire \Di0_in[7][26] ;
 wire \Di0_in[7][27] ;
 wire \Di0_in[7][28] ;
 wire \Di0_in[7][29] ;
 wire \Di0_in[7][2] ;
 wire \Di0_in[7][30] ;
 wire \Di0_in[7][31] ;
 wire \Di0_in[7][3] ;
 wire \Di0_in[7][4] ;
 wire \Di0_in[7][5] ;
 wire \Di0_in[7][6] ;
 wire \Di0_in[7][7] ;
 wire \Di0_in[7][8] ;
 wire \Di0_in[7][9] ;
 wire \Di0_in[8][0] ;
 wire \Di0_in[8][10] ;
 wire \Di0_in[8][11] ;
 wire \Di0_in[8][12] ;
 wire \Di0_in[8][13] ;
 wire \Di0_in[8][14] ;
 wire \Di0_in[8][15] ;
 wire \Di0_in[8][16] ;
 wire \Di0_in[8][17] ;
 wire \Di0_in[8][18] ;
 wire \Di0_in[8][19] ;
 wire \Di0_in[8][1] ;
 wire \Di0_in[8][20] ;
 wire \Di0_in[8][21] ;
 wire \Di0_in[8][22] ;
 wire \Di0_in[8][23] ;
 wire \Di0_in[8][24] ;
 wire \Di0_in[8][25] ;
 wire \Di0_in[8][26] ;
 wire \Di0_in[8][27] ;
 wire \Di0_in[8][28] ;
 wire \Di0_in[8][29] ;
 wire \Di0_in[8][2] ;
 wire \Di0_in[8][30] ;
 wire \Di0_in[8][31] ;
 wire \Di0_in[8][3] ;
 wire \Di0_in[8][4] ;
 wire \Di0_in[8][5] ;
 wire \Di0_in[8][6] ;
 wire \Di0_in[8][7] ;
 wire \Di0_in[8][8] ;
 wire \Di0_in[8][9] ;
 wire \Di0_in[9][0] ;
 wire \Di0_in[9][10] ;
 wire \Di0_in[9][11] ;
 wire \Di0_in[9][12] ;
 wire \Di0_in[9][13] ;
 wire \Di0_in[9][14] ;
 wire \Di0_in[9][15] ;
 wire \Di0_in[9][16] ;
 wire \Di0_in[9][17] ;
 wire \Di0_in[9][18] ;
 wire \Di0_in[9][19] ;
 wire \Di0_in[9][1] ;
 wire \Di0_in[9][20] ;
 wire \Di0_in[9][21] ;
 wire \Di0_in[9][22] ;
 wire \Di0_in[9][23] ;
 wire \Di0_in[9][24] ;
 wire \Di0_in[9][25] ;
 wire \Di0_in[9][26] ;
 wire \Di0_in[9][27] ;
 wire \Di0_in[9][28] ;
 wire \Di0_in[9][29] ;
 wire \Di0_in[9][2] ;
 wire \Di0_in[9][30] ;
 wire \Di0_in[9][31] ;
 wire \Di0_in[9][3] ;
 wire \Di0_in[9][4] ;
 wire \Di0_in[9][5] ;
 wire \Di0_in[9][6] ;
 wire \Di0_in[9][7] ;
 wire \Di0_in[9][8] ;
 wire \Di0_in[9][9] ;
 wire \Do0_pre[15][0] ;
 wire \Do0_pre[15][10] ;
 wire \Do0_pre[15][11] ;
 wire \Do0_pre[15][12] ;
 wire \Do0_pre[15][13] ;
 wire \Do0_pre[15][14] ;
 wire \Do0_pre[15][15] ;
 wire \Do0_pre[15][16] ;
 wire \Do0_pre[15][17] ;
 wire \Do0_pre[15][18] ;
 wire \Do0_pre[15][19] ;
 wire \Do0_pre[15][1] ;
 wire \Do0_pre[15][20] ;
 wire \Do0_pre[15][21] ;
 wire \Do0_pre[15][22] ;
 wire \Do0_pre[15][23] ;
 wire \Do0_pre[15][24] ;
 wire \Do0_pre[15][25] ;
 wire \Do0_pre[15][26] ;
 wire \Do0_pre[15][27] ;
 wire \Do0_pre[15][28] ;
 wire \Do0_pre[15][29] ;
 wire \Do0_pre[15][2] ;
 wire \Do0_pre[15][30] ;
 wire \Do0_pre[15][31] ;
 wire \Do0_pre[15][3] ;
 wire \Do0_pre[15][4] ;
 wire \Do0_pre[15][5] ;
 wire \Do0_pre[15][6] ;
 wire \Do0_pre[15][7] ;
 wire \Do0_pre[15][8] ;
 wire \Do0_pre[15][9] ;
 wire \Do1_pre0[0][0] ;
 wire \Do1_pre0[0][10] ;
 wire \Do1_pre0[0][11] ;
 wire \Do1_pre0[0][12] ;
 wire \Do1_pre0[0][13] ;
 wire \Do1_pre0[0][14] ;
 wire \Do1_pre0[0][15] ;
 wire \Do1_pre0[0][16] ;
 wire \Do1_pre0[0][17] ;
 wire \Do1_pre0[0][18] ;
 wire \Do1_pre0[0][19] ;
 wire \Do1_pre0[0][1] ;
 wire \Do1_pre0[0][20] ;
 wire \Do1_pre0[0][21] ;
 wire \Do1_pre0[0][22] ;
 wire \Do1_pre0[0][23] ;
 wire \Do1_pre0[0][24] ;
 wire \Do1_pre0[0][25] ;
 wire \Do1_pre0[0][26] ;
 wire \Do1_pre0[0][27] ;
 wire \Do1_pre0[0][28] ;
 wire \Do1_pre0[0][29] ;
 wire \Do1_pre0[0][2] ;
 wire \Do1_pre0[0][30] ;
 wire \Do1_pre0[0][31] ;
 wire \Do1_pre0[0][3] ;
 wire \Do1_pre0[0][4] ;
 wire \Do1_pre0[0][5] ;
 wire \Do1_pre0[0][6] ;
 wire \Do1_pre0[0][7] ;
 wire \Do1_pre0[0][8] ;
 wire \Do1_pre0[0][9] ;
 wire \Do1_pre0[1][0] ;
 wire \Do1_pre0[1][10] ;
 wire \Do1_pre0[1][11] ;
 wire \Do1_pre0[1][12] ;
 wire \Do1_pre0[1][13] ;
 wire \Do1_pre0[1][14] ;
 wire \Do1_pre0[1][15] ;
 wire \Do1_pre0[1][16] ;
 wire \Do1_pre0[1][17] ;
 wire \Do1_pre0[1][18] ;
 wire \Do1_pre0[1][19] ;
 wire \Do1_pre0[1][1] ;
 wire \Do1_pre0[1][20] ;
 wire \Do1_pre0[1][21] ;
 wire \Do1_pre0[1][22] ;
 wire \Do1_pre0[1][23] ;
 wire \Do1_pre0[1][24] ;
 wire \Do1_pre0[1][25] ;
 wire \Do1_pre0[1][26] ;
 wire \Do1_pre0[1][27] ;
 wire \Do1_pre0[1][28] ;
 wire \Do1_pre0[1][29] ;
 wire \Do1_pre0[1][2] ;
 wire \Do1_pre0[1][30] ;
 wire \Do1_pre0[1][31] ;
 wire \Do1_pre0[1][3] ;
 wire \Do1_pre0[1][4] ;
 wire \Do1_pre0[1][5] ;
 wire \Do1_pre0[1][6] ;
 wire \Do1_pre0[1][7] ;
 wire \Do1_pre0[1][8] ;
 wire \Do1_pre0[1][9] ;
 wire \Do1_pre0[2][0] ;
 wire \Do1_pre0[2][10] ;
 wire \Do1_pre0[2][11] ;
 wire \Do1_pre0[2][12] ;
 wire \Do1_pre0[2][13] ;
 wire \Do1_pre0[2][14] ;
 wire \Do1_pre0[2][15] ;
 wire \Do1_pre0[2][16] ;
 wire \Do1_pre0[2][17] ;
 wire \Do1_pre0[2][18] ;
 wire \Do1_pre0[2][19] ;
 wire \Do1_pre0[2][1] ;
 wire \Do1_pre0[2][20] ;
 wire \Do1_pre0[2][21] ;
 wire \Do1_pre0[2][22] ;
 wire \Do1_pre0[2][23] ;
 wire \Do1_pre0[2][24] ;
 wire \Do1_pre0[2][25] ;
 wire \Do1_pre0[2][26] ;
 wire \Do1_pre0[2][27] ;
 wire \Do1_pre0[2][28] ;
 wire \Do1_pre0[2][29] ;
 wire \Do1_pre0[2][2] ;
 wire \Do1_pre0[2][30] ;
 wire \Do1_pre0[2][31] ;
 wire \Do1_pre0[2][3] ;
 wire \Do1_pre0[2][4] ;
 wire \Do1_pre0[2][5] ;
 wire \Do1_pre0[2][6] ;
 wire \Do1_pre0[2][7] ;
 wire \Do1_pre0[2][8] ;
 wire \Do1_pre0[2][9] ;
 wire \Do1_pre0[3][0] ;
 wire \Do1_pre0[3][10] ;
 wire \Do1_pre0[3][11] ;
 wire \Do1_pre0[3][12] ;
 wire \Do1_pre0[3][13] ;
 wire \Do1_pre0[3][14] ;
 wire \Do1_pre0[3][15] ;
 wire \Do1_pre0[3][16] ;
 wire \Do1_pre0[3][17] ;
 wire \Do1_pre0[3][18] ;
 wire \Do1_pre0[3][19] ;
 wire \Do1_pre0[3][1] ;
 wire \Do1_pre0[3][20] ;
 wire \Do1_pre0[3][21] ;
 wire \Do1_pre0[3][22] ;
 wire \Do1_pre0[3][23] ;
 wire \Do1_pre0[3][24] ;
 wire \Do1_pre0[3][25] ;
 wire \Do1_pre0[3][26] ;
 wire \Do1_pre0[3][27] ;
 wire \Do1_pre0[3][28] ;
 wire \Do1_pre0[3][29] ;
 wire \Do1_pre0[3][2] ;
 wire \Do1_pre0[3][30] ;
 wire \Do1_pre0[3][31] ;
 wire \Do1_pre0[3][3] ;
 wire \Do1_pre0[3][4] ;
 wire \Do1_pre0[3][5] ;
 wire \Do1_pre0[3][6] ;
 wire \Do1_pre0[3][7] ;
 wire \Do1_pre0[3][8] ;
 wire \Do1_pre0[3][9] ;
 wire \Do1_pre1[0][0] ;
 wire \Do1_pre1[0][10] ;
 wire \Do1_pre1[0][11] ;
 wire \Do1_pre1[0][12] ;
 wire \Do1_pre1[0][13] ;
 wire \Do1_pre1[0][14] ;
 wire \Do1_pre1[0][15] ;
 wire \Do1_pre1[0][16] ;
 wire \Do1_pre1[0][17] ;
 wire \Do1_pre1[0][18] ;
 wire \Do1_pre1[0][19] ;
 wire \Do1_pre1[0][1] ;
 wire \Do1_pre1[0][20] ;
 wire \Do1_pre1[0][21] ;
 wire \Do1_pre1[0][22] ;
 wire \Do1_pre1[0][23] ;
 wire \Do1_pre1[0][24] ;
 wire \Do1_pre1[0][25] ;
 wire \Do1_pre1[0][26] ;
 wire \Do1_pre1[0][27] ;
 wire \Do1_pre1[0][28] ;
 wire \Do1_pre1[0][29] ;
 wire \Do1_pre1[0][2] ;
 wire \Do1_pre1[0][30] ;
 wire \Do1_pre1[0][31] ;
 wire \Do1_pre1[0][3] ;
 wire \Do1_pre1[0][4] ;
 wire \Do1_pre1[0][5] ;
 wire \Do1_pre1[0][6] ;
 wire \Do1_pre1[0][7] ;
 wire \Do1_pre1[0][8] ;
 wire \Do1_pre1[0][9] ;
 wire \Do1_pre1[1][0] ;
 wire \Do1_pre1[1][10] ;
 wire \Do1_pre1[1][11] ;
 wire \Do1_pre1[1][12] ;
 wire \Do1_pre1[1][13] ;
 wire \Do1_pre1[1][14] ;
 wire \Do1_pre1[1][15] ;
 wire \Do1_pre1[1][16] ;
 wire \Do1_pre1[1][17] ;
 wire \Do1_pre1[1][18] ;
 wire \Do1_pre1[1][19] ;
 wire \Do1_pre1[1][1] ;
 wire \Do1_pre1[1][20] ;
 wire \Do1_pre1[1][21] ;
 wire \Do1_pre1[1][22] ;
 wire \Do1_pre1[1][23] ;
 wire \Do1_pre1[1][24] ;
 wire \Do1_pre1[1][25] ;
 wire \Do1_pre1[1][26] ;
 wire \Do1_pre1[1][27] ;
 wire \Do1_pre1[1][28] ;
 wire \Do1_pre1[1][29] ;
 wire \Do1_pre1[1][2] ;
 wire \Do1_pre1[1][30] ;
 wire \Do1_pre1[1][31] ;
 wire \Do1_pre1[1][3] ;
 wire \Do1_pre1[1][4] ;
 wire \Do1_pre1[1][5] ;
 wire \Do1_pre1[1][6] ;
 wire \Do1_pre1[1][7] ;
 wire \Do1_pre1[1][8] ;
 wire \Do1_pre1[1][9] ;
 wire \Do1_pre1[2][0] ;
 wire \Do1_pre1[2][10] ;
 wire \Do1_pre1[2][11] ;
 wire \Do1_pre1[2][12] ;
 wire \Do1_pre1[2][13] ;
 wire \Do1_pre1[2][14] ;
 wire \Do1_pre1[2][15] ;
 wire \Do1_pre1[2][16] ;
 wire \Do1_pre1[2][17] ;
 wire \Do1_pre1[2][18] ;
 wire \Do1_pre1[2][19] ;
 wire \Do1_pre1[2][1] ;
 wire \Do1_pre1[2][20] ;
 wire \Do1_pre1[2][21] ;
 wire \Do1_pre1[2][22] ;
 wire \Do1_pre1[2][23] ;
 wire \Do1_pre1[2][24] ;
 wire \Do1_pre1[2][25] ;
 wire \Do1_pre1[2][26] ;
 wire \Do1_pre1[2][27] ;
 wire \Do1_pre1[2][28] ;
 wire \Do1_pre1[2][29] ;
 wire \Do1_pre1[2][2] ;
 wire \Do1_pre1[2][30] ;
 wire \Do1_pre1[2][31] ;
 wire \Do1_pre1[2][3] ;
 wire \Do1_pre1[2][4] ;
 wire \Do1_pre1[2][5] ;
 wire \Do1_pre1[2][6] ;
 wire \Do1_pre1[2][7] ;
 wire \Do1_pre1[2][8] ;
 wire \Do1_pre1[2][9] ;
 wire \Do1_pre1[3][0] ;
 wire \Do1_pre1[3][10] ;
 wire \Do1_pre1[3][11] ;
 wire \Do1_pre1[3][12] ;
 wire \Do1_pre1[3][13] ;
 wire \Do1_pre1[3][14] ;
 wire \Do1_pre1[3][15] ;
 wire \Do1_pre1[3][16] ;
 wire \Do1_pre1[3][17] ;
 wire \Do1_pre1[3][18] ;
 wire \Do1_pre1[3][19] ;
 wire \Do1_pre1[3][1] ;
 wire \Do1_pre1[3][20] ;
 wire \Do1_pre1[3][21] ;
 wire \Do1_pre1[3][22] ;
 wire \Do1_pre1[3][23] ;
 wire \Do1_pre1[3][24] ;
 wire \Do1_pre1[3][25] ;
 wire \Do1_pre1[3][26] ;
 wire \Do1_pre1[3][27] ;
 wire \Do1_pre1[3][28] ;
 wire \Do1_pre1[3][29] ;
 wire \Do1_pre1[3][2] ;
 wire \Do1_pre1[3][30] ;
 wire \Do1_pre1[3][31] ;
 wire \Do1_pre1[3][3] ;
 wire \Do1_pre1[3][4] ;
 wire \Do1_pre1[3][5] ;
 wire \Do1_pre1[3][6] ;
 wire \Do1_pre1[3][7] ;
 wire \Do1_pre1[3][8] ;
 wire \Do1_pre1[3][9] ;
 wire \Do1_pre[0][0] ;
 wire \Do1_pre[0][10] ;
 wire \Do1_pre[0][11] ;
 wire \Do1_pre[0][12] ;
 wire \Do1_pre[0][13] ;
 wire \Do1_pre[0][14] ;
 wire \Do1_pre[0][15] ;
 wire \Do1_pre[0][16] ;
 wire \Do1_pre[0][17] ;
 wire \Do1_pre[0][18] ;
 wire \Do1_pre[0][19] ;
 wire \Do1_pre[0][1] ;
 wire \Do1_pre[0][20] ;
 wire \Do1_pre[0][21] ;
 wire \Do1_pre[0][22] ;
 wire \Do1_pre[0][23] ;
 wire \Do1_pre[0][24] ;
 wire \Do1_pre[0][25] ;
 wire \Do1_pre[0][26] ;
 wire \Do1_pre[0][27] ;
 wire \Do1_pre[0][28] ;
 wire \Do1_pre[0][29] ;
 wire \Do1_pre[0][2] ;
 wire \Do1_pre[0][30] ;
 wire \Do1_pre[0][31] ;
 wire \Do1_pre[0][3] ;
 wire \Do1_pre[0][4] ;
 wire \Do1_pre[0][5] ;
 wire \Do1_pre[0][6] ;
 wire \Do1_pre[0][7] ;
 wire \Do1_pre[0][8] ;
 wire \Do1_pre[0][9] ;
 wire \Do1_pre[1][0] ;
 wire \Do1_pre[1][10] ;
 wire \Do1_pre[1][11] ;
 wire \Do1_pre[1][12] ;
 wire \Do1_pre[1][13] ;
 wire \Do1_pre[1][14] ;
 wire \Do1_pre[1][15] ;
 wire \Do1_pre[1][16] ;
 wire \Do1_pre[1][17] ;
 wire \Do1_pre[1][18] ;
 wire \Do1_pre[1][19] ;
 wire \Do1_pre[1][1] ;
 wire \Do1_pre[1][20] ;
 wire \Do1_pre[1][21] ;
 wire \Do1_pre[1][22] ;
 wire \Do1_pre[1][23] ;
 wire \Do1_pre[1][24] ;
 wire \Do1_pre[1][25] ;
 wire \Do1_pre[1][26] ;
 wire \Do1_pre[1][27] ;
 wire \Do1_pre[1][28] ;
 wire \Do1_pre[1][29] ;
 wire \Do1_pre[1][2] ;
 wire \Do1_pre[1][30] ;
 wire \Do1_pre[1][31] ;
 wire \Do1_pre[1][3] ;
 wire \Do1_pre[1][4] ;
 wire \Do1_pre[1][5] ;
 wire \Do1_pre[1][6] ;
 wire \Do1_pre[1][7] ;
 wire \Do1_pre[1][8] ;
 wire \Do1_pre[1][9] ;
 wire \Do1_pre[2][0] ;
 wire \Do1_pre[2][10] ;
 wire \Do1_pre[2][11] ;
 wire \Do1_pre[2][12] ;
 wire \Do1_pre[2][13] ;
 wire \Do1_pre[2][14] ;
 wire \Do1_pre[2][15] ;
 wire \Do1_pre[2][16] ;
 wire \Do1_pre[2][17] ;
 wire \Do1_pre[2][18] ;
 wire \Do1_pre[2][19] ;
 wire \Do1_pre[2][1] ;
 wire \Do1_pre[2][20] ;
 wire \Do1_pre[2][21] ;
 wire \Do1_pre[2][22] ;
 wire \Do1_pre[2][23] ;
 wire \Do1_pre[2][24] ;
 wire \Do1_pre[2][25] ;
 wire \Do1_pre[2][26] ;
 wire \Do1_pre[2][27] ;
 wire \Do1_pre[2][28] ;
 wire \Do1_pre[2][29] ;
 wire \Do1_pre[2][2] ;
 wire \Do1_pre[2][30] ;
 wire \Do1_pre[2][31] ;
 wire \Do1_pre[2][3] ;
 wire \Do1_pre[2][4] ;
 wire \Do1_pre[2][5] ;
 wire \Do1_pre[2][6] ;
 wire \Do1_pre[2][7] ;
 wire \Do1_pre[2][8] ;
 wire \Do1_pre[2][9] ;
 wire \Do1_pre[3][0] ;
 wire \Do1_pre[3][10] ;
 wire \Do1_pre[3][11] ;
 wire \Do1_pre[3][12] ;
 wire \Do1_pre[3][13] ;
 wire \Do1_pre[3][14] ;
 wire \Do1_pre[3][15] ;
 wire \Do1_pre[3][16] ;
 wire \Do1_pre[3][17] ;
 wire \Do1_pre[3][18] ;
 wire \Do1_pre[3][19] ;
 wire \Do1_pre[3][1] ;
 wire \Do1_pre[3][20] ;
 wire \Do1_pre[3][21] ;
 wire \Do1_pre[3][22] ;
 wire \Do1_pre[3][23] ;
 wire \Do1_pre[3][24] ;
 wire \Do1_pre[3][25] ;
 wire \Do1_pre[3][26] ;
 wire \Do1_pre[3][27] ;
 wire \Do1_pre[3][28] ;
 wire \Do1_pre[3][29] ;
 wire \Do1_pre[3][2] ;
 wire \Do1_pre[3][30] ;
 wire \Do1_pre[3][31] ;
 wire \Do1_pre[3][3] ;
 wire \Do1_pre[3][4] ;
 wire \Do1_pre[3][5] ;
 wire \Do1_pre[3][6] ;
 wire \Do1_pre[3][7] ;
 wire \Do1_pre[3][8] ;
 wire \Do1_pre[3][9] ;
 wire \LE0[0] ;
 wire \LE0[10] ;
 wire \LE0[11] ;
 wire \LE0[12] ;
 wire \LE0[13] ;
 wire \LE0[14] ;
 wire \LE0[15] ;
 wire \LE0[1] ;
 wire \LE0[2] ;
 wire \LE0[3] ;
 wire \LE0[4] ;
 wire \LE0[5] ;
 wire \LE0[6] ;
 wire \LE0[7] ;
 wire \LE0[8] ;
 wire \LE0[9] ;
 wire \OUT_NAND[0].OUT_MUX.A0 ;
 wire \OUT_NAND[0].OUT_MUX.X ;
 wire \OUT_NAND[10].OUT_MUX.A0 ;
 wire \OUT_NAND[10].OUT_MUX.X ;
 wire \OUT_NAND[11].OUT_MUX.A0 ;
 wire \OUT_NAND[11].OUT_MUX.X ;
 wire \OUT_NAND[12].OUT_MUX.A0 ;
 wire \OUT_NAND[12].OUT_MUX.X ;
 wire \OUT_NAND[13].OUT_MUX.A0 ;
 wire \OUT_NAND[13].OUT_MUX.X ;
 wire \OUT_NAND[14].OUT_MUX.A0 ;
 wire \OUT_NAND[14].OUT_MUX.X ;
 wire \OUT_NAND[15].OUT_MUX.A0 ;
 wire \OUT_NAND[15].OUT_MUX.X ;
 wire \OUT_NAND[16].OUT_MUX.A0 ;
 wire \OUT_NAND[16].OUT_MUX.X ;
 wire \OUT_NAND[17].OUT_MUX.A0 ;
 wire \OUT_NAND[17].OUT_MUX.X ;
 wire \OUT_NAND[18].OUT_MUX.A0 ;
 wire \OUT_NAND[18].OUT_MUX.X ;
 wire \OUT_NAND[19].OUT_MUX.A0 ;
 wire \OUT_NAND[19].OUT_MUX.X ;
 wire \OUT_NAND[1].OUT_MUX.A0 ;
 wire \OUT_NAND[1].OUT_MUX.X ;
 wire \OUT_NAND[20].OUT_MUX.A0 ;
 wire \OUT_NAND[20].OUT_MUX.X ;
 wire \OUT_NAND[21].OUT_MUX.A0 ;
 wire \OUT_NAND[21].OUT_MUX.X ;
 wire \OUT_NAND[22].OUT_MUX.A0 ;
 wire \OUT_NAND[22].OUT_MUX.X ;
 wire \OUT_NAND[23].OUT_MUX.A0 ;
 wire \OUT_NAND[23].OUT_MUX.X ;
 wire \OUT_NAND[24].OUT_MUX.A0 ;
 wire \OUT_NAND[24].OUT_MUX.X ;
 wire \OUT_NAND[25].OUT_MUX.A0 ;
 wire \OUT_NAND[25].OUT_MUX.X ;
 wire \OUT_NAND[26].OUT_MUX.A0 ;
 wire \OUT_NAND[26].OUT_MUX.X ;
 wire \OUT_NAND[27].OUT_MUX.A0 ;
 wire \OUT_NAND[27].OUT_MUX.X ;
 wire \OUT_NAND[28].OUT_MUX.A0 ;
 wire \OUT_NAND[28].OUT_MUX.X ;
 wire \OUT_NAND[29].OUT_MUX.A0 ;
 wire \OUT_NAND[29].OUT_MUX.X ;
 wire \OUT_NAND[2].OUT_MUX.A0 ;
 wire \OUT_NAND[2].OUT_MUX.X ;
 wire \OUT_NAND[30].OUT_MUX.A0 ;
 wire \OUT_NAND[30].OUT_MUX.X ;
 wire \OUT_NAND[31].OUT_MUX.A0 ;
 wire \OUT_NAND[31].OUT_MUX.X ;
 wire \OUT_NAND[3].OUT_MUX.A0 ;
 wire \OUT_NAND[3].OUT_MUX.X ;
 wire \OUT_NAND[4].OUT_MUX.A0 ;
 wire \OUT_NAND[4].OUT_MUX.X ;
 wire \OUT_NAND[5].OUT_MUX.A0 ;
 wire \OUT_NAND[5].OUT_MUX.X ;
 wire \OUT_NAND[6].OUT_MUX.A0 ;
 wire \OUT_NAND[6].OUT_MUX.X ;
 wire \OUT_NAND[7].OUT_MUX.A0 ;
 wire \OUT_NAND[7].OUT_MUX.X ;
 wire \OUT_NAND[8].OUT_MUX.A0 ;
 wire \OUT_NAND[8].OUT_MUX.X ;
 wire \OUT_NAND[9].OUT_MUX.A0 ;
 wire \OUT_NAND[9].OUT_MUX.X ;
 wire \QUADS[0].QBIT[0].QUAD_A22OI0.A2 ;
 wire \QUADS[0].QBIT[0].QUAD_A22OI0.B2 ;
 wire \QUADS[0].QBIT[0].QUAD_A22OI1.A2 ;
 wire \QUADS[0].QBIT[0].QUAD_A22OI1.B2 ;
 wire \QUADS[1].QBIT[0].QUAD_A22OI0.A2 ;
 wire \QUADS[1].QBIT[0].QUAD_A22OI0.B2 ;
 wire \QUADS[1].QBIT[0].QUAD_A22OI1.A2 ;
 wire \QUADS[1].QBIT[0].QUAD_A22OI1.B2 ;
 wire \QUADS[2].QBIT[0].QUAD_A22OI0.A2 ;
 wire \QUADS[2].QBIT[0].QUAD_A22OI0.B2 ;
 wire \QUADS[2].QBIT[0].QUAD_A22OI1.A2 ;
 wire \QUADS[2].QBIT[0].QUAD_A22OI1.B2 ;
 wire \QUADS[3].QBIT[0].QUAD_A22OI0.A2 ;
 wire \QUADS[3].QBIT[0].QUAD_A22OI0.B2 ;
 wire \QUADS[3].QBIT[0].QUAD_A22OI1.A2 ;
 wire \QUADS[3].QBIT[0].QUAD_A22OI1.B2 ;

 sg13cmos5l_buf_2 \A0BUF[0].__cell__  (.A(A0[0]),
    .X(\A0BUF[0].X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \A0BUF[1].__cell__  (.A(A0[1]),
    .X(\A0BUF[1].X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \A0BUF[2].__cell__  (.A(A0[2]),
    .X(\A0BUF[2].X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \A0BUF[3].__cell__  (.A(A0[3]),
    .X(\A0BUF[3].X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \ANTENNA_BYPBUF.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(BYP));
 sg13cmos5l_antennanp \ANTENNA_BYPBUF.__cell___X  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_DEC0.D.AND0_B_N  (.VDD(VPWR),
    .VSS(VGND),
    .A(EN0));
 sg13cmos5l_antennanp \ANTENNA_DEC0.D.AND1_B  (.VDD(VPWR),
    .VSS(VGND),
    .A(EN0));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[0].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[0]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[0].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[10].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[10]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[10].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[11].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[11]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[11].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[12].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[12]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[12].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[13].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[13]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[13].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[14].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[14]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[14].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[15].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[15]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[15].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[16].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[16]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[16].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[17].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[17]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[17].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[18].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[18]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[18].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[19].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[19]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[19].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[1].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[1]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[1].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[20].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[20]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[20].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[21].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[21]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[21].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[22].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[22]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[22].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[23].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[23]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[23].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[24].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[24]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[24].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[25].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[25]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[25].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[26].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[26]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[26].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[27].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[27]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[27].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[28].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[28]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[28].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[29].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[29]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[29].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[2].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[2]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[2].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[30].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[30]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[30].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[31].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[31]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[31].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[3].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[3]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[3].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[4].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[4]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[4].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[5].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[5]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[5].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[6].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[6]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[6].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[7].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[7]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[7].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[8].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[8]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[8].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[9].OUT_MUX.__cell___A1  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[9]));
 sg13cmos5l_antennanp \ANTENNA_OUT_NAND[9].OUT_MUX.__cell___S  (.VDD(VPWR),
    .VSS(VGND),
    .A(\BYPBUF.X ));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[0].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[0]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[10].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[10]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[11].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[11]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[12].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[12]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[13].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[13]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[14].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[14]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[15].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[15]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[16].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[16]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[17].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[17]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[18].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[18]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[19].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[19]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[1].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[1]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[20].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[20]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[21].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[21]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[22].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[22]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[23].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[23]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[24].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[24]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[25].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[25]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[26].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[26]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[27].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[27]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[28].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[28]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[29].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[29]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[2].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[2]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[30].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[30]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[31].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[31]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[3].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[3]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[4].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[4]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[5].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[5]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[6].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[6]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[7].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[7]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[8].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[8]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].CWORD.CFG_BIT[9].STORAGE_D  (.VDD(VPWR),
    .VSS(VGND),
    .A(Di0[9]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[0]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[0].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[10].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[10]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[10].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[11].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[11]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[11].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[12].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[12]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[12].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[13].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[13]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[13].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[14].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[14]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[14].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[15].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[15]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[15].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[1].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[1]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[1].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[2].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[2]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[2].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[3].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[3]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[3].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[4].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[4]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[4].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[5].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[5]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[5].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[6].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[6]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[6].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[7].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[7]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[7].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[8].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[8]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[8].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_antennanp \ANTENNA_SLICE[9].ROW_AND.__cell___A  (.VDD(VPWR),
    .VSS(VGND),
    .A(WROW[9]));
 sg13cmos5l_antennanp \ANTENNA_SLICE[9].ROW_AND.__cell___B  (.VDD(VPWR),
    .VSS(VGND),
    .A(WE0));
 sg13cmos5l_buf_2 \BYPBUF.__cell__  (.A(BYP),
    .X(\BYPBUF.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nor2b_1 \DEC0.D.AND0  (.A(\A0BUF[3].X ),
    .B_N(EN0),
    .Y(\DEC0.D.SEL[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \DEC0.D.AND1  (.A(\A0BUF[3].X ),
    .B(EN0),
    .X(\DEC0.D.SEL[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D0.ABUF[0]  (.A(\A0BUF[0].X ),
    .X(\DEC0.D0.A_buf[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D0.ABUF[1]  (.A(\A0BUF[1].X ),
    .X(\DEC0.D0.A_buf[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D0.ABUF[2]  (.A(\A0BUF[2].X ),
    .X(\DEC0.D0.A_buf[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND0  (.A(\DEC0.D0.A_N[0] ),
    .B(\DEC0.D0.A_N[1] ),
    .C(\DEC0.D0.A_N[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND1  (.A(\DEC0.D0.A_buf[0] ),
    .B(\DEC0.D0.A_N[1] ),
    .C(\DEC0.D0.A_N[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND2  (.A(\DEC0.D0.A_N[0] ),
    .B(\DEC0.D0.A_buf[1] ),
    .C(\DEC0.D0.A_N[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND3  (.A(\DEC0.D0.A_buf[0] ),
    .B(\DEC0.D0.A_buf[1] ),
    .C(\DEC0.D0.A_N[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND4  (.A(\DEC0.D0.A_N[0] ),
    .B(\DEC0.D0.A_N[1] ),
    .C(\DEC0.D0.A_buf[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND5  (.A(\DEC0.D0.A_buf[0] ),
    .B(\DEC0.D0.A_N[1] ),
    .C(\DEC0.D0.A_buf[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND6  (.A(\DEC0.D0.A_N[0] ),
    .B(\DEC0.D0.A_buf[1] ),
    .C(\DEC0.D0.A_buf[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D0.AND7  (.A(\DEC0.D0.A_buf[0] ),
    .B(\DEC0.D0.A_buf[1] ),
    .C(\DEC0.D0.A_buf[2] ),
    .D(\DEC0.D0.EN_buf ),
    .X(\DEC0.D0.SEL[7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D0.ENBUF  (.A(\DEC0.D.SEL[0] ),
    .X(\DEC0.D0.EN_buf ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 \DEC0.D0.INV0  (.VDD(VPWR),
    .Y(\DEC0.D0.A_N[0] ),
    .A(\DEC0.D0.A_buf[0] ),
    .VSS(VGND));
 sg13cmos5l_inv_1 \DEC0.D0.INV1  (.VDD(VPWR),
    .Y(\DEC0.D0.A_N[1] ),
    .A(\DEC0.D0.A_buf[1] ),
    .VSS(VGND));
 sg13cmos5l_inv_1 \DEC0.D0.INV2  (.VDD(VPWR),
    .Y(\DEC0.D0.A_N[2] ),
    .A(\DEC0.D0.A_buf[2] ),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D1.ABUF[0]  (.A(\A0BUF[0].X ),
    .X(\DEC0.D1.A_buf[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D1.ABUF[1]  (.A(\A0BUF[1].X ),
    .X(\DEC0.D1.A_buf[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D1.ABUF[2]  (.A(\A0BUF[2].X ),
    .X(\DEC0.D1.A_buf[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND0  (.A(\DEC0.D1.A_N[0] ),
    .B(\DEC0.D1.A_N[1] ),
    .C(\DEC0.D1.A_N[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND1  (.A(\DEC0.D1.A_buf[0] ),
    .B(\DEC0.D1.A_N[1] ),
    .C(\DEC0.D1.A_N[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND2  (.A(\DEC0.D1.A_N[0] ),
    .B(\DEC0.D1.A_buf[1] ),
    .C(\DEC0.D1.A_N[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND3  (.A(\DEC0.D1.A_buf[0] ),
    .B(\DEC0.D1.A_buf[1] ),
    .C(\DEC0.D1.A_N[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND4  (.A(\DEC0.D1.A_N[0] ),
    .B(\DEC0.D1.A_N[1] ),
    .C(\DEC0.D1.A_buf[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND5  (.A(\DEC0.D1.A_buf[0] ),
    .B(\DEC0.D1.A_N[1] ),
    .C(\DEC0.D1.A_buf[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND6  (.A(\DEC0.D1.A_N[0] ),
    .B(\DEC0.D1.A_buf[1] ),
    .C(\DEC0.D1.A_buf[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and4_1 \DEC0.D1.AND7  (.A(\DEC0.D1.A_buf[0] ),
    .B(\DEC0.D1.A_buf[1] ),
    .C(\DEC0.D1.A_buf[2] ),
    .D(\DEC0.D1.EN_buf ),
    .X(\DEC0.D1.SEL[7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_2 \DEC0.D1.ENBUF  (.A(\DEC0.D.SEL[1] ),
    .X(\DEC0.D1.EN_buf ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 \DEC0.D1.INV0  (.VDD(VPWR),
    .Y(\DEC0.D1.A_N[0] ),
    .A(\DEC0.D1.A_buf[0] ),
    .VSS(VGND));
 sg13cmos5l_inv_1 \DEC0.D1.INV1  (.VDD(VPWR),
    .Y(\DEC0.D1.A_N[1] ),
    .A(\DEC0.D1.A_buf[1] ),
    .VSS(VGND));
 sg13cmos5l_inv_1 \DEC0.D1.INV2  (.VDD(VPWR),
    .Y(\DEC0.D1.A_N[2] ),
    .A(\DEC0.D1.A_buf[2] ),
    .VSS(VGND));
 sg13cmos5l_antennanp \DIODE_A0[0].__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(A0[0]));
 sg13cmos5l_antennanp \DIODE_A0[1].__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(A0[1]));
 sg13cmos5l_antennanp \DIODE_A0[2].__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(A0[2]));
 sg13cmos5l_antennanp \DIODE_A0[3].__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(A0[3]));
 sg13cmos5l_fill_2 FILLER_0_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_0_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_0_680 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_10_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_338 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_10_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_10_678 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_685 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_10_707 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_11_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_12_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_13_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_14_699 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_14_706 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_338 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_678 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_685 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_687 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_694 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_701 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_15_708 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_16_699 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_16_706 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_17_702 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_709 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_18_702 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_709 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_19_699 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_19_706 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_1_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_338 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_678 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_685 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_687 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_691 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_698 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_5_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_338 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_5_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_5_678 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_682 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_6_702 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_709 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_7_702 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_709 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_8_702 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_709 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_117 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_119 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_144 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_146 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_164 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_166 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_17 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_184 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_186 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_19 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_204 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_206 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_224 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_226 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_244 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_246 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_264 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_266 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_291 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_293 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_311 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_313 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_331 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_333 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_357 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_359 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_377 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_379 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_39 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_397 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_399 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_424 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_426 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_444 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_446 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_464 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_466 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_484 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_486 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_504 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_506 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_524 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_526 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_544 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_546 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_57 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_571 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_573 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_59 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_591 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_593 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_611 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_613 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_631 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_633 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_651 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_653 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_671 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_673 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_9_702 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_709 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_79 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_97 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_99 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_mux2_2 \OUT_NAND[0].OUT_MUX.__cell__  (.A0(\OUT_NAND[0].OUT_MUX.A0 ),
    .A1(Di0[0]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[0].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[0].QUAD_NAND.__cell__  (.B(\Do1_pre[1][0] ),
    .C(\Do1_pre[2][0] ),
    .A(\Do1_pre[0][0] ),
    .Y(\OUT_NAND[0].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][0] ));
 sg13cmos5l_mux2_2 \OUT_NAND[10].OUT_MUX.__cell__  (.A0(\OUT_NAND[10].OUT_MUX.A0 ),
    .A1(Di0[10]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[10].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[10].QUAD_NAND.__cell__  (.B(\Do1_pre[1][10] ),
    .C(\Do1_pre[2][10] ),
    .A(\Do1_pre[0][10] ),
    .Y(\OUT_NAND[10].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][10] ));
 sg13cmos5l_mux2_2 \OUT_NAND[11].OUT_MUX.__cell__  (.A0(\OUT_NAND[11].OUT_MUX.A0 ),
    .A1(Di0[11]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[11].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[11].QUAD_NAND.__cell__  (.B(\Do1_pre[1][11] ),
    .C(\Do1_pre[2][11] ),
    .A(\Do1_pre[0][11] ),
    .Y(\OUT_NAND[11].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][11] ));
 sg13cmos5l_mux2_2 \OUT_NAND[12].OUT_MUX.__cell__  (.A0(\OUT_NAND[12].OUT_MUX.A0 ),
    .A1(Di0[12]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[12].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[12].QUAD_NAND.__cell__  (.B(\Do1_pre[1][12] ),
    .C(\Do1_pre[2][12] ),
    .A(\Do1_pre[0][12] ),
    .Y(\OUT_NAND[12].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][12] ));
 sg13cmos5l_mux2_2 \OUT_NAND[13].OUT_MUX.__cell__  (.A0(\OUT_NAND[13].OUT_MUX.A0 ),
    .A1(Di0[13]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[13].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[13].QUAD_NAND.__cell__  (.B(\Do1_pre[1][13] ),
    .C(\Do1_pre[2][13] ),
    .A(\Do1_pre[0][13] ),
    .Y(\OUT_NAND[13].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][13] ));
 sg13cmos5l_mux2_2 \OUT_NAND[14].OUT_MUX.__cell__  (.A0(\OUT_NAND[14].OUT_MUX.A0 ),
    .A1(Di0[14]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[14].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[14].QUAD_NAND.__cell__  (.B(\Do1_pre[1][14] ),
    .C(\Do1_pre[2][14] ),
    .A(\Do1_pre[0][14] ),
    .Y(\OUT_NAND[14].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][14] ));
 sg13cmos5l_mux2_2 \OUT_NAND[15].OUT_MUX.__cell__  (.A0(\OUT_NAND[15].OUT_MUX.A0 ),
    .A1(Di0[15]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[15].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[15].QUAD_NAND.__cell__  (.B(\Do1_pre[1][15] ),
    .C(\Do1_pre[2][15] ),
    .A(\Do1_pre[0][15] ),
    .Y(\OUT_NAND[15].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][15] ));
 sg13cmos5l_mux2_2 \OUT_NAND[16].OUT_MUX.__cell__  (.A0(\OUT_NAND[16].OUT_MUX.A0 ),
    .A1(Di0[16]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[16].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[16].QUAD_NAND.__cell__  (.B(\Do1_pre[1][16] ),
    .C(\Do1_pre[2][16] ),
    .A(\Do1_pre[0][16] ),
    .Y(\OUT_NAND[16].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][16] ));
 sg13cmos5l_mux2_2 \OUT_NAND[17].OUT_MUX.__cell__  (.A0(\OUT_NAND[17].OUT_MUX.A0 ),
    .A1(Di0[17]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[17].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[17].QUAD_NAND.__cell__  (.B(\Do1_pre[1][17] ),
    .C(\Do1_pre[2][17] ),
    .A(\Do1_pre[0][17] ),
    .Y(\OUT_NAND[17].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][17] ));
 sg13cmos5l_mux2_2 \OUT_NAND[18].OUT_MUX.__cell__  (.A0(\OUT_NAND[18].OUT_MUX.A0 ),
    .A1(Di0[18]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[18].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[18].QUAD_NAND.__cell__  (.B(\Do1_pre[1][18] ),
    .C(\Do1_pre[2][18] ),
    .A(\Do1_pre[0][18] ),
    .Y(\OUT_NAND[18].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][18] ));
 sg13cmos5l_mux2_2 \OUT_NAND[19].OUT_MUX.__cell__  (.A0(\OUT_NAND[19].OUT_MUX.A0 ),
    .A1(Di0[19]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[19].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[19].QUAD_NAND.__cell__  (.B(\Do1_pre[1][19] ),
    .C(\Do1_pre[2][19] ),
    .A(\Do1_pre[0][19] ),
    .Y(\OUT_NAND[19].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][19] ));
 sg13cmos5l_mux2_2 \OUT_NAND[1].OUT_MUX.__cell__  (.A0(\OUT_NAND[1].OUT_MUX.A0 ),
    .A1(Di0[1]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[1].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[1].QUAD_NAND.__cell__  (.B(\Do1_pre[1][1] ),
    .C(\Do1_pre[2][1] ),
    .A(\Do1_pre[0][1] ),
    .Y(\OUT_NAND[1].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][1] ));
 sg13cmos5l_mux2_2 \OUT_NAND[20].OUT_MUX.__cell__  (.A0(\OUT_NAND[20].OUT_MUX.A0 ),
    .A1(Di0[20]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[20].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[20].QUAD_NAND.__cell__  (.B(\Do1_pre[1][20] ),
    .C(\Do1_pre[2][20] ),
    .A(\Do1_pre[0][20] ),
    .Y(\OUT_NAND[20].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][20] ));
 sg13cmos5l_mux2_2 \OUT_NAND[21].OUT_MUX.__cell__  (.A0(\OUT_NAND[21].OUT_MUX.A0 ),
    .A1(Di0[21]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[21].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[21].QUAD_NAND.__cell__  (.B(\Do1_pre[1][21] ),
    .C(\Do1_pre[2][21] ),
    .A(\Do1_pre[0][21] ),
    .Y(\OUT_NAND[21].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][21] ));
 sg13cmos5l_mux2_2 \OUT_NAND[22].OUT_MUX.__cell__  (.A0(\OUT_NAND[22].OUT_MUX.A0 ),
    .A1(Di0[22]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[22].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[22].QUAD_NAND.__cell__  (.B(\Do1_pre[1][22] ),
    .C(\Do1_pre[2][22] ),
    .A(\Do1_pre[0][22] ),
    .Y(\OUT_NAND[22].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][22] ));
 sg13cmos5l_mux2_2 \OUT_NAND[23].OUT_MUX.__cell__  (.A0(\OUT_NAND[23].OUT_MUX.A0 ),
    .A1(Di0[23]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[23].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[23].QUAD_NAND.__cell__  (.B(\Do1_pre[1][23] ),
    .C(\Do1_pre[2][23] ),
    .A(\Do1_pre[0][23] ),
    .Y(\OUT_NAND[23].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][23] ));
 sg13cmos5l_mux2_2 \OUT_NAND[24].OUT_MUX.__cell__  (.A0(\OUT_NAND[24].OUT_MUX.A0 ),
    .A1(Di0[24]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[24].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[24].QUAD_NAND.__cell__  (.B(\Do1_pre[1][24] ),
    .C(\Do1_pre[2][24] ),
    .A(\Do1_pre[0][24] ),
    .Y(\OUT_NAND[24].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][24] ));
 sg13cmos5l_mux2_2 \OUT_NAND[25].OUT_MUX.__cell__  (.A0(\OUT_NAND[25].OUT_MUX.A0 ),
    .A1(Di0[25]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[25].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[25].QUAD_NAND.__cell__  (.B(\Do1_pre[1][25] ),
    .C(\Do1_pre[2][25] ),
    .A(\Do1_pre[0][25] ),
    .Y(\OUT_NAND[25].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][25] ));
 sg13cmos5l_mux2_2 \OUT_NAND[26].OUT_MUX.__cell__  (.A0(\OUT_NAND[26].OUT_MUX.A0 ),
    .A1(Di0[26]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[26].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[26].QUAD_NAND.__cell__  (.B(\Do1_pre[1][26] ),
    .C(\Do1_pre[2][26] ),
    .A(\Do1_pre[0][26] ),
    .Y(\OUT_NAND[26].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][26] ));
 sg13cmos5l_mux2_2 \OUT_NAND[27].OUT_MUX.__cell__  (.A0(\OUT_NAND[27].OUT_MUX.A0 ),
    .A1(Di0[27]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[27].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[27].QUAD_NAND.__cell__  (.B(\Do1_pre[1][27] ),
    .C(\Do1_pre[2][27] ),
    .A(\Do1_pre[0][27] ),
    .Y(\OUT_NAND[27].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][27] ));
 sg13cmos5l_mux2_2 \OUT_NAND[28].OUT_MUX.__cell__  (.A0(\OUT_NAND[28].OUT_MUX.A0 ),
    .A1(Di0[28]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[28].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[28].QUAD_NAND.__cell__  (.B(\Do1_pre[1][28] ),
    .C(\Do1_pre[2][28] ),
    .A(\Do1_pre[0][28] ),
    .Y(\OUT_NAND[28].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][28] ));
 sg13cmos5l_mux2_2 \OUT_NAND[29].OUT_MUX.__cell__  (.A0(\OUT_NAND[29].OUT_MUX.A0 ),
    .A1(Di0[29]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[29].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[29].QUAD_NAND.__cell__  (.B(\Do1_pre[1][29] ),
    .C(\Do1_pre[2][29] ),
    .A(\Do1_pre[0][29] ),
    .Y(\OUT_NAND[29].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][29] ));
 sg13cmos5l_mux2_2 \OUT_NAND[2].OUT_MUX.__cell__  (.A0(\OUT_NAND[2].OUT_MUX.A0 ),
    .A1(Di0[2]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[2].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[2].QUAD_NAND.__cell__  (.B(\Do1_pre[1][2] ),
    .C(\Do1_pre[2][2] ),
    .A(\Do1_pre[0][2] ),
    .Y(\OUT_NAND[2].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][2] ));
 sg13cmos5l_mux2_2 \OUT_NAND[30].OUT_MUX.__cell__  (.A0(\OUT_NAND[30].OUT_MUX.A0 ),
    .A1(Di0[30]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[30].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[30].QUAD_NAND.__cell__  (.B(\Do1_pre[1][30] ),
    .C(\Do1_pre[2][30] ),
    .A(\Do1_pre[0][30] ),
    .Y(\OUT_NAND[30].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][30] ));
 sg13cmos5l_mux2_2 \OUT_NAND[31].OUT_MUX.__cell__  (.A0(\OUT_NAND[31].OUT_MUX.A0 ),
    .A1(Di0[31]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[31].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[31].QUAD_NAND.__cell__  (.B(\Do1_pre[1][31] ),
    .C(\Do1_pre[2][31] ),
    .A(\Do1_pre[0][31] ),
    .Y(\OUT_NAND[31].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][31] ));
 sg13cmos5l_mux2_2 \OUT_NAND[3].OUT_MUX.__cell__  (.A0(\OUT_NAND[3].OUT_MUX.A0 ),
    .A1(Di0[3]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[3].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[3].QUAD_NAND.__cell__  (.B(\Do1_pre[1][3] ),
    .C(\Do1_pre[2][3] ),
    .A(\Do1_pre[0][3] ),
    .Y(\OUT_NAND[3].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][3] ));
 sg13cmos5l_mux2_2 \OUT_NAND[4].OUT_MUX.__cell__  (.A0(\OUT_NAND[4].OUT_MUX.A0 ),
    .A1(Di0[4]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[4].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[4].QUAD_NAND.__cell__  (.B(\Do1_pre[1][4] ),
    .C(\Do1_pre[2][4] ),
    .A(\Do1_pre[0][4] ),
    .Y(\OUT_NAND[4].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][4] ));
 sg13cmos5l_mux2_2 \OUT_NAND[5].OUT_MUX.__cell__  (.A0(\OUT_NAND[5].OUT_MUX.A0 ),
    .A1(Di0[5]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[5].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[5].QUAD_NAND.__cell__  (.B(\Do1_pre[1][5] ),
    .C(\Do1_pre[2][5] ),
    .A(\Do1_pre[0][5] ),
    .Y(\OUT_NAND[5].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][5] ));
 sg13cmos5l_mux2_2 \OUT_NAND[6].OUT_MUX.__cell__  (.A0(\OUT_NAND[6].OUT_MUX.A0 ),
    .A1(Di0[6]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[6].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[6].QUAD_NAND.__cell__  (.B(\Do1_pre[1][6] ),
    .C(\Do1_pre[2][6] ),
    .A(\Do1_pre[0][6] ),
    .Y(\OUT_NAND[6].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][6] ));
 sg13cmos5l_mux2_2 \OUT_NAND[7].OUT_MUX.__cell__  (.A0(\OUT_NAND[7].OUT_MUX.A0 ),
    .A1(Di0[7]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[7].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[7].QUAD_NAND.__cell__  (.B(\Do1_pre[1][7] ),
    .C(\Do1_pre[2][7] ),
    .A(\Do1_pre[0][7] ),
    .Y(\OUT_NAND[7].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][7] ));
 sg13cmos5l_mux2_2 \OUT_NAND[8].OUT_MUX.__cell__  (.A0(\OUT_NAND[8].OUT_MUX.A0 ),
    .A1(Di0[8]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[8].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[8].QUAD_NAND.__cell__  (.B(\Do1_pre[1][8] ),
    .C(\Do1_pre[2][8] ),
    .A(\Do1_pre[0][8] ),
    .Y(\OUT_NAND[8].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][8] ));
 sg13cmos5l_mux2_2 \OUT_NAND[9].OUT_MUX.__cell__  (.A0(\OUT_NAND[9].OUT_MUX.A0 ),
    .A1(Di0[9]),
    .S(\BYPBUF.X ),
    .X(\OUT_NAND[9].OUT_MUX.X ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand4_1 \OUT_NAND[9].QUAD_NAND.__cell__  (.B(\Do1_pre[1][9] ),
    .C(\Do1_pre[2][9] ),
    .A(\Do1_pre[0][9] ),
    .Y(\OUT_NAND[9].OUT_MUX.A0 ),
    .VDD(VPWR),
    .VSS(VGND),
    .D(\Do1_pre[3][9] ));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[0].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][0] ),
    .B1(\Di0_in[2][0] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[0].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][0] ),
    .B1(\Di0_in[4][0] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[0].QUAD_AND.__cell__  (.A(\Do1_pre0[0][0] ),
    .B(\Do1_pre1[0][0] ),
    .X(\Do1_pre[0][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[10].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][10] ),
    .B1(\Di0_in[2][10] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[10].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][10] ),
    .B1(\Di0_in[4][10] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[10].QUAD_AND.__cell__  (.A(\Do1_pre0[0][10] ),
    .B(\Do1_pre1[0][10] ),
    .X(\Do1_pre[0][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[11].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][11] ),
    .B1(\Di0_in[2][11] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[11].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][11] ),
    .B1(\Di0_in[4][11] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[11].QUAD_AND.__cell__  (.A(\Do1_pre0[0][11] ),
    .B(\Do1_pre1[0][11] ),
    .X(\Do1_pre[0][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[12].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][12] ),
    .B1(\Di0_in[2][12] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[12].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][12] ),
    .B1(\Di0_in[4][12] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[12].QUAD_AND.__cell__  (.A(\Do1_pre0[0][12] ),
    .B(\Do1_pre1[0][12] ),
    .X(\Do1_pre[0][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[13].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][13] ),
    .B1(\Di0_in[2][13] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[13].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][13] ),
    .B1(\Di0_in[4][13] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[13].QUAD_AND.__cell__  (.A(\Do1_pre0[0][13] ),
    .B(\Do1_pre1[0][13] ),
    .X(\Do1_pre[0][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[14].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][14] ),
    .B1(\Di0_in[2][14] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[14].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][14] ),
    .B1(\Di0_in[4][14] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[14].QUAD_AND.__cell__  (.A(\Do1_pre0[0][14] ),
    .B(\Do1_pre1[0][14] ),
    .X(\Do1_pre[0][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[15].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][15] ),
    .B1(\Di0_in[2][15] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[15].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][15] ),
    .B1(\Di0_in[4][15] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[15].QUAD_AND.__cell__  (.A(\Do1_pre0[0][15] ),
    .B(\Do1_pre1[0][15] ),
    .X(\Do1_pre[0][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[16].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][16] ),
    .B1(\Di0_in[2][16] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[16].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][16] ),
    .B1(\Di0_in[4][16] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[16].QUAD_AND.__cell__  (.A(\Do1_pre0[0][16] ),
    .B(\Do1_pre1[0][16] ),
    .X(\Do1_pre[0][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[17].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][17] ),
    .B1(\Di0_in[2][17] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[17].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][17] ),
    .B1(\Di0_in[4][17] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[17].QUAD_AND.__cell__  (.A(\Do1_pre0[0][17] ),
    .B(\Do1_pre1[0][17] ),
    .X(\Do1_pre[0][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[18].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][18] ),
    .B1(\Di0_in[2][18] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[18].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][18] ),
    .B1(\Di0_in[4][18] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[18].QUAD_AND.__cell__  (.A(\Do1_pre0[0][18] ),
    .B(\Do1_pre1[0][18] ),
    .X(\Do1_pre[0][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[19].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][19] ),
    .B1(\Di0_in[2][19] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[19].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][19] ),
    .B1(\Di0_in[4][19] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[19].QUAD_AND.__cell__  (.A(\Do1_pre0[0][19] ),
    .B(\Do1_pre1[0][19] ),
    .X(\Do1_pre[0][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[1].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][1] ),
    .B1(\Di0_in[2][1] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[1].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][1] ),
    .B1(\Di0_in[4][1] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[1].QUAD_AND.__cell__  (.A(\Do1_pre0[0][1] ),
    .B(\Do1_pre1[0][1] ),
    .X(\Do1_pre[0][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[20].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][20] ),
    .B1(\Di0_in[2][20] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[20].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][20] ),
    .B1(\Di0_in[4][20] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[20].QUAD_AND.__cell__  (.A(\Do1_pre0[0][20] ),
    .B(\Do1_pre1[0][20] ),
    .X(\Do1_pre[0][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[21].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][21] ),
    .B1(\Di0_in[2][21] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[21].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][21] ),
    .B1(\Di0_in[4][21] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[21].QUAD_AND.__cell__  (.A(\Do1_pre0[0][21] ),
    .B(\Do1_pre1[0][21] ),
    .X(\Do1_pre[0][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[22].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][22] ),
    .B1(\Di0_in[2][22] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[22].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][22] ),
    .B1(\Di0_in[4][22] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[22].QUAD_AND.__cell__  (.A(\Do1_pre0[0][22] ),
    .B(\Do1_pre1[0][22] ),
    .X(\Do1_pre[0][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[23].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][23] ),
    .B1(\Di0_in[2][23] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[23].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][23] ),
    .B1(\Di0_in[4][23] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[23].QUAD_AND.__cell__  (.A(\Do1_pre0[0][23] ),
    .B(\Do1_pre1[0][23] ),
    .X(\Do1_pre[0][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[24].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][24] ),
    .B1(\Di0_in[2][24] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[24].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][24] ),
    .B1(\Di0_in[4][24] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[24].QUAD_AND.__cell__  (.A(\Do1_pre0[0][24] ),
    .B(\Do1_pre1[0][24] ),
    .X(\Do1_pre[0][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[25].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][25] ),
    .B1(\Di0_in[2][25] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[25].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][25] ),
    .B1(\Di0_in[4][25] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[25].QUAD_AND.__cell__  (.A(\Do1_pre0[0][25] ),
    .B(\Do1_pre1[0][25] ),
    .X(\Do1_pre[0][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[26].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][26] ),
    .B1(\Di0_in[2][26] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[26].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][26] ),
    .B1(\Di0_in[4][26] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[26].QUAD_AND.__cell__  (.A(\Do1_pre0[0][26] ),
    .B(\Do1_pre1[0][26] ),
    .X(\Do1_pre[0][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[27].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][27] ),
    .B1(\Di0_in[2][27] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[27].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][27] ),
    .B1(\Di0_in[4][27] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[27].QUAD_AND.__cell__  (.A(\Do1_pre0[0][27] ),
    .B(\Do1_pre1[0][27] ),
    .X(\Do1_pre[0][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[28].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][28] ),
    .B1(\Di0_in[2][28] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[28].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][28] ),
    .B1(\Di0_in[4][28] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[28].QUAD_AND.__cell__  (.A(\Do1_pre0[0][28] ),
    .B(\Do1_pre1[0][28] ),
    .X(\Do1_pre[0][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[29].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][29] ),
    .B1(\Di0_in[2][29] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[29].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][29] ),
    .B1(\Di0_in[4][29] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[29].QUAD_AND.__cell__  (.A(\Do1_pre0[0][29] ),
    .B(\Do1_pre1[0][29] ),
    .X(\Do1_pre[0][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[2].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][2] ),
    .B1(\Di0_in[2][2] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[2].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][2] ),
    .B1(\Di0_in[4][2] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[2].QUAD_AND.__cell__  (.A(\Do1_pre0[0][2] ),
    .B(\Do1_pre1[0][2] ),
    .X(\Do1_pre[0][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[30].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][30] ),
    .B1(\Di0_in[2][30] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[30].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][30] ),
    .B1(\Di0_in[4][30] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[30].QUAD_AND.__cell__  (.A(\Do1_pre0[0][30] ),
    .B(\Do1_pre1[0][30] ),
    .X(\Do1_pre[0][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[31].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][31] ),
    .B1(\Di0_in[2][31] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[31].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][31] ),
    .B1(\Di0_in[4][31] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[31].QUAD_AND.__cell__  (.A(\Do1_pre0[0][31] ),
    .B(\Do1_pre1[0][31] ),
    .X(\Do1_pre[0][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[3].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][3] ),
    .B1(\Di0_in[2][3] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[3].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][3] ),
    .B1(\Di0_in[4][3] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[3].QUAD_AND.__cell__  (.A(\Do1_pre0[0][3] ),
    .B(\Do1_pre1[0][3] ),
    .X(\Do1_pre[0][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[4].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][4] ),
    .B1(\Di0_in[2][4] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[4].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][4] ),
    .B1(\Di0_in[4][4] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[4].QUAD_AND.__cell__  (.A(\Do1_pre0[0][4] ),
    .B(\Do1_pre1[0][4] ),
    .X(\Do1_pre[0][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[5].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][5] ),
    .B1(\Di0_in[2][5] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[5].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][5] ),
    .B1(\Di0_in[4][5] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[5].QUAD_AND.__cell__  (.A(\Do1_pre0[0][5] ),
    .B(\Do1_pre1[0][5] ),
    .X(\Do1_pre[0][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[6].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][6] ),
    .B1(\Di0_in[2][6] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[6].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][6] ),
    .B1(\Di0_in[4][6] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[6].QUAD_AND.__cell__  (.A(\Do1_pre0[0][6] ),
    .B(\Do1_pre1[0][6] ),
    .X(\Do1_pre[0][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[7].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][7] ),
    .B1(\Di0_in[2][7] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[7].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][7] ),
    .B1(\Di0_in[4][7] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[7].QUAD_AND.__cell__  (.A(\Do1_pre0[0][7] ),
    .B(\Do1_pre1[0][7] ),
    .X(\Do1_pre[0][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[8].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][8] ),
    .B1(\Di0_in[2][8] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[8].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][8] ),
    .B1(\Di0_in[4][8] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[8].QUAD_AND.__cell__  (.A(\Do1_pre0[0][8] ),
    .B(\Do1_pre1[0][8] ),
    .X(\Do1_pre[0][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[9].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[0][9] ),
    .B1(\Di0_in[2][9] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[1][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[0].QBIT[9].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[0][9] ),
    .B1(\Di0_in[4][9] ),
    .B2(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[3][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[0].QBIT[9].QUAD_AND.__cell__  (.A(\Do1_pre0[0][9] ),
    .B(\Do1_pre1[0][9] ),
    .X(\Do1_pre[0][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[0].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][0] ),
    .B1(\Di0_in[6][0] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[0].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][0] ),
    .B1(\Di0_in[8][0] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[0].QUAD_AND.__cell__  (.A(\Do1_pre0[1][0] ),
    .B(\Do1_pre1[1][0] ),
    .X(\Do1_pre[1][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[10].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][10] ),
    .B1(\Di0_in[6][10] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[10].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][10] ),
    .B1(\Di0_in[8][10] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[10].QUAD_AND.__cell__  (.A(\Do1_pre0[1][10] ),
    .B(\Do1_pre1[1][10] ),
    .X(\Do1_pre[1][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[11].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][11] ),
    .B1(\Di0_in[6][11] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[11].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][11] ),
    .B1(\Di0_in[8][11] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[11].QUAD_AND.__cell__  (.A(\Do1_pre0[1][11] ),
    .B(\Do1_pre1[1][11] ),
    .X(\Do1_pre[1][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[12].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][12] ),
    .B1(\Di0_in[6][12] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[12].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][12] ),
    .B1(\Di0_in[8][12] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[12].QUAD_AND.__cell__  (.A(\Do1_pre0[1][12] ),
    .B(\Do1_pre1[1][12] ),
    .X(\Do1_pre[1][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[13].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][13] ),
    .B1(\Di0_in[6][13] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[13].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][13] ),
    .B1(\Di0_in[8][13] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[13].QUAD_AND.__cell__  (.A(\Do1_pre0[1][13] ),
    .B(\Do1_pre1[1][13] ),
    .X(\Do1_pre[1][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[14].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][14] ),
    .B1(\Di0_in[6][14] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[14].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][14] ),
    .B1(\Di0_in[8][14] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[14].QUAD_AND.__cell__  (.A(\Do1_pre0[1][14] ),
    .B(\Do1_pre1[1][14] ),
    .X(\Do1_pre[1][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[15].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][15] ),
    .B1(\Di0_in[6][15] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[15].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][15] ),
    .B1(\Di0_in[8][15] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[15].QUAD_AND.__cell__  (.A(\Do1_pre0[1][15] ),
    .B(\Do1_pre1[1][15] ),
    .X(\Do1_pre[1][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[16].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][16] ),
    .B1(\Di0_in[6][16] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[16].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][16] ),
    .B1(\Di0_in[8][16] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[16].QUAD_AND.__cell__  (.A(\Do1_pre0[1][16] ),
    .B(\Do1_pre1[1][16] ),
    .X(\Do1_pre[1][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[17].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][17] ),
    .B1(\Di0_in[6][17] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[17].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][17] ),
    .B1(\Di0_in[8][17] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[17].QUAD_AND.__cell__  (.A(\Do1_pre0[1][17] ),
    .B(\Do1_pre1[1][17] ),
    .X(\Do1_pre[1][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[18].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][18] ),
    .B1(\Di0_in[6][18] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[18].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][18] ),
    .B1(\Di0_in[8][18] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[18].QUAD_AND.__cell__  (.A(\Do1_pre0[1][18] ),
    .B(\Do1_pre1[1][18] ),
    .X(\Do1_pre[1][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[19].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][19] ),
    .B1(\Di0_in[6][19] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[19].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][19] ),
    .B1(\Di0_in[8][19] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[19].QUAD_AND.__cell__  (.A(\Do1_pre0[1][19] ),
    .B(\Do1_pre1[1][19] ),
    .X(\Do1_pre[1][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[1].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][1] ),
    .B1(\Di0_in[6][1] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[1].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][1] ),
    .B1(\Di0_in[8][1] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[1].QUAD_AND.__cell__  (.A(\Do1_pre0[1][1] ),
    .B(\Do1_pre1[1][1] ),
    .X(\Do1_pre[1][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[20].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][20] ),
    .B1(\Di0_in[6][20] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[20].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][20] ),
    .B1(\Di0_in[8][20] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[20].QUAD_AND.__cell__  (.A(\Do1_pre0[1][20] ),
    .B(\Do1_pre1[1][20] ),
    .X(\Do1_pre[1][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[21].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][21] ),
    .B1(\Di0_in[6][21] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[21].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][21] ),
    .B1(\Di0_in[8][21] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[21].QUAD_AND.__cell__  (.A(\Do1_pre0[1][21] ),
    .B(\Do1_pre1[1][21] ),
    .X(\Do1_pre[1][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[22].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][22] ),
    .B1(\Di0_in[6][22] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[22].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][22] ),
    .B1(\Di0_in[8][22] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[22].QUAD_AND.__cell__  (.A(\Do1_pre0[1][22] ),
    .B(\Do1_pre1[1][22] ),
    .X(\Do1_pre[1][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[23].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][23] ),
    .B1(\Di0_in[6][23] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[23].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][23] ),
    .B1(\Di0_in[8][23] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[23].QUAD_AND.__cell__  (.A(\Do1_pre0[1][23] ),
    .B(\Do1_pre1[1][23] ),
    .X(\Do1_pre[1][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[24].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][24] ),
    .B1(\Di0_in[6][24] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[24].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][24] ),
    .B1(\Di0_in[8][24] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[24].QUAD_AND.__cell__  (.A(\Do1_pre0[1][24] ),
    .B(\Do1_pre1[1][24] ),
    .X(\Do1_pre[1][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[25].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][25] ),
    .B1(\Di0_in[6][25] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[25].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][25] ),
    .B1(\Di0_in[8][25] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[25].QUAD_AND.__cell__  (.A(\Do1_pre0[1][25] ),
    .B(\Do1_pre1[1][25] ),
    .X(\Do1_pre[1][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[26].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][26] ),
    .B1(\Di0_in[6][26] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[26].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][26] ),
    .B1(\Di0_in[8][26] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[26].QUAD_AND.__cell__  (.A(\Do1_pre0[1][26] ),
    .B(\Do1_pre1[1][26] ),
    .X(\Do1_pre[1][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[27].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][27] ),
    .B1(\Di0_in[6][27] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[27].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][27] ),
    .B1(\Di0_in[8][27] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[27].QUAD_AND.__cell__  (.A(\Do1_pre0[1][27] ),
    .B(\Do1_pre1[1][27] ),
    .X(\Do1_pre[1][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[28].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][28] ),
    .B1(\Di0_in[6][28] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[28].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][28] ),
    .B1(\Di0_in[8][28] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[28].QUAD_AND.__cell__  (.A(\Do1_pre0[1][28] ),
    .B(\Do1_pre1[1][28] ),
    .X(\Do1_pre[1][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[29].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][29] ),
    .B1(\Di0_in[6][29] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[29].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][29] ),
    .B1(\Di0_in[8][29] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[29].QUAD_AND.__cell__  (.A(\Do1_pre0[1][29] ),
    .B(\Do1_pre1[1][29] ),
    .X(\Do1_pre[1][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[2].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][2] ),
    .B1(\Di0_in[6][2] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[2].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][2] ),
    .B1(\Di0_in[8][2] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[2].QUAD_AND.__cell__  (.A(\Do1_pre0[1][2] ),
    .B(\Do1_pre1[1][2] ),
    .X(\Do1_pre[1][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[30].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][30] ),
    .B1(\Di0_in[6][30] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[30].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][30] ),
    .B1(\Di0_in[8][30] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[30].QUAD_AND.__cell__  (.A(\Do1_pre0[1][30] ),
    .B(\Do1_pre1[1][30] ),
    .X(\Do1_pre[1][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[31].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][31] ),
    .B1(\Di0_in[6][31] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[31].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][31] ),
    .B1(\Di0_in[8][31] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[31].QUAD_AND.__cell__  (.A(\Do1_pre0[1][31] ),
    .B(\Do1_pre1[1][31] ),
    .X(\Do1_pre[1][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[3].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][3] ),
    .B1(\Di0_in[6][3] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[3].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][3] ),
    .B1(\Di0_in[8][3] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[3].QUAD_AND.__cell__  (.A(\Do1_pre0[1][3] ),
    .B(\Do1_pre1[1][3] ),
    .X(\Do1_pre[1][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[4].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][4] ),
    .B1(\Di0_in[6][4] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[4].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][4] ),
    .B1(\Di0_in[8][4] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[4].QUAD_AND.__cell__  (.A(\Do1_pre0[1][4] ),
    .B(\Do1_pre1[1][4] ),
    .X(\Do1_pre[1][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[5].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][5] ),
    .B1(\Di0_in[6][5] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[5].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][5] ),
    .B1(\Di0_in[8][5] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[5].QUAD_AND.__cell__  (.A(\Do1_pre0[1][5] ),
    .B(\Do1_pre1[1][5] ),
    .X(\Do1_pre[1][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[6].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][6] ),
    .B1(\Di0_in[6][6] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[6].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][6] ),
    .B1(\Di0_in[8][6] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[6].QUAD_AND.__cell__  (.A(\Do1_pre0[1][6] ),
    .B(\Do1_pre1[1][6] ),
    .X(\Do1_pre[1][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[7].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][7] ),
    .B1(\Di0_in[6][7] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[7].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][7] ),
    .B1(\Di0_in[8][7] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[7].QUAD_AND.__cell__  (.A(\Do1_pre0[1][7] ),
    .B(\Do1_pre1[1][7] ),
    .X(\Do1_pre[1][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[8].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][8] ),
    .B1(\Di0_in[6][8] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[8].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][8] ),
    .B1(\Di0_in[8][8] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[8].QUAD_AND.__cell__  (.A(\Do1_pre0[1][8] ),
    .B(\Do1_pre1[1][8] ),
    .X(\Do1_pre[1][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[9].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[1][9] ),
    .B1(\Di0_in[6][9] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[5][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[1].QBIT[9].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[1][9] ),
    .B1(\Di0_in[8][9] ),
    .B2(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[7][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[1].QBIT[9].QUAD_AND.__cell__  (.A(\Do1_pre0[1][9] ),
    .B(\Do1_pre1[1][9] ),
    .X(\Do1_pre[1][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[0].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][0] ),
    .B1(\Di0_in[10][0] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[0].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][0] ),
    .B1(\Di0_in[12][0] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[0].QUAD_AND.__cell__  (.A(\Do1_pre0[2][0] ),
    .B(\Do1_pre1[2][0] ),
    .X(\Do1_pre[2][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[10].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][10] ),
    .B1(\Di0_in[10][10] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[10].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][10] ),
    .B1(\Di0_in[12][10] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[10].QUAD_AND.__cell__  (.A(\Do1_pre0[2][10] ),
    .B(\Do1_pre1[2][10] ),
    .X(\Do1_pre[2][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[11].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][11] ),
    .B1(\Di0_in[10][11] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[11].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][11] ),
    .B1(\Di0_in[12][11] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[11].QUAD_AND.__cell__  (.A(\Do1_pre0[2][11] ),
    .B(\Do1_pre1[2][11] ),
    .X(\Do1_pre[2][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[12].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][12] ),
    .B1(\Di0_in[10][12] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[12].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][12] ),
    .B1(\Di0_in[12][12] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[12].QUAD_AND.__cell__  (.A(\Do1_pre0[2][12] ),
    .B(\Do1_pre1[2][12] ),
    .X(\Do1_pre[2][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[13].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][13] ),
    .B1(\Di0_in[10][13] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[13].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][13] ),
    .B1(\Di0_in[12][13] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[13].QUAD_AND.__cell__  (.A(\Do1_pre0[2][13] ),
    .B(\Do1_pre1[2][13] ),
    .X(\Do1_pre[2][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[14].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][14] ),
    .B1(\Di0_in[10][14] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[14].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][14] ),
    .B1(\Di0_in[12][14] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[14].QUAD_AND.__cell__  (.A(\Do1_pre0[2][14] ),
    .B(\Do1_pre1[2][14] ),
    .X(\Do1_pre[2][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[15].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][15] ),
    .B1(\Di0_in[10][15] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[15].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][15] ),
    .B1(\Di0_in[12][15] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[15].QUAD_AND.__cell__  (.A(\Do1_pre0[2][15] ),
    .B(\Do1_pre1[2][15] ),
    .X(\Do1_pre[2][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[16].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][16] ),
    .B1(\Di0_in[10][16] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[16].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][16] ),
    .B1(\Di0_in[12][16] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[16].QUAD_AND.__cell__  (.A(\Do1_pre0[2][16] ),
    .B(\Do1_pre1[2][16] ),
    .X(\Do1_pre[2][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[17].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][17] ),
    .B1(\Di0_in[10][17] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[17].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][17] ),
    .B1(\Di0_in[12][17] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[17].QUAD_AND.__cell__  (.A(\Do1_pre0[2][17] ),
    .B(\Do1_pre1[2][17] ),
    .X(\Do1_pre[2][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[18].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][18] ),
    .B1(\Di0_in[10][18] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[18].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][18] ),
    .B1(\Di0_in[12][18] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[18].QUAD_AND.__cell__  (.A(\Do1_pre0[2][18] ),
    .B(\Do1_pre1[2][18] ),
    .X(\Do1_pre[2][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[19].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][19] ),
    .B1(\Di0_in[10][19] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[19].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][19] ),
    .B1(\Di0_in[12][19] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[19].QUAD_AND.__cell__  (.A(\Do1_pre0[2][19] ),
    .B(\Do1_pre1[2][19] ),
    .X(\Do1_pre[2][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[1].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][1] ),
    .B1(\Di0_in[10][1] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[1].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][1] ),
    .B1(\Di0_in[12][1] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[1].QUAD_AND.__cell__  (.A(\Do1_pre0[2][1] ),
    .B(\Do1_pre1[2][1] ),
    .X(\Do1_pre[2][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[20].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][20] ),
    .B1(\Di0_in[10][20] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[20].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][20] ),
    .B1(\Di0_in[12][20] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[20].QUAD_AND.__cell__  (.A(\Do1_pre0[2][20] ),
    .B(\Do1_pre1[2][20] ),
    .X(\Do1_pre[2][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[21].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][21] ),
    .B1(\Di0_in[10][21] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[21].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][21] ),
    .B1(\Di0_in[12][21] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[21].QUAD_AND.__cell__  (.A(\Do1_pre0[2][21] ),
    .B(\Do1_pre1[2][21] ),
    .X(\Do1_pre[2][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[22].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][22] ),
    .B1(\Di0_in[10][22] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[22].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][22] ),
    .B1(\Di0_in[12][22] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[22].QUAD_AND.__cell__  (.A(\Do1_pre0[2][22] ),
    .B(\Do1_pre1[2][22] ),
    .X(\Do1_pre[2][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[23].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][23] ),
    .B1(\Di0_in[10][23] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[23].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][23] ),
    .B1(\Di0_in[12][23] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[23].QUAD_AND.__cell__  (.A(\Do1_pre0[2][23] ),
    .B(\Do1_pre1[2][23] ),
    .X(\Do1_pre[2][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[24].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][24] ),
    .B1(\Di0_in[10][24] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[24].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][24] ),
    .B1(\Di0_in[12][24] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[24].QUAD_AND.__cell__  (.A(\Do1_pre0[2][24] ),
    .B(\Do1_pre1[2][24] ),
    .X(\Do1_pre[2][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[25].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][25] ),
    .B1(\Di0_in[10][25] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[25].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][25] ),
    .B1(\Di0_in[12][25] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[25].QUAD_AND.__cell__  (.A(\Do1_pre0[2][25] ),
    .B(\Do1_pre1[2][25] ),
    .X(\Do1_pre[2][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[26].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][26] ),
    .B1(\Di0_in[10][26] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[26].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][26] ),
    .B1(\Di0_in[12][26] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[26].QUAD_AND.__cell__  (.A(\Do1_pre0[2][26] ),
    .B(\Do1_pre1[2][26] ),
    .X(\Do1_pre[2][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[27].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][27] ),
    .B1(\Di0_in[10][27] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[27].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][27] ),
    .B1(\Di0_in[12][27] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[27].QUAD_AND.__cell__  (.A(\Do1_pre0[2][27] ),
    .B(\Do1_pre1[2][27] ),
    .X(\Do1_pre[2][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[28].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][28] ),
    .B1(\Di0_in[10][28] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[28].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][28] ),
    .B1(\Di0_in[12][28] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[28].QUAD_AND.__cell__  (.A(\Do1_pre0[2][28] ),
    .B(\Do1_pre1[2][28] ),
    .X(\Do1_pre[2][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[29].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][29] ),
    .B1(\Di0_in[10][29] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[29].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][29] ),
    .B1(\Di0_in[12][29] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[29].QUAD_AND.__cell__  (.A(\Do1_pre0[2][29] ),
    .B(\Do1_pre1[2][29] ),
    .X(\Do1_pre[2][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[2].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][2] ),
    .B1(\Di0_in[10][2] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[2].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][2] ),
    .B1(\Di0_in[12][2] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[2].QUAD_AND.__cell__  (.A(\Do1_pre0[2][2] ),
    .B(\Do1_pre1[2][2] ),
    .X(\Do1_pre[2][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[30].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][30] ),
    .B1(\Di0_in[10][30] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[30].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][30] ),
    .B1(\Di0_in[12][30] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[30].QUAD_AND.__cell__  (.A(\Do1_pre0[2][30] ),
    .B(\Do1_pre1[2][30] ),
    .X(\Do1_pre[2][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[31].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][31] ),
    .B1(\Di0_in[10][31] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[31].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][31] ),
    .B1(\Di0_in[12][31] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[31].QUAD_AND.__cell__  (.A(\Do1_pre0[2][31] ),
    .B(\Do1_pre1[2][31] ),
    .X(\Do1_pre[2][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[3].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][3] ),
    .B1(\Di0_in[10][3] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[3].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][3] ),
    .B1(\Di0_in[12][3] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[3].QUAD_AND.__cell__  (.A(\Do1_pre0[2][3] ),
    .B(\Do1_pre1[2][3] ),
    .X(\Do1_pre[2][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[4].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][4] ),
    .B1(\Di0_in[10][4] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[4].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][4] ),
    .B1(\Di0_in[12][4] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[4].QUAD_AND.__cell__  (.A(\Do1_pre0[2][4] ),
    .B(\Do1_pre1[2][4] ),
    .X(\Do1_pre[2][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[5].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][5] ),
    .B1(\Di0_in[10][5] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[5].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][5] ),
    .B1(\Di0_in[12][5] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[5].QUAD_AND.__cell__  (.A(\Do1_pre0[2][5] ),
    .B(\Do1_pre1[2][5] ),
    .X(\Do1_pre[2][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[6].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][6] ),
    .B1(\Di0_in[10][6] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[6].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][6] ),
    .B1(\Di0_in[12][6] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[6].QUAD_AND.__cell__  (.A(\Do1_pre0[2][6] ),
    .B(\Do1_pre1[2][6] ),
    .X(\Do1_pre[2][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[7].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][7] ),
    .B1(\Di0_in[10][7] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[7].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][7] ),
    .B1(\Di0_in[12][7] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[7].QUAD_AND.__cell__  (.A(\Do1_pre0[2][7] ),
    .B(\Do1_pre1[2][7] ),
    .X(\Do1_pre[2][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[8].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][8] ),
    .B1(\Di0_in[10][8] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[8].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][8] ),
    .B1(\Di0_in[12][8] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[8].QUAD_AND.__cell__  (.A(\Do1_pre0[2][8] ),
    .B(\Do1_pre1[2][8] ),
    .X(\Do1_pre[2][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[9].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[2][9] ),
    .B1(\Di0_in[10][9] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[9][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[2].QBIT[9].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[2][9] ),
    .B1(\Di0_in[12][9] ),
    .B2(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[11][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[2].QBIT[9].QUAD_AND.__cell__  (.A(\Do1_pre0[2][9] ),
    .B(\Do1_pre1[2][9] ),
    .X(\Do1_pre[2][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[0].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][0] ),
    .B1(\Di0_in[14][0] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[0].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][0] ),
    .B1(\Do0_pre[15][0] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[0].QUAD_AND.__cell__  (.A(\Do1_pre0[3][0] ),
    .B(\Do1_pre1[3][0] ),
    .X(\Do1_pre[3][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[10].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][10] ),
    .B1(\Di0_in[14][10] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[10].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][10] ),
    .B1(\Do0_pre[15][10] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[10].QUAD_AND.__cell__  (.A(\Do1_pre0[3][10] ),
    .B(\Do1_pre1[3][10] ),
    .X(\Do1_pre[3][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[11].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][11] ),
    .B1(\Di0_in[14][11] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[11].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][11] ),
    .B1(\Do0_pre[15][11] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[11].QUAD_AND.__cell__  (.A(\Do1_pre0[3][11] ),
    .B(\Do1_pre1[3][11] ),
    .X(\Do1_pre[3][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[12].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][12] ),
    .B1(\Di0_in[14][12] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[12].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][12] ),
    .B1(\Do0_pre[15][12] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[12].QUAD_AND.__cell__  (.A(\Do1_pre0[3][12] ),
    .B(\Do1_pre1[3][12] ),
    .X(\Do1_pre[3][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[13].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][13] ),
    .B1(\Di0_in[14][13] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[13].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][13] ),
    .B1(\Do0_pre[15][13] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[13].QUAD_AND.__cell__  (.A(\Do1_pre0[3][13] ),
    .B(\Do1_pre1[3][13] ),
    .X(\Do1_pre[3][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[14].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][14] ),
    .B1(\Di0_in[14][14] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[14].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][14] ),
    .B1(\Do0_pre[15][14] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[14].QUAD_AND.__cell__  (.A(\Do1_pre0[3][14] ),
    .B(\Do1_pre1[3][14] ),
    .X(\Do1_pre[3][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[15].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][15] ),
    .B1(\Di0_in[14][15] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[15].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][15] ),
    .B1(\Do0_pre[15][15] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[15].QUAD_AND.__cell__  (.A(\Do1_pre0[3][15] ),
    .B(\Do1_pre1[3][15] ),
    .X(\Do1_pre[3][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[16].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][16] ),
    .B1(\Di0_in[14][16] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[16].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][16] ),
    .B1(\Do0_pre[15][16] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[16].QUAD_AND.__cell__  (.A(\Do1_pre0[3][16] ),
    .B(\Do1_pre1[3][16] ),
    .X(\Do1_pre[3][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[17].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][17] ),
    .B1(\Di0_in[14][17] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[17].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][17] ),
    .B1(\Do0_pre[15][17] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[17].QUAD_AND.__cell__  (.A(\Do1_pre0[3][17] ),
    .B(\Do1_pre1[3][17] ),
    .X(\Do1_pre[3][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[18].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][18] ),
    .B1(\Di0_in[14][18] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[18].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][18] ),
    .B1(\Do0_pre[15][18] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[18].QUAD_AND.__cell__  (.A(\Do1_pre0[3][18] ),
    .B(\Do1_pre1[3][18] ),
    .X(\Do1_pre[3][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[19].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][19] ),
    .B1(\Di0_in[14][19] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[19].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][19] ),
    .B1(\Do0_pre[15][19] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[19].QUAD_AND.__cell__  (.A(\Do1_pre0[3][19] ),
    .B(\Do1_pre1[3][19] ),
    .X(\Do1_pre[3][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[1].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][1] ),
    .B1(\Di0_in[14][1] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[1].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][1] ),
    .B1(\Do0_pre[15][1] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[1].QUAD_AND.__cell__  (.A(\Do1_pre0[3][1] ),
    .B(\Do1_pre1[3][1] ),
    .X(\Do1_pre[3][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[20].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][20] ),
    .B1(\Di0_in[14][20] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[20].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][20] ),
    .B1(\Do0_pre[15][20] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[20].QUAD_AND.__cell__  (.A(\Do1_pre0[3][20] ),
    .B(\Do1_pre1[3][20] ),
    .X(\Do1_pre[3][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[21].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][21] ),
    .B1(\Di0_in[14][21] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[21].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][21] ),
    .B1(\Do0_pre[15][21] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[21].QUAD_AND.__cell__  (.A(\Do1_pre0[3][21] ),
    .B(\Do1_pre1[3][21] ),
    .X(\Do1_pre[3][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[22].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][22] ),
    .B1(\Di0_in[14][22] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[22].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][22] ),
    .B1(\Do0_pre[15][22] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[22].QUAD_AND.__cell__  (.A(\Do1_pre0[3][22] ),
    .B(\Do1_pre1[3][22] ),
    .X(\Do1_pre[3][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[23].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][23] ),
    .B1(\Di0_in[14][23] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[23].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][23] ),
    .B1(\Do0_pre[15][23] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[23].QUAD_AND.__cell__  (.A(\Do1_pre0[3][23] ),
    .B(\Do1_pre1[3][23] ),
    .X(\Do1_pre[3][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[24].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][24] ),
    .B1(\Di0_in[14][24] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[24].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][24] ),
    .B1(\Do0_pre[15][24] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[24].QUAD_AND.__cell__  (.A(\Do1_pre0[3][24] ),
    .B(\Do1_pre1[3][24] ),
    .X(\Do1_pre[3][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[25].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][25] ),
    .B1(\Di0_in[14][25] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[25].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][25] ),
    .B1(\Do0_pre[15][25] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[25].QUAD_AND.__cell__  (.A(\Do1_pre0[3][25] ),
    .B(\Do1_pre1[3][25] ),
    .X(\Do1_pre[3][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[26].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][26] ),
    .B1(\Di0_in[14][26] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[26].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][26] ),
    .B1(\Do0_pre[15][26] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[26].QUAD_AND.__cell__  (.A(\Do1_pre0[3][26] ),
    .B(\Do1_pre1[3][26] ),
    .X(\Do1_pre[3][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[27].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][27] ),
    .B1(\Di0_in[14][27] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[27].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][27] ),
    .B1(\Do0_pre[15][27] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[27].QUAD_AND.__cell__  (.A(\Do1_pre0[3][27] ),
    .B(\Do1_pre1[3][27] ),
    .X(\Do1_pre[3][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[28].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][28] ),
    .B1(\Di0_in[14][28] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[28].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][28] ),
    .B1(\Do0_pre[15][28] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[28].QUAD_AND.__cell__  (.A(\Do1_pre0[3][28] ),
    .B(\Do1_pre1[3][28] ),
    .X(\Do1_pre[3][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[29].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][29] ),
    .B1(\Di0_in[14][29] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[29].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][29] ),
    .B1(\Do0_pre[15][29] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[29].QUAD_AND.__cell__  (.A(\Do1_pre0[3][29] ),
    .B(\Do1_pre1[3][29] ),
    .X(\Do1_pre[3][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[2].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][2] ),
    .B1(\Di0_in[14][2] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[2].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][2] ),
    .B1(\Do0_pre[15][2] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[2].QUAD_AND.__cell__  (.A(\Do1_pre0[3][2] ),
    .B(\Do1_pre1[3][2] ),
    .X(\Do1_pre[3][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[30].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][30] ),
    .B1(\Di0_in[14][30] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[30].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][30] ),
    .B1(\Do0_pre[15][30] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[30].QUAD_AND.__cell__  (.A(\Do1_pre0[3][30] ),
    .B(\Do1_pre1[3][30] ),
    .X(\Do1_pre[3][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[31].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][31] ),
    .B1(\Di0_in[14][31] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[31].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][31] ),
    .B1(\Do0_pre[15][31] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[31].QUAD_AND.__cell__  (.A(\Do1_pre0[3][31] ),
    .B(\Do1_pre1[3][31] ),
    .X(\Do1_pre[3][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[3].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][3] ),
    .B1(\Di0_in[14][3] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[3].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][3] ),
    .B1(\Do0_pre[15][3] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[3].QUAD_AND.__cell__  (.A(\Do1_pre0[3][3] ),
    .B(\Do1_pre1[3][3] ),
    .X(\Do1_pre[3][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[4].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][4] ),
    .B1(\Di0_in[14][4] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[4].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][4] ),
    .B1(\Do0_pre[15][4] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[4].QUAD_AND.__cell__  (.A(\Do1_pre0[3][4] ),
    .B(\Do1_pre1[3][4] ),
    .X(\Do1_pre[3][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[5].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][5] ),
    .B1(\Di0_in[14][5] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[5].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][5] ),
    .B1(\Do0_pre[15][5] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[5].QUAD_AND.__cell__  (.A(\Do1_pre0[3][5] ),
    .B(\Do1_pre1[3][5] ),
    .X(\Do1_pre[3][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[6].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][6] ),
    .B1(\Di0_in[14][6] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[6].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][6] ),
    .B1(\Do0_pre[15][6] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[6].QUAD_AND.__cell__  (.A(\Do1_pre0[3][6] ),
    .B(\Do1_pre1[3][6] ),
    .X(\Do1_pre[3][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[7].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][7] ),
    .B1(\Di0_in[14][7] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[7].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][7] ),
    .B1(\Do0_pre[15][7] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[7].QUAD_AND.__cell__  (.A(\Do1_pre0[3][7] ),
    .B(\Do1_pre1[3][7] ),
    .X(\Do1_pre[3][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[8].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][8] ),
    .B1(\Di0_in[14][8] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[8].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][8] ),
    .B1(\Do0_pre[15][8] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[8].QUAD_AND.__cell__  (.A(\Do1_pre0[3][8] ),
    .B(\Do1_pre1[3][8] ),
    .X(\Do1_pre[3][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[9].QUAD_A22OI0.__cell__  (.Y(\Do1_pre0[3][9] ),
    .B1(\Di0_in[14][9] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A1(\Di0_in[13][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 \QUADS[3].QBIT[9].QUAD_A22OI1.__cell__  (.Y(\Do1_pre1[3][9] ),
    .B1(\Do0_pre[15][9] ),
    .B2(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A2(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A1(\Di0_in[15][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_and2_1 \QUADS[3].QBIT[9].QUAD_AND.__cell__  (.A(\Do1_pre0[3][9] ),
    .B(\Do1_pre1[3][9] ),
    .X(\Do1_pre[3][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[0].STORAGE  (.D(Di0[0]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[10].STORAGE  (.D(Di0[10]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[11].STORAGE  (.D(Di0[11]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[12].STORAGE  (.D(Di0[12]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[13].STORAGE  (.D(Di0[13]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[14].STORAGE  (.D(Di0[14]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[15].STORAGE  (.D(Di0[15]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[16].STORAGE  (.D(Di0[16]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[17].STORAGE  (.D(Di0[17]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[18].STORAGE  (.D(Di0[18]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[19].STORAGE  (.D(Di0[19]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[1].STORAGE  (.D(Di0[1]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[20].STORAGE  (.D(Di0[20]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[21].STORAGE  (.D(Di0[21]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[22].STORAGE  (.D(Di0[22]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[23].STORAGE  (.D(Di0[23]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[24].STORAGE  (.D(Di0[24]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[25].STORAGE  (.D(Di0[25]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[26].STORAGE  (.D(Di0[26]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[27].STORAGE  (.D(Di0[27]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[28].STORAGE  (.D(Di0[28]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[29].STORAGE  (.D(Di0[29]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[2].STORAGE  (.D(Di0[2]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[30].STORAGE  (.D(Di0[30]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[31].STORAGE  (.D(Di0[31]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[3].STORAGE  (.D(Di0[3]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[4].STORAGE  (.D(Di0[4]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[5].STORAGE  (.D(Di0[5]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[6].STORAGE  (.D(Di0[6]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[7].STORAGE  (.D(Di0[7]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[8].STORAGE  (.D(Di0[8]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[0].CWORD.CFG_BIT[9].STORAGE  (.D(Di0[9]),
    .GATE(\LE0[0] ),
    .Q(\Di0_in[1][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[0].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[0] ));
 sg13cmos5l_antennanp \SLICE[0].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ));
 sg13cmos5l_and2_2 \SLICE[0].ROW_AND.__cell__  (.A(WROW[0]),
    .B(WE0),
    .X(\LE0[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[0].SELBUF.__cell__  (.X(\QUADS[0].QBIT[0].QUAD_A22OI0.A2 ),
    .A(\DEC0.D0.SEL[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[10][0] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[10][10] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[10][11] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[10][12] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[10][13] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[10][14] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[10][15] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[10][16] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[10][17] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[10][18] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[10][19] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[10][1] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[10][20] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[10][21] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[10][22] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[10][23] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[10][24] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[10][25] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[10][26] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[10][27] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[10][28] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[10][29] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[10][2] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[10][30] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[10][31] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[10][3] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[10][4] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[10][5] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[10][6] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[10][7] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[10][8] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[10].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[10][9] ),
    .GATE(\LE0[10] ),
    .Q(\Di0_in[11][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[10].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[10] ));
 sg13cmos5l_antennanp \SLICE[10].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ));
 sg13cmos5l_and2_2 \SLICE[10].ROW_AND.__cell__  (.A(WROW[10]),
    .B(WE0),
    .X(\LE0[10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[10].SELBUF.__cell__  (.X(\QUADS[2].QBIT[0].QUAD_A22OI1.A2 ),
    .A(\DEC0.D1.SEL[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[11][0] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[11][10] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[11][11] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[11][12] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[11][13] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[11][14] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[11][15] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[11][16] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[11][17] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[11][18] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[11][19] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[11][1] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[11][20] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[11][21] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[11][22] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[11][23] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[11][24] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[11][25] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[11][26] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[11][27] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[11][28] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[11][29] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[11][2] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[11][30] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[11][31] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[11][3] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[11][4] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[11][5] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[11][6] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[11][7] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[11][8] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[11].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[11][9] ),
    .GATE(\LE0[11] ),
    .Q(\Di0_in[12][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[11].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[11] ));
 sg13cmos5l_antennanp \SLICE[11].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ));
 sg13cmos5l_and2_2 \SLICE[11].ROW_AND.__cell__  (.A(WROW[11]),
    .B(WE0),
    .X(\LE0[11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[11].SELBUF.__cell__  (.X(\QUADS[2].QBIT[0].QUAD_A22OI1.B2 ),
    .A(\DEC0.D1.SEL[3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[12][0] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[12][10] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[12][11] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[12][12] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[12][13] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[12][14] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[12][15] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[12][16] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[12][17] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[12][18] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[12][19] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[12][1] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[12][20] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[12][21] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[12][22] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[12][23] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[12][24] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[12][25] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[12][26] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[12][27] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[12][28] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[12][29] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[12][2] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[12][30] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[12][31] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[12][3] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[12][4] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[12][5] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[12][6] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[12][7] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[12][8] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[12].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[12][9] ),
    .GATE(\LE0[12] ),
    .Q(\Di0_in[13][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[12].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[12] ));
 sg13cmos5l_antennanp \SLICE[12].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ));
 sg13cmos5l_and2_2 \SLICE[12].ROW_AND.__cell__  (.A(WROW[12]),
    .B(WE0),
    .X(\LE0[12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[12].SELBUF.__cell__  (.X(\QUADS[3].QBIT[0].QUAD_A22OI0.A2 ),
    .A(\DEC0.D1.SEL[4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[13][0] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[13][10] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[13][11] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[13][12] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[13][13] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[13][14] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[13][15] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[13][16] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[13][17] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[13][18] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[13][19] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[13][1] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[13][20] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[13][21] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[13][22] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[13][23] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[13][24] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[13][25] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[13][26] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[13][27] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[13][28] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[13][29] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[13][2] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[13][30] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[13][31] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[13][3] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[13][4] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[13][5] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[13][6] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[13][7] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[13][8] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[13].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[13][9] ),
    .GATE(\LE0[13] ),
    .Q(\Di0_in[14][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[13].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[13] ));
 sg13cmos5l_antennanp \SLICE[13].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ));
 sg13cmos5l_and2_2 \SLICE[13].ROW_AND.__cell__  (.A(WROW[13]),
    .B(WE0),
    .X(\LE0[13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[13].SELBUF.__cell__  (.X(\QUADS[3].QBIT[0].QUAD_A22OI0.B2 ),
    .A(\DEC0.D1.SEL[5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[14][0] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[14][10] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[14][11] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[14][12] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[14][13] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[14][14] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[14][15] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[14][16] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[14][17] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[14][18] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[14][19] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[14][1] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[14][20] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[14][21] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[14][22] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[14][23] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[14][24] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[14][25] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[14][26] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[14][27] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[14][28] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[14][29] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[14][2] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[14][30] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[14][31] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[14][3] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[14][4] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[14][5] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[14][6] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[14][7] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[14][8] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[14].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[14][9] ),
    .GATE(\LE0[14] ),
    .Q(\Di0_in[15][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[14].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[14] ));
 sg13cmos5l_antennanp \SLICE[14].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ));
 sg13cmos5l_and2_2 \SLICE[14].ROW_AND.__cell__  (.A(WROW[14]),
    .B(WE0),
    .X(\LE0[14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[14].SELBUF.__cell__  (.X(\QUADS[3].QBIT[0].QUAD_A22OI1.A2 ),
    .A(\DEC0.D1.SEL[6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[15][0] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[15][10] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[15][11] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[15][12] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[15][13] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[15][14] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[15][15] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[15][16] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[15][17] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[15][18] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[15][19] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[15][1] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[15][20] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[15][21] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[15][22] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[15][23] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[15][24] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[15][25] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[15][26] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[15][27] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[15][28] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[15][29] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[15][2] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[15][30] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[15][31] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[15][3] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[15][4] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[15][5] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[15][6] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[15][7] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[15][8] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[15].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[15][9] ),
    .GATE(\LE0[15] ),
    .Q(\Do0_pre[15][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[15].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[15] ));
 sg13cmos5l_antennanp \SLICE[15].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ));
 sg13cmos5l_and2_2 \SLICE[15].ROW_AND.__cell__  (.A(WROW[15]),
    .B(WE0),
    .X(\LE0[15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[15].SELBUF.__cell__  (.X(\QUADS[3].QBIT[0].QUAD_A22OI1.B2 ),
    .A(\DEC0.D1.SEL[7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[1][0] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[1][10] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[1][11] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[1][12] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[1][13] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[1][14] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[1][15] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[1][16] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[1][17] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[1][18] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[1][19] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[1][1] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[1][20] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[1][21] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[1][22] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[1][23] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[1][24] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[1][25] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[1][26] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[1][27] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[1][28] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[1][29] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[1][2] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[1][30] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[1][31] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[1][3] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[1][4] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[1][5] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[1][6] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[1][7] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[1][8] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[1].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[1][9] ),
    .GATE(\LE0[1] ),
    .Q(\Di0_in[2][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[1].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[1] ));
 sg13cmos5l_antennanp \SLICE[1].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ));
 sg13cmos5l_and2_2 \SLICE[1].ROW_AND.__cell__  (.A(WROW[1]),
    .B(WE0),
    .X(\LE0[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[1].SELBUF.__cell__  (.X(\QUADS[0].QBIT[0].QUAD_A22OI0.B2 ),
    .A(\DEC0.D0.SEL[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[2][0] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[2][10] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[2][11] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[2][12] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[2][13] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[2][14] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[2][15] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[2][16] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[2][17] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[2][18] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[2][19] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[2][1] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[2][20] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[2][21] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[2][22] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[2][23] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[2][24] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[2][25] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[2][26] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[2][27] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[2][28] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[2][29] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[2][2] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[2][30] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[2][31] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[2][3] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[2][4] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[2][5] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[2][6] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[2][7] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[2][8] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[2].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[2][9] ),
    .GATE(\LE0[2] ),
    .Q(\Di0_in[3][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[2].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[2] ));
 sg13cmos5l_antennanp \SLICE[2].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ));
 sg13cmos5l_and2_2 \SLICE[2].ROW_AND.__cell__  (.A(WROW[2]),
    .B(WE0),
    .X(\LE0[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[2].SELBUF.__cell__  (.X(\QUADS[0].QBIT[0].QUAD_A22OI1.A2 ),
    .A(\DEC0.D0.SEL[2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[3][0] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[3][10] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[3][11] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[3][12] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[3][13] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[3][14] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[3][15] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[3][16] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[3][17] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[3][18] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[3][19] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[3][1] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[3][20] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[3][21] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[3][22] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[3][23] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[3][24] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[3][25] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[3][26] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[3][27] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[3][28] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[3][29] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[3][2] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[3][30] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[3][31] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[3][3] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[3][4] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[3][5] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[3][6] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[3][7] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[3][8] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[3].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[3][9] ),
    .GATE(\LE0[3] ),
    .Q(\Di0_in[4][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[3].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[3] ));
 sg13cmos5l_antennanp \SLICE[3].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ));
 sg13cmos5l_and2_2 \SLICE[3].ROW_AND.__cell__  (.A(WROW[3]),
    .B(WE0),
    .X(\LE0[3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[3].SELBUF.__cell__  (.X(\QUADS[0].QBIT[0].QUAD_A22OI1.B2 ),
    .A(\DEC0.D0.SEL[3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[4][0] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[4][10] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[4][11] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[4][12] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[4][13] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[4][14] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[4][15] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[4][16] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[4][17] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[4][18] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[4][19] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[4][1] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[4][20] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[4][21] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[4][22] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[4][23] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[4][24] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[4][25] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[4][26] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[4][27] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[4][28] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[4][29] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[4][2] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[4][30] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[4][31] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[4][3] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[4][4] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[4][5] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[4][6] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[4][7] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[4][8] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[4].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[4][9] ),
    .GATE(\LE0[4] ),
    .Q(\Di0_in[5][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[4].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[4] ));
 sg13cmos5l_antennanp \SLICE[4].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ));
 sg13cmos5l_and2_2 \SLICE[4].ROW_AND.__cell__  (.A(WROW[4]),
    .B(WE0),
    .X(\LE0[4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[4].SELBUF.__cell__  (.X(\QUADS[1].QBIT[0].QUAD_A22OI0.A2 ),
    .A(\DEC0.D0.SEL[4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[5][0] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[5][10] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[5][11] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[5][12] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[5][13] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[5][14] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[5][15] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[5][16] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[5][17] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[5][18] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[5][19] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[5][1] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[5][20] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[5][21] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[5][22] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[5][23] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[5][24] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[5][25] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[5][26] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[5][27] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[5][28] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[5][29] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[5][2] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[5][30] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[5][31] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[5][3] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[5][4] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[5][5] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[5][6] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[5][7] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[5][8] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[5].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[5][9] ),
    .GATE(\LE0[5] ),
    .Q(\Di0_in[6][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[5].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[5] ));
 sg13cmos5l_antennanp \SLICE[5].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ));
 sg13cmos5l_and2_2 \SLICE[5].ROW_AND.__cell__  (.A(WROW[5]),
    .B(WE0),
    .X(\LE0[5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[5].SELBUF.__cell__  (.X(\QUADS[1].QBIT[0].QUAD_A22OI0.B2 ),
    .A(\DEC0.D0.SEL[5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[6][0] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[6][10] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[6][11] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[6][12] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[6][13] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[6][14] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[6][15] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[6][16] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[6][17] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[6][18] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[6][19] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[6][1] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[6][20] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[6][21] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[6][22] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[6][23] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[6][24] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[6][25] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[6][26] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[6][27] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[6][28] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[6][29] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[6][2] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[6][30] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[6][31] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[6][3] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[6][4] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[6][5] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[6][6] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[6][7] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[6][8] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[6].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[6][9] ),
    .GATE(\LE0[6] ),
    .Q(\Di0_in[7][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[6].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[6] ));
 sg13cmos5l_antennanp \SLICE[6].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ));
 sg13cmos5l_and2_2 \SLICE[6].ROW_AND.__cell__  (.A(WROW[6]),
    .B(WE0),
    .X(\LE0[6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[6].SELBUF.__cell__  (.X(\QUADS[1].QBIT[0].QUAD_A22OI1.A2 ),
    .A(\DEC0.D0.SEL[6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[7][0] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[7][10] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[7][11] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[7][12] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[7][13] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[7][14] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[7][15] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[7][16] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[7][17] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[7][18] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[7][19] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[7][1] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[7][20] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[7][21] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[7][22] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[7][23] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[7][24] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[7][25] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[7][26] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[7][27] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[7][28] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[7][29] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[7][2] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[7][30] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[7][31] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[7][3] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[7][4] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[7][5] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[7][6] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[7][7] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[7][8] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[7].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[7][9] ),
    .GATE(\LE0[7] ),
    .Q(\Di0_in[8][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[7].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[7] ));
 sg13cmos5l_antennanp \SLICE[7].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ));
 sg13cmos5l_and2_2 \SLICE[7].ROW_AND.__cell__  (.A(WROW[7]),
    .B(WE0),
    .X(\LE0[7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[7].SELBUF.__cell__  (.X(\QUADS[1].QBIT[0].QUAD_A22OI1.B2 ),
    .A(\DEC0.D0.SEL[7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[8][0] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[8][10] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[8][11] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[8][12] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[8][13] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[8][14] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[8][15] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[8][16] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[8][17] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[8][18] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[8][19] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[8][1] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[8][20] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[8][21] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[8][22] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[8][23] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[8][24] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[8][25] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[8][26] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[8][27] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[8][28] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[8][29] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[8][2] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[8][30] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[8][31] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[8][3] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[8][4] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[8][5] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[8][6] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[8][7] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[8][8] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[8].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[8][9] ),
    .GATE(\LE0[8] ),
    .Q(\Di0_in[9][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[8].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[8] ));
 sg13cmos5l_antennanp \SLICE[8].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ));
 sg13cmos5l_and2_2 \SLICE[8].ROW_AND.__cell__  (.A(WROW[8]),
    .B(WE0),
    .X(\LE0[8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[8].SELBUF.__cell__  (.X(\QUADS[2].QBIT[0].QUAD_A22OI0.A2 ),
    .A(\DEC0.D1.SEL[0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[0].STORAGE  (.D(\Di0_in[9][0] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][0] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[10].STORAGE  (.D(\Di0_in[9][10] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][10] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[11].STORAGE  (.D(\Di0_in[9][11] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][11] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[12].STORAGE  (.D(\Di0_in[9][12] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][12] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[13].STORAGE  (.D(\Di0_in[9][13] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][13] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[14].STORAGE  (.D(\Di0_in[9][14] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][14] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[15].STORAGE  (.D(\Di0_in[9][15] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][15] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[16].STORAGE  (.D(\Di0_in[9][16] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][16] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[17].STORAGE  (.D(\Di0_in[9][17] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][17] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[18].STORAGE  (.D(\Di0_in[9][18] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][18] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[19].STORAGE  (.D(\Di0_in[9][19] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][19] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[1].STORAGE  (.D(\Di0_in[9][1] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[20].STORAGE  (.D(\Di0_in[9][20] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][20] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[21].STORAGE  (.D(\Di0_in[9][21] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][21] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[22].STORAGE  (.D(\Di0_in[9][22] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][22] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[23].STORAGE  (.D(\Di0_in[9][23] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][23] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[24].STORAGE  (.D(\Di0_in[9][24] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][24] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[25].STORAGE  (.D(\Di0_in[9][25] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][25] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[26].STORAGE  (.D(\Di0_in[9][26] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][26] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[27].STORAGE  (.D(\Di0_in[9][27] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][27] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[28].STORAGE  (.D(\Di0_in[9][28] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][28] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[29].STORAGE  (.D(\Di0_in[9][29] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][29] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[2].STORAGE  (.D(\Di0_in[9][2] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][2] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[30].STORAGE  (.D(\Di0_in[9][30] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][30] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[31].STORAGE  (.D(\Di0_in[9][31] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][31] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[3].STORAGE  (.D(\Di0_in[9][3] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][3] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[4].STORAGE  (.D(\Di0_in[9][4] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][4] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[5].STORAGE  (.D(\Di0_in[9][5] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][5] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[6].STORAGE  (.D(\Di0_in[9][6] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][6] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[7].STORAGE  (.D(\Di0_in[9][7] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][7] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[8].STORAGE  (.D(\Di0_in[9][8] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][8] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_dlhq_1 \SLICE[9].CWORD.CFG_BIT[9].STORAGE  (.D(\Di0_in[9][9] ),
    .GATE(\LE0[9] ),
    .Q(\Di0_in[10][9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_antennanp \SLICE[9].CWORD.DIODE_LE0  (.VDD(VPWR),
    .VSS(VGND),
    .A(\LE0[9] ));
 sg13cmos5l_antennanp \SLICE[9].DIODE_SEL1.__cell__  (.VDD(VPWR),
    .VSS(VGND),
    .A(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ));
 sg13cmos5l_and2_2 \SLICE[9].ROW_AND.__cell__  (.A(WROW[9]),
    .B(WE0),
    .X(\LE0[9] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_4 \SLICE[9].SELBUF.__cell__  (.X(\QUADS[2].QBIT[0].QUAD_A22OI0.B2 ),
    .A(\DEC0.D1.SEL[1] ),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_0_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_0_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_0_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_0_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_10_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_10_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_10_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_10_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_11_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_11_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_11_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_11_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_12_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_12_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_12_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_12_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_13_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_13_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_13_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_13_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_14_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_14_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_14_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_14_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_15_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_15_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_15_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_15_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_16_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_16_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_16_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_16_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_17_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_17_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_17_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_17_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_18_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_18_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_18_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_18_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_19_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_19_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_19_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_19_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_1_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_1_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_1_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_1_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_20_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_20_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_20_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_20_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_2_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_2_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_2_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_2_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_3_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_3_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_3_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_3_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_4_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_4_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_4_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_4_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_5_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_5_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_5_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_5_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_6_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_6_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_6_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_6_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_7_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_7_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_7_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_7_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_8_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_8_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_8_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_8_3 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_9_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_9_1 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_9_2 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 chan_9_3 (.VDD(VPWR),
    .VSS(VGND));
 assign Do0[0] = \OUT_NAND[0].OUT_MUX.X ;
 assign Do0[10] = \OUT_NAND[10].OUT_MUX.X ;
 assign Do0[11] = \OUT_NAND[11].OUT_MUX.X ;
 assign Do0[12] = \OUT_NAND[12].OUT_MUX.X ;
 assign Do0[13] = \OUT_NAND[13].OUT_MUX.X ;
 assign Do0[14] = \OUT_NAND[14].OUT_MUX.X ;
 assign Do0[15] = \OUT_NAND[15].OUT_MUX.X ;
 assign Do0[16] = \OUT_NAND[16].OUT_MUX.X ;
 assign Do0[17] = \OUT_NAND[17].OUT_MUX.X ;
 assign Do0[18] = \OUT_NAND[18].OUT_MUX.X ;
 assign Do0[19] = \OUT_NAND[19].OUT_MUX.X ;
 assign Do0[1] = \OUT_NAND[1].OUT_MUX.X ;
 assign Do0[20] = \OUT_NAND[20].OUT_MUX.X ;
 assign Do0[21] = \OUT_NAND[21].OUT_MUX.X ;
 assign Do0[22] = \OUT_NAND[22].OUT_MUX.X ;
 assign Do0[23] = \OUT_NAND[23].OUT_MUX.X ;
 assign Do0[24] = \OUT_NAND[24].OUT_MUX.X ;
 assign Do0[25] = \OUT_NAND[25].OUT_MUX.X ;
 assign Do0[26] = \OUT_NAND[26].OUT_MUX.X ;
 assign Do0[27] = \OUT_NAND[27].OUT_MUX.X ;
 assign Do0[28] = \OUT_NAND[28].OUT_MUX.X ;
 assign Do0[29] = \OUT_NAND[29].OUT_MUX.X ;
 assign Do0[2] = \OUT_NAND[2].OUT_MUX.X ;
 assign Do0[30] = \OUT_NAND[30].OUT_MUX.X ;
 assign Do0[31] = \OUT_NAND[31].OUT_MUX.X ;
 assign Do0[3] = \OUT_NAND[3].OUT_MUX.X ;
 assign Do0[4] = \OUT_NAND[4].OUT_MUX.X ;
 assign Do0[5] = \OUT_NAND[5].OUT_MUX.X ;
 assign Do0[6] = \OUT_NAND[6].OUT_MUX.X ;
 assign Do0[7] = \OUT_NAND[7].OUT_MUX.X ;
 assign Do0[8] = \OUT_NAND[8].OUT_MUX.X ;
 assign Do0[9] = \OUT_NAND[9].OUT_MUX.X ;
endmodule
