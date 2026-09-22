module CFGMEM_IHP16 (BYP,
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
 sg13cmos5l_fill_2 FILLER_0_340 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_0_342 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_0_683 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_23 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_25 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_10_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_344 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_10_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_684 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_686 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_10_707 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_10_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_10_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_11_699 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_11_706 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_11_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_11_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_12_699 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_12_706 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_12_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_12_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_13_699 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_13_706 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_13_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_13_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_14_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_14_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_14_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_14_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_344 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_684 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_691 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_698 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_15_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_15_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_15_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_16_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_16_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_16_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_16_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_17_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_17_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_17_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_17_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_18_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_18_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_18_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_18_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_19_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_19_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_19_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_19_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_1_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_1_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_1_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_344 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_684 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_691 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_698 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_20_705 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_20_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_20_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_707 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_3_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_3_707 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_3_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_4_704 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_4_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_4_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_5_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_344 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_5_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_5_697 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_5_704 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_711 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_5_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_5_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_6_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_6_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_6_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_6_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_7_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_7_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_7_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_7_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_8_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_8_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_8_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_8_85 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_103 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_105 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_123 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_125 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_150 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_152 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_170 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_172 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_190 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_192 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_210 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_212 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_230 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_232 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_250 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_252 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_270 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_272 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_297 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_299 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_317 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_319 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_337 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_339 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_363 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_365 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_383 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_385 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_403 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_405 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_43 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_430 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_432 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_45 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_450 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_452 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_470 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_472 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_490 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_492 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_510 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_512 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_530 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_532 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_550 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_552 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_577 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_579 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_597 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_599 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_617 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_619 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_63 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_637 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_639 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_65 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_657 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_659 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_677 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_679 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_9_696 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_9_703 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_710 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_9_83 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_9_85 (.VDD(VPWR),
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
